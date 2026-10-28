import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../configs/strings/string_extensions.dart';
import '../../controllers/daily_log_controller.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';
import '../evolution/evolution_page.dart';
import '../goals/goals_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Voltando do segundo plano num dia novo, a Home acompanha a data.
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<DailyLogController>().followToday(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          GoalsPage(),
          EvolutionPage(),
          ProfilePage(),
        ],
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
            icon: Icons.show_chart_rounded,
            selectedIcon: Icons.insights_rounded,
            label: AppStrings.tabEvolution,
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
