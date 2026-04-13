import 'package:ai_resume_analyzer/core/widgets/highlight_card.dart';
import 'package:ai_resume_analyzer/core/widgets/page_layout.dart';
import 'package:ai_resume_analyzer/features/demo/data/demo_resume_seed.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DemoPage extends ConsumerWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadControllerProvider);

    return AppPageLayout(
      eyebrow: 'Recruiter-friendly walkthrough',
      title: 'Demo mode for instant portfolio review',
      description:
          'This route lets a visitor see the product shape without hunting for '
          'their own resume first. It now connects to the same upload session '
          'state as the real parser flow.',
      badges: const <String>[
        'Sample resume',
        'Guided flow',
        'Fast first impression',
      ],
      headerAction: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          FilledButton.icon(
            onPressed: uploadState.isBusy
                ? null
                : () async {
                    await ref
                        .read(uploadControllerProvider.notifier)
                        .loadDemoResume();
                    if (context.mounted) {
                      context.go('/analysis');
                    }
                  },
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Seed demo into analysis'),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go('/upload'),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Switch to real upload'),
          ),
        ],
      ),
      children: <Widget>[
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: const <Widget>[
            SizedBox(
              width: 340,
              child: HighlightCard(
                title: demoCandidateName,
                icon: Icons.person_outline_rounded,
                subtitle: demoRoleTitle,
                bullets: demoStrengths,
              ),
            ),
            SizedBox(
              width: 340,
              child: HighlightCard(
                title: 'Current summary',
                icon: Icons.short_text_rounded,
                subtitle: demoSummary,
                bullets: <String>[
                  'Good baseline, but the story can feel more role-specific.',
                  'A stronger impact framing would improve first impression.',
                ],
              ),
            ),
            SizedBox(
              width: 340,
              child: HighlightCard(
                title: 'Target role',
                icon: Icons.work_outline_rounded,
                subtitle: demoTargetRole,
                bullets: demoRisks,
              ),
            ),
          ],
        ),
        const HighlightCard(
          title: 'Demo flow to implement',
          subtitle:
              'Keep the demo deterministic so the portfolio remains stable even '
              'before the full parser and AI stack is complete.',
          icon: Icons.route_outlined,
          bullets: <String>[
            'Load a bundled sample resume JSON object.',
            'Show a ready-made report with explainable ATS findings.',
            'Offer one or two static AI rewrite examples to preview the vision.',
          ],
        ),
      ],
    );
  }
}
