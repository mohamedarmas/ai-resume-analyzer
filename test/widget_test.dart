import 'package:ai_resume_analyzer/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('landing route renders the scaffold', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ResumeAnalyzerApp()));
    await tester.pumpAndSettle();

    expect(find.text('AI Resume Analyzer'), findsWidgets);
    expect(find.text('Open live demo flow'), findsOneWidget);
    expect(find.text('End-to-end product flow'), findsOneWidget);
  });
}
