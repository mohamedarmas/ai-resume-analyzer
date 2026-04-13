import 'package:ai_resume_analyzer/core/models/resume_file_type.dart';

class ResumeDocument {
  ResumeDocument({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.rawText,
    required this.parser,
    required this.byteSize,
    required this.pageCount,
    required this.characterCount,
    required this.wordCount,
    required this.createdAt,
    this.notes = const <String>[],
    this.isDemo = false,
  });

  final String id;
  final String fileName;
  final ResumeFileType fileType;
  final String rawText;
  final String parser;
  final int byteSize;
  final int pageCount;
  final int characterCount;
  final int wordCount;
  final DateTime createdAt;
  final List<String> notes;
  final bool isDemo;

  String get previewText {
    final normalized = rawText
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    if (normalized.length <= 680) {
      return normalized;
    }

    return '${normalized.substring(0, 680).trimRight()}...';
  }

  String get formattedSize {
    final kilobytes = byteSize / 1024;

    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(kilobytes < 100 ? 1 : 0)} KB';
    }

    final megabytes = kilobytes / 1024;
    return '${megabytes.toStringAsFixed(1)} MB';
  }

  String get createdLabel {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-'
        '${createdAt.day.toString().padLeft(2, '0')} $hour:$minute';
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'fileName': fileName,
      'fileType': fileType.name,
      'rawText': rawText,
      'parser': parser,
      'byteSize': byteSize,
      'pageCount': pageCount,
      'characterCount': characterCount,
      'wordCount': wordCount,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'isDemo': isDemo,
    };
  }

  factory ResumeDocument.fromMap(Map<Object?, Object?> map) {
    final fileTypeName = map['fileType'] as String? ?? ResumeFileType.pdf.name;

    return ResumeDocument(
      id: map['id'] as String? ?? 'restored-resume',
      fileName: map['fileName'] as String? ?? 'restored-resume.pdf',
      fileType: ResumeFileType.values.firstWhere(
        (type) => type.name == fileTypeName,
        orElse: () => ResumeFileType.pdf,
      ),
      rawText: map['rawText'] as String? ?? '',
      parser: map['parser'] as String? ?? 'restored',
      byteSize: (map['byteSize'] as num?)?.toInt() ?? 0,
      pageCount: (map['pageCount'] as num?)?.toInt() ?? 1,
      characterCount: (map['characterCount'] as num?)?.toInt() ?? 0,
      wordCount: (map['wordCount'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      notes: (map['notes'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toList(growable: false),
      isDemo: map['isDemo'] as bool? ?? false,
    );
  }
}
