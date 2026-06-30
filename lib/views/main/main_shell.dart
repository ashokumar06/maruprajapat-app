import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

import '../home/home_screen.dart';
import '../news/news_screen.dart';
import '../forms/forms_screen.dart';
import '../honours/honours_screen.dart';
import '../explore/explore_screen.dart';

import 'package:url_launcher/url_launcher.dart';

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
  bool _showNavBar = true;

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
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification) {
            final delta = notification.scrollDelta;
            if (delta != null) {
              if (delta > 5 && _showNavBar) {
                setState(() => _showNavBar = false);
              } else if (delta < -5 && !_showNavBar) {
                setState(() => _showNavBar = true);
              }
            }
          }
          return false;
        },
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: _showNavBar ? 8 : 3,
              offset: Offset(0, _showNavBar ? -3 : -1),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Navigation Items
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _showNavBar ? 58 : 0,
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
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
              ),
              // Sponsor Footer
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('https://avirastra.com');
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    debugPrint('Could not launch URL: $e');
                  }
                },
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(
                    bottom: _showNavBar ? 8 : 10,
                    top: _showNavBar ? 2 : 10,
                  ),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 10, color: ThemeConfig.textSecondary),
                      children: [
                        TextSpan(text: 'Charity by '),
                        TextSpan(
                          text: 'AVIRASTRA',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
