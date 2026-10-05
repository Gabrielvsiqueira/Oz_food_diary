import 'package:flutter/material.dart';

import '../../configs/strings/string_extensions.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';
import '../goals/goals_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';

/// Abas principais. `IndexedStack` mantém o estado de cada aba
/// (ex.: edições em andamento em Metas) ao trocar de aba.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [HomePage(), GoalsPage(), ProfilePage()],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          AppBottomNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: AppStrings.tabHome,
          ),
          AppBottomNavItem(
            icon: Icons.track_changes_outlined,
            selectedIcon: Icons.track_changes_rounded,
            label: AppStrings.tabGoals,
          ),
          AppBottomNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: AppStrings.tabProfile,
          ),
        ],
      ),
    );
  }
}
