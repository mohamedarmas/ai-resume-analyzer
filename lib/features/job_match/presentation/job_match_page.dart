import 'package:ai_resume_analyzer/core/widgets/highlight_card.dart';
import 'package:ai_resume_analyzer/core/widgets/page_layout.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_report.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JobMatchPage extends ConsumerStatefulWidget {
  const JobMatchPage({super.key});

  @override
  ConsumerState<JobMatchPage> createState() => _JobMatchPageState();
}

class _JobMatchPageState extends ConsumerState<JobMatchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(jobDescriptionProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadControllerProvider);
    final report = ref.watch(jobMatchReportProvider);

    return AppPageLayout(
      eyebrow: 'Role targeting',
      title: 'Job description matching and keyword gaps',
      description:
          'Paste a target role or JD and the app will compare it to the parsed '
          'resume locally. This gives the user a factual targeting layer before '
          'any AI rewriting begins.',
      badges: const <String>[
        'JD parser',
        'Keyword diff',
        'Match score',
        'Tailoring suggestions',
      ],
      headerAction: FilledButton.icon(
        onPressed: uploadState.hasDocument
            ? () => context.go('/ai-assist')
            : null,
        icon: const Icon(Icons.psychology_alt_rounded),
        label: const Text('Hand off to AI assist'),
      ),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Target role input',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  uploadState.hasDocument
                      ? 'Paste a job description to compare it against the active resume session.'
                      : 'Load a resume first, then paste a job description here to compute a match.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  maxLines: 10,
                  minLines: 8,
                  onChanged: (value) =>
                      ref.read(jobDescriptionProvider.notifier).update(value),
                  decoration: const InputDecoration(
                    hintText:
                        'Paste a job description here. Example: Frontend Engineer focused on Flutter Web, analytics dashboards, developer tooling, and testing discipline...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!uploadState.hasDocument)
          const HighlightCard(
            title: 'Resume required first',
            icon: Icons.hourglass_empty_rounded,
            bullets: <String>[
              'The match engine compares the JD against the parsed resume in the current session.',
              'Use the upload route or demo mode to seed a resume first.',
            ],
          )
        else if (report != null) ...<Widget>[
          _JobMatchOverview(report: report),
          _KeywordPanels(report: report),
        ] else
          const HighlightCard(
            title: 'Paste a job description to start matching',
            icon: Icons.content_paste_search_rounded,
            bullets: <String>[
              'The app will extract role keywords and compare them against the current resume.',
              'Missing keywords do not mean you should invent experience.',
              'Use this as a tailoring guide, not as permission to fabricate claims.',
            ],
          ),
        const HighlightCard(
          title: 'Guardrails',
          subtitle:
              'The app should help users frame existing experience better, not '
              'invent qualifications they do not actually have.',
          icon: Icons.gpp_good_outlined,
          bullets: <String>[
            'Never fabricate projects, employers, or tools.',
            'Flag suggestions that depend on user verification.',
            'Keep a clear distinction between detected facts and generated copy.',
          ],
        ),
      ],
    );
  }
}

class _JobMatchOverview extends StatelessWidget {
  const _JobMatchOverview({required this.report});

  final JobMatchReport report;

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
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Current match score: ${report.matchScore}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        report.roleSignal,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                _MatchBadge(score: report.matchScore),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _MetricChip(
                  label: 'Target keywords',
                  value: report.targetKeywords.length.toString(),
                ),
                _MetricChip(
                  label: 'Matched',
                  value: report.matchedKeywords.length.toString(),
                ),
                _MetricChip(
                  label: 'Missing',
                  value: report.missingKeywords.length.toString(),
                ),
              ],
            ),
            if (report.tailoringSuggestions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              Text(
                'Tailoring suggestions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              for (final suggestion in report.tailoringSuggestions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('• $suggestion'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KeywordPanels extends StatelessWidget {
  const _KeywordPanels({required this.report});

  final JobMatchReport report;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        SizedBox(
          width: 520,
          child: HighlightCard(
            title: 'Matched keywords',
            icon: Icons.check_circle_outline_rounded,
            subtitle: report.matchedKeywords.isEmpty
                ? 'No strong matches yet.'
                : 'These terms already appear in the active resume session.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: report.matchedKeywords.isEmpty
                  ? <Widget>[const Chip(label: Text('No matches yet'))]
                  : report.matchedKeywords
                        .map((keyword) => Chip(label: Text(keyword)))
                        .toList(),
            ),
          ),
        ),
        SizedBox(
          width: 520,
          child: HighlightCard(
            title: 'Missing keywords',
            icon: Icons.error_outline_rounded,
            subtitle: report.missingKeywords.isEmpty
                ? 'The resume already covers the extracted keyword set.'
                : 'Only mirror these if they are factually supported by your experience.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: report.missingKeywords.isEmpty
                  ? <Widget>[const Chip(label: Text('No major gaps'))]
                  : report.missingKeywords
                        .map((keyword) => Chip(label: Text(keyword)))
                        .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

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

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = switch (score) {
      >= 80 => const Color(0xFF4C7A53),
      >= 60 => const Color(0xFFB17B2E),
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
