import 'package:ai_resume_analyzer/core/constants/app_copy.dart';
import 'package:ai_resume_analyzer/core/models/app_destination.dart';
import 'package:ai_resume_analyzer/core/widgets/highlight_card.dart';
import 'package:ai_resume_analyzer/core/widgets/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageLayout(
      eyebrow: 'Zero-cost Flutter Web showcase',
      title: appName,
      description:
          'A local-first resume improvement studio that parses resumes in the '
          'browser, scores ATS readiness, matches job descriptions, generates '
          'structured rewrite suggestions, persists the local session, and exports '
          'shareable reports without a paid backend.',
      badges: const <String>[
        'Flutter Web',
        'ATS analysis live',
        'Job match live',
        'AI Assist fallback live',
        'Export ready',
      ],
      headerAction: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          FilledButton.icon(
            onPressed: () => context.go('/demo'),
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('Start guided demo'),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go('/upload'),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Upload your resume'),
          ),
        ],
      ),
      children: <Widget>[
        const _StartHereCard(),
        const _HeroProofStrip(),
        const _WorkflowShowcase(),
        const _BeforeAfterShowcase(),
        HighlightCard(
          title: 'What the project already demonstrates',
          subtitle:
              'This repo now goes beyond architecture notes and actually shows a '
              'full local-first product loop.',
          icon: Icons.workspace_premium_outlined,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: appDestinations
                .where((destination) => destination.route != '/')
                .map(
                  (destination) => SizedBox(
                    width: 240,
                    child: _DestinationPreview(destination: destination),
                  ),
                )
                .toList(),
          ),
        ),
        const Wrap(
          spacing: 24,
          runSpacing: 24,
          children: <Widget>[
            SizedBox(
              width: 342,
              child: HighlightCard(
                title: 'Why this direction works',
                icon: Icons.savings_outlined,
                bullets: <String>[
                  'No hosting bill, no database bill, and no paid LLM API keys.',
                  'Resume data can stay on-device for a stronger privacy story.',
                  'The repo still showcases architecture, UI, parsing, heuristics, and AI seams.',
                ],
              ),
            ),
            SizedBox(
              width: 342,
              child: HighlightCard(
                title: 'What makes it portfolio-ready',
                icon: Icons.account_tree_outlined,
                bullets: <String>[
                  'Feature-first Flutter structure with a real routed shell.',
                  'Deterministic ATS scoring, JD matching, and local session restore.',
                  'Report exports and publishing workflow for a public showcase.',
                ],
              ),
            ),
            SizedBox(
              width: 342,
              child: HighlightCard(
                title: 'What can grow next',
                icon: Icons.construction_rounded,
                bullets: <String>[
                  'Swap the AI fallback seam for a true local WebLLM worker.',
                  'Add richer before/after diffing and accepted rewrite state.',
                  'Capture screenshots and a short demo GIF for the repo front page.',
                ],
              ),
            ),
          ],
        ),
        const HighlightCard(
          title: 'Publishing path',
          subtitle:
              'The repo now includes a GitHub Pages workflow and is designed to stay separate from a managed company GitHub account.',
          icon: Icons.public_outlined,
          bullets: <String>[
            'Use a personal SSH key alias for this repository only.',
            'Push to a personal public GitHub repo and enable Pages via GitHub Actions.',
            'The app builds as static Flutter web output with no backend deployment cost.',
          ],
        ),
      ],
    );
  }
}

