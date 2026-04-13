import 'package:ai_resume_analyzer/core/models/resume_document.dart';

class SessionSnapshot {
  const SessionSnapshot({required this.jobDescription, this.document});

  final ResumeDocument? document;
  final String jobDescription;

  bool get isEmpty => document == null && jobDescription.trim().isEmpty;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'jobDescription': jobDescription,
      'document': document?.toMap(),
    };
  }

  factory SessionSnapshot.fromMap(Map<Object?, Object?> map) {
    final documentMap = map['document'];

    return SessionSnapshot(
      jobDescription: map['jobDescription'] as String? ?? '',
      document: documentMap is Map<Object?, Object?>
          ? ResumeDocument.fromMap(documentMap)
          : null,
    );
  }
}
