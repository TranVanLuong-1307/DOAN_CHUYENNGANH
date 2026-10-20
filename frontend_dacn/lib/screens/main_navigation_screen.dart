import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'health/health_screen.dart';
import 'exercise/exercise_screen.dart';
import 'devices/devices_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HealthScreen(
            onAvatarTap: () => _onTabSelected(3), // Navigate to Profile
          ),
          ExerciseScreen(
            onDeviceConnectTap: () => _onTabSelected(2), // Navigate to Devices
          ),
          const DevicesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
