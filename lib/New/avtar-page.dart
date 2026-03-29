import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillconnect/BottomNav.dart';
import '../Services/AppColors.dart';
import '../Services/api-service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarCreatePage extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String username;
  final List<String> skills;
  final String bio;
  final String role;

  const AvatarCreatePage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.username,
    required this.skills,
    required this.bio,
    required this.role,
  });

  @override
  State<AvatarCreatePage> createState() => _AvatarCreatePageState();
}

class _AvatarCreatePageState extends State<AvatarCreatePage> {
  String avatarSvg = "";
  bool showAvatar = false;
  File? selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    generateAvatar();
  }

  void generateAvatar() {
    avatarSvg = multiavatar(widget.username);
    setState(() {
      showAvatar = true;
      selectedImage = null;
    });
  }

  void regenerateAvatar() {
    final random = Random().nextInt(9999);
    avatarSvg = multiavatar("${widget.username}_$random");
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> loadTokenAndUserId() async {
    final prefs = await SharedPreferences.getInstance();
    ApiService.token = prefs.getString("token");
    ApiService.userId = prefs.getInt("user_id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 50, // Reduced toolbar height
        title: const Text("Choose Avatar",
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// PROGRESS BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _stepCircle("✓", true),
                          Expanded(child: Container(height: 2, color: AppColors.primary)),
                          _stepCircle("2", true),
                          Expanded(child: Container(height: 2, color: AppColors.surface)),
                          _stepCircle("3", false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// AVATAR DISPLAY WITH REDUCED SIZES
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Glow
                            Container(
                              height: 160, // Reduced from 210
                              width: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withOpacity(0.05),
                              ),
                            ),
                            // Inner Border Ring
                            Container(
                              height: 140, // Reduced from 180
                              width: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                              ),
                            ),
                            // Main Avatar Container
                            Container(
                              height: 125, // Reduced from 160
                              width: 125,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: selectedImage != null
                                    ? Image.file(selectedImage!, fit: BoxFit.cover)
                                    : SvgPicture.string(avatarSvg, fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "@${widget.username}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Your identity on SkillConnect",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),

                    const SizedBox(height: 15),

                    /// SELECTION BUTTONS
                    _buildModernOption(
                      label: "Shuffle Random Avatar",
                      icon: Icons.auto_awesome_rounded,
                      onTap: regenerateAvatar,
                    ),

                    const SizedBox(height: 10),

                    _buildModernOption(
                      label: "Upload from Gallery",
                      icon: Icons.camera_alt_rounded,
                      onTap: pickImage,
                    ),

                    const SizedBox(height: 20),

                    /// SUBMIT BUTTON
                    _buildSubmitButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
        ),
      ),
    );
  }

  Widget _stepCircle(String text, bool active) {
    return Container(
      width: 24, height: 24, // Reduced from 28
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary : AppColors.surface,
        border: Border.all(color: active ? AppColors.primary : AppColors.textMuted.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(text, style: TextStyle(
            color: active ? Colors.white : AppColors.textMuted,
            fontWeight: FontWeight.bold, fontSize: 10)),
      ),
    );
  }

  Widget _buildModernOption({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Tighter padding
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              )),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 54, // Slightly reduced
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: !_isLoading ? AppColors.primaryGradient : null,
        color: _isLoading ? AppColors.surface : null,
        boxShadow: !_isLoading ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ] : [],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Text(
          "Create My Account",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    try {
      await ApiService().registerUser(widget.name, widget.email, widget.password);
      await loadTokenAndUserId();

      File? avatarFile;
      if (selectedImage != null) {
        avatarFile = selectedImage;
      } else {
        final bytes = utf8.encode(avatarSvg);
        final file = File('${Directory.systemTemp.path}/avatar.svg');
        await file.writeAsBytes(bytes);
        avatarFile = file;
      }

      try {
        await ApiService().createProfile(
          username: widget.username,
          skills: widget.skills.join(","),
          role: widget.role,
          bio: widget.bio,
          avatarFile: avatarFile,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IconOnlyBottomNav()),
        );
      } catch (profileError) {
        if (ApiService.userId != null) {
          await ApiService().deleteUser(ApiService.userId!);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile creation failed. Registration rolled back.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}