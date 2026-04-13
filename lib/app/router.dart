import 'package:ai_resume_analyzer/core/models/app_destination.dart';
import 'package:ai_resume_analyzer/core/widgets/app_shell.dart';
import 'package:ai_resume_analyzer/features/ai_assist/presentation/ai_assist_page.dart';
import 'package:ai_resume_analyzer/features/analysis/presentation/analysis_page.dart';
import 'package:ai_resume_analyzer/features/demo/presentation/demo_page.dart';
import 'package:ai_resume_analyzer/features/job_match/presentation/job_match_page.dart';
import 'package:ai_resume_analyzer/features/landing/presentation/landing_page.dart';
import 'package:ai_resume_analyzer/features/report/presentation/report_page.dart';
import 'package:ai_resume_analyzer/features/settings/presentation/settings_page.dart';
import 'package:ai_resume_analyzer/features/upload/presentation/upload_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: _initialLocationFromQuery(),
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(currentLocation: state.uri.toString(), child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: 'landing',
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: '/upload',
          name: 'upload',
          builder: (context, state) => const UploadPage(),
        ),
        GoRoute(
          path: '/analysis',
          name: 'analysis',
          builder: (context, state) => const AnalysisPage(),
        ),
        GoRoute(
          path: '/job-match',
          name: 'job-match',
          builder: (context, state) => const JobMatchPage(),
        ),
        GoRoute(
          path: '/ai-assist',
          name: 'ai-assist',
          builder: (context, state) => const AiAssistPage(),
        ),
        GoRoute(
          path: '/report',
          name: 'report',
          builder: (context, state) => const ReportPage(),
        ),
        GoRoute(
          path: '/demo',
          name: 'demo',
          builder: (context, state) => const DemoPage(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);

String _initialLocationFromQuery() {
  final requestedRoute = Uri.base.queryParameters['route'];
  if (requestedRoute == null || requestedRoute.isEmpty) {
    return '/';
  }

  final uri = Uri.tryParse(requestedRoute);
  final path = uri?.path;
  if (uri == null || path == null || !requestedRoute.startsWith('/')) {
    return '/';
  }

  final isKnownRoute = appDestinations.any(
    (destination) => destination.route == path,
  );
  if (!isKnownRoute) {
    return '/';
  }

  return uri.toString();
}
