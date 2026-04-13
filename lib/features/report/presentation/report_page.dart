import 'package:ai_resume_analyzer/core/widgets/highlight_card.dart';
import 'package:ai_resume_analyzer/core/widgets/page_layout.dart';
import 'package:ai_resume_analyzer/core/widgets/workflow_journey_card.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:ai_resume_analyzer/features/report/domain/report_export_builder.dart';
import 'package:ai_resume_analyzer/features/report/domain/report_export_bundle.dart';
import 'package:ai_resume_analyzer/features/report/domain/report_export_service.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundle = ref.watch(reportExportBundleProvider);
    final hasResume = ref.watch(uploadControllerProvider).hasDocument;
    final hasJobDescription = ref.watch(jobDescriptionProvider).trim().isNotEmpty;

    return AppPageLayout(
      eyebrow: 'Outputs',
      title: 'Reports, exports, and recruiter-friendly handoff',
      description:
          'A polished export flow makes the project feel complete. This screen '
          'now turns the live ATS, job-match, and AI Assist state into copyable '
          'and downloadable artifacts.',
      badges: const <String>[
        'Live report',
        'JSON export',
        'Printable HTML',
        'Selectable text',
      ],
      headerAction: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          FilledButton.icon(
            onPressed: () => context.go('/demo'),
            icon: const Icon(Icons.slideshow_rounded),
            label: const Text('View sample report flow'),
          ),
          OutlinedButton.icon(
            onPressed: bundle == null
                ? null
                : () => _copySummary(context, ref, bundle),
            icon: const Icon(Icons.copy_all_rounded),
            label: const Text('Copy summary'),
          ),
        ],
      ),
      children: <Widget>[
        WorkflowJourneyCard(
          currentRoute: '/report',
          hasResume: hasResume,
          hasJobDescription: hasJobDescription,
          hasExport: bundle != null,
        ),
        if (bundle == null)
          HighlightCard(
            title: 'Load a resume before opening the report',
            subtitle:
                'The export bundle is generated from the current parsed resume '
                'and ATS analysis. Without that session, this page has nothing to export.',
            icon: Icons.description_outlined,
            bullets: const <String>[
              'Parse a resume first so the ATS engine can create a report.',
              'The export actions appear once live analysis data exists.',
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
        else ...<Widget>[
          _ExportActionsCard(bundle: bundle),
          HighlightCard(
            title: 'Generated report summary',
            icon: Icons.description_outlined,
            subtitle:
                'This can already be copied into notes, email drafts, or your own revision checklist.',
            child: SelectableText(bundle.summaryText),
          ),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: <Widget>[
              const SizedBox(
                width: 340,
                child: HighlightCard(
                  title: 'Export targets',
                  icon: Icons.file_download_outlined,
                  bullets: <String>[
                    'JSON for future imports or audit trails.',
                    'Printable HTML for portfolio demos and quick sharing.',
                    'Clipboard-ready text for immediate follow-up edits.',
                  ],
                ),
              ),
              SizedBox(
                width: 340,
                child: HighlightCard(
                  title: 'Bundle details',
                  icon: Icons.inventory_2_outlined,
                  bullets: <String>[
                    'Base file name: ${bundle.fileStem}',
                    'JSON payload size: ${bundle.jsonContent.length} chars',
                    'HTML payload size: ${bundle.htmlContent.length} chars',
                  ],
                ),
              ),
              const SizedBox(
                width: 340,
                child: HighlightCard(
                  title: 'What ships in the bundle',
                  icon: Icons.fact_check_outlined,
                  bullets: <String>[
                    'Resume metadata and parsed text reference',
                    'ATS score, strengths, and issue list',
                    'Job-match results and AI Assist suggestions',
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _copySummary(
    BuildContext context,
    WidgetRef ref,
    ReportExportBundle bundle,
  ) async {
    await ref.read(reportExportServiceProvider).copyText(bundle.summaryText);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report summary copied to clipboard.')),
      );
    }
  }
}

class _ExportActionsCard extends ConsumerWidget {
  const _ExportActionsCard({required this.bundle});

  final ReportExportBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Download exports',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Use these actions to download the current report as structured JSON or a printable HTML document.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () => _downloadJson(context, ref),
                  icon: const Icon(Icons.data_object_rounded),
                  label: const Text('Download JSON'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _downloadHtml(context, ref),
                  icon: const Icon(Icons.language_rounded),
                  label: const Text('Download HTML'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _copySummary(context, ref),
                  icon: const Icon(Icons.copy_all_rounded),
                  label: const Text('Copy summary'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadJson(BuildContext context, WidgetRef ref) async {
    await ref
        .read(reportExportServiceProvider)
        .downloadJson(fileStem: bundle.fileStem, content: bundle.jsonContent);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON report download started.')),
      );
    }
  }

  Future<void> _downloadHtml(BuildContext context, WidgetRef ref) async {
    await ref
        .read(reportExportServiceProvider)
        .downloadHtml(fileStem: bundle.fileStem, content: bundle.htmlContent);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HTML report download started.')),
      );
    }
  }

  Future<void> _copySummary(BuildContext context, WidgetRef ref) async {
    await ref.read(reportExportServiceProvider).copyText(bundle.summaryText);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report summary copied to clipboard.')),
      );
    }
  }
}
