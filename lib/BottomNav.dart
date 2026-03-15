import 'package:flutter/material.dart';
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
    setState(() => selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  IconData _getIcon(int index, bool isSelected) {
    switch (index) {
      case 0:
        return isSelected
            ? PhosphorIconsFill.house
            : PhosphorIconsRegular.house;
      case 1:
        return isSelected
            ? PhosphorIconsFill.chatCircle
            : PhosphorIconsRegular.chatCircle;
      case 2:
        return isSelected
            ? PhosphorIconsFill.plusSquare
            : PhosphorIconsRegular.plusSquare;
      case 3:
        return isSelected
            ? PhosphorIconsFill.video
            : PhosphorIconsRegular.video;
      case 4:
        return isSelected
            ? PhosphorIconsFill.package
            : PhosphorIconsRegular.package;
      default:
        return PhosphorIconsRegular.house;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => selectedIndex = index);
          },
          children: pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xff262626),
            border: Border(
              top: BorderSide(
                color: Colors.white10,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              final bool isSelected = selectedIndex == index;
        
              return GestureDetector(
                onTap: () => _onTabTap(index),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.15 : 1.0,
                  child: Icon(
                    _getIcon(index, isSelected),
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
