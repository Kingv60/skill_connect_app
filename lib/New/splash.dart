import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/BottomNav.dart';

import '../Provider/profile_provider.dart';
import '../Smooth/presentation/new_login_page.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }


  Future<void> checkLoginStatus() async {

    // Splash animation delay
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();

    bool? remember = prefs.getBool("remember_me");
    String? token = prefs.getString("token");

    if (remember == true && token != null) {

      // ✅ Load profile globally from API
      await ref.read(profileProvider.notifier).loadProfile();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const IconOnlyBottomNav(),
        ),
      );

    } else {

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NewLoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Change background to white
      backgroundColor: Colors.white,
      body: Center( // 2. Center the animation
        child: SizedBox(
          height: 200, // 3. Set a specific height
          width: 200,  // 4. Set a specific width
          child: Lottie.asset(
            'assets/file.json',
            fit: BoxFit.contain, // 5. Ensure it fits within the box
          ),
        ),
      ),
    );
  }
}