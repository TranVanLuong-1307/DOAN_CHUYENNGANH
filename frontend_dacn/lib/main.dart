import 'package:flutter/material.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const HealthExerciseApp());
}

class HealthExerciseApp extends StatefulWidget {
  const HealthExerciseApp({super.key});

  @override
  State<HealthExerciseApp> createState() => _HealthExerciseAppState();
}

class _HealthExerciseAppState extends State<HealthExerciseApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'Sức khỏe & Luyện tập',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
