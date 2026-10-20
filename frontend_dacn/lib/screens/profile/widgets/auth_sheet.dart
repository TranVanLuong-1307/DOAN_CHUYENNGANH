import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthSheet extends StatefulWidget {
  final AppState appState;

  const AuthSheet({super.key, required this.appState});

  static void show(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AuthSheet(appState: appState),
    );
  }

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  int _selectedTab = 0; // 0: Đăng nhập, 1: Đăng ký
  final _emailLoginCtrl = TextEditingController();
  final _passLoginCtrl = TextEditingController();
  final _nameRegCtrl = TextEditingController();
  final _emailRegCtrl = TextEditingController();
  final _passRegCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isGoogleSigningIn = false;
  bool _isGoogleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_isGoogleInitialized) return;
    try {
      await GoogleSignIn.instance.initialize();
      _isGoogleInitialized = true;
    } catch (_) {
      // Ignored if already initialized or unsupported
    }
  }

  @override
  void dispose() {
    _emailLoginCtrl.dispose();
    _passLoginCtrl.dispose();
    _nameRegCtrl.dispose();
    _emailRegCtrl.dispose();
    _passRegCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailLoginCtrl.text.trim();
    if (email.isEmpty) return;

    widget.appState.login(
      email: email,
      name: email.contains('@') ? email.split('@')[0] : 'Người dùng',
    );
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.pillActive,
        content: Text('Đăng nhập thành công! Chào mừng trở lại, ${widget.appState.userName}!'),
      ),
    );
  }

  void _handleRegister() {
    final name = _nameRegCtrl.text.trim();
    final email = _emailRegCtrl.text.trim();
    if (email.isEmpty) return;

    widget.appState.login(
      email: email,
      name: name.isNotEmpty ? name : 'Người dùng mới',
    );
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.pillActive,
        content: Text('Tạo tài khoản thành công! Xin chào ${widget.appState.userName}!'),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleSigningIn) return;
    setState(() => _isGoogleSigningIn = true);

    try {
      await _ensureGoogleInitialized();

      // Kích hoạt hộp thoại Google Play Services để chọn tài khoản và xác nhận cấp quyền
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate(
        scopeHint: const <String>['email', 'profile'],
      );

      if (!mounted) return;

      final String displayName = (account.displayName != null && account.displayName!.trim().isNotEmpty)
          ? account.displayName!.trim()
          : (account.email.contains('@') ? account.email.split('@')[0] : 'Google User');

      widget.appState.login(
        email: account.email,
        name: displayName,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryMintDark,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đăng nhập Google thành công: ${account.email}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // Người dùng đã hủy hoặc thoát khỏi hộp thoại chọn tài khoản Google
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Đã hủy thao tác chọn tài khoản Google.'),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.heartRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Lỗi xác thực tài khoản Google: ${e.description ?? e.code.name}'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.heartRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Không thể kết nối dịch vụ Google: $e'),
              ),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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

              // Tab Switcher: Đăng nhập / Đăng ký mới (Segmented style)
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? AppColors.primaryMint : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Đăng nhập',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: _selectedTab == 0 ? AppColors.primaryDarkText : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? AppColors.primaryMint : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Đăng ký mới',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: _selectedTab == 1 ? AppColors.primaryDarkText : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Active Tab Content (Dynamic height, zero overflow)
              _selectedTab == 0 ? _buildLoginTab() : _buildRegisterTab(),
              const SizedBox(height: 16),

              // Social Login Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('hoặc tiếp tục với', style: AppTextStyles.tinyMuted),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 14),

              // Social Google button (Real Google Account Chooser & Auth)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  backgroundColor: AppColors.background,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isGoogleSigningIn
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMintDark),
                        ),
                      )
                    : _buildGoogleLogo(),
                label: Text(
                  _isGoogleSigningIn ? 'Đang mở Google...' : 'Đăng nhập bằng Google',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                onPressed: _isGoogleSigningIn ? null : _handleGoogleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailLoginCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            labelText: 'Email',
            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryMint, size: 20),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryMint, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passLoginCtrl,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            labelText: 'Mật khẩu',
            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryMint, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryMint, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMint,
            foregroundColor: AppColors.primaryDarkText,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _handleLogin,
          child: const Text('Đăng nhập ngay', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildRegisterTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameRegCtrl,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            labelText: 'Họ và tên',
            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryMint, size: 20),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryMint, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emailRegCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            labelText: 'Email',
            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryMint, size: 20),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryMint, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passRegCtrl,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            labelText: 'Tạo mật khẩu',
            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryMint, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryMint, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMint,
            foregroundColor: AppColors.primaryDarkText,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _handleRegister,
          child: const Text('Tạo tài khoản', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildGoogleLogo() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6), width: 0.8),
      ),
      alignment: Alignment.center,
      child: const CustomPaint(
        size: Size(13, 13),
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final double radius = w / 2;
    final double stroke = w * 0.28;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    // Blue arc (top-right to right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.785, 1.3, false, paint);

    // Green arc (bottom right to bottom left)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.515, 1.8, false, paint);

    // Yellow arc (bottom left to top left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.315, 1.3, false, paint);

    // Red arc (top left to top right)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.615, 1.8, false, paint);

    // Center horizontal bar (Blue)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.5 - stroke / 2, w * 0.58, stroke),
      Radius.circular(stroke * 0.2),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
