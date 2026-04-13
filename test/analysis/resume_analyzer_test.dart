import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/core/models/resume_file_type.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analyzer.dart';
import 'package:ai_resume_analyzer/features/demo/data/demo_resume_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResumeAnalyzer', () {
    const analyzer = ResumeAnalyzer();

    test('scores the bundled demo resume with useful strengths', () {
      final report = analyzer.analyze(
        ResumeDocument(
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
      );

      expect(report.overallScore, greaterThan(70));
      expect(report.detectedSections, contains('experience'));
      expect(report.strengths, isNotEmpty);
      expect(
        report.issues.any((issue) => issue.title.contains('Impact')),
        isFalse,
      );
    });

    test('flags missing sections and weak structure', () {
      const rawText = '''
John Doe
john@example.com

Worked on apps for clients and helped ship features quickly.
Responsible for development, meetings, and support.
''';

      final report = analyzer.analyze(
        ResumeDocument(
          id: 'weak',
          fileName: 'weak.pdf',
          fileType: ResumeFileType.pdf,
          rawText: rawText,
          parser: 'demo',
          byteSize: rawText.length,
          pageCount: 1,
          characterCount: rawText.length,
          wordCount: rawText.split(RegExp(r'\s+')).length,
          createdAt: DateTime(2026, 4, 13),
        ),
      );

      expect(report.overallScore, lessThan(60));
      expect(report.missingSections, contains('experience'));
      expect(
        report.issues.any((issue) => issue.severity.name == 'high'),
        isTrue,
      );
    });
  });
}
