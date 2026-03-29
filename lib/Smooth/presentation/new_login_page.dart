import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this is imported
import 'package:animate_do/animate_do.dart';
import '../../BottomNav.dart';

import '../../Services/AppColors.dart';
import '../bloc/login_bloc/login_bloc.dart';
import '../bloc/login_bloc/login_event.dart';
import '../bloc/login_bloc/login_state.dart';
import 'new_register_page.dart';

class NewLoginPage extends StatefulWidget {
  const NewLoginPage({super.key});

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc()..add(CheckRememberMe()),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const IconOnlyBottomNav()),
            );
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: AppColors.error),
            );
          } else if (state is CredentialsLoaded) {
            emailController.text = state.email;
            passwordController.text = state.password;
            setState(() => rememberMe = state.rememberMe);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        _buildForm(),
                        const SizedBox(height: 10),
                        _buildRememberMe(),
                        const SizedBox(height: 15),
                        _buildLoginButton(context, state),
                        const SizedBox(height: 15),
                        _buildRegisterRow(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.38,
      child: Stack(
        children: [
          // SVG Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50)),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  AppColors.primary.withOpacity(0.2),
                  BlendMode.dstATop,
                ),
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              )
            ),
          ),
          // Gradient Overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.scaffoldBg.withOpacity(0.2),
                ],
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50)),
            ),
          ),
          Center(
            child: FadeInDown(
              duration: const Duration(milliseconds: 1000),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Sign in to continue",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Column(
        children: [
          _buildTextField(
            controller: emailController,
            hint: "Email",
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: passwordController,
            hint: "Password",
            icon: Icons.lock_outline_rounded,
            isPassword: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscurePassword : false,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textMuted, size: 18,
            ),
            onPressed: () => setState(() => obscurePassword = !obscurePassword),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              activeColor: AppColors.primary,
              side: const BorderSide(color: AppColors.textMuted),
              onChanged: (value) => setState(() => rememberMe = value ?? false),
            ),
            const Text("Remember Me", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text("Forgot?", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    bool isLoading = state is LoginLoading;
    return GestureDetector(
      onTap: isLoading ? null : () {
        context.read<LoginBloc>().add(LoginSubmitted(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          rememberMe: rememberMe,
        ));
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildRegisterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("New here? ", style: TextStyle(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
          child: const Text("Create Account", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}