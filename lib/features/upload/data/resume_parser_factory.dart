import 'package:ai_resume_analyzer/features/upload/data/resume_parser.dart';

import 'resume_parser_stub.dart'
    if (dart.library.js_interop) 'resume_parser_web.dart'
    as parser_impl;

ResumeParser createResumeParser() => parser_impl.createResumeParser();
