import 'dart:typed_data';

import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/features/upload/data/resume_parser.dart';
import 'package:ai_resume_analyzer/features/upload/data/resume_parser_exception.dart';

ResumeParser createResumeParser() => const UnsupportedResumeParser();

class UnsupportedResumeParser implements ResumeParser {
  const UnsupportedResumeParser();

  @override
  Future<ResumeDocument> parse({
    required String fileName,
    required Uint8List bytes,
  }) async {
    throw const ResumeParserException(
      'Resume parsing is only available in the web build of this app.',
    );
  }
}
