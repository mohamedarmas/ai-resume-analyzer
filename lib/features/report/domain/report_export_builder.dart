import 'dart:convert';

import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_assist_generator.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_assist_plan.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analysis_report.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analyzer.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_report.dart';
import 'package:ai_resume_analyzer/features/report/domain/report_export_bundle.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportExportBuilderProvider = Provider<ReportExportBuilder>((ref) {
  return const ReportExportBuilder();
});

final reportExportBundleProvider = Provider<ReportExportBundle?>((ref) {
  final document = ref.watch(uploadControllerProvider).document;
  final analysis = ref.watch(analysisReportProvider);

  if (document == null || analysis == null) {
    return null;
  }

  final jobMatch = ref.watch(jobMatchReportProvider);
  final aiPlan = ref.watch(aiAssistPlanProvider);

  return ref
      .watch(reportExportBuilderProvider)
      .build(
        resume: document,
        analysis: analysis,
        jobMatch: jobMatch,
        aiPlan: aiPlan,
      );
});

class ReportExportBuilder {
  const ReportExportBuilder();

  ReportExportBundle build({
    required ResumeDocument resume,
    required ResumeAnalysisReport analysis,
    JobMatchReport? jobMatch,
    AiAssistPlan? aiPlan,
  }) {
    final generatedAt = DateTime.now();
    final fileStem = _sanitizeFileStem(resume.fileName);
    final summaryText = _buildSummaryText(
      resume: resume,
      analysis: analysis,
      jobMatch: jobMatch,
      aiPlan: aiPlan,
      generatedAt: generatedAt,
    );
    final jsonContent = const JsonEncoder.withIndent('  ').convert(
      _buildJsonPayload(
        resume: resume,
        analysis: analysis,
        jobMatch: jobMatch,
        aiPlan: aiPlan,
        generatedAt: generatedAt,
      ),
    );
    final htmlContent = _buildHtmlReport(
      resume: resume,
      analysis: analysis,
      jobMatch: jobMatch,
      aiPlan: aiPlan,
      generatedAt: generatedAt,
    );

    return ReportExportBundle(
      fileStem: fileStem,
      summaryText: summaryText,
      jsonContent: jsonContent,
      htmlContent: htmlContent,
    );
  }
}

String _buildSummaryText({
  required ResumeDocument resume,
  required ResumeAnalysisReport analysis,
  required DateTime generatedAt,
  JobMatchReport? jobMatch,
  AiAssistPlan? aiPlan,
}) {
  final categoryLines = analysis.categoryScores
      .map((category) => '- ${category.label}: ${category.score}/100')
      .join('\n');
  final strengthLines = analysis.strengths
      .map((strength) => '- $strength')
      .join('\n');
  final issueLines = analysis.issues
      .map((issue) => '- ${issue.title}: ${issue.recommendation}')
      .join('\n');
  final jobMatchLines = jobMatch == null
      ? 'No target job description was included.'
      : [
          'Match score: ${jobMatch.matchScore}',
          'Matched keywords: ${jobMatch.matchedKeywords.join(', ')}',
          'Missing keywords: ${jobMatch.missingKeywords.join(', ')}',
        ].join('\n');
  final aiLines = aiPlan == null
      ? 'No AI assist plan was generated.'
      : [
          'Summary rewrite: ${aiPlan.summaryRewrite.rewrittenText}',
          if (aiPlan.bulletRewrites.isNotEmpty)
            'Example bullet rewrite: ${aiPlan.bulletRewrites.first.rewrittenText}',
          'Tailoring suggestions: ${aiPlan.tailoringSuggestions.join(' | ')}',
        ].join('\n');

  return '''
AI Resume Analyzer Report
Generated: ${generatedAt.toIso8601String()}
Resume: ${resume.fileName}

Overall ATS score: ${analysis.overallScore}
${analysis.summary}

Category scores
$categoryLines

Strengths
$strengthLines

Priority fixes
$issueLines

Job match
$jobMatchLines

AI assist
$aiLines
'''
      .trim();
}

Map<String, Object?> _buildJsonPayload({
  required ResumeDocument resume,
  required ResumeAnalysisReport analysis,
  required DateTime generatedAt,
  JobMatchReport? jobMatch,
  AiAssistPlan? aiPlan,
}) {
  return <String, Object?>{
    'generatedAt': generatedAt.toIso8601String(),
    'resume': resume.toMap(),
    'analysis': <String, Object?>{
      'overallScore': analysis.overallScore,
      'summary': analysis.summary,
      'categoryScores': analysis.categoryScores
          .map(
            (category) => <String, Object?>{
              'label': category.label,
              'score': category.score,
              'summary': category.summary,
            },
          )
          .toList(),
      'strengths': analysis.strengths,
      'issues': analysis.issues
          .map(
            (issue) => <String, Object?>{
              'title': issue.title,
              'description': issue.description,
              'recommendation': issue.recommendation,
              'severity': issue.severity.name,
            },
          )
          .toList(),
      'detectedSections': analysis.detectedSections,
      'missingSections': analysis.missingSections,
      'bulletCount': analysis.bulletCount,
      'actionVerbBulletCount': analysis.actionVerbBulletCount,
      'quantifiedBulletCount': analysis.quantifiedBulletCount,
      'contactSignalCount': analysis.contactSignalCount,
      'longLineCount': analysis.longLineCount,
    },
    'jobMatch': jobMatch == null
        ? null
        : <String, Object?>{
            'matchScore': jobMatch.matchScore,
            'targetKeywords': jobMatch.targetKeywords,
            'matchedKeywords': jobMatch.matchedKeywords,
            'missingKeywords': jobMatch.missingKeywords,
            'tailoringSuggestions': jobMatch.tailoringSuggestions,
            'roleSignal': jobMatch.roleSignal,
          },
    'aiAssist': aiPlan == null
        ? null
        : <String, Object?>{
            'modeLabel': aiPlan.modeLabel,
            'summaryRewrite': _rewriteToMap(aiPlan.summaryRewrite),
            'bulletRewrites': aiPlan.bulletRewrites
                .map(_rewriteToMap)
                .toList(growable: false),
            'tailoringSuggestions': aiPlan.tailoringSuggestions,
            'promptPreviews': aiPlan.promptPreviews
                .map(
                  (prompt) => <String, Object?>{
                    'label': prompt.label,
                    'prompt': prompt.prompt,
                  },
                )
                .toList(growable: false),
          },
  };
}

