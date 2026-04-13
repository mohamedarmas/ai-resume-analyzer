import 'dart:math' as math;

import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analysis_report.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resumeAnalyzerProvider = Provider<ResumeAnalyzer>((ref) {
  return const ResumeAnalyzer();
});

final analysisReportProvider = Provider<ResumeAnalysisReport?>((ref) {
  final document = ref.watch(uploadControllerProvider).document;
  if (document == null) {
    return null;
  }

  return ref.watch(resumeAnalyzerProvider).analyze(document);
});

class ResumeAnalyzer {
  const ResumeAnalyzer();

  ResumeAnalysisReport analyze(ResumeDocument document) {
    final lines = _normalizedLines(document.rawText);
    final sectionResult = _detectSections(lines);
    final bulletLines = lines.where(_isBulletLine).toList(growable: false);
    final actionVerbBullets = bulletLines.where(_startsWithActionVerb).length;
    final quantifiedBullets = bulletLines.where(_containsMetricSignal).length;
    final longLineCount = lines.where((line) => line.length > 120).length;
    final allCapsLineCount = lines
        .where((line) => line.length > 8 && line == line.toUpperCase())
        .length;

    final hasEmail = RegExp(
      r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
      caseSensitive: false,
    ).hasMatch(document.rawText);
    final hasPhone = RegExp(
      r'(\+\d{1,3}[\s-]?)?[\d][\d\s()-]{7,}',
    ).hasMatch(document.rawText);
    final hasProfessionalLink = RegExp(
      r'(linkedin\.com|github\.com|portfolio|behance|dribbble)',
      caseSensitive: false,
    ).hasMatch(document.rawText);
    final contactSignalCount = [
      hasEmail,
      hasPhone,
      hasProfessionalLink,
    ].where((value) => value).length;

    final requiredSections = <String>[
      'summary',
      'experience',
      'skills',
      'education',
    ];
    final missingSections = requiredSections
        .where((section) => !sectionResult.contains(section))
        .toList(growable: false);

    final completenessScore = _clampScore(
      20 +
          (contactSignalCount * 20) +
          ((requiredSections.length - missingSections.length) * 10),
    );

    final sectionQualityScore = _clampScore(
      35 +
          (sectionResult.detectedSections.length * 8) +
          math.min(bulletLines.length, 8) * 4 -
          (missingSections.length * 8) -
          (longLineCount * 3),
    );

    final impactScore = _clampScore(
      20 +
          (bulletLines.isEmpty
              ? 0
              : (actionVerbBullets * 45 ~/ bulletLines.length)) +
          (bulletLines.isEmpty
              ? 0
              : (quantifiedBullets * 35 ~/ bulletLines.length)),
    );

    final skillSignalScore = _clampScore(
      25 +
          (sectionResult.contains('skills') ? 25 : 0) +
          math.min(_countSkillKeywords(document.rawText), 10) * 5,
    );

    final readabilityScore = _clampScore(
      90 - (longLineCount * 8) - math.max(allCapsLineCount - 6, 0) * 4,
    );

    final atsSafetyScore = _clampScore(
      85 -
          (missingSections.contains('experience') ? 25 : 0) -
          (missingSections.contains('education') ? 12 : 0) -
          (allCapsLineCount > 10 ? 12 : 0),
    );

    final categoryScores = <AnalysisCategoryScore>[
      AnalysisCategoryScore(
        label: 'Completeness',
        score: completenessScore,
        summary: missingSections.isEmpty
            ? 'Core resume ingredients are present.'
            : 'Add the missing essentials: ${missingSections.join(', ')}.',
      ),
      AnalysisCategoryScore(
        label: 'Section quality',
        score: sectionQualityScore,
        summary: bulletLines.isEmpty
            ? 'Experience details are thin or hard to scan.'
            : 'The resume has $actionVerbBullets strong bullet openings out of ${bulletLines.length}.',
      ),
      AnalysisCategoryScore(
        label: 'Impact language',
        score: impactScore,
        summary: quantifiedBullets == 0
            ? 'Add measurable outcomes to show business impact.'
            : '$quantifiedBullets bullets already include metric or outcome signals.',
      ),
      AnalysisCategoryScore(
        label: 'Skill signal',
        score: skillSignalScore,
        summary: sectionResult.contains('skills')
            ? 'The resume exposes tools and platforms clearly.'
            : 'A dedicated skills section would improve keyword visibility.',
      ),
      AnalysisCategoryScore(
        label: 'Readability',
        score: readabilityScore,
        summary: longLineCount == 0
            ? 'The text is reasonably easy to scan.'
            : '$longLineCount long lines may feel dense to recruiters.',
      ),
      AnalysisCategoryScore(
        label: 'ATS safety',
        score: atsSafetyScore,
        summary: sectionResult.contains('experience')
            ? 'Standard headings make the layout easier for ATS tools.'
            : 'Use standard headings like Experience and Education.',
      ),
    ];

    final overallScore = _clampScore(
      (completenessScore * 0.20).round() +
          (sectionQualityScore * 0.20).round() +
          (impactScore * 0.20).round() +
          (skillSignalScore * 0.15).round() +
          (readabilityScore * 0.10).round() +
          (atsSafetyScore * 0.15).round(),
    );

    final strengths = <String>[
      if (contactSignalCount >= 2)
        'Contact information is discoverable and recruiter-ready.',
      if (sectionResult.contains('experience'))
        'Standard experience headings improve ATS recognition.',
      if (actionVerbBullets >= 2)
        'Several bullets already start with strong action language.',
      if (quantifiedBullets >= 1)
        'The resume includes measurable outcomes, which helps credibility.',
      if (sectionResult.contains('skills'))
        'A dedicated skills section improves keyword visibility.',
    ];

    final issues = <AnalysisIssue>[
      if (missingSections.isNotEmpty)
        AnalysisIssue(
          title: 'Core sections are missing',
          description:
              'The analyzer could not find ${missingSections.join(', ')} using common ATS-friendly headings.',
          recommendation:
              'Add explicit section headers so the resume is easier for both recruiters and ATS tools to parse.',
          severity: AnalysisSeverity.high,
        ),
      if (bulletLines.isEmpty)
        const AnalysisIssue(
          title: 'Experience bullets are hard to detect',
          description:
              'The resume does not expose clear bullet-style accomplishments in the extracted text.',
          recommendation:
              'Rewrite experience entries into short bullet points that start with action verbs.',
          severity: AnalysisSeverity.high,
        ),
      if (bulletLines.isNotEmpty && quantifiedBullets == 0)
        const AnalysisIssue(
          title: 'Impact is not yet measurable',
          description:
              'The bullets describe responsibilities, but the analyzer found no metric or result signals.',
          recommendation:
              'Add numbers, percentages, time saved, revenue impact, adoption, or scope where they are real and known.',
          severity: AnalysisSeverity.high,
        ),
      if (bulletLines.isNotEmpty &&
          actionVerbBullets < math.max(1, bulletLines.length ~/ 2))
        const AnalysisIssue(
          title: 'Bullet openings can be stronger',
          description:
              'Many bullets do not begin with a strong verb, which makes the experience feel less action-oriented.',
          recommendation:
              'Start bullets with verbs like Built, Led, Shipped, Improved, Automated, or Reduced.',
          severity: AnalysisSeverity.medium,
        ),
      if (!sectionResult.contains('skills'))
        const AnalysisIssue(
          title: 'Skills section is missing',
          description:
              'Without a dedicated skills block, important keywords are easier to miss.',
          recommendation:
              'Add a concise skills section with tools, frameworks, languages, and domain areas you genuinely know.',
          severity: AnalysisSeverity.medium,
        ),
      if (!hasProfessionalLink)
        const AnalysisIssue(
          title: 'Professional link is missing',
          description:
              'The analyzer did not find a LinkedIn, GitHub, or portfolio link in the header area.',
          recommendation:
              'Add one professional profile link so reviewers can quickly validate your work.',
          severity: AnalysisSeverity.low,
        ),
      if (longLineCount >= 3)
        AnalysisIssue(
          title: 'Some lines are too dense',
          description:
              '$longLineCount lines are long enough to slow down scanning on both desktop and mobile.',
          recommendation:
              'Break long paragraphs into tighter bullets or shorter statements.',
          severity: AnalysisSeverity.low,
        ),
    ];

    final summary = switch (overallScore) {
      >= 85 =>
        'Strong baseline. The resume is structurally solid and mainly needs targeted polish.',
      >= 70 =>
        'Good foundation with room to improve impact, scanability, and role targeting.',
      >= 55 =>
        'Promising base, but several ATS and storytelling gaps still need attention.',
      _ =>
        'The resume needs structural cleanup before AI rewrites will add much value.',
    };

    return ResumeAnalysisReport(
      overallScore: overallScore,
      summary: summary,
      categoryScores: categoryScores,
      strengths: strengths.isEmpty
          ? const <String>[
              'The resume text is available for scoring, which is enough to start improving it.',
            ]
          : strengths,
      issues: issues,
      detectedSections: sectionResult.detectedSections,
      missingSections: missingSections,
      bulletCount: bulletLines.length,
      actionVerbBulletCount: actionVerbBullets,
      quantifiedBulletCount: quantifiedBullets,
      contactSignalCount: contactSignalCount,
      longLineCount: longLineCount,
    );
  }
}

