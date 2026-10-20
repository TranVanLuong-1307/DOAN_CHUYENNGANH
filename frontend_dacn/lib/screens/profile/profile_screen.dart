import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/auth_sheet.dart';
import 'widgets/permissions_sheet.dart';
import 'package:google_sign_in/google_sign_in.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 24,
          ),
          children: [
            // Screen Title with Gear Settings Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Tôi',
                  style: AppTextStyles.titleLarge,
                ),
                Material(
                  color: Colors.transparent,
                  child: Tooltip(
                    message: 'Cài đặt & Cấp quyền ứng dụng',
                    child: InkWell(
                      key: const Key('gear_settings_button'),
                      borderRadius: BorderRadius.circular(100),
                      onTap: () => PermissionsSheet.show(context, appState),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ==========================================
            // 1. CARD: THÔNG TIN TÀI KHOẢN (Account Card)
            // ==========================================
            _buildSectionHeader(
              title: 'Thông tin tài khoản',
              actionText: appState.isLoggedIn ? 'Chỉnh sửa' : 'Đăng nhập',
              onAction: () => appState.isLoggedIn
                  ? _showEditAccountSheet(context, appState)
                  : AuthSheet.show(context, appState),
            ),
            const SizedBox(height: 8),
            _buildAccountCard(context, appState),
            const SizedBox(height: 20),

            // ==========================================
            // 2. CARD: THÔNG TIN CÁ NHÂN (Personal Card)
            // ==========================================
            _buildSectionHeader(
              title: 'Thông tin cá nhân',
              actionText: 'Cập nhật',
              onAction: () => _showEditPersonalInfoSheet(context, appState),
            ),
            const SizedBox(height: 8),
            _buildPersonalInfoCard(context, appState),
            const SizedBox(height: 24),

            // ==========================================
            // 3. CÀI ĐẶT & TÙY CHỌN ỨNG DỤNG
            // ==========================================
            Text('Cài đặt & Tiện ích', style: AppTextStyles.titleMedium),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.track_changes_rounded,
                    title: 'Mục tiêu thể chất',
                    subtitle: 'Số bước, lượng calo, giấc ngủ',
                    onTap: () => _showPersonalGoalSheet(context, appState),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildMenuItem(
                    icon: Icons.sync_alt_rounded,
                    title: 'Đồng bộ dữ liệu sức khỏe',
                    subtitle: 'Google Fit, Strava, Apple Health',
                    onTap: () => _showCloudSyncSheet(context, appState),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Thông báo & Nhắc nhở',
                    subtitle: 'Nhắc uống nước, vận động',
                    onTap: () => _showReminderSheet(context, appState),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Cấp quyền ứng dụng',
                    subtitle: 'Vị trí, Bluetooth, cảm biến, thông báo',
                    onTap: () => PermissionsSheet.show(context, appState),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Quyền riêng tư & Bảo mật',
                    subtitle: 'Quản lý mã hóa dữ liệu y tế',
                    onTap: () => _showPrivacySecuritySheet(context, appState),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Về ứng dụng',
                    subtitle: 'Sức khỏe & Luyện tập v1.0 (DACN)',
                    onTap: () => _showAboutAppDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút Đăng nhập / Đăng xuất tài khoản
            if (appState.isLoggedIn)
              OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: AppColors.heartRed, size: 20),
                label: const Text(
                  'Đăng xuất tài khoản',
                  style: TextStyle(color: AppColors.heartRed, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F3),
                  side: const BorderSide(color: Color(0xFFFFD1D9)),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _confirmLogout(context, appState),
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text(
                  'Đăng nhập / Đăng ký tài khoản',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMint,
                  foregroundColor: AppColors.primaryDarkText,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => AuthSheet.show(context, appState),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // --- Section Header Helper ---
  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              actionText,
              style: AppTextStyles.bodyMint,
            ),
          ),
        ),
      ],
    );
  }

  // --- 1. ACCOUNT CARD WIDGET ---
  Widget _buildAccountCard(BuildContext context, AppState appState) {
    if (!appState.isLoggedIn) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AuthSheet.show(context, appState),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.avatarBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chưa đăng nhập',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Đăng nhập để đồng bộ dữ liệu đám mây',
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMint,
                    foregroundColor: AppColors.primaryDarkText,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => AuthSheet.show(context, appState),
                  child: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEditAccountSheet(context, appState),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              // Avatar Circle
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.avatarBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryMint,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(appState.userName),
                  style: const TextStyle(
                    color: AppColors.primaryMint,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Account Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.userName.isNotEmpty ? appState.userName : 'Người dùng',
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appState.userEmail.isNotEmpty ? appState.userEmail : 'Chưa liên kết email',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'ID: ${appState.accountId.isNotEmpty ? appState.accountId : "--"}',
                          style: AppTextStyles.tinyMuted,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.pillActive,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            appState.accountType.isNotEmpty ? appState.accountType : 'Tài khoản thường',
                            style: AppTextStyles.bodyMint.copyWith(fontSize: 9.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit Icon
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. PERSONAL INFO CARD WIDGET ---
  Widget _buildPersonalInfoCard(BuildContext context, AppState appState) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEditPersonalInfoSheet(context, appState),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4 Core Fields: Giới tính, Ngày sinh, Chiều cao, Cân nặng
              Row(
                children: [
                  Expanded(
                    child: _buildPersonalFieldItem(
                      icon: appState.gender == 'Nam'
                          ? Icons.male_rounded
                          : (appState.gender == 'Nữ' ? Icons.female_rounded : Icons.person_outline_rounded),
                      label: 'Giới tính',
                      value: appState.gender.isNotEmpty ? appState.gender : '--',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPersonalFieldItem(
                      icon: Icons.cake_outlined,
                      label: 'Ngày sinh',
                      value: appState.birthDate.isNotEmpty
                          ? (appState.age > 0 ? '${appState.birthDate} (${appState.age}t)' : appState.birthDate)
                          : '--',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildPersonalFieldItem(
                      icon: Icons.height_rounded,
                      label: 'Chiều cao',
                      value: appState.userHeightCm > 0 ? '${appState.userHeightCm.toInt()} cm' : '--',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPersonalFieldItem(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Cân nặng',
                      value: appState.weightKg > 0 ? '${appState.weightKg.toString().replaceAll(".", ",")} kg' : '--',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),

              // BMI Summary Sub-Bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.pillActive,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.accessibility_new_rounded,
                      color: AppColors.primaryMint,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.bmi > 0
                              ? 'Chỉ số khối cơ thể (BMI): ${appState.bmi.toString().replaceAll(".", ",")}'
                              : 'Chỉ số khối cơ thể (BMI): --',
                          style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          appState.bmi > 0
                              ? 'Thể trạng: ${appState.bmiStatus} · Cân đối, tiếp tục duy trì!'
                              : 'Thể trạng: Chưa có dữ liệu chiều cao & cân nặng',
                          style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryMint,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalFieldItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryMint, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.tinyMuted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL: EDIT ACCOUNT INFO ---
  void _showEditAccountSheet(BuildContext context, AppState appState) {
    final nameCtrl = TextEditingController(text: appState.userName);
    final emailCtrl = TextEditingController(text: appState.userEmail);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.account_circle_outlined, color: AppColors.primaryMint),
                  const SizedBox(width: 8),
                  Text('Chỉnh sửa thông tin tài khoản', style: AppTextStyles.titleMedium),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryMint),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Email đăng nhập',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.primaryMint),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMint,
                  foregroundColor: AppColors.primaryDarkText,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final newName = nameCtrl.text.trim();
                  final newEmail = emailCtrl.text.trim();
                  if (newName.isNotEmpty) {
                    appState.updateAccountInfo(
                      name: newName,
                      email: newEmail.isNotEmpty ? newEmail : appState.userEmail,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật thông tin tài khoản thành công!')),
                    );
                  }
                },
                child: const Text('Lưu tài khoản', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- MODAL: EDIT PERSONAL INFO (Gender, BirthDate, Height, Weight) ---
  void _showEditPersonalInfoSheet(BuildContext context, AppState appState) {
    String selectedGender = appState.gender.isNotEmpty ? appState.gender : 'Nam';
    String selectedBirthDate = appState.birthDate;
    final heightCtrl = TextEditingController(
      text: appState.userHeightCm > 0 ? appState.userHeightCm.toInt().toString() : '',
    );
    final weightCtrl = TextEditingController(
      text: appState.weightKg > 0 ? appState.weightKg.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, color: AppColors.primaryMint),
                        const SizedBox(width: 8),
                        Text('Cập nhật thông tin cá nhân', style: AppTextStyles.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 1. Giới tính
                    Text('Giới tính', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Nam', 'Nữ', 'Khác'].map((g) {
                        final isSel = selectedGender == g;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedGender = g;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primaryMint : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel ? AppColors.primaryMint : AppColors.border,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                g,
                                style: GoogleFonts.inter(
                                  color: isSel ? AppColors.primaryDarkText : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 2. Ngày sinh (DatePicker)
                    Text('Ngày sinh', style: AppTextStyles.caption),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        DateTime initial = DateTime(2001, 8, 15);
                        try {
                          final parts = selectedBirthDate.split('/');
                          if (parts.length == 3) {
                            initial = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[1]),
                              int.parse(parts[0]),
                            );
                          }
                        } catch (_) {}

                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: DateTime(1940),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primaryMint,
                                  onPrimary: AppColors.primaryDarkText,
                                  surface: AppColors.cardSurface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setModalState(() {
                            final d = picked.day.toString().padLeft(2, '0');
                            final m = picked.month.toString().padLeft(2, '0');
                            selectedBirthDate = '$d/$m/${picked.year}';
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedBirthDate,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                            ),
                            const Icon(Icons.calendar_today_rounded, color: AppColors.primaryMint, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3 & 4. Chiều cao và Cân nặng
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Chiều cao (cm)',
                              labelStyle: TextStyle(color: AppColors.textSecondary),
                              prefixIcon: Icon(Icons.height_rounded, color: AppColors.primaryMint),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Cân nặng (kg)',
                              labelStyle: TextStyle(color: AppColors.textSecondary),
                              prefixIcon: Icon(Icons.monitor_weight_outlined, color: AppColors.primaryMint),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMint,
                        foregroundColor: AppColors.primaryDarkText,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final h = double.tryParse(heightCtrl.text) ?? appState.userHeightCm;
                        final w = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? appState.weightKg;
                        appState.updatePersonalInfo(
                          newGender: selectedGender,
                          newBirthDate: selectedBirthDate,
                          newHeight: h,
                          newWeight: w,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã cập nhật thông tin cá nhân và tính lại BMI!')),
                        );
                      },
                      child: const Text('Lưu thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Other Settings Handlers ---
  void _showPersonalGoalSheet(BuildContext context, AppState appState) {
    int tempSteps = (appState.targetSteps >= 2000 && appState.targetSteps <= 25000)
        ? appState.targetSteps
        : 8000;
    int tempCalories = (appState.targetCalories >= 200 && appState.targetCalories <= 1500)
        ? appState.targetCalories
        : 500;
    int tempSleep = (appState.targetSleepHours >= 5 && appState.targetSleepHours <= 10)
        ? appState.targetSleepHours
        : 8;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.pillActive,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.track_changes_rounded, color: AppColors.primaryMint, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mục tiêu thể chất hàng ngày',
                              style: AppTextStyles.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Slider 1: Steps
                      _buildGoalSlider(
                        icon: Icons.directions_walk_rounded,
                        iconColor: AppColors.primaryMint,
                        title: 'Mục tiêu số bước',
                        valueText: '$tempSteps bước/ngày',
                        value: tempSteps.toDouble(),
                        min: 2000,
                        max: 25000,
                        divisions: 46,
                        activeColor: AppColors.primaryMint,
                        onChanged: (v) => setSheetState(() => tempSteps = v.toInt()),
                      ),
                      const SizedBox(height: 14),

                      // Slider 2: Calories
                      _buildGoalSlider(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: AppColors.stressActive,
                        title: 'Mục tiêu tiêu hao Calo',
                        valueText: '$tempCalories kcal/ngày',
                        value: tempCalories.toDouble(),
                        min: 200,
                        max: 1500,
                        divisions: 26,
                        activeColor: AppColors.stressActive,
                        onChanged: (v) => setSheetState(() => tempCalories = v.toInt()),
                      ),
                      const SizedBox(height: 14),

                      // Slider 3: Sleep
                      _buildGoalSlider(
                        icon: Icons.bedtime_outlined,
                        iconColor: AppColors.sleepLight,
                        title: 'Thời lượng giấc ngủ',
                        valueText: '$tempSleep giờ/đêm',
                        value: tempSleep.toDouble(),
                        min: 5,
                        max: 10,
                        divisions: 5,
                        activeColor: AppColors.sleepLight,
                        onChanged: (v) => setSheetState(() => tempSleep = v.toInt()),
                      ),
                      const SizedBox(height: 22),

                      // Save Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryMint,
                          foregroundColor: AppColors.primaryDarkText,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          appState.updateGoals(
                            steps: tempSteps,
                            calories: tempCalories,
                            sleepHours: tempSleep,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật mục tiêu thể chất thành công!'),
                              backgroundColor: AppColors.pillActive,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Lưu mục tiêu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoalSlider({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: AppTextStyles.titleSmall),
              ),
              Text(
                valueText,
                style: GoogleFonts.inter(
                  color: activeColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: activeColor,
            inactiveColor: AppColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showCloudSyncSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.pillActive,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.sync_alt_rounded, color: AppColors.primaryMint, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Đồng bộ dữ liệu sức khỏe', style: AppTextStyles.titleMedium),
                                Text('Lần cuối: ${appState.lastSyncTime}', style: AppTextStyles.tinyMuted),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Google Fit / Health Connect', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Đồng bộ bước chân, cự ly và nhịp tim', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.syncGoogleFit,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.toggleSync('google', v);
                          setSheetState(() {});
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Strava', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Tự động chia sẻ lộ trình chạy và đạp xe GPS', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.syncStrava,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.toggleSync('strava', v);
                          setSheetState(() {});
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Apple Health / Cloud Sync', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Đồng bộ chỉ số y tế và phân tích giấc ngủ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.syncAppleHealth,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.toggleSync('apple', v);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sync_rounded, size: 20),
                        label: const Text('Đồng bộ ngay bây giờ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryMint,
                          foregroundColor: AppColors.primaryDarkText,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          appState.triggerManualSync();
                          setSheetState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã đồng bộ dữ liệu sức khỏe thành công (${appState.lastSyncTime})!'),
                              backgroundColor: AppColors.pillActive,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReminderSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.pillActive,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.notifications_none_rounded, color: AppColors.primaryMint, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Thông báo & Nhắc nhở', style: AppTextStyles.titleMedium),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Nhắc uống nước', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Thông báo bổ sung 250ml nước mỗi 2 giờ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.reminderWater,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.toggleReminder('water', v);
                          setSheetState(() {});
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Cảnh báo ngồi lâu', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Nhắc đứng dậy vận động nhẹ sau 60 phút', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.reminderSedentary,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.toggleReminder('sedentary', v);
                          setSheetState(() {});
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Nhắc nhở giờ ngủ', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Chuẩn bị nghỉ ngơi vào lúc 22:30 mỗi tối', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.reminderSleep,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.toggleReminder('sleep', v);
                          setSheetState(() {});
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Huy hiệu & Kỷ lục mới', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Chúc mừng khi phá kỷ lục bước chân hoặc cự ly', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.reminderAchievement,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.toggleReminder('achievement', v);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacySecuritySheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.pillActive,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryMint, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Quyền riêng tư & Bảo mật', style: AppTextStyles.titleMedium),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Khóa Sinh trắc học (Vân tay / FaceID)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Yêu cầu xác thực khi mở ứng dụng', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.privacyBiometrics,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.togglePrivacy('biometrics', v);
                          setSheetState(() {});
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Mã hóa đầu-cuối (E2EE)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Bảo vệ dữ liệu y tế bằng chuẩn AES-256', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.privacyE2EE,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.togglePrivacy('e2ee', v);
                          setSheetState(() {});
                        },
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Chia sẻ dữ liệu chẩn đoán', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Hỗ trợ cải thiện thuật toán đo nhịp tim', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        value: appState.privacyAnalytics,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (v) {
                          appState.togglePrivacy('analytics', v);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cleaning_services_rounded, size: 18),
                        label: const Text('Xóa bộ nhớ đệm (42.8 MB)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã dọn dẹp 42.8 MB bộ nhớ đệm thành công!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Xuất dữ liệu sức khỏe (JSON / CSV)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryMint,
                          side: const BorderSide(color: AppColors.border),
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã chuẩn bị tệp xuất dữ liệu cá nhân health_export.json'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pillActive,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite_rounded, color: AppColors.primaryMint, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health & Exercise App', style: AppTextStyles.titleMedium),
                    Text('Phiên bản 1.0.0 (DACN)', style: AppTextStyles.tinyMuted),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ứng dụng theo dõi sức khỏe và luyện tập thể thao thông minh chuẩn thiết kế Figma dark mode.\n\n• Đo nhịp tim, SpO2 & mức độ căng thẳng\n• Theo dõi GPS buổi chạy thời gian thực\n• Kết nối thiết bị đeo thông minh Smart Watch\n• Mã hóa an toàn dữ liệu cá nhân',
                style: AppTextStyles.caption.copyWith(height: 1.4),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.system_update_rounded, size: 18),
                label: const Text('Kiểm tra bản cập nhật'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryMint,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn đang sử dụng phiên bản mới nhất (v1.0.0)!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Đóng', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.heartRed, size: 24),
            const SizedBox(width: 10),
            Text('Đăng xuất', style: AppTextStyles.titleMedium),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất tài khoản khỏi thiết bị này không?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.heartRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              try {
                GoogleSignIn.instance.signOut();
              } catch (_) {}
              appState.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đăng xuất tài khoản thành công'),
                  backgroundColor: AppColors.cardSurface,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.primaryMint.withValues(alpha: 0.1),
      highlightColor: AppColors.primaryMint.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryMint, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[parts.length - 1].isNotEmpty) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
