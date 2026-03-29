import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animate_do/animate_do.dart';

import '../../Services/AppColors.dart';
import '../bloc/register_bloc/register_bloc.dart';
import '../bloc/register_bloc/register_event.dart';
import '../bloc/register_bloc/register_state.dart';
import 'new_profile_setup_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(),
      child: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterValidationSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSetupPage(
                  name: state.name,
                  email: state.email,
                  password: state.password,
                ),
              ),
            );
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  _buildHeader(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 15),
                        _buildForm(),
                        const SizedBox(height: 15),
                        _buildRegisterButton(context, state),
                        const SizedBox(height: 15),
                        _buildLoginLink(context),
                        const SizedBox(height: 20),
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
      height: MediaQuery.of(context).size.height * 0.35,
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
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.scaffoldBg.withOpacity(0.3),
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
                    "Join Us",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Create your SkillConnect account",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
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
          _buildTextField(nameController, "Full Name", Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _buildTextField(emailController, "Email Address", Icons.alternate_email_rounded),
          const SizedBox(height: 12),
          _buildTextField(
              passwordController,
              "Password",
              Icons.lock_outline_rounded,
              isPassword: true
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
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
          border: InputBorder.none,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, RegisterState state) {
    bool isLoading = state is RegisterLoading;
    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: GestureDetector(
        onTap: isLoading
            ? null
            : () {
          context.read<RegisterBloc>().add(RegisterSubmitted(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ));
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
                : const Text(
              "Register Now",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account? ",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text("Login",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}