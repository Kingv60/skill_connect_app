import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 🔹 Username Generator (Anonymous + Unique Style)
class UsernameGenerator {
  static final _random = Random();

  static const _adjectives = [
    'silent', 'neon', 'swift', 'dark', 'lucky',
    'urban', 'cosmic', 'frozen', 'wild', 'pixel'
  ];

  static const _nouns = [
    'fox', 'wolf', 'tiger', 'nova', 'orbit',
    'shadow', 'vibe', 'eagle', 'ghost'
  ];

  static String generate() {
    final adj = _adjectives[_random.nextInt(_adjectives.length)];
    final noun = _nouns[_random.nextInt(_nouns.length)];
    final number = _random.nextInt(900) + 100;

    return "$adj$noun$number"; // neonFox482
  }
}

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = UsernameGenerator.generate();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/SimpleMotivational.png',
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 520,
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "SIGN UP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// Username Field (with Dice 🎲)
                      _deepField(
                        hint: "Username",
                        icon: Icons.alternate_email,
                        controller: _usernameController,
                        suffix: IconButton(
                          icon: const Icon(
                            Icons.casino_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _usernameController.text =
                                  UsernameGenerator.generate();
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// Name
                      _deepField(
                        hint: "Name",
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 18),

                      /// Email
                      _deepField(
                        hint: "Email",
                        icon: Icons.email_outlined,
                        keyboard: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 18),

                      /// Password
                      _deepField(
                        hint: "Password",
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),

                      const SizedBox(height: 30),

                      /// Sign Up Button
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff6D5DF6),
                              Color(0xff46C2FF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.45),
                              offset: const Offset(4, 4),
                              blurRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.25),
                              offset: const Offset(-2, -2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "SIGN UP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pop(context);
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Reusable Deep TextField
  Widget _deepField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    Widget? suffix,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            offset: const Offset(3, 3),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            offset: const Offset(-3, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white.withOpacity(0.10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
