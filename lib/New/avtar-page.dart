import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillconnect/BottomNav.dart';
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

  @override
  void initState() {
    super.initState();
    generateAvatar();
  }

  /// Generate default avatar
  void generateAvatar() {
    avatarSvg = multiavatar(widget.username);
    setState(() {
      showAvatar = true;
      selectedImage = null;
    });
  }

  /// Generate new avatar randomly
  void regenerateAvatar() {
    final random = Random().nextInt(9999);
    avatarSvg = multiavatar("${widget.username}_$random");
    setState(() {
      selectedImage = null;
    });
  }

  /// Pick custom image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Load saved token and userId from SharedPreferences
  Future<void> loadTokenAndUserId() async {
    final prefs = await SharedPreferences.getInstance();
    ApiService.token = prefs.getString("token");
    ApiService.userId = prefs.getInt("user_id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// HEADER
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF8F94FB),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Create Your Avatar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// USERNAME
              Text(
                "@${widget.username}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8F94FB),
                ),
              ),

              const SizedBox(height: 30),

              /// AVATAR DISPLAY
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF8F94FB),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : SvgPicture.string(avatarSvg, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// GENERATE NEW AVATAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: regenerateAvatar,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF8F94FB)),
                    ),
                    child: const Text(
                      "Generate New Avatar",
                      style: TextStyle(color: Color(0xFF8F94FB)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// UPLOAD IMAGE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: pickImage,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF8F94FB)),
                    ),
                    child: const Text(
                      "Upload Your Own Image",
                      style: TextStyle(color: Color(0xFF8F94FB)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// SUBMIT BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        /// 1️⃣ REGISTER USER
                        final registerResponse = await ApiService().registerUser(
                          widget.name,
                          widget.email,
                          widget.password,
                        );

                        print("✅ Register success: $registerResponse");

                        /// Load saved token and userId
                        await loadTokenAndUserId();

                        /// 2️⃣ PREPARE AVATAR FILE
                        File? avatarFile;
                        if (selectedImage != null) {
                          avatarFile = selectedImage;
                        } else {
                          final bytes = utf8.encode(avatarSvg);
                          final file = File('${Directory.systemTemp.path}/avatar.svg');
                          await file.writeAsBytes(bytes);
                          avatarFile = file;
                        }

                        /// 3️⃣ CREATE PROFILE
                        try {
                          final profileResponse = await ApiService().createProfile(
                            username: widget.username,
                            skills: widget.skills.join(","), // convert list to string
                            role: widget.role,
                            bio: widget.bio,
                            avatarFile: avatarFile,
                          );

                          print("✅ Profile created: $profileResponse");

                          /// Navigate to Home
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => IconOnlyBottomNav()),
                          );

                        } catch (profileError) {
                          print("❌ Profile creation failed: $profileError");

                          // ⚠️ Rollback registration
                          if (ApiService.userId != null) {
                            await ApiService().deleteUser(ApiService.userId!);
                            print("⚠️ User registration rolled back due to profile failure.");
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Profile creation failed. Registration has been rolled back."),
                            ),
                          );
                        }

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Registration failed: $e")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F94FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}