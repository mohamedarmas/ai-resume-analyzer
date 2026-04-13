import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_capability.dart';

abstract class AiRuntime {
  Future<AiCapability> getCapability();
}
