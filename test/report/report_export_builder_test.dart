import 'dart:convert';

import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/core/models/resume_file_type.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_assist_generator.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analyzer.dart';
import 'package:ai_resume_analyzer/features/demo/data/demo_resume_seed.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:ai_resume_analyzer/features/report/domain/report_export_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportExportBuilder', () {
    const builder = ReportExportBuilder();
    const analysisEngine = ResumeAnalyzer();
    const jobEngine = JobMatchAnalyzer();
    const aiEngine = AiAssistGenerator();

    test('builds json and html exports from live state', () {
      final document = ResumeDocument(
        id: 'demo',
        fileName: 'aarav-mehta-resume.pdf',
        fileType: ResumeFileType.pdf,
        rawText: demoResumeRawText,
        parser: 'demo',
        byteSize: demoResumeRawText.length,
        pageCount: 1,
        characterCount: demoResumeRawText.length,
        wordCount: demoResumeRawText.split(RegExp(r'\s+')).length,
        createdAt: DateTime(2026, 4, 13),
      );
      final analysis = analysisEngine.analyze(document);
      final jobMatch = jobEngine.analyze(
        resume: document,
        jobDescription:
            'Frontend Engineer focused on Flutter web, analytics dashboards, '
            'testing discipline, and product collaboration.',
      );
      final aiPlan = aiEngine.buildPlan(
        resume: document,
        analysis: analysis,
        jobMatch: jobMatch,
      );

      final bundle = builder.build(
        resume: document,
        analysis: analysis,
        jobMatch: jobMatch,
        aiPlan: aiPlan,
      );

      final jsonMap = jsonDecode(bundle.jsonContent) as Map<String, Object?>;

      expect(bundle.summaryText, contains('Overall ATS score'));
      expect(bundle.htmlContent, contains('<html'));
      expect(bundle.fileStem, 'aarav-mehta-resume');
      expect(jsonMap['analysis'], isNotNull);
      expect(bundle.htmlContent, contains('AI Resume Analyzer Report'));
    });
  });
}
