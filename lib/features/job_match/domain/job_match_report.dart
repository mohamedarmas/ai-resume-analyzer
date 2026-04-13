class JobMatchReport {
  const JobMatchReport({
    required this.matchScore,
    required this.targetKeywords,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.tailoringSuggestions,
    required this.roleSignal,
  });

  final int matchScore;
  final List<String> targetKeywords;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final List<String> tailoringSuggestions;
  final String roleSignal;
}
