import 'dart:async';

import 'package:ai_resume_analyzer/app/router.dart';
import 'package:ai_resume_analyzer/app/theme.dart';
import 'package:ai_resume_analyzer/core/storage/session_persistence.dart';
import 'package:ai_resume_analyzer/core/storage/session_snapshot.dart';
import 'package:ai_resume_analyzer/features/demo/data/demo_resume_seed.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResumeAnalyzerApp extends ConsumerStatefulWidget {
  const ResumeAnalyzerApp({super.key});

  @override
  ConsumerState<ResumeAnalyzerApp> createState() => _ResumeAnalyzerAppState();
}

class _ResumeAnalyzerAppState extends ConsumerState<ResumeAnalyzerApp> {
  bool _restored = false;
  late final bool _bootstrapDemo = Uri.base.queryParameters['demo'] == '1';
  Timer? _persistDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  @override
  void dispose() {
    _persistDebounce?.cancel();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    try {
      final snapshot = await ref.read(sessionPersistenceProvider).load();
      if (!mounted) {
        return;
      }

      if (snapshot.document != null) {
        ref
            .read(uploadControllerProvider.notifier)
            .restoreDocument(snapshot.document!);
      }
      if (snapshot.jobDescription.trim().isNotEmpty) {
        ref
            .read(jobDescriptionProvider.notifier)
            .restore(snapshot.jobDescription);
      }
      if (snapshot.document == null && _shouldBootstrapDemo()) {
        await ref.read(uploadControllerProvider.notifier).loadDemoResume();
        ref.read(jobDescriptionProvider.notifier).restore(demoJobDescription);
      }
    } catch (_) {
      // If local persistence fails, the app should still boot normally.
    } finally {
      _restored = true;
    }
  }

  void _schedulePersist() {
    if (!_restored) {
      return;
    }

    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 300), () async {
      final snapshot = SessionSnapshot(
        document: ref.read(uploadControllerProvider).document,
        jobDescription: ref.read(jobDescriptionProvider),
      );
      await ref.read(sessionPersistenceProvider).save(snapshot);
    });
  }

  bool _shouldBootstrapDemo() {
    return _bootstrapDemo;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UploadState>(uploadControllerProvider, (previous, next) {
      _schedulePersist();
    });
    ref.listen<String>(jobDescriptionProvider, (previous, next) {
      _schedulePersist();
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AI Resume Analyzer',
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
