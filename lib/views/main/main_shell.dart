import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';

import '../home/home_screen.dart';
import '../news/news_screen.dart';
import '../forms/forms_screen.dart';
import '../honours/honours_screen.dart';
import '../explore/explore_screen.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('पोस्ट बनाएं'));
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NewsScreen(),
    const ExploreScreen(),
    const FormsScreen(),
    const HonoursScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'होम'),
              _buildNavItem(1, Icons.article_outlined, Icons.article, 'न्यूज़'),
              _buildNavItem(2, Icons.search, Icons.search, 'अन्वेषण'),
              _buildNavItem(3, Icons.list_alt_outlined, Icons.list_alt, 'फॉर्म'),
              _buildNavItem(4, Icons.military_tech_outlined, Icons.military_tech, 'गौरव'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? ThemeConfig.primary : ThemeConfig.textSecondary;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: color,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
