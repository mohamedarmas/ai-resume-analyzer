import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/core/models/resume_file_type.dart';
import 'package:ai_resume_analyzer/core/storage/session_persistence.dart';
import 'package:ai_resume_analyzer/core/storage/session_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesSessionPersistence', () {
    const persistence = SharedPreferencesSessionPersistence();

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('saves and restores the local session snapshot', () async {
      final snapshot = SessionSnapshot(
        jobDescription: 'Frontend Engineer focused on Flutter and analytics.',
        document: ResumeDocument(
          id: 'demo',
          fileName: 'resume.pdf',
          fileType: ResumeFileType.pdf,
          rawText: 'SUMMARY\nFlutter engineer building analytics dashboards.',
          parser: 'demo',
          byteSize: 1234,
          pageCount: 1,
          characterCount: 54,
          wordCount: 7,
          createdAt: DateTime(2026, 4, 13, 12, 0),
          notes: const <String>['Saved for persistence test'],
        ),
      );

      await persistence.save(snapshot);
      final restored = await persistence.load();

      expect(restored.jobDescription, contains('Flutter'));
      expect(restored.document, isNotNull);
      expect(restored.document!.fileName, 'resume.pdf');
      expect(restored.document!.notes, contains('Saved for persistence test'));
    });

    test('clears the saved snapshot', () async {
      await persistence.save(
        const SessionSnapshot(jobDescription: 'Temporary JD'),
      );

      await persistence.clear();
      final restored = await persistence.load();

      expect(restored.isEmpty, isTrue);
    });
  });
}
