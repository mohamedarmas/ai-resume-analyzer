import 'package:ai_resume_analyzer/core/models/resume_document.dart';
import 'package:ai_resume_analyzer/core/models/resume_file_type.dart';
import 'package:ai_resume_analyzer/features/demo/data/demo_resume_seed.dart';
import 'package:ai_resume_analyzer/features/upload/data/resume_parser.dart';
import 'package:ai_resume_analyzer/features/upload/data/resume_parser_exception.dart';
import 'package:ai_resume_analyzer/features/upload/data/resume_parser_factory.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resumeParserProvider = Provider<ResumeParser>((ref) {
  return createResumeParser();
});

final uploadControllerProvider =
    NotifierProvider<UploadController, UploadState>(UploadController.new);

enum UploadStage { idle, picking, parsing, ready, failure }

class UploadState {
  const UploadState({
    this.stage = UploadStage.idle,
    this.document,
    this.statusMessage,
    this.errorMessage,
  });

  final UploadStage stage;
  final ResumeDocument? document;
  final String? statusMessage;
  final String? errorMessage;

  bool get isBusy =>
      stage == UploadStage.picking || stage == UploadStage.parsing;

  bool get hasDocument => document != null;

  UploadState copyWith({
    UploadStage? stage,
    ResumeDocument? document,
    bool clearDocument = false,
    String? statusMessage,
    bool clearStatus = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UploadState(
      stage: stage ?? this.stage,
      document: clearDocument ? null : (document ?? this.document),
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class UploadController extends Notifier<UploadState> {
  @override
  UploadState build() => const UploadState();

  Future<void> pickResume() async {
    final previousDocument = state.document;

    state = state.copyWith(
      stage: UploadStage.picking,
      statusMessage: 'Choose a PDF or DOCX resume to parse locally.',
      clearError: true,
    );

    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: const <String>['pdf', 'docx'],
      );

      if (result == null) {
        state = UploadState(
          stage: previousDocument == null
              ? UploadStage.idle
              : UploadStage.ready,
          document: previousDocument,
          statusMessage: 'File selection cancelled.',
        );
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        state = UploadState(
          stage: previousDocument == null
              ? UploadStage.failure
              : UploadStage.ready,
          document: previousDocument,
          errorMessage:
              'The selected file did not expose readable bytes in the browser.',
        );
        return;
      }

      state = state.copyWith(
        stage: UploadStage.parsing,
        statusMessage: 'Parsing ${file.name} in the browser...',
        clearError: true,
      );

      final document = await ref
          .read(resumeParserProvider)
          .parse(fileName: file.name, bytes: bytes);

      state = UploadState(
        stage: UploadStage.ready,
        document: document,
        statusMessage: 'Parsed ${document.fileName} with ${document.parser}.',
      );
    } on FormatException catch (error) {
      _setFailure(previousDocument, error.toString());
    } on ResumeParserException catch (error) {
      _setFailure(previousDocument, error.message);
    } catch (error) {
      _setFailure(
        previousDocument,
        'Something unexpected happened while parsing the resume. ${error.toString()}',
      );
    }
  }

  Future<void> loadDemoResume() async {
    state = state.copyWith(
      stage: UploadStage.parsing,
      statusMessage: 'Loading bundled sample resume...',
      clearError: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 150));

    final rawText = demoResumeRawText.trim();
    final document = ResumeDocument(
      id: 'demo-resume',
      fileName: 'aarav-mehta-resume.pdf',
      fileType: ResumeFileType.pdf,
      rawText: rawText,
      parser: 'demo-seed',
      byteSize: rawText.length,
      pageCount: 1,
      characterCount: rawText.length,
      wordCount: rawText
          .split(RegExp(r'\s+'))
          .where((chunk) => chunk.isNotEmpty)
          .length,
      createdAt: DateTime.now(),
      notes: const <String>[
        'This is bundled sample data for a portfolio-friendly walkthrough.',
      ],
      isDemo: true,
    );

    state = UploadState(
      stage: UploadStage.ready,
      document: document,
      statusMessage: 'Sample resume loaded into the session.',
    );
  }

  void clearSession() {
    state = const UploadState(
      statusMessage: 'The current resume session has been cleared.',
    );
  }

  void restoreDocument(ResumeDocument document) {
    state = UploadState(
      stage: UploadStage.ready,
      document: document,
      statusMessage: 'Restored the previous local resume session.',
    );
  }

  void _setFailure(ResumeDocument? previousDocument, String message) {
    state = UploadState(
      stage: previousDocument == null ? UploadStage.failure : UploadStage.ready,
      document: previousDocument,
      errorMessage: message,
      statusMessage: previousDocument == null
          ? 'Upload failed before any resume was loaded.'
          : 'Upload failed, but the previous parsed resume is still available.',
    );
  }
}
