class RewriteSuggestion {
  const RewriteSuggestion({
    required this.title,
    required this.originalText,
    required this.rewrittenText,
    required this.rationale,
  });

  final String title;
  final String originalText;
  final String rewrittenText;
  final String rationale;
}

class PromptPreview {
  const PromptPreview({required this.label, required this.prompt});

  final String label;
  final String prompt;
}

class AiAssistPlan {
  const AiAssistPlan({
    required this.modeLabel,
    required this.summaryRewrite,
    required this.bulletRewrites,
    required this.tailoringSuggestions,
    required this.promptPreviews,
  });

  final String modeLabel;
  final RewriteSuggestion summaryRewrite;
  final List<RewriteSuggestion> bulletRewrites;
  final List<String> tailoringSuggestions;
  final List<PromptPreview> promptPreviews;
}
