import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_dacn/main.dart';

void main() {
  testWidgets('Verify interactive settings card-base items', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const HealthExerciseApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Navigate to Profile tab ("Tôi")
    await tester.tap(find.text('Tôi').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Test Mục tiêu thể chất
    await tester.scrollUntilVisible(
      find.text('Mục tiêu thể chất'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Mục tiêu thể chất'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mục tiêu thể chất hàng ngày'), findsOneWidget);
    expect(find.text('Lưu mục tiêu'), findsOneWidget);
    await tester.tap(find.text('Lưu mục tiêu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 2. Test Đồng bộ dữ liệu sức khỏe
    await tester.scrollUntilVisible(
      find.text('Đồng bộ dữ liệu sức khỏe'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Đồng bộ dữ liệu sức khỏe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Google Fit / Health Connect'), findsOneWidget);
    expect(find.text('Đồng bộ ngay bây giờ'), findsOneWidget);
    await tester.tap(find.text('Đồng bộ ngay bây giờ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Close sync sheet using close button
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 3. Test Thông báo & Nhắc nhở
    await tester.scrollUntilVisible(
      find.text('Thông báo & Nhắc nhở'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Thông báo & Nhắc nhở'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Nhắc uống nước'), findsOneWidget);
    expect(find.text('Cảnh báo ngồi lâu'), findsOneWidget);
    // Toggle switch
    await tester.tap(find.text('Nhắc uống nước'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Close reminder sheet using close button
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 4. Test Quyền riêng tư & Bảo mật
    await tester.scrollUntilVisible(
      find.text('Quyền riêng tư & Bảo mật'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Quyền riêng tư & Bảo mật'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Khóa Sinh trắc học (Vân tay / FaceID)'), findsOneWidget);
    expect(find.text('Xóa bộ nhớ đệm (42.8 MB)'), findsOneWidget);
    await tester.tap(find.text('Xóa bộ nhớ đệm (42.8 MB)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Close privacy sheet using close button
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 5. Test Về ứng dụng
    await tester.scrollUntilVisible(
      find.text('Về ứng dụng'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Về ứng dụng'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Kiểm tra bản cập nhật'), findsOneWidget);
    await tester.tap(find.text('Kiểm tra bản cập nhật'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Đóng'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('Verify gear setting button opens app permissions sheet and allows granting permissions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const HealthExerciseApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Navigate to Profile tab ("Tôi")
    await tester.tap(find.text('Tôi').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap gear settings button in header
    final gearButton = find.byKey(const Key('gear_settings_button'));
    expect(gearButton, findsOneWidget);
    await tester.tap(gearButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify PermissionsSheet is open
    expect(find.text('Cấp quyền ứng dụng'), findsWidgets);
    expect(find.textContaining('Vị trí & GPS'), findsOneWidget);
    expect(find.textContaining('Cảm biến cơ thể'), findsOneWidget);
    expect(find.textContaining('Bluetooth & Thiết bị'), findsOneWidget);
    expect(find.textContaining('Hoạt động thể chất'), findsOneWidget);
    expect(find.text('Thông báo & Nhắc nhở sức khỏe'), findsOneWidget);
    expect(find.textContaining('Tối ưu hóa tính năng'), findsOneWidget);

    // Tap "Cấp tất cả" quick action button
    await tester.tap(find.text('Cấp tất cả'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Đã cấp 7 / 7 quyền hệ thống'), findsOneWidget);

    // Close sheet
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Also verify opening via "Cài đặt & Tiện ích" menu item
    await tester.scrollUntilVisible(
      find.text('Cấp quyền ứng dụng'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Cấp quyền ứng dụng'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Đã cấp 7 / 7 quyền hệ thống'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    addTearDown(tester.view.resetPhysicalSize);
  });
}

