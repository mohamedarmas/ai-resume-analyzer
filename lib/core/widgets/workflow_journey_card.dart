import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkflowJourneyCard extends StatelessWidget {
  const WorkflowJourneyCard({
    required this.currentRoute,
    required this.hasResume,
    required this.hasJobDescription,
    required this.hasExport,
    super.key,
  });

  final String currentRoute;
  final bool hasResume;
  final bool hasJobDescription;
  final bool hasExport;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    final actions = _buildActions();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Recommended path',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              _summaryText(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _SessionChip(
                  label: hasResume ? 'Resume loaded' : 'No resume yet',
                  tone: hasResume ? _StepTone.complete : _StepTone.current,
                ),
                _SessionChip(
                  label: hasJobDescription
                      ? 'Target role added'
                      : 'Job match optional next',
                  tone: hasJobDescription
                      ? _StepTone.complete
                      : _StepTone.ready,
                ),
                _SessionChip(
                  label: hasExport ? 'Export ready' : 'Export waits on resume',
                  tone: hasExport ? _StepTone.complete : _StepTone.locked,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: steps
                  .map(
                    (step) => SizedBox(
                      width: 200,
                      child: _StepCard(step: step),
                    ),
                  )
                  .toList(growable: false),
            ),
            if (actions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: actions
                    .map(
                      (action) => action.isPrimary
                          ? FilledButton.icon(
                              onPressed: () => context.go(action.route),
                              icon: Icon(action.icon),
                              label: Text(action.label),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => context.go(action.route),
                              icon: Icon(action.icon),
                              label: Text(action.label),
                            ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _summaryText() {
    if (!hasResume) {
      return 'Nothing is loaded yet. Start with Upload for a real resume or '
          'Demo for a guided walkthrough, then follow the steps left to right.';
    }

    if (!hasJobDescription) {
      return 'Your resume is already loaded. Analysis and Report work now, '
          'but adding a job description will unlock stronger targeting advice.';
    }

    return 'Your resume and target role are loaded. Review the rewrite '
        'suggestions in AI Assist, then export the report.';
  }

  List<_JourneyStep> _buildSteps() {
    final onAnalysis = _matches('/analysis');
    final onJobMatch = _matches('/job-match');
    final onAiAssist = _matches('/ai-assist');
    final onReport = _matches('/report');

    return <_JourneyStep>[
      _JourneyStep(
        number: '01',
        title: 'Upload',
        hint: 'Load a PDF, DOCX, or demo resume.',
        route: '/upload',
        tone: _matches('/upload')
            ? _StepTone.current
            : hasResume
            ? _StepTone.complete
            : _StepTone.ready,
      ),
      _JourneyStep(
        number: '02',
        title: 'Analysis',
        hint: 'Review ATS score and priority fixes.',
        route: '/analysis',
        tone: !hasResume
            ? _StepTone.locked
            : onAnalysis
            ? _StepTone.current
            : (onJobMatch || onAiAssist || onReport)
            ? _StepTone.complete
            : _StepTone.ready,
      ),
      _JourneyStep(
        number: '03',
        title: 'Job Match',
        hint: 'Paste a target role to compare keywords.',
        route: '/job-match',
        tone: !hasResume
            ? _StepTone.locked
            : onJobMatch
            ? _StepTone.current
            : (hasJobDescription && (onAiAssist || onReport))
            ? _StepTone.complete
            : _StepTone.ready,
      ),
      _JourneyStep(
        number: '04',
        title: 'AI Assist',
        hint: 'Use summary and bullet rewrite suggestions.',
        route: '/ai-assist',
        tone: !hasResume
            ? _StepTone.locked
            : onAiAssist
            ? _StepTone.current
            : onReport
            ? _StepTone.complete
            : _StepTone.ready,
      ),
      _JourneyStep(
        number: '05',
        title: 'Report',
        hint: 'Copy the summary or download exports.',
        route: '/report',
        tone: !hasResume
            ? _StepTone.locked
            : onReport
            ? _StepTone.current
            : hasExport
            ? _StepTone.ready
            : _StepTone.locked,
      ),
    ];
  }

  List<_JourneyAction> _buildActions() {
    if (!hasResume) {
      return const <_JourneyAction>[
        _JourneyAction(
          label: 'Upload resume',
          route: '/upload',
          icon: Icons.upload_file_rounded,
          isPrimary: true,
        ),
        _JourneyAction(
          label: 'Use demo flow',
          route: '/demo',
          icon: Icons.play_circle_outline_rounded,
        ),
      ];
    }

    if (_matches('/upload')) {
      return const <_JourneyAction>[
        _JourneyAction(
          label: 'Open analysis',
          route: '/analysis',
          icon: Icons.analytics_rounded,
          isPrimary: true,
        ),
        _JourneyAction(
          label: 'Add target role',
          route: '/job-match',
          icon: Icons.track_changes_rounded,
        ),
      ];
    }

    if (_matches('/analysis')) {
      return <_JourneyAction>[
        _JourneyAction(
          label: hasJobDescription ? 'Open AI assist' : 'Add target role',
          route: hasJobDescription ? '/ai-assist' : '/job-match',
          icon: hasJobDescription
              ? Icons.psychology_alt_rounded
              : Icons.track_changes_rounded,
          isPrimary: true,
        ),
        const _JourneyAction(
          label: 'Open report',
          route: '/report',
          icon: Icons.inventory_2_rounded,
        ),
      ];
    }

    if (_matches('/job-match')) {
      return <_JourneyAction>[
        _JourneyAction(
          label: hasJobDescription ? 'Open AI assist' : 'Back to analysis',
          route: hasJobDescription ? '/ai-assist' : '/analysis',
          icon: hasJobDescription
              ? Icons.psychology_alt_rounded
              : Icons.analytics_rounded,
          isPrimary: true,
        ),
        const _JourneyAction(
          label: 'Open report',
          route: '/report',
          icon: Icons.inventory_2_rounded,
        ),
      ];
    }

    if (_matches('/ai-assist')) {
      return const <_JourneyAction>[
        _JourneyAction(
          label: 'Open report',
          route: '/report',
          icon: Icons.inventory_2_rounded,
          isPrimary: true,
        ),
        _JourneyAction(
          label: 'Back to job match',
          route: '/job-match',
          icon: Icons.track_changes_rounded,
        ),
      ];
    }

    if (_matches('/report')) {
      return <_JourneyAction>[
        _JourneyAction(
          label: hasJobDescription ? 'Refine in AI assist' : 'Add target role',
          route: hasJobDescription ? '/ai-assist' : '/job-match',
          icon: hasJobDescription
              ? Icons.psychology_alt_rounded
              : Icons.track_changes_rounded,
          isPrimary: true,
        ),
        const _JourneyAction(
          label: 'Load another resume',
          route: '/upload',
          icon: Icons.upload_file_rounded,
        ),
      ];
    }

    return const <_JourneyAction>[];
  }

  bool _matches(String route) {
    if (route == '/') {
      return currentRoute == '/';
    }

    return currentRoute.startsWith(route);
  }
}

class _JourneyStep {
  const _JourneyStep({
    required this.number,
    required this.title,
    required this.hint,
    required this.route,
    required this.tone,
  });

  final String number;
  final String title;
  final String hint;
  final String route;
  final _StepTone tone;
}

class _JourneyAction {
  const _JourneyAction({
    required this.label,
    required this.route,
    required this.icon,
    this.isPrimary = false,
  });

  final String label;
  final String route;
  final IconData icon;
  final bool isPrimary;
}

enum _StepTone { complete, current, ready, locked }

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});

  final _JourneyStep step;

  @override
  Widget build(BuildContext context) {
    final tone = _colorsFor(context, step.tone);

    return Material(
      color: tone.background,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: step.tone == _StepTone.locked
            ? null
            : () => context.go(step.route),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: tone.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: tone.badgeBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step.number,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: tone.badgeForeground,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _StatusPill(tone: step.tone),
                ],
              ),
              const SizedBox(height: 16),
              Text(step.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(step.hint, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.tone});

  final _StepTone tone;

  @override
  Widget build(BuildContext context) {
    final toneColors = _colorsFor(context, tone);
    final label = switch (tone) {
      _StepTone.complete => 'Done',
      _StepTone.current => 'Now',
      _StepTone.ready => 'Ready',
      _StepTone.locked => 'Locked',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: toneColors.badgeBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: toneColors.badgeForeground,
        ),
      ),
    );
  }
}

