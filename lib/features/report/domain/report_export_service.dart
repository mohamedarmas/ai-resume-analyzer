import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportExportServiceProvider = Provider<ReportExportService>((ref) {
  return const DefaultReportExportService();
});

abstract class ReportExportService {
  Future<void> copyText(String text);

  Future<void> downloadJson({
    required String fileStem,
    required String content,
  });

  Future<void> downloadHtml({
    required String fileStem,
    required String content,
  });
}

class DefaultReportExportService implements ReportExportService {
  const DefaultReportExportService();

  @override
  Future<void> copyText(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Future<void> downloadJson({
    required String fileStem,
    required String content,
  }) {
    return _downloadFile(
      fileName: '${fileStem.isEmpty ? 'resume-report' : fileStem}-report.json',
      content: content,
    );
  }

  @override
  Future<void> downloadHtml({
    required String fileStem,
    required String content,
  }) {
    return _downloadFile(
      fileName: '${fileStem.isEmpty ? 'resume-report' : fileStem}-report.html',
      content: content,
    );
  }

  Future<void> _downloadFile({
    required String fileName,
    required String content,
  }) {
    return FilePicker.saveFile(
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(content)),
    );
  }
}
