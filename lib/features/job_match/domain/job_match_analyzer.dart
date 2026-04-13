import 'dart:math' as math;

import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/features/job_match/domain/job_match_report.dart';
import 'package:ai_resume_analyzer/features/upload/application/upload_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final jobDescriptionProvider =
    NotifierProvider<JobDescriptionController, String>(
      JobDescriptionController.new,
    );

final jobMatchAnalyzerProvider = Provider<JobMatchAnalyzer>((ref) {
  return const JobMatchAnalyzer();
});

final jobMatchReportProvider = Provider<JobMatchReport?>((ref) {
  final document = ref.watch(uploadControllerProvider).document;
  final jobDescription = ref.watch(jobDescriptionProvider).trim();

  if (document == null || jobDescription.isEmpty) {
    return null;
  }

  return ref
      .watch(jobMatchAnalyzerProvider)
      .analyze(resume: document, jobDescription: jobDescription);
});

class JobMatchAnalyzer {
  const JobMatchAnalyzer();

  JobMatchReport analyze({
    required ResumeDocument resume,
    required String jobDescription,
  }) {
    final normalizedResume = ' ${resume.rawText.toLowerCase()} ';
    final keywords = _extractTargetKeywords(jobDescription);
    final matched = <String>[];
    final missing = <String>[];

    for (final keyword in keywords) {
      if (normalizedResume.contains(' $keyword ')) {
        matched.add(keyword);
      } else {
        missing.add(keyword);
      }
    }

    final roleSignal = _extractRoleSignal(jobDescription);
    final matchScore = keywords.isEmpty
        ? 0
        : ((matched.length / keywords.length) * 100).round().clamp(0, 100);

    final suggestions = <String>[
      if (missing.isNotEmpty)
        'Mirror the language around ${missing.take(3).join(', ')} where it truthfully matches your experience.',
      if (!matched.contains('flutter') &&
          normalizedResume.contains(' flutter ') &&
          keywords.contains('mobile'))
        'Make Flutter ownership more explicit in your summary and latest experience bullets.',
      if (matched.isNotEmpty)
        'Reuse strong matched terms like ${matched.take(3).join(', ')} in your summary or skills section.',
      if (missing.contains('testing') || missing.contains('automation'))
        'If accurate, call out QA, automated checks, or release confidence improvements more directly.',
    ];

    return JobMatchReport(
      matchScore: matchScore,
      targetKeywords: keywords,
      matchedKeywords: matched,
      missingKeywords: missing,
      tailoringSuggestions: suggestions.toSet().toList(growable: false),
      roleSignal: roleSignal,
    );
  }
}

class JobDescriptionController extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) {
    state = value;
  }

  void restore(String value) {
    state = value;
  }
}

List<String> _extractTargetKeywords(String jobDescription) {
  final normalized = jobDescription.toLowerCase();
  final counts = <String, int>{};

  for (final token in RegExp(r'[a-z][a-z+#.-]{2,}').allMatches(normalized)) {
    final word = token.group(0)!;
    if (_stopWords.contains(word)) {
      continue;
    }
    counts.update(word, (value) => value + 1, ifAbsent: () => 1);
  }

  final seededKeywords = _knownKeywords
      .where((keyword) => normalized.contains(keyword))
      .toList(growable: false);

  final frequencyKeywords = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final combined = <String>[
    ...seededKeywords,
    ...frequencyKeywords.map((entry) => entry.key),
  ];

  return combined.toSet().where((word) => word.length >= 3).take(12).toList();
}

String _extractRoleSignal(String jobDescription) {
  final firstLine = jobDescription
      .split('\n')
      .map((line) => line.trim())
      .firstWhere((line) => line.isNotEmpty, orElse: () => '');

  if (firstLine.isNotEmpty && firstLine.length <= 80) {
    return firstLine;
  }

  final keywords = _extractTargetKeywords(jobDescription);
  if (keywords.isEmpty) {
    return 'Target role not yet clear';
  }

  return 'Role focus: ${keywords.take(math.min(4, keywords.length)).join(', ')}';
}

const _knownKeywords = <String>[
  'flutter',
  'dart',
  'firebase',
  'react',
  'typescript',
  'javascript',
  'python',
  'fastapi',
  'api',
  'postgres',
  'supabase',
  'analytics',
  'dashboard',
  'testing',
  'automation',
  'web',
  'mobile',
  'ai',
  'developer',
  'tooling',
  'ux',
  'product',
];

const _stopWords = <String>{
  'with',
  'that',
  'this',
  'from',
  'have',
  'will',
  'your',
  'they',
  'them',
  'into',
  'more',
  'must',
  'should',
  'would',
  'could',
  'about',
  'their',
  'there',
  'need',
  'needs',
  'across',
  'using',
  'used',
  'build',
  'building',
  'work',
  'role',
  'team',
  'teams',
  'experience',
  'years',
  'year',
  'strong',
  'help',
  'looking',
  'ideal',
  'candidate',
  'responsible',
};
