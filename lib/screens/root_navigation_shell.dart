import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'update_post_screen.dart';
import '../widgets/custom_bottom_nav.dart';

class RootNavigationShell extends StatefulWidget {
  const RootNavigationShell({super.key});

  @override
  State<RootNavigationShell> createState() => _RootNavigationShellState();
}

class _RootNavigationShellState extends State<RootNavigationShell> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(key: _homeScreenKey),
      const SearchScreen(),
      const MessagesScreen(),
      const NotificationsScreen(),
    ];
  }

  void _handleNavigation(int index) {
    if (index == 4) {
      // Tap on "+" button -> Navigate to Screen 2 (Update/Gallery Screen)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UpdatePostScreen()),
      ).then((uploaded) {
        if (uploaded == true) {
          // If a new post was successfully created, refresh the Home feed state
          _homeScreenKey.currentState?.loadPosts();
          setState(() {
            _currentIndex = 0; // Return to Home feed page
          });
        }
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}
