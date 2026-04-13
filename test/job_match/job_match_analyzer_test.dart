import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/core/models/resume_file_type.dart';
import 'package:ai_resume_analyzer/features/demo/data/demo_resume_seed.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JobMatchAnalyzer', () {
    const analyzer = JobMatchAnalyzer();

    test('finds meaningful matches for a related Flutter role', () {
      final report = analyzer.analyze(
        resume: ResumeDocument(
          id: 'demo',
          fileName: 'demo.pdf',
          fileType: ResumeFileType.pdf,
          rawText: demoResumeRawText,
          parser: 'demo',
          byteSize: demoResumeRawText.length,
          pageCount: 1,
          characterCount: demoResumeRawText.length,
          wordCount: demoResumeRawText.split(RegExp(r'\s+')).length,
          createdAt: DateTime(2026, 4, 13),
        ),
        jobDescription:
            'Frontend Engineer focused on Flutter web, analytics dashboards, '
            'developer tooling, testing discipline, and product collaboration.',
      );

      expect(report.matchScore, greaterThan(40));
      expect(report.matchedKeywords, contains('flutter'));
      expect(report.targetKeywords, contains('analytics'));
    });
  });
}
