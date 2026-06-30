import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'classes_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

import '../services/guest_service.dart';
import '../widgets/auth_prompt_dialog.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  int currentIndex = 0;

  final List<Widget> screens = [

    const HomeScreen(),

    const ClassesScreen(),

    const SearchScreen(),

    const LibraryScreen(),

    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        

       onTap: (index) async {

  // Protect Profile tab for Guests
  if (index == 4) {

    final isGuest =
        await GuestService().isGuest();

    if (isGuest) {

      if (!context.mounted) return;

      showAuthPrompt(context);

      return;
    }
  }

  setState(() {
    currentIndex = index;
  });

},

        type: BottomNavigationBarType.fixed,

        backgroundColor: const Color.fromARGB(255, 205, 40, 194),

        selectedItemColor:
            const Color.fromARGB(255, 41, 199, 123),

        unselectedItemColor:
            Colors.white70,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: "Classes",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Library",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        
      ),
      
    );
  }
}
