import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:skillconnect/Screens/Home.dart';
import 'package:skillconnect/Screens/Upload.dart';
import 'package:skillconnect/Screens/Video.dart';
import 'package:skillconnect/Screens/Project.dart';
import 'ChatList.dart';

class IconOnlyBottomNav extends StatefulWidget {
  const IconOnlyBottomNav({super.key});

  @override
  State<IconOnlyBottomNav> createState() => _IconOnlyBottomNavState();
}

class _IconOnlyBottomNavState extends State<IconOnlyBottomNav> {
  int selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> pages = const [
    HomeScreen(),
    ChatScreen(),
    UploadScreen(),
    VideoPage(),
    ProjectScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (selectedIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // IMPORTANT: DO NOT use extendBody: true here.
      // Keeping it false ensures PageView content ends above the nav bar.
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => selectedIndex = index),
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      // Standard height for fixed bars + SafeArea handles the bottom notch
      decoration: const BoxDecoration(
        color: Color(0xff1A1A1A),
        border: Border(
          top: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) => _buildNavItem(index)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        // Ensures the tap area is wide enough
        width: MediaQuery.of(context).size.width / 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // Use a subtle square/rounded-rect instead of a circle for fixed bars
                color: isSelected ? Colors.indigoAccent.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(index, isSelected),
                size: 24,
                color: isSelected ? Colors.indigoAccent : Colors.white60,
              ),
            ),
            const SizedBox(height: 4),
            // Horizontal line indicator looks cleaner on fixed bars than a dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              width: isSelected ? 18 : 0,
              decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(int index, bool isSelected) {
    switch (index) {
      case 0: return isSelected ? PhosphorIconsFill.house : PhosphorIconsLight.house;
      case 1: return isSelected ? PhosphorIconsFill.chatCircle : PhosphorIconsLight.chatCircle;
      case 2: return isSelected ? PhosphorIconsFill.plusSquare : PhosphorIconsLight.plusSquare;
      case 3: return isSelected ? PhosphorIconsFill.video : PhosphorIconsLight.video;
      case 4: return isSelected ? PhosphorIconsFill.package : PhosphorIconsLight.package;
      default: return PhosphorIconsLight.house;
    }
  }
}