import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillconnect/New/splash.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'SkillConnect',
      theme: ThemeData(useMaterial3: true,
        brightness: Brightness.light, // Matches your black ProjectScreen
        textTheme: GoogleFonts.figtreeTextTheme(
          ThemeData.light().textTheme,
        ),),
      home: const SplashScreen(),
    );
  }
}