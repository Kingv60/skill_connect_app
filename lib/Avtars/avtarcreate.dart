import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class AvatarOnboardingPage extends StatefulWidget {
  const AvatarOnboardingPage({super.key});

  @override
  State<AvatarOnboardingPage> createState() => _AvatarOnboardingPageState();
}

class _AvatarOnboardingPageState extends State<AvatarOnboardingPage> {
  File? avatarImage;
  bool isGenerating = false;
  void startGenerating() {
    setState(() {
      isGenerating = true;
    });

    Future.doWhile(() async {
      if (!isGenerating) return false;
      await Future.delayed(const Duration(seconds: 1));
      setState(() {});
      return true;
    });
  }


  Future<void> pickImage() async {
    // 🚫 Image picker camera is NOT supported on Windows
    if (Platform.isWindows) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera not supported on Windows"),
        ),
      );
      return; // ⛔ STOP execution here
    }

    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (picked != null) {
      setState(() {
        avatarImage = File(picked.path);
      });
    }
  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff6d4c6d), Color(0xff1c4f57)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  height: 56,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 12),
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      "assets/Back.svg",
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                SizedBox(height: 50,),


                /// Title
                const Text(
                  "Your avatar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Take a selfie to generate\nyour own anonymous avatar",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),

                const SizedBox(height: 40),

                /// Avatar Picker
                GestureDetector(
                  onTap: isGenerating ? null : pickImage,
                  child: AnimatedRotation(
                    turns: isGenerating ? 100 : 1,
                    duration: const Duration(seconds: 1),
                    curve: Curves.linear,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isGenerating ? Colors.white : Colors.white70,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 85,
                        backgroundColor: Colors.black26,
                        backgroundImage:
                        avatarImage != null ? FileImage(avatarImage!) : null,
                        child: avatarImage == null
                            ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white70,
                        )
                            : null,
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 30),
                Icon(Icons.lock, color: Colors.white70, size: 18),

                /// Privacy Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "No one will see your real photo. We do not store anything and use it only to generate an avatar.",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                /// Continue Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(35)),
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isGenerating
                          ? null
                          : () {
                        startGenerating();

                        Future.delayed(const Duration(seconds: 3), () {
                          setState(() {
                            isGenerating = false;
                          });

                          // TODO: Navigate next
                        });
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isGenerating
                            ? "Your avatar is generating..."
                            : "Continue",
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
