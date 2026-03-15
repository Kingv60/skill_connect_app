import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/BottomNav.dart';
import '../New/New-Register.dart';
import '../Services/api-service.dart';

class NewLoginPage extends StatefulWidget {
  const NewLoginPage({super.key});

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkRememberMe();
  }

  /// 🔹 Check saved credentials & token on app start
  Future<void> _checkRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final savedRememberMe = prefs.getBool('remember_me') ?? false;

    if (savedToken != null && savedRememberMe) {
      // Token exists and remember me is true → navigate directly
      ApiService.token = savedToken;
      ApiService.userId = prefs.getInt('user_id');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IconOnlyBottomNav()),
      );
    } else {
      // Fill email/password if previously saved
      if (savedRememberMe) {
        emailController.text = savedEmail ?? '';
        passwordController.text = savedPassword ?? '';
        rememberMe = true;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// 🔹 Handle login button
  Future<void> handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.loginUser(email, password);

      if (response.containsKey("token")) {
        final prefs = await SharedPreferences.getInstance();

        // Save token & userId
        await prefs.setString('token', ApiService.token!);
        await prefs.setInt('user_id', ApiService.userId!);

        // Save email/password if remember me
        if (rememberMe) {
          await prefs.setString('email', email);
          await prefs.setString('password', password);
          await prefs.setBool('remember_me', true);
        } else {
          await prefs.remove('email');
          await prefs.remove('password');
          await prefs.setBool('remember_me', false);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IconOnlyBottomNav()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top animated header
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 1600),
                    child: Container(
                      margin: const EdgeInsets.only(top: 60),
                      alignment: Alignment.topCenter,
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Input container
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF8F94FB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x338F94FB),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Email
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF8F94FB)),
                              ),
                            ),
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Color(0xFF8F94FB),
                                ),
                              ),
                            ),
                          ),
                          // Password
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Color(0xFF8F94FB),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Remember Me
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: const Color(0xFF8F94FB),
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        "Remember Me",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Login Button
                  GestureDetector(
                    onTap: isLoading ? null : handleLogin,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF8F94FB),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: Color(0xFF8F94FB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}