import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/core/widgets/highlight_card.dart';
import 'package:ai_resume_analyzer/core/widgets/page_layout.dart';
import 'package:ai_resume_analyzer/core/widgets/workflow_journey_card.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:ai_resume_analyzer/features/report/domain/report_export_builder.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UploadPage extends ConsumerWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadControllerProvider);
    final controller = ref.read(uploadControllerProvider.notifier);
    final hasJobDescription = ref.watch(jobDescriptionProvider).trim().isNotEmpty;
    final hasExport = ref.watch(reportExportBundleProvider) != null;

    return AppPageLayout(
      eyebrow: 'Resume intake',
      title: 'Upload, parse, and inspect resume text locally',
      description:
          'This first functional slice keeps everything in the browser. Pick a '
          'PDF or DOCX resume, extract raw text through the parser bridge, and '
          'use the result as the source of truth for later ATS scoring.',
      badges: const <String>[
        'PDF.js bridge',
        'Mammoth.js bridge',
        'Local parsing',
        'Session state',
      ],
      headerAction: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          FilledButton.icon(
            onPressed: state.isBusy ? null : controller.pickResume,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(state.isBusy ? 'Working...' : 'Pick resume'),
          ),
          OutlinedButton.icon(
            onPressed: state.isBusy ? null : controller.loadDemoResume,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('Load sample'),
          ),
          OutlinedButton.icon(
            onPressed: state.hasDocument ? () => context.go('/analysis') : null,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Open analysis'),
          ),
        ],
      ),
      children: <Widget>[
        WorkflowJourneyCard(
          currentRoute: '/upload',
          hasResume: state.hasDocument,
          hasJobDescription: hasJobDescription,
          hasExport: hasExport,
        ),
        _UploadWorkbench(
          state: state,
          onPickResume: state.isBusy ? null : controller.pickResume,
          onLoadDemo: state.isBusy ? null : controller.loadDemoResume,
          onClear: state.hasDocument ? controller.clearSession : null,
        ),
        if (state.errorMessage case final errorMessage?)
          _InlineMessageCard(
            title: 'Parser feedback',
            message: errorMessage,
            tone: _MessageTone.error,
          ),
        if (state.statusMessage case final statusMessage?)
          _InlineMessageCard(
            title: 'Session status',
            message: statusMessage,
            tone: _MessageTone.info,
          ),
        if (state.document case final document?)
          _ParsedResumeCard(document: document)
        else
          const HighlightCard(
            title: 'What happens after this step',
            icon: Icons.account_tree_outlined,
            bullets: <String>[
              'The extracted text becomes the base for ATS scoring.',
              'Job match compares this text against the target role.',
              'AI Assist rewrites only the content already detected here.',
            ],
          ),
        const Wrap(
          spacing: 24,
          runSpacing: 24,
          children: <Widget>[
            SizedBox(
              width: 340,
              child: HighlightCard(
                title: 'Accepted inputs',
                icon: Icons.description_outlined,
                bullets: <String>[
                  'PDF resumes parsed with PDF.js in the browser.',
                  'DOCX resumes converted through Mammoth.js.',
                  'Sample mode for instant portfolio walkthroughs.',
                ],
              ),
            ),
            SizedBox(
              width: 340,
              child: HighlightCard(
                title: 'Validation before parse',
                icon: Icons.verified_outlined,
                bullets: <String>[
                  'Reject unsupported extensions before any parsing begins.',
                  'Fail loudly when text extraction produces an empty result.',
                  'Preserve the previous good session if a new parse fails.',
                ],
              ),
            ),
            SizedBox(
              width: 340,
              child: HighlightCard(
                title: 'State after upload',
                icon: Icons.inventory_2_outlined,
                bullets: <String>[
                  'The parsed resume is stored in app state for the current session.',
                  'Analysis routes can read the same document immediately.',
                  'Local persistence can be layered in next without changing the UI.',
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UploadWorkbench extends StatelessWidget {
  const _UploadWorkbench({
    required this.state,
    required this.onPickResume,
    required this.onLoadDemo,
    required this.onClear,
  });

  final UploadState state;
  final VoidCallback? onPickResume;
  final VoidCallback? onLoadDemo;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.file_present_rounded,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Resume intake workbench',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use a real resume or the bundled sample. Parsing stays '
                        'inside the browser and the output below shows exactly '
                        'what the analysis engine will inspect next.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Wrap(
                spacing: 14,
                runSpacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: onPickResume,
                    icon: const Icon(Icons.attach_file_rounded),
                    label: Text(
                      state.isBusy ? 'Parsing...' : 'Choose PDF or DOCX',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onLoadDemo,
                    icon: const Icon(Icons.theater_comedy_outlined),
                    label: const Text('Use demo resume'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Clear session'),
                  ),
                  Chip(
                    label: Text(
                      state.document == null
                          ? 'No resume loaded'
                          : 'Loaded: ${state.document!.fileName}',
                    ),
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

class _ParsedResumeCard extends StatelessWidget {
  const _ParsedResumeCard({required this.document});

  final ResumeDocument document;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  'Parsed Resume Snapshot',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (document.isDemo) const Chip(label: Text('Demo session')),
                Chip(label: Text(document.fileType.label)),
                Chip(label: Text('Parser: ${document.parser}')),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _MetricChip(
                  label: 'Pages',
                  value: document.pageCount.toString(),
                ),
                _MetricChip(
                  label: 'Words',
                  value: document.wordCount.toString(),
                ),
                _MetricChip(
                  label: 'Characters',
                  value: document.characterCount.toString(),
                ),
                _MetricChip(label: 'Size', value: document.formattedSize),
                _MetricChip(label: 'Loaded', value: document.createdLabel),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Extracted text preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: SelectableText(
                document.previewText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (document.notes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              Text(
                'Parser notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              for (final note in document.notes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(note),
                ),
            ],
          ],
        ),
      ),
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

enum _MessageTone { info, error }

class _InlineMessageCard extends StatelessWidget {
  const _InlineMessageCard({
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final _MessageTone tone;

  @override
  Widget build(BuildContext context) {
    final background = switch (tone) {
      _MessageTone.info => Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.08),
      _MessageTone.error => const Color(0xFFF7DDD3),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}
