class ResumeParserException implements Exception {
  const ResumeParserException(this.message);

  final String message;

  @override
  String toString() => message;
}
