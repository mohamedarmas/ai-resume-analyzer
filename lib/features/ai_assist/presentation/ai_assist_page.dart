import 'package:ai_resume_analyzer/core/widgets/highlight_card.dart';
import 'package:ai_resume_analyzer/core/widgets/page_layout.dart';
import 'package:ai_resume_analyzer/core/widgets/workflow_journey_card.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_assist_generator.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_assist_plan.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_capability.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:ai_resume_analyzer/features/report/domain/report_export_builder.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AiAssistPage extends ConsumerWidget {
  const AiAssistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadControllerProvider);
    final capability = ref.watch(aiCapabilityProvider);
    final plan = ref.watch(aiAssistPlanProvider);
    final hasJobDescription = ref.watch(jobDescriptionProvider).trim().isNotEmpty;
    final hasExport = ref.watch(reportExportBundleProvider) != null;

    return AppPageLayout(
      eyebrow: 'Local AI rewrite layer',
      title: 'Structured rewrites with a graceful local fallback',
      description:
          'AI Assist now turns ATS findings and job-match gaps into concrete '
          'rewrite tasks. Until a full local model is wired in, the app uses a '
          'deterministic fallback engine so the product stays useful and honest.',
      badges: const <String>[
        'Capability detection',
        'Deterministic fallback',
        'Prompt templates',
        'Worker-ready seam',
      ],
      headerAction: OutlinedButton.icon(
        onPressed: uploadState.hasDocument ? () => context.go('/report') : null,
        icon: const Icon(Icons.inventory_2_rounded),
        label: const Text('Preview final report'),
      ),
      children: <Widget>[
        WorkflowJourneyCard(
          currentRoute: '/ai-assist',
          hasResume: uploadState.hasDocument,
          hasJobDescription: hasJobDescription,
          hasExport: hasExport,
        ),
        _CapabilityCard(capability: capability),
        if (!uploadState.hasDocument)
          HighlightCard(
            title: 'Load a resume before opening AI Assist',
            subtitle:
                'This screen depends on the parsed resume and ATS output. It '
                'cannot generate meaningful rewrite suggestions without them.',
            icon: Icons.hourglass_empty_rounded,
            bullets: const <String>[
              'Upload or load a resume before opening AI Assist.',
              'This screen depends on the parsed resume, ATS report, and optional job-match data.',
            ],
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () => context.go('/upload'),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Go to upload'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/demo'),
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: const Text('Use demo'),
                ),
              ],
            ),
          )
        else if (plan != null) ...<Widget>[
          _SummaryRewriteCard(plan: plan),
          if (plan.bulletRewrites.isNotEmpty) _BulletRewriteList(plan: plan),
          _TailoringCard(plan: plan),
          _PromptPreviewCard(plan: plan),
        ] else
          HighlightCard(
            title: 'Open analysis first, then come back here',
            subtitle:
                'AI Assist uses the ATS engine as its source of truth. Job Match '
                'is optional, but it improves the tailoring suggestions.',
            icon: Icons.analytics_outlined,
            bullets: const <String>[
              'Run the parser and ATS analysis first.',
              'Job match is optional, but it improves tailoring suggestions.',
            ],
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () => context.go('/analysis'),
                  icon: const Icon(Icons.analytics_rounded),
                  label: const Text('Open analysis'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/job-match'),
                  icon: const Icon(Icons.track_changes_rounded),
                  label: const Text('Add job description'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({required this.capability});

  final AsyncValue<AiCapability> capability;

  @override
  Widget build(BuildContext context) {
    return capability.when(
      data: (value) => Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Local AI runtime status',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                value.statusLabel,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _RuntimeChip(
                    label: 'Worker support',
                    value: value.supported ? 'Yes' : 'No',
                  ),
                  _RuntimeChip(
                    label: 'WebGPU',
                    value: value.webGpuAvailable ? 'Available' : 'Unavailable',
                  ),
                  _RuntimeChip(
                    label: 'Worker ready',
                    value: value.workerReady ? 'Yes' : 'No',
                  ),
                  _RuntimeChip(label: 'Provider', value: value.provider),
                ],
              ),
            ],
          ),
        ),
      ),
      loading: () => const HighlightCard(
        title: 'Checking runtime capability',
        icon: Icons.memory_rounded,
        bullets: <String>[
          'Inspecting browser worker support and WebGPU availability.',
        ],
      ),
      error: (error, stackTrace) => HighlightCard(
        title: 'Runtime capability check failed',
        icon: Icons.error_outline_rounded,
        bullets: <String>[error.toString()],
      ),
    );
  }
}

class _SummaryRewriteCard extends StatelessWidget {
  const _SummaryRewriteCard({required this.plan});

  final AiAssistPlan plan;

  @override
  Widget build(BuildContext context) {
    final rewrite = plan.summaryRewrite;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  rewrite.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Chip(label: Text(plan.modeLabel)),
              ],
            ),
            const SizedBox(height: 18),
            _RewritePanel(label: 'Original', text: rewrite.originalText),
            const SizedBox(height: 16),
            _RewritePanel(
              label: 'Suggested rewrite',
              text: rewrite.rewrittenText,
            ),
            const SizedBox(height: 14),
            Text(
              rewrite.rationale,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletRewriteList extends StatelessWidget {
  const _BulletRewriteList({required this.plan});

  final AiAssistPlan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Suggested bullet rewrites',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            for (final rewrite in plan.bulletRewrites)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _RewritePanel(
                      label: 'Original bullet',
                      text: rewrite.originalText,
                    ),
                    const SizedBox(height: 12),
                    _RewritePanel(
                      label: 'Suggested rewrite',
                      text: rewrite.rewrittenText,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      rewrite.rationale,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TailoringCard extends StatelessWidget {
  const _TailoringCard({required this.plan});

  final AiAssistPlan plan;

  @override
  Widget build(BuildContext context) {
    return HighlightCard(
      title: 'Tailoring suggestions',
      icon: Icons.tune_rounded,
      bullets: plan.tailoringSuggestions,
    );
  }
}

class _PromptPreviewCard extends StatelessWidget {
  const _PromptPreviewCard({required this.plan});

  final AiAssistPlan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Prompt previews',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'These prompt templates are ready to feed into a future WebLLM worker without changing the UI contract.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            for (final prompt in plan.promptPreviews)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      prompt.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: SelectableText(prompt.prompt),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RewritePanel extends StatelessWidget {
  const _RewritePanel({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(text),
        ],
      ),
    );
  }
}

class _RuntimeChip extends StatelessWidget {
  const _RuntimeChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
