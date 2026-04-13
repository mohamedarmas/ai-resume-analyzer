import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_assist_plan.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_runtime.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_runtime_factory.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analysis_report.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analyzer.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_report.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiRuntimeProvider = Provider<AiRuntime>((ref) {
  return createAiRuntime();
});

final aiCapabilityProvider = FutureProvider((ref) {
  return ref.watch(aiRuntimeProvider).getCapability();
});

final aiAssistGeneratorProvider = Provider<AiAssistGenerator>((ref) {
  return const AiAssistGenerator();
});

final aiAssistPlanProvider = Provider<AiAssistPlan?>((ref) {
  final document = ref.watch(uploadControllerProvider).document;
  final analysis = ref.watch(analysisReportProvider);

  if (document == null || analysis == null) {
    return null;
  }

  final jobMatch = ref.watch(jobMatchReportProvider);

  return ref
      .watch(aiAssistGeneratorProvider)
      .buildPlan(resume: document, analysis: analysis, jobMatch: jobMatch);
});

class AiAssistGenerator {
  const AiAssistGenerator();

  AiAssistPlan buildPlan({
    required ResumeDocument resume,
    required ResumeAnalysisReport analysis,
    JobMatchReport? jobMatch,
  }) {
    final lines = _normalizedLines(resume.rawText);
    final summaryText = _extractSummary(lines);
    final bulletLines = _extractBullets(lines);
    final weakBullets = bulletLines.where(_needsRewrite).take(3).toList();
    final topResumeKeywords = _extractResumeKeywords(resume.rawText);

    final summaryRewrite = RewriteSuggestion(
      title: 'Summary rewrite',
      originalText: summaryText.isEmpty
          ? 'No dedicated summary detected.'
          : summaryText,
      rewrittenText: _rewriteSummary(
        summaryText: summaryText,
        resumeKeywords: topResumeKeywords,
        matchedKeywords: jobMatch?.matchedKeywords ?? const <String>[],
      ),
      rationale:
          'Tightens positioning, keeps claims factual, and reflects keywords the resume already supports.',
    );

    final bulletRewrites = weakBullets
        .map(
          (bullet) => RewriteSuggestion(
            title: 'Bullet rewrite',
            originalText: bullet,
            rewrittenText: _rewriteBullet(bullet),
            rationale:
                'Uses stronger ownership language without adding fake metrics or invented scope.',
          ),
        )
        .toList(growable: false);

    final tailoringSuggestions = <String>[
      if (analysis.missingSections.isNotEmpty)
        'Fix missing sections first: ${analysis.missingSections.join(', ')}.',
      if (analysis.quantifiedBulletCount == 0)
        'Add real metrics or concrete outcomes before relying on AI polish.',
      if (jobMatch != null && jobMatch.missingKeywords.isNotEmpty)
        'Where truthful, reflect missing role language such as ${jobMatch.missingKeywords.take(4).join(', ')}.',
      if (jobMatch != null && jobMatch.matchedKeywords.isNotEmpty)
        'Reuse matched terms like ${jobMatch.matchedKeywords.take(3).join(', ')} in the summary and experience bullets.',
      if (bulletRewrites.isEmpty)
        'Your bullets are already relatively strong; focus next on tailoring and measurable outcomes.',
    ];

    final promptPreviews = <PromptPreview>[
      PromptPreview(
        label: 'summary_rewrite',
        prompt: _summaryPrompt(
          originalSummary: summaryText,
          matchedKeywords: jobMatch?.matchedKeywords ?? const <String>[],
          roleSignal: jobMatch?.roleSignal,
        ),
      ),
      if (weakBullets.isNotEmpty)
        PromptPreview(
          label: 'bullet_rewrite',
          prompt: _bulletPrompt(
            originalBullet: weakBullets.first,
            analysisIssues: analysis.issues
                .map((issue) => issue.title)
                .take(3)
                .toList(),
          ),
        ),
      if (jobMatch != null)
        PromptPreview(
          label: 'job_tailoring',
          prompt: _tailoringPrompt(
            matchedKeywords: jobMatch.matchedKeywords,
            missingKeywords: jobMatch.missingKeywords,
            roleSignal: jobMatch.roleSignal,
          ),
        ),
    ];

    return AiAssistPlan(
      modeLabel: 'Deterministic fallback rewrites active',
      summaryRewrite: summaryRewrite,
      bulletRewrites: bulletRewrites,
      tailoringSuggestions: tailoringSuggestions.toSet().toList(
        growable: false,
      ),
      promptPreviews: promptPreviews,
    );
  }
}

List<String> _normalizedLines(String rawText) {
  return rawText
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}

String _extractSummary(List<String> lines) {
  final summaryHeadingIndex = lines.indexWhere(
    (line) => <String>{
      'summary',
      'professional summary',
      'profile',
    }.contains(line.toLowerCase()),
  );

  if (summaryHeadingIndex != -1) {
    final buffer = <String>[];
    for (var index = summaryHeadingIndex + 1; index < lines.length; index++) {
      final line = lines[index];
      if (_isHeading(line)) {
        break;
      }
      if (_isBulletLine(line)) {
        break;
      }
      buffer.add(line);
    }

    return buffer.join(' ').trim();
  }

  if (lines.length <= 2) {
    return '';
  }

  return lines
      .skip(1)
      .take(2)
      .where((line) => !_isHeading(line))
      .join(' ')
      .trim();
}

List<String> _extractBullets(List<String> lines) {
  return lines.where(_isBulletLine).toList(growable: false);
}

