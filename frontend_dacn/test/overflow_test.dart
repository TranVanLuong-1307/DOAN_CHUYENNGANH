import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_dacn/core/state/app_state.dart';
import 'package:frontend_dacn/main.dart';
import 'package:frontend_dacn/screens/profile/widgets/auth_sheet.dart';

void main() {
  testWidgets('Verify zero RenderFlex overflow across all 4 tabs on small screen',
      (WidgetTester tester) async {
    // Test on an ultra-narrow screen (320px width) with enlarged text scale (1.3x)
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(1.3),
        ),
        child: HealthExerciseApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tab 0 (Health): Verify rendered with 0 errors
    expect(find.text('Sức khỏe'), findsAtLeastNWidgets(1));
    expect(find.text('Chỉ số sức khỏe'), findsOneWidget);

    // Switch to Tab 1 (Exercise)
    await tester.tap(find.text('Bài tập').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Bài tập'), findsAtLeastNWidgets(1));

    // Switch to Tab 2 (Devices)
    await tester.tap(find.text('Thiết bị').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Thiết bị'), findsAtLeastNWidgets(1));

    // Switch to Tab 3 (Profile)
    await tester.tap(find.text('Tôi').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Tôi'), findsAtLeastNWidgets(1));

    // Reset size
    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('Verify zero RenderFlex overflow on AuthSheet with large font on small screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 560);
    tester.view.devicePixelRatio = 1.0;

    final appState = AppState();

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 560),
            textScaler: TextScaler.linear(1.3),
          ),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => AuthSheet.show(context, appState),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Open sheet
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Tab 1 (Login) renders without overflow
    expect(find.text('Đăng nhập ngay'), findsOneWidget);

    // Switch to Tab 2 (Register)
    await tester.tap(find.text('Đăng ký mới'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Tab 2 (Register) renders without overflow
    expect(find.text('Tạo tài khoản'), findsOneWidget);
    expect(find.text('Họ và tên'), findsOneWidget);
    expect(find.text('Tạo mật khẩu'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