class _StartHereCard extends StatelessWidget {
  const _StartHereCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Start here in under a minute',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'The app feels best when you follow the flow left to right. '
              'If this is your first visit, use Demo. If you want real analysis, '
              'go to Upload first. The Report page only becomes useful after a '
              'resume has been loaded.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: <Widget>[
                SizedBox(
                  width: 500,
                  child: HighlightCard(
                    title: 'Quick walkthrough',
                    subtitle:
                        'Best for first-time visitors, recruiters, or screenshots.',
                    icon: Icons.play_circle_outline_rounded,
                    bullets: const <String>[
                      'Open Demo and click Seed demo into analysis.',
                      'Review Analysis, then paste a target role in Job Match.',
                      'Open AI Assist and finish on Report for exports.',
                    ],
                    child: FilledButton.icon(
                      onPressed: () => context.go('/demo'),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Open demo'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 500,
                  child: HighlightCard(
                    title: 'Use your own resume',
                    subtitle:
                        'Best when you want to test the real parser and scoring flow.',
                    icon: Icons.upload_file_rounded,
                    bullets: const <String>[
                      'Open Upload and choose a PDF or DOCX file.',
                      'Wait for the parsed snapshot, then open Analysis.',
                      'Add a job description later if you want tailoring suggestions.',
                    ],
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/upload'),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Go to upload'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroProofStrip extends StatelessWidget {
  const _HeroProofStrip();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: const <Widget>[
        SizedBox(
          width: 250,
          child: _ProofCard(
            metric: '\$0',
            label: 'backend spend',
            description:
                'Static hosting and browser-local logic keep the stack free.',
          ),
        ),
        SizedBox(
          width: 250,
          child: _ProofCard(
            metric: '100%',
            label: 'local-first flow',
            description:
                'Resume parsing, scoring, and export generation stay on-device.',
          ),
        ),
        SizedBox(
          width: 250,
          child: _ProofCard(
            metric: '4',
            label: 'product engines',
            description:
                'Parser, ATS scoring, job match, and AI Assist all work together.',
          ),
        ),
        SizedBox(
          width: 250,
          child: _ProofCard(
            metric: '3',
            label: 'export paths',
            description:
                'Copy summary, JSON download, and printable HTML export are ready.',
          ),
        ),
      ],
    );
  }
}

class _WorkflowShowcase extends StatelessWidget {
  const _WorkflowShowcase();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'End-to-end product flow',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'The repo now demonstrates a coherent sequence rather than disconnected pages.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: const <Widget>[
                _FlowStep(
                  step: '01',
                  title: 'Upload resume',
                  body:
                      'Pick a PDF or DOCX, parse it in the browser, and persist the session.',
                ),
                _FlowStep(
                  step: '02',
                  title: 'Score ATS readiness',
                  body:
                      'Run deterministic checks for sections, bullets, metrics, and scanability.',
                ),
                _FlowStep(
                  step: '03',
                  title: 'Match a target role',
                  body:
                      'Paste a job description and compare its keywords against the active resume.',
                ),
                _FlowStep(
                  step: '04',
                  title: 'Generate rewrites',
                  body:
                      'Produce structured summary and bullet rewrites with a graceful local fallback.',
                ),
                _FlowStep(
                  step: '05',
                  title: 'Export the results',
                  body:
                      'Copy the summary or download JSON and printable HTML artifacts.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BeforeAfterShowcase extends StatelessWidget {
  const _BeforeAfterShowcase();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Before vs after',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'This is the kind of improvement the product aims to make visible and trustworthy.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: const <Widget>[
                SizedBox(
                  width: 500,
                  child: _RewriteShowcase(
                    label: 'Original summary',
                    tone: _RewriteTone.original,
                    text:
                        'Flutter developer with 3 years of experience shipping internal tools, admin portals, and analytics dashboards across web and mobile.',
                  ),
                ),
                SizedBox(
                  width: 500,
                  child: _RewriteShowcase(
                    label: 'Suggested rewrite',
                    tone: _RewriteTone.rewrite,
                    text:
                        'Engineer with 3 years of experience focused on Flutter, analytics dashboards, web product delivery, and internal tools. Builds clear user and operational experiences, collaborates closely across product and design, and keeps execution factual and outcome-oriented.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofCard extends StatelessWidget {
  const _ProofCard({
    required this.metric,
    required this.label,
    required this.description,
  });

  final String metric;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(metric, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.step,
    required this.title,
    required this.body,
  });

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(step, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

enum _RewriteTone { original, rewrite }

class _RewriteShowcase extends StatelessWidget {
  const _RewriteShowcase({
    required this.label,
    required this.text,
    required this.tone,
  });

  final String label;
  final String text;
  final _RewriteTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _RewriteTone.original => const Color(0xFFE9DED1),
      _RewriteTone.rewrite => const Color(0xFFDCE9DE),
    };

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _DestinationPreview extends StatelessWidget {
  const _DestinationPreview({required this.destination});

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.go(destination.route),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              destination.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              destination.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              destination.subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