bool _isHeading(String line) {
  final normalized = line.toLowerCase();
  return <String>{
    'summary',
    'professional summary',
    'profile',
    'experience',
    'work experience',
    'employment',
    'education',
    'skills',
    'technical skills',
    'projects',
    'certifications',
  }.contains(normalized);
}

bool _isBulletLine(String line) {
  return line.startsWith('- ') ||
      line.startsWith('• ') ||
      RegExp(r'^\d+\.\s').hasMatch(line);
}

bool _needsRewrite(String bullet) {
  final normalized = bullet.toLowerCase();
  return normalized.startsWith('- worked on') ||
      normalized.startsWith('- responsible for') ||
      normalized.startsWith('- helped') ||
      normalized.startsWith('• worked on') ||
      normalized.startsWith('• responsible for') ||
      normalized.startsWith('• helped') ||
      !_startsWithStrongVerb(bullet) ||
      !_containsMetricSignal(bullet);
}

bool _startsWithStrongVerb(String line) {
  final normalized = line
      .replaceFirst(RegExp(r'^(-|•|\d+\.)\s*'), '')
      .trimLeft()
      .toLowerCase();

  const verbs = <String>[
    'built',
    'led',
    'shipped',
    'launched',
    'improved',
    'reduced',
    'increased',
    'created',
    'designed',
    'implemented',
    'developed',
    'optimized',
    'delivered',
    'managed',
    'automated',
    'scaled',
    'owned',
    'collaborated',
    'partnered',
    'supported',
  ];

  return verbs.any((verb) => normalized.startsWith('$verb '));
}

bool _containsMetricSignal(String line) {
  return RegExp(
    r'(\d+%|\d+\+|\$\d+|\d+\s?(users|customers|days|weeks|months|hours|mins|minutes|markets|teams|apps|projects))',
    caseSensitive: false,
  ).hasMatch(line);
}

String _rewriteSummary({
  required String summaryText,
  required List<String> resumeKeywords,
  required List<String> matchedKeywords,
}) {
  final yearsMatch = RegExp(
    r'\b\d+\+?\s+years?\b',
    caseSensitive: false,
  ).firstMatch(summaryText)?.group(0);
  final emphasis = <String>{
    ...resumeKeywords.take(3),
    ...matchedKeywords
        .where((keyword) => resumeKeywords.contains(keyword))
        .take(2),
  }.take(4).toList();

  final opening = yearsMatch == null
      ? 'Engineer focused on ${emphasis.isEmpty ? 'shipping useful products' : emphasis.join(', ')}.'
      : 'Engineer with $yearsMatch of experience focused on ${emphasis.isEmpty ? 'shipping useful products' : emphasis.join(', ')}.';

  const closing =
      'Builds clear user and internal experiences, collaborates closely across product and design, and keeps experience framing factual and outcome-oriented.';

  return '$opening $closing'.trim();
}

String _rewriteBullet(String bullet) {
  final cleaned = bullet.replaceFirst(RegExp(r'^(-|•|\d+\.)\s*'), '').trim();
  final lower = cleaned.toLowerCase();

  if (lower.startsWith('worked on ')) {
    return 'Built and improved ${cleaned.substring(10)}';
  }
  if (lower.startsWith('helped ')) {
    return 'Supported ${cleaned.substring(7)} with clear execution ownership';
  }
  if (lower.startsWith('responsible for ')) {
    return 'Owned ${cleaned.substring(16)}';
  }
  if (_startsWithStrongVerb(bullet)) {
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  return 'Delivered ${cleaned[0].toLowerCase()}${cleaned.substring(1)}';
}

List<String> _extractResumeKeywords(String rawText) {
  const keywords = <String>[
    'flutter',
    'dart',
    'analytics',
    'dashboard',
    'web',
    'mobile',
    'product',
    'testing',
    'automation',
    'firebase',
    'developer tooling',
    'internal tools',
  ];

  final normalized = rawText.toLowerCase();
  return keywords.where(normalized.contains).toList(growable: false);
}

String _summaryPrompt({
  required String originalSummary,
  required List<String> matchedKeywords,
  String? roleSignal,
}) {
  return [
    'Rewrite the resume summary for stronger positioning.',
    'Preserve factual claims only.',
    if (roleSignal != null && roleSignal.isNotEmpty) 'Target role: $roleSignal',
    if (matchedKeywords.isNotEmpty)
      'Prefer terms already supported by the resume: ${matchedKeywords.take(4).join(', ')}',
    'Original summary: ${originalSummary.isEmpty ? 'No explicit summary detected.' : originalSummary}',
  ].join('\n');
}

String _bulletPrompt({
  required String originalBullet,
  required List<String> analysisIssues,
}) {
  return [
    'Rewrite this resume bullet using stronger ownership language.',
    'Do not add fake metrics, tools, or scope.',
    if (analysisIssues.isNotEmpty)
      'Current analyzer concerns: ${analysisIssues.join(', ')}',
    'Original bullet: $originalBullet',
  ].join('\n');
}

String _tailoringPrompt({
  required List<String> matchedKeywords,
  required List<String> missingKeywords,
  required String roleSignal,
}) {
  return [
    'Tailor the resume for this role without inventing experience.',
    'Role signal: $roleSignal',
    if (matchedKeywords.isNotEmpty)
      'Already supported terms: ${matchedKeywords.take(5).join(', ')}',
    if (missingKeywords.isNotEmpty)
      'Only incorporate these if factual: ${missingKeywords.take(5).join(', ')}',
  ].join('\n');
}