Map<String, Object?> _rewriteToMap(RewriteSuggestion rewrite) {
  return <String, Object?>{
    'title': rewrite.title,
    'originalText': rewrite.originalText,
    'rewrittenText': rewrite.rewrittenText,
    'rationale': rewrite.rationale,
  };
}

String _buildHtmlReport({
  required ResumeDocument resume,
  required ResumeAnalysisReport analysis,
  required DateTime generatedAt,
  JobMatchReport? jobMatch,
  AiAssistPlan? aiPlan,
}) {
  final categoryItems = analysis.categoryScores
      .map(
        (category) =>
            '<li><strong>${_escapeHtml(category.label)}:</strong> ${category.score}/100'
            '<br><span>${_escapeHtml(category.summary)}</span></li>',
      )
      .join();
  final strengths = analysis.strengths
      .map((strength) => '<li>${_escapeHtml(strength)}</li>')
      .join();
  final issues = analysis.issues
      .map(
        (issue) =>
            '<li><strong>${_escapeHtml(issue.title)}</strong> '
            '(${_escapeHtml(issue.severity.label)})<br>${_escapeHtml(issue.recommendation)}</li>',
      )
      .join();
  final jobMatchBlock = jobMatch == null
      ? '<p>No target job description was included.</p>'
      : '''
<p><strong>Match score:</strong> ${jobMatch.matchScore}</p>
<p><strong>Role signal:</strong> ${_escapeHtml(jobMatch.roleSignal)}</p>
<p><strong>Matched keywords:</strong> ${_escapeHtml(jobMatch.matchedKeywords.join(', '))}</p>
<p><strong>Missing keywords:</strong> ${_escapeHtml(jobMatch.missingKeywords.join(', '))}</p>
''';
  final aiBlock = aiPlan == null
      ? '<p>No AI assist plan was generated.</p>'
      : '''
<p><strong>Mode:</strong> ${_escapeHtml(aiPlan.modeLabel)}</p>
<h3>Summary rewrite</h3>
<p>${_escapeHtml(aiPlan.summaryRewrite.rewrittenText)}</p>
${aiPlan.bulletRewrites.isEmpty ? '' : '<h3>Bullet rewrites</h3><ul>${aiPlan.bulletRewrites.map((rewrite) => '<li>${_escapeHtml(rewrite.rewrittenText)}</li>').join()}</ul>'}
<h3>Tailoring suggestions</h3>
<ul>${aiPlan.tailoringSuggestions.map((item) => '<li>${_escapeHtml(item)}</li>').join()}</ul>
''';

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI Resume Analyzer Report</title>
  <style>
    body { font-family: Georgia, serif; background: #f4efe6; color: #1f2933; margin: 0; }
    main { max-width: 920px; margin: 0 auto; padding: 40px 24px 64px; }
    section { background: #fffaf2; border: 1px solid #dacfbe; border-radius: 24px; padding: 24px; margin-bottom: 20px; }
    h1, h2, h3 { color: #0e4c5c; }
    ul { padding-left: 20px; }
    li { margin-bottom: 10px; }
    .meta { color: #5d6974; }
  </style>
</head>
<body>
  <main>
    <section>
      <h1>AI Resume Analyzer Report</h1>
      <p class="meta">Generated ${_escapeHtml(generatedAt.toIso8601String())}</p>
      <p><strong>Resume:</strong> ${_escapeHtml(resume.fileName)}</p>
      <p><strong>Overall ATS score:</strong> ${analysis.overallScore}</p>
      <p>${_escapeHtml(analysis.summary)}</p>
    </section>
    <section>
      <h2>Category scores</h2>
      <ul>$categoryItems</ul>
    </section>
    <section>
      <h2>Strengths</h2>
      <ul>$strengths</ul>
    </section>
    <section>
      <h2>Priority fixes</h2>
      <ul>$issues</ul>
    </section>
    <section>
      <h2>Job match</h2>
      $jobMatchBlock
    </section>
    <section>
      <h2>AI assist</h2>
      $aiBlock
    </section>
  </main>
</body>
</html>
''';
}

String _sanitizeFileStem(String fileName) {
  final withoutExtension = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
  return withoutExtension
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

String _escapeHtml(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
