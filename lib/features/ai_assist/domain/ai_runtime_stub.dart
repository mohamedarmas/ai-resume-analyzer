import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_capability.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_runtime.dart';

AiRuntime createAiRuntime() => const UnsupportedAiRuntime();

class UnsupportedAiRuntime implements AiRuntime {
  const UnsupportedAiRuntime();

  @override
  Future<AiCapability> getCapability() async {
    return const AiCapability(
      supported: false,
      webGpuAvailable: false,
      workerReady: false,
      provider: 'unsupported',
    );
  }
}
