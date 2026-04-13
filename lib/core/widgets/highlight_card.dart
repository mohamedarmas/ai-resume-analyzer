import 'package:flutter/material.dart';

class HighlightCard extends StatelessWidget {
  const HighlightCard({
    required this.title,
    required this.icon,
    this.subtitle,
    this.bullets = const <String>[],
    this.child,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final List<String> bullets;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle case final subtitle?) ...<Widget>[
              const SizedBox(height: 10),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (bullets.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              for (final bullet in bullets) _BulletLine(text: bullet),
            ],
            if (child case final child?) ...<Widget>[
              const SizedBox(height: 18),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
