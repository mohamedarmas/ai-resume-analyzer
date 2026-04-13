import 'package:ai_resume_analyzer/core/storage/session_persistence.dart';
import 'package:ai_resume_analyzer/core/widgets/highlight_card.dart';
import 'package:ai_resume_analyzer/core/widgets/page_layout.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadControllerProvider);
    final jobDescription = ref.watch(jobDescriptionProvider);

    return AppPageLayout(
      eyebrow: 'Environment and controls',
      title: 'Capability checks and local data settings',
      description:
          'Settings should stay lean in v1: focus on browser compatibility, '
          'storage visibility, and a clean way to clear locally cached sessions.',
      badges: <String>[
        'IndexedDB visibility',
        'WebGPU support check',
        'Reset actions',
      ],
      headerAction: OutlinedButton.icon(
        onPressed: () async {
          ref.read(uploadControllerProvider.notifier).clearSession();
          ref.read(jobDescriptionProvider.notifier).restore('');
          await ref.read(sessionPersistenceProvider).clear();
        },
        icon: const Icon(Icons.delete_outline_rounded),
        label: const Text('Clear local session'),
      ),
      children: <Widget>[
        HighlightCard(
          title: 'Current local session',
          icon: Icons.storage_outlined,
          bullets: <String>[
            uploadState.hasDocument
                ? 'Resume loaded: ${uploadState.document!.fileName}'
                : 'No resume is currently persisted in the active session.',
            jobDescription.trim().isEmpty
                ? 'No job description is currently saved.'
                : 'Job description draft is saved locally in the browser.',
            'Clearing the local session removes the restored resume and JD draft.',
          ],
        ),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: const <Widget>[
            SizedBox(
              width: 340,
              child: HighlightCard(
                title: 'Capability checks',
                icon: Icons.computer_outlined,
                bullets: <String>[
                  'Browser support for file APIs and drag-drop.',
                  'WebGPU or fallback readiness for browser AI.',
                  'Readable status text for unsupported environments.',
                ],
              ),
            ),
            SizedBox(
              width: 340,
              child: HighlightCard(
                title: 'Local data controls',
                icon: Icons.storage_outlined,
                bullets: <String>[
                  'List cached sessions stored in the browser.',
                  'Clear parsed resume data and generated reports.',
                  'Explain that data stays local unless a future sync mode is added.',
                ],
              ),
            ),
            SizedBox(
              width: 340,
              child: HighlightCard(
                title: 'Developer utilities',
                icon: Icons.build_outlined,
                bullets: <String>[
                  'Surface model warmup status during development.',
                  'Expose parser bridge health and worker logs.',
                  'Provide a quick toggle for demo-mode seed data.',
                ],
              ),
            ),
          ],
        ),
        HighlightCard(
          title: 'What belongs later',
          subtitle:
              'Authentication and cloud sync should stay out of v1 if the goal is '
              'a free, no-conflict showcase project.',
          icon: Icons.do_not_disturb_alt_outlined,
          bullets: <String>[
            'Do not add paid services just to fill out settings.',
            'Keep the app portable and easy to run from a public repo.',
            'Treat cloud features as an optional future branch, not a blocker.',
          ],
        ),
      ],
    );
  }
}
