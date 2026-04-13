import 'package:ai_resume_analyzer/core/constants/app_copy.dart';
import 'package:ai_resume_analyzer/core/models/app_destination.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.currentLocation,
    required this.child,
    super.key,
  });

  final String currentLocation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1080;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFFF4EFE6),
            Color(0xFFF8F4EC),
            Color(0xFFEAE5D9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        drawer: isWide ? null : _AppDrawer(currentLocation: currentLocation),
        appBar: AppBar(
          toolbarHeight: 86,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(appName, style: Theme.of(context).textTheme.titleLarge),
                Text(appTagline, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          actions: <Widget>[
            if (isWide)
              const _TopBadge(
                label: 'Local-first beta',
                icon: Icons.lock_outline_rounded,
              ),
            const SizedBox(width: 12),
            const _TopBadge(
              label: 'Zero-cost stack',
              icon: Icons.savings_outlined,
            ),
            const SizedBox(width: 24),
          ],
        ),
        body: SafeArea(
          top: false,
          child: isWide
              ? Row(
                  children: <Widget>[
                    const SizedBox(width: 24),
                    _SidebarNavigation(currentLocation: currentLocation),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 24, 24),
                        child: child,
                      ),
                    ),
                  ],
                )
              : child,
        ),
      ),
    );
  }
}

class _SidebarNavigation extends StatelessWidget {
  const _SidebarNavigation({required this.currentLocation});

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedDestinationIndex(currentLocation);

    return Container(
      width: 270,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: <Widget>[
          NavigationRail(
            selectedIndex: selectedIndex,
            backgroundColor: Colors.transparent,
            extended: true,
            minExtendedWidth: 244,
            useIndicator: true,
            indicatorColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.14),
            groupAlignment: -0.85,
            destinations: appDestinations
                .map(
                  (destination) => NavigationRailDestination(
                    icon: Icon(destination.icon),
                    label: Text(destination.label),
                  ),
                )
                .toList(),
            onDestinationSelected: (index) =>
                context.go(appDestinations[index].route),
          ),
          const Spacer(),
          _SidebarNote(
            headline: 'Scaffold focus',
            body:
                'Start by wiring upload, parser bridges, and ATS scoring. The '
                'rest of the product can grow behind this shell.',
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.currentLocation});

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: <Widget>[
            ListTile(
              title: Text(
                appName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: const Text(appTagline),
            ),
            const SizedBox(height: 12),
            for (final destination in appDestinations)
              ListTile(
                leading: Icon(destination.icon),
                title: Text(destination.label),
                subtitle: Text(destination.subtitle),
                selected: _matches(currentLocation, destination.route),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(destination.route);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  const _TopBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _SidebarNote extends StatelessWidget {
  const _SidebarNote({required this.headline, required this.body});

  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(headline, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

int _selectedDestinationIndex(String currentLocation) {
  final index = appDestinations.indexWhere(
    (destination) => _matches(currentLocation, destination.route),
  );

  return index == -1 ? 0 : index;
}

bool _matches(String currentLocation, String route) {
  if (route == '/') {
    return currentLocation == '/';
  }

  return currentLocation.startsWith(route);
}
