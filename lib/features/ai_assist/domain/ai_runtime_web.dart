@JS()
library;

import 'dart:js_interop';

import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_capability.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_runtime.dart';

AiRuntime createAiRuntime() => const BrowserAiRuntime();

@JS('resumeAnalyzer.getAiCapability')
external JSPromise<JSAny?> _getAiCapability();

class BrowserAiRuntime implements AiRuntime {
  const BrowserAiRuntime();

  @override
  Future<AiCapability> getCapability() async {
    final result = await _getAiCapability().toDart;
    final map = (result?.dartify() as Map<Object?, Object?>?) ?? const {};

    return AiCapability(
      supported: map['supported'] as bool? ?? false,
      webGpuAvailable: map['webGpuAvailable'] as bool? ?? false,
      workerReady: map['workerReady'] as bool? ?? false,
      provider: map['provider'] as String? ?? 'unknown',
    );
  }
}
