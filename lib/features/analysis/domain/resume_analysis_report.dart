enum AnalysisSeverity {
  low('Low'),
  medium('Medium'),
  high('High');

  const AnalysisSeverity(this.label);

  final String label;
}

class AnalysisCategoryScore {
  const AnalysisCategoryScore({
    required this.label,
    required this.score,
    required this.summary,
  });

  final String label;
  final int score;
  final String summary;
}

class AnalysisIssue {
  const AnalysisIssue({
    required this.title,
    required this.description,
    required this.recommendation,
    required this.severity,
  });

  final String title;
  final String description;
  final String recommendation;
  final AnalysisSeverity severity;
}

class ResumeAnalysisReport {
  const ResumeAnalysisReport({
    required this.overallScore,
    required this.summary,
    required this.categoryScores,
    required this.strengths,
    required this.issues,
    required this.detectedSections,
    required this.missingSections,
    required this.bulletCount,
    required this.actionVerbBulletCount,
    required this.quantifiedBulletCount,
    required this.contactSignalCount,
    required this.longLineCount,
  });

  final int overallScore;
  final String summary;
  final List<AnalysisCategoryScore> categoryScores;
  final List<String> strengths;
  final List<AnalysisIssue> issues;
  final List<String> detectedSections;
  final List<String> missingSections;
  final int bulletCount;
  final int actionVerbBulletCount;
  final int quantifiedBulletCount;
  final int contactSignalCount;
  final int longLineCount;
}
