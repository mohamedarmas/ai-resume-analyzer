import 'package:ai_resume_analyzer/core/constants/app_copy.dart';
import 'package:flutter/material.dart';

class AppPageLayout extends StatelessWidget {
  const AppPageLayout({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.children,
    this.headerAction,
    this.badges = const <String>[],
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final List<Widget> children;
  final Widget? headerAction;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _StatusBanner(message: scaffoldStatus),
              const SizedBox(height: 28),
              Text(
                eyebrow.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 2.2,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: _buildHeaderChildren(context),
              ),
              if (badges.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: badges
                      .map((badge) => Chip(label: Text(badge)))
                      .toList(),
                ),
              ],
              const SizedBox(height: 32),
              ..._spaceChildren(children),
            ],
          ),
        ),
      ),
    );
  }
}

extension on AppPageLayout {
  List<Widget> _buildHeaderChildren(BuildContext context) {
    final children = <Widget>[
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 740),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    ];

    if (headerAction != null) {
      children.add(headerAction!);
    }

    return children;
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

List<Widget> _spaceChildren(List<Widget> children) {
  return <Widget>[
    for (var index = 0; index < children.length; index++) ...<Widget>[
      children[index],
      if (index != children.length - 1) const SizedBox(height: 24),
    ],
  ];
}
