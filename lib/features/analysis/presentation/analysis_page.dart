import 'package:ai_resume_analyzer/core/widgets/highlight_card.dart';
import 'package:ai_resume_analyzer/core/widgets/page_layout.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analysis_report.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analyzer.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadControllerProvider);
    final report = ref.watch(analysisReportProvider);

    return AppPageLayout(
      eyebrow: 'ATS scoring engine',
      title: 'Deterministic ATS analysis is now live',
      description:
          'The parser output from the upload flow now feeds a local scoring engine '
          'that checks structure, impact language, skill visibility, readability, '
          'and ATS-friendly section patterns.',
      badges: const <String>[
        'Live session state',
        'Rule engine',
        'Section detection',
        'Score breakdown',
      ],
      headerAction: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          OutlinedButton.icon(
            onPressed: () => context.go('/upload'),
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(state.hasDocument ? 'Swap resume' : 'Load a resume'),
          ),
          FilledButton.icon(
            onPressed: state.hasDocument
                ? () => context.go('/job-match')
                : null,
            icon: const Icon(Icons.track_changes_rounded),
            label: const Text('Continue to job match'),
          ),
        ],
      ),
      children: <Widget>[
        if (report != null)
          _AnalysisOverviewCard(report: report)
        else
          const HighlightCard(
            title: 'No parsed resume in session',
            icon: Icons.hourglass_empty_rounded,
            bullets: <String>[
              'Start from the upload route and parse a PDF or DOCX file.',
              'The analysis engine will consume the exact text extracted there.',
              'Demo mode can also seed a sample resume into this flow.',
            ],
          ),
        if (report != null) ...<Widget>[
          _CategoryScoreGrid(report: report),
          _StrengthsAndIssuesSection(report: report),
        ] else
          const HighlightCard(
            title: 'What the analyzer will score',
            icon: Icons.scoreboard_outlined,
            bullets: <String>[
              'Resume completeness and essential contact details.',
              'Bullet quality, action verbs, and measurable impact.',
              'Formatting safety, scanability, and section clarity.',
            ],
          ),
      ],
    );
  }
}

class _AnalysisOverviewCard extends StatelessWidget {
  const _AnalysisOverviewCard({required this.report});

  final ResumeAnalysisReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Overall ATS score: ${report.overallScore}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        report.summary,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                _ScoreBadge(score: report.overallScore),
              ],
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _AnalysisMetric(
                  label: 'Detected sections',
                  value: report.detectedSections.length.toString(),
                ),
                _AnalysisMetric(
                  label: 'Bullets',
                  value: report.bulletCount.toString(),
                ),
                _AnalysisMetric(
                  label: 'Action bullets',
                  value: report.actionVerbBulletCount.toString(),
                ),
                _AnalysisMetric(
                  label: 'Quantified bullets',
                  value: report.quantifiedBulletCount.toString(),
                ),
                _AnalysisMetric(
                  label: 'Contact signals',
                  value: report.contactSignalCount.toString(),
                ),
                _AnalysisMetric(
                  label: 'Long lines',
                  value: report.longLineCount.toString(),
                ),
              ],
            ),
            if (report.detectedSections.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: report.detectedSections
                    .map((section) => Chip(label: Text(section)))
                    .toList(),
              ),
            ],
            if (report.missingSections.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Missing or unclear sections: ${report.missingSections.join(', ')}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryScoreGrid extends StatelessWidget {
  const _CategoryScoreGrid({required this.report});

  final ResumeAnalysisReport report;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: report.categoryScores
          .map(
            (category) => SizedBox(
              width: 340,
              child: HighlightCard(
                title: category.label,
                icon: Icons.analytics_outlined,
                subtitle: category.summary,
                child: Text(
                  '${category.score}/100',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StrengthsAndIssuesSection extends StatelessWidget {
  const _StrengthsAndIssuesSection({required this.report});

  final ResumeAnalysisReport report;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        SizedBox(
          width: 520,
          child: HighlightCard(
            title: 'Strengths',
            icon: Icons.thumb_up_alt_outlined,
            bullets: report.strengths,
          ),
        ),
        SizedBox(
          width: 520,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Priority fixes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  for (final issue in report.issues.take(5))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _IssueTile(issue: issue),
                    ),
                  if (report.issues.isEmpty)
                    Text(
                      'No major issues were detected by the first-pass rule engine.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalysisMetric extends StatelessWidget {
  const _AnalysisMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = switch (score) {
      >= 85 => const Color(0xFF4C7A53),
      >= 70 => const Color(0xFFB17B2E),
      _ => const Color(0xFFB45646),
    };

    return Container(
      width: 124,
      height: 124,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.45), width: 2),
      ),
      child: Center(
        child: Text(
          '$score',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({required this.issue});

  final AnalysisIssue issue;

  @override
  Widget build(BuildContext context) {
    final color = switch (issue.severity) {
      AnalysisSeverity.high => const Color(0xFF9E3D2F),
      AnalysisSeverity.medium => const Color(0xFF9A6B28),
      AnalysisSeverity.low => const Color(0xFF4C7A53),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(issue.title, style: Theme.of(context).textTheme.titleMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  issue.severity.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(issue.description),
          const SizedBox(height: 8),
          Text(
            issue.recommendation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