class _SectionDetectionResult {
  const _SectionDetectionResult(this.detectedSections);

  final List<String> detectedSections;

  bool contains(String section) => detectedSections.contains(section);
}

_SectionDetectionResult _detectSections(List<String> lines) {
  final detected = <String>{};

  for (final line in lines) {
    final normalized = line.toLowerCase().trim();
    if (normalized.isEmpty) {
      continue;
    }

    if (_matchesAny(normalized, const <String>[
      'summary',
      'professional summary',
      'profile',
    ])) {
      detected.add('summary');
    } else if (_matchesAny(normalized, const <String>[
      'experience',
      'work experience',
      'employment',
    ])) {
      detected.add('experience');
    } else if (_matchesAny(normalized, const <String>[
      'education',
      'academic background',
    ])) {
      detected.add('education');
    } else if (_matchesAny(normalized, const <String>[
      'skills',
      'technical skills',
      'core skills',
    ])) {
      detected.add('skills');
    } else if (_matchesAny(normalized, const <String>[
      'projects',
      'selected projects',
    ])) {
      detected.add('projects');
    } else if (_matchesAny(normalized, const <String>[
      'certifications',
      'certification',
    ])) {
      detected.add('certifications');
    }
  }

  return _SectionDetectionResult(detected.toList(growable: false));
}