class _SessionChip extends StatelessWidget {
  const _SessionChip({required this.label, required this.tone});

  final String label;
  final _StepTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(context, tone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.badgeForeground,
        ),
      ),
    );
  }
}

class _TonePalette {
  const _TonePalette({
    required this.background,
    required this.border,
    required this.badgeBackground,
    required this.badgeForeground,
  });

  final Color background;
  final Color border;
  final Color badgeBackground;
  final Color badgeForeground;
}

_TonePalette _colorsFor(BuildContext context, _StepTone tone) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (tone) {
    _StepTone.complete => _TonePalette(
      background: const Color(0xFFF1F6EE),
      border: const Color(0xFFC9DAC0),
      badgeBackground: const Color(0xFFDDEAD5),
      badgeForeground: const Color(0xFF355D33),
    ),
    _StepTone.current => _TonePalette(
      background: colorScheme.primary.withValues(alpha: 0.08),
      border: colorScheme.primary.withValues(alpha: 0.22),
      badgeBackground: colorScheme.primary,
      badgeForeground: colorScheme.onPrimary,
    ),
    _StepTone.ready => _TonePalette(
      background: colorScheme.secondary.withValues(alpha: 0.08),
      border: colorScheme.secondary.withValues(alpha: 0.18),
      badgeBackground: colorScheme.secondary.withValues(alpha: 0.16),
      badgeForeground: colorScheme.primary,
    ),
    _StepTone.locked => _TonePalette(
      background: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
      border: colorScheme.outline.withValues(alpha: 0.6),
      badgeBackground: colorScheme.surfaceContainerHighest,
      badgeForeground: colorScheme.onSurfaceVariant,
    ),
  };
}
