import 'dart:typed_data';

import 'package:ai_resume_analyzer/core/models/resume_document.dart';

abstract class ResumeParser {
  Future<ResumeDocument> parse({
    required String fileName,
    required Uint8List bytes,
  });
}
