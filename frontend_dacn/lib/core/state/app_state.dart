import 'package:flutter/material.dart';

class WorkoutRecord {
  final IconData icon;
  final String title;
  final double distanceKm;
  final String duration;
  final String pace;
  final String date;
  final int calories;

  const WorkoutRecord({
    required this.icon,
    required this.title,
    required this.distanceKm,
    required this.duration,
    required this.pace,
    required this.date,
    required this.calories,
  });
}

class AppState extends ChangeNotifier {
  // Steps & Activity (Khung dữ liệu ban đầu chờ Backend)
  int currentSteps = 0;
  int targetSteps = 0;
  double distanceKm = 0.0;
  int caloriesKcal = 0;
  int durationMinutes = 0;

  // Health Metrics (Khung dữ liệu ban đầu chờ Backend)
  double weightKg = 0.0;
  double weightDelta = 0.0;
  int sleepHours = 0;
  int sleepMinutes = 0;
  int heartRate = 0;
  int spo2 = 0;
  int hrv = 0;
  int stressLevel = 0;

  // Trạng thái xác thực & Thông tin tài khoản
  bool isLoggedIn = false;
  String userName = '';
  String userEmail = '';
  String accountId = '';
  String accountType = '';
  String joinDate = '';

  // Thông tin cá nhân (Khung dữ liệu ban đầu trống)
  String gender = '';
  String birthDate = '';
  double userHeightCm = 0.0;

  // Cài đặt mục tiêu thể chất
  int targetCalories = 0;
  int targetSleepHours = 0;

  // Đồng bộ đám mây
  bool syncGoogleFit = false;
  bool syncStrava = false;
  bool syncAppleHealth = false;
  String lastSyncTime = 'Chưa đồng bộ';

  // Thông báo & Nhắc nhở
  bool reminderWater = false;
  bool reminderSedentary = false;
  bool reminderSleep = false;
  bool reminderAchievement = false;

  // Quyền riêng tư & Bảo mật
  bool privacyBiometrics = false;
  bool privacyE2EE = true;
  bool privacyAnalytics = false;

  // Cấp quyền ứng dụng (Mặc định chưa cấp khi chưa tương tác)
  bool permLocation = false;
  bool permSensors = false;
  bool permBluetooth = false;
  bool permActivity = false;
  bool permNotification = false;
  bool permStorage = false;
  bool permCamera = false;

  // Device (Chưa kết nối thiết bị nào)
  bool isDeviceConnected = false;
  String deviceName = '';
  int deviceBattery = 0;

  // Workouts (Khung danh sách rỗng chờ Backend)
  List<WorkoutRecord> workoutHistory = [];

  // Calculated BMI
  double get bmi {
    if (userHeightCm <= 0 || weightKg <= 0) return 0.0;
    final heightM = userHeightCm / 100.0;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

  String get bmiStatus {
    final b = bmi;
    if (b <= 0) return 'Chưa có dữ liệu';
    if (b < 18.5) return 'Gầy';
    if (b < 24.9) return 'Chuẩn';
    if (b < 29.9) return 'Thừa cân';
    return 'Béo phì';
  }

  // Calculated Age
  int get age {
    try {
      if (birthDate.isEmpty) return 0;
      final parts = birthDate.split('/');
      if (parts.length == 3) {
        final year = int.tryParse(parts[2]);
        if (year != null) {
          return DateTime.now().year - year;
        }
      }
    } catch (_) {}
    return 0;
  }

  // Update methods
  void updateWeight(double newWeight) {
    if (weightKg > 0) {
      weightDelta = double.parse((newWeight - weightKg).toStringAsFixed(1));
    } else {
      weightDelta = 0.0;
    }
    weightKg = newWeight;
    notifyListeners();
  }

  void updateTargetSteps(int newTarget) {
    targetSteps = newTarget;
    notifyListeners();
  }

  void login({String? email, String? name}) {
    isLoggedIn = true;
    if (email != null && email.isNotEmpty) userEmail = email;
    if (name != null && name.isNotEmpty) userName = name;
    if (accountId.isEmpty) {
      accountId = 'MA-${(DateTime.now().millisecondsSinceEpoch % 90000 + 10000)}';
    }
    if (accountType.isEmpty) accountType = 'Tài khoản thường';
    if (joinDate.isEmpty) {
      final now = DateTime.now();
      joinDate = '${now.month}/${now.year}';
    }
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    userName = '';
    userEmail = '';
    accountId = '';
    accountType = '';
    joinDate = '';
    notifyListeners();
  }

  void updateAccountInfo({required String name, required String email}) {
    userName = name;
    userEmail = email;
    notifyListeners();
  }

  void updatePersonalInfo({
    required String newGender,
    required String newBirthDate,
    required double newHeight,
    required double newWeight,
  }) {
    gender = newGender;
    birthDate = newBirthDate;
    userHeightCm = newHeight;
    updateWeight(newWeight);
    notifyListeners();
  }

  void updateProfile({required String name, required double height, required double weight}) {
    userName = name;
    userHeightCm = height;
    updateWeight(weight);
    notifyListeners();
  }

  void toggleDeviceConnection() {
    isDeviceConnected = !isDeviceConnected;
    notifyListeners();
  }

  void setDeviceConnected(bool connected) {
    isDeviceConnected = connected;
    notifyListeners();
  }

  void addWorkout(WorkoutRecord record) {
    workoutHistory.insert(0, record);
    distanceKm = double.parse((distanceKm + record.distanceKm).toStringAsFixed(1));
    caloriesKcal += record.calories;
    notifyListeners();
  }

  void recordHeartRate(int newBpm) {
    heartRate = newBpm;
    notifyListeners();
  }

  void recordSpo2(int newSpo2) {
    spo2 = newSpo2;
    notifyListeners();
  }

  void recordStress(int newStress) {
    stressLevel = newStress;
    notifyListeners();
  }

  void updateGoals({int? steps, int? calories, int? sleepHours}) {
    if (steps != null) targetSteps = steps;
    if (calories != null) targetCalories = calories;
    if (sleepHours != null) targetSleepHours = sleepHours;
    notifyListeners();
  }

  void toggleSync(String service, bool value) {
    if (service == 'google') syncGoogleFit = value;
    if (service == 'strava') syncStrava = value;
    if (service == 'apple') syncAppleHealth = value;
    notifyListeners();
  }

  void triggerManualSync() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    lastSyncTime = '$hour:$min hôm nay';
    notifyListeners();
  }

  void toggleReminder(String type, bool value) {
    if (type == 'water') reminderWater = value;
    if (type == 'sedentary') reminderSedentary = value;
    if (type == 'sleep') reminderSleep = value;
    if (type == 'achievement') reminderAchievement = value;
    notifyListeners();
  }

  void togglePrivacy(String type, bool value) {
    if (type == 'biometrics') privacyBiometrics = value;
    if (type == 'e2ee') privacyE2EE = value;
    if (type == 'analytics') privacyAnalytics = value;
    notifyListeners();
  }

  void togglePermission(String key, bool value) {
    switch (key) {
      case 'location': permLocation = value; break;
      case 'sensors': permSensors = value; break;
      case 'bluetooth': permBluetooth = value; break;
      case 'activity': permActivity = value; break;
      case 'notification': permNotification = value; break;
      case 'storage': permStorage = value; break;
      case 'camera': permCamera = value; break;
    }
    notifyListeners();
  }

  void grantAllPermissions() {
    permLocation = true;
    permSensors = true;
    permBluetooth = true;
    permActivity = true;
    permNotification = true;
    permStorage = true;
    permCamera = true;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}
