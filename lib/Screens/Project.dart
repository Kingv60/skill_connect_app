import 'dart:ui';
import 'package:flutter/material.dart';

import '../New/project-info.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  double _dragX = 0;
  double _dragY = 0; // Added for Upward swipe
  double _rotation = 0;
  int _currentIndex = 0;

  // Sample data to demonstrate Next/Previous
  final List<Map<String, String>> projects = [
    {"title": "SkillConnect App", "desc": "Platform for Flutter developers.", "img": "https://picsum.photos/600/400?random=1"},
    {"title": "Eco Tracker", "desc": "Track your carbon footprint daily.", "img": "https://picsum.photos/600/400?random=2"},
    {"title": "FitFlow AI", "desc": "AI powered workout generator.", "img": "https://picsum.photos/600/400?random=3"},
  ];

  void _handleSwipe(String direction) {
    setState(() {
      if (direction == "right") {
        _dragX = 600;
        if (_currentIndex < projects.length - 1) _currentIndex++;
      } else if (direction == "left") {
        _dragX = -600;
        if (_currentIndex > 0) _currentIndex--;
      } else if (direction == "up") {
        _dragY = -800;
        // Logic for 'Not Interested' could go here
      }
      _rotation = _dragX / 300;
    });

    // Reset position after animation for the new card content
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _dragX = 0;
        _dragY = 0;
        _rotation = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🌌 BACKGROUND (Pure Black for Modern look)
          Positioned.fill(child: Container(color: Colors.black)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("PROJECTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 4)),

                const Spacer(),

                /// 🔥 SWIPEABLE CARD
                GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _dragX += details.delta.dx;
                      _dragY += details.delta.dy;
                      _rotation = _dragX / 300;
                    });
                  },
                  onPanEnd: (details) {
                    if (_dragY < -150) {
                      _handleSwipe("up");
                    } else if (_dragX > 150) {
                      _handleSwipe("right");
                    } else if (_dragX < -150) {
                      _handleSwipe("left");
                    } else {
                      setState(() { _dragX = 0; _dragY = 0; _rotation = 0; });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    transform: Matrix4.identity()
                      ..translate(_dragX, _dragY)
                      ..rotateZ(_rotation),
                    child: _buildCard(),
                  ),
                ),

                const Spacer(),

                /// 🎯 ACTION BUTTONS (Gradients Removed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(icon: Icons.arrow_back, color: Colors.white24, onTap: () => _handleSwipe("left")),
                      _ActionButton(icon: Icons.keyboard_double_arrow_up, color: Colors.redAccent, size: 70, onTap: () => _handleSwipe("up")),
                      _ActionButton(icon: Icons.arrow_forward, color: Colors.white24, onTap: () => _handleSwipe("right")),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    final project = projects[_currentIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(onDoubleTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectInfoPage()));
          },
            child: Container(
              height: 450,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(project['img']!, height: 250, width: double.infinity, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project['title']!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 10),
                        Text(project['desc']!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, this.size = 60, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}