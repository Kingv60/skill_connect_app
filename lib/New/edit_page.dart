import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skillconnect/Constants/constants.dart';
import '../Provider/profile_provider.dart';
import '../Services/api-service.dart';
import '../Services/AppColors.dart'; // Ensure this matches your path

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController skillController = TextEditingController();

  List<String> skills = [];
  File? selectedImage;
  String? avatarUrl;
  String? generatedSvg; // Stores SVG string
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      final api = ApiService();
      final data = await api.getProfile();
      setState(() {
        nameController.text = data["name"] ?? "";
        usernameController.text = data["username"] ?? "";
        bioController.text = data["bio"] ?? "";
        roleController.text = data["role"] ?? "";
        avatarUrl = data["avatar_url"];
        skills = (data["skills"] ?? "").toString().split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Open Modern Choice Sheet
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("Update Profile Picture", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPickerOption(
              icon: Icons.image_search_rounded,
              title: "Gallery",
              subtitle: "Upload a photo from your library",
              onTap: () {
                Navigator.pop(context);
                pickImage();
              },
            ),
            const SizedBox(height: 12),
            _buildPickerOption(
              icon: Icons.auto_awesome_rounded,
              title: "Avatar Studio",
              subtitle: "Generate a custom vector avatar",
              onTap: () {
                Navigator.pop(context);
                _showAvatarGenerator();
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  /// 🔹 Avatar Generation Dialog
  void _showAvatarGenerator() {
    String currentSeed = usernameController.text.isNotEmpty ? usernameController.text : "user";
    String tempSvg = multiavatar(currentSeed);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Avatar Studio", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  height: 130, width: 130,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                  child: ClipOval(child: SvgPicture.string(tempSvg)),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => setDialogState(() => tempSvg = multiavatar(DateTime.now().toString())),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  label: const Text("Generate New", style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.only(bottom: 15, right: 15, left: 15),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  setState(() {
                    generatedSvg = tempSvg;
                    selectedImage = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Use Avatar", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() {
      selectedImage = File(image.path);
      generatedSvg = null; // Reset SVG if image is picked
    });
  }

  void addSkill() {
    final text = skillController.text.trim();
    if (text.isNotEmpty && !skills.contains(text)) {
      setState(() { skills.add(text); skillController.clear(); });
    }
  }

  void removeSkill(String skill) => setState(() => skills.remove(skill));

  Future<void> saveProfile() async {
    setState(() => isLoading = true);
    try {
      File? finalAvatar;
      if (selectedImage != null) {
        finalAvatar = selectedImage;
      } else if (generatedSvg != null) {
        // Convert SVG string to File for API
        final tempDir = await getTemporaryDirectory();
        finalAvatar = await File('${tempDir.path}/avatar.svg').writeAsBytes(utf8.encode(generatedSvg!));
      }

      await ApiService().updateProfile( // Assumes you have an updateProfile method
        name: nameController.text,
        username: usernameController.text,
        bio: bioController.text,
        role: roleController.text,
        skills: skills.join(","),
        avatarFile: finalAvatar,
      );

      await ref.read(profileProvider.notifier).loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated"), backgroundColor: AppColors.success));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(onPressed: saveProfile, child: const Text("Save", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showAvatarPicker,
                  child: Stack(
                    children: [
                      Container(
                        height: 100, width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                        ),
                        child: ClipOval(
                          child: generatedSvg != null
                              ? SvgPicture.string(generatedSvg!)
                              : buildAvatarContent(avatarUrl, selectedImage),
                        ),
                      ),
                      Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary), child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              _sectionTitle("Personal Info"),
              const SizedBox(height: 15),
              _darkTextField(nameController, "Full Name", Icons.person_outline),
              const SizedBox(height: 15),
              _darkTextField(usernameController, "Username", Icons.alternate_email),
              const SizedBox(height: 25),
              _sectionTitle("Professional Info"),
              const SizedBox(height: 15),
              _darkTextField(roleController, "Current Role", Icons.work_outline),
              const SizedBox(height: 15),
              _darkTextField(bioController, "Bio", Icons.notes, maxLines: 3),
              const SizedBox(height: 25),
              _sectionTitle("Skills"),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: _darkTextField(skillController, "Add Skill", Icons.bolt)),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: addSkill, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)), child: const Text("Add")),
              ]),
              const SizedBox(height: 15),
              Wrap(spacing: 8, runSpacing: 8, children: skills.map((skill) => Chip(label: Text(skill, style: const TextStyle(color: Colors.white, fontSize: 12)), backgroundColor: AppColors.surface, deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70), onDeleted: () => removeSkill(skill), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),))).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAvatarContent(String? url, File? file) {
    if (file != null) return Image.file(file, fit: BoxFit.cover);
    return AppAvatar(url: url); // Uses your existing AppAvatar widget
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2));

  Widget _darkTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}