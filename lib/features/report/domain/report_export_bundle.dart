class ReportExportBundle {
  const ReportExportBundle({
    required this.fileStem,
    required this.summaryText,
    required this.jsonContent,
    required this.htmlContent,
  });

  final String fileStem;
  final String summaryText;
  final String jsonContent;
  final String htmlContent;
}
