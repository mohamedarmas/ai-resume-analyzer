@JS()
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/core/models/resume_file_type.dart';
import 'package:ai_resume_analyzer/features/upload/data/resume_parser.dart';
import 'package:ai_resume_analyzer/features/upload/data/resume_parser_exception.dart';

ResumeParser createResumeParser() => const BrowserResumeParser();

@JS('resumeAnalyzer.parsePdf')
external JSPromise<JSAny?> _parsePdf(JSUint8Array data);

@JS('resumeAnalyzer.parseDocx')
external JSPromise<JSAny?> _parseDocx(JSUint8Array data);

class BrowserResumeParser implements ResumeParser {
  const BrowserResumeParser();

  @override
  Future<ResumeDocument> parse({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final fileType = ResumeFileType.fromFileName(fileName);

    try {
      final result = switch (fileType) {
        ResumeFileType.pdf => await _parsePdf(bytes.toJS).toDart,
        ResumeFileType.docx => await _parseDocx(bytes.toJS).toDart,
      };

      if (result == null) {
        throw const ResumeParserException(
          'The parser bridge returned an empty response.',
        );
      }

      final map = result.dartify() as Map<Object?, Object?>;
      final rawText = (map['rawText'] as String? ?? '').trim();

      if (rawText.isEmpty) {
        throw const ResumeParserException(
          'The file parsed successfully, but no resume text was extracted.',
        );
      }

      final characterCount = _toInt(map['charCount']) ?? rawText.length;

      return ResumeDocument(
        id: '${DateTime.now().microsecondsSinceEpoch}-${fileName.toLowerCase()}',
        fileName: fileName,
        fileType: fileType,
        rawText: rawText,
        parser: (map['parser'] as String?) ?? 'browser-parser',
        byteSize: bytes.lengthInBytes,
        pageCount: _toInt(map['pageCount']) ?? 1,
        characterCount: characterCount,
        wordCount: _countWords(rawText),
        createdAt: DateTime.now(),
        notes: _readMessages(map['messages']),
      );
    } on ResumeParserException {
      rethrow;
    } catch (error) {
      throw ResumeParserException(
        'Failed to parse $fileName locally. ${error.toString()}',
      );
    }
  }
}

int _countWords(String value) {
  return value.split(RegExp(r'\s+')).where((chunk) => chunk.isNotEmpty).length;
}

int? _toInt(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return null;
}

List<String> _readMessages(Object? value) {
  if (value is! List<Object?>) {
    return const <String>[];
  }

  return value.whereType<String>().toList(growable: false);
}