bool _matchesAny(String normalizedLine, List<String> candidates) {
  return candidates.any((candidate) => normalizedLine == candidate);
}

List<String> _normalizedLines(String rawText) {
  return rawText
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}

bool _isBulletLine(String line) {
  return line.startsWith('- ') ||
      line.startsWith('• ') ||
      RegExp(r'^\d+\.\s').hasMatch(line);
}

bool _startsWithActionVerb(String line) {
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
  ];

  return verbs.any((verb) => normalized.startsWith('$verb '));
}

bool _containsMetricSignal(String line) {
  return RegExp(
    r'(\d+%|\d+\+|\$\d+|\d+\s?(users|customers|days|weeks|months|hours|mins|minutes|markets|teams|apps|projects))',
    caseSensitive: false,
  ).hasMatch(line);
}

int _countSkillKeywords(String rawText) {
  const keywords = <String>[
    'flutter',
    'dart',
    'react',
    'typescript',
    'javascript',
    'firebase',
    'api',
    'postgres',
    'supabase',
    'ai',
    'ml',
    'analytics',
    'dashboard',
    'testing',
    'automation',
  ];

  final normalized = rawText.toLowerCase();
  return keywords.where(normalized.contains).length;
}

int _clampScore(int value) => value.clamp(0, 100);
