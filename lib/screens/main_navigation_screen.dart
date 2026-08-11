import 'package:flutter/material.dart';

import 'classes_screen.dart';
import 'hadith_screen.dart';
import 'home_screen.dart';
import 'package:seeker/screens/quran/quran_screen.dart';
import 'profile_screen.dart';

import '../services/guest_service.dart';
import '../widgets/auth_prompt_dialog.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),

    QuranScreen(),

    ClassesScreen(),

    HadithScreen(),

    ProfileScreen(),
  ];

  Future<void> _onItemTapped(int index) async {
    if (index == 4) {
      final isGuest = await GuestService().isGuest();

      if (isGuest) {
        if (!mounted) return;

        showAuthPrompt(context);

        return;
      }
    }

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F6F1),

      body: IndexedStack(index: currentIndex, children: screens),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: Container(
            height: 78,

            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 242, 243, 244),

              borderRadius: BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                // Home
                _NavItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  selected: currentIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),

                // Quran
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: "Quran",
                  selected: currentIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),

                // Classes
                _NavItem(
                  icon: Icons.ondemand_video_rounded,
                  label: "Classes",
                  selected: currentIndex == 2,
                  onTap: () => _onItemTapped(2),
                ),

                // Hadith
                _NavItem(
                  icon: Icons.auto_stories_rounded,
                  label: "Hadith",
                  selected: currentIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),

                // Profile
                _NavItem(
                  icon: Icons.person_rounded,
                  label: "Profile",
                  selected: currentIndex == 4,
                  onTap: () => _onItemTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromARGB(255, 238, 239, 203)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.15 : 1,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  icon,
                  size: 27,
                  color: selected
                      ? const Color.fromARGB(255, 231, 8, 138)
                      : const Color.fromARGB(242, 39, 113, 153),
                ),
              ),

              const SizedBox(height: 5),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? const Color(0xff0E5A56)
                      : const Color.fromARGB(179, 14, 3, 6),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
