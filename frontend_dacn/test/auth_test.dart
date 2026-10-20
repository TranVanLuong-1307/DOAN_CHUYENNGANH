import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_dacn/main.dart';

void main() {
  testWidgets('Verify Login and Logout flow and reactive UI state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const HealthExerciseApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Navigate to Profile tab ("Tôi")
    await tester.tap(find.text('Tôi').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify initial unauthenticated skeleton state
    expect(find.text('Thông tin tài khoản'), findsOneWidget);
    expect(find.text('Chưa đăng nhập'), findsOneWidget);

    // Scroll to see login button
    await tester.scrollUntilVisible(
      find.text('Đăng nhập / Đăng ký tài khoản'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('Đăng nhập / Đăng ký tài khoản'), findsOneWidget);

    // 2. Tap "Đăng nhập / Đăng ký tài khoản" to open AuthSheet
    await tester.tap(find.text('Đăng nhập / Đăng ký tài khoản'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AuthSheet tabs
    expect(find.text('Đăng ký mới'), findsOneWidget);
    expect(find.text('Đăng nhập ngay'), findsOneWidget);

    // Switch to "Đăng ký mới" tab
    await tester.tap(find.text('Đăng ký mới'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify registration fields and button without any overflow
    expect(find.text('Họ và tên'), findsOneWidget);
    expect(find.text('Tạo mật khẩu'), findsOneWidget);
    expect(find.text('Tạo tài khoản'), findsOneWidget);

    // Enter registration info
    await tester.enterText(find.widgetWithText(TextField, 'Họ và tên'), 'Trần Văn');
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'tranvan@gmail.com');
    await tester.pump();

    // Tap "Tạo tài khoản"
    await tester.tap(find.text('Tạo tài khoản'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 3. Verify logged in state
    expect(find.text('Trần Văn'), findsOneWidget);
    expect(find.text('tranvan@gmail.com'), findsOneWidget);

    // Scroll if needed to find logout button
    await tester.scrollUntilVisible(
      find.text('Đăng xuất tài khoản'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.text('Đăng xuất tài khoản'), findsOneWidget);

    // 4. Tap "Đăng xuất tài khoản"
    await tester.tap(find.text('Đăng xuất tài khoản'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify confirmation dialog
    expect(find.text('Bạn có chắc chắn muốn đăng xuất tài khoản khỏi thiết bị này không?'), findsOneWidget);

    // Confirm logout
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng xuất'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify back to logged out state
    expect(find.text('Chưa đăng nhập'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
