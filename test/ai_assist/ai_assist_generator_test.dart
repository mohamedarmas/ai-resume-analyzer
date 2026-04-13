import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/core/models/resume_file_type.dart';
import 'package:ai_resume_analyzer/features/ai_assist/domain/ai_assist_generator.dart';
import 'package:ai_resume_analyzer/features/analysis/domain/resume_analyzer.dart';
import 'package:ai_resume_analyzer/features/demo/data/demo_resume_seed.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiAssistGenerator', () {
    const generator = AiAssistGenerator();
    const analysisEngine = ResumeAnalyzer();
    const jobEngine = JobMatchAnalyzer();

    test('builds a deterministic rewrite plan from resume and job match', () {
      final document = ResumeDocument(
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
      );

      final analysis = analysisEngine.analyze(document);
      final jobMatch = jobEngine.analyze(
        resume: document,
        jobDescription:
            'Frontend Engineer focused on Flutter web, analytics dashboards, '
            'testing discipline, and product collaboration.',
      );

      final plan = generator.buildPlan(
        resume: document,
        analysis: analysis,
        jobMatch: jobMatch,
      );

      expect(plan.summaryRewrite.rewrittenText, isNotEmpty);
      expect(plan.tailoringSuggestions, isNotEmpty);
      expect(
        plan.promptPreviews.map((prompt) => prompt.label),
        contains('summary_rewrite'),
      );
    });
  });
}
