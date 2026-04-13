import 'package:flutter/material.dart';

class AppDestination {
  const AppDestination({
    required this.label,
    required this.route,
    required this.icon,
    required this.subtitle,
  });

  final String label;
  final String route;
  final IconData icon;
  final String subtitle;
}

const appDestinations = <AppDestination>[
  AppDestination(
    label: 'Home',
    route: '/',
    icon: Icons.auto_awesome_mosaic_rounded,
    subtitle: 'Narrative and launchpad',
  ),
  AppDestination(
    label: 'Upload',
    route: '/upload',
    icon: Icons.upload_file_rounded,
    subtitle: 'Browser-only intake pipeline',
  ),
  AppDestination(
    label: 'Analysis',
    route: '/analysis',
    icon: Icons.analytics_rounded,
    subtitle: 'ATS scoring and issue detection',
  ),
  AppDestination(
    label: 'Job Match',
    route: '/job-match',
    icon: Icons.track_changes_rounded,
    subtitle: 'Role targeting and keyword gaps',
  ),
  AppDestination(
    label: 'AI Assist',
    route: '/ai-assist',
    icon: Icons.psychology_alt_rounded,
    subtitle: 'Local rewrite and tailoring prompts',
  ),
  AppDestination(
    label: 'Report',
    route: '/report',
    icon: Icons.inventory_2_rounded,
    subtitle: 'Exports and recruiter handoff',
  ),
  AppDestination(
    label: 'Demo',
    route: '/demo',
    icon: Icons.play_circle_outline_rounded,
    subtitle: 'Sample flow for portfolio viewers',
  ),
  AppDestination(
    label: 'Settings',
    route: '/settings',
    icon: Icons.tune_rounded,
    subtitle: 'Capabilities and local data controls',
  ),
];
