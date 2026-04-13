enum ResumeFileType {
  pdf('pdf', 'PDF'),
  docx('docx', 'DOCX');

  const ResumeFileType(this.extension, this.label);

  final String extension;
  final String label;

  static ResumeFileType fromFileName(String fileName) {
    final normalized = fileName.toLowerCase().trim();

    if (normalized.endsWith('.pdf')) {
      return ResumeFileType.pdf;
    }

    if (normalized.endsWith('.docx')) {
      return ResumeFileType.docx;
    }

    throw FormatException(
      'Unsupported file type. Please choose a PDF or DOCX resume.',
    );
  }
}
