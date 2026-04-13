import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_runtime.dart';

import 'ai_runtime_stub.dart'
    if (dart.library.js_interop) 'ai_runtime_web.dart'
    as runtime_impl;

AiRuntime createAiRuntime() => runtime_impl.createAiRuntime();
