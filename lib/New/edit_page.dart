import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../Provider/profile_provider.dart';
import '../Services/api-service.dart';

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

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// 🔹 Load profile from API
  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      final api = ApiService();
      final data = await api.getProfile();

      if (data.containsKey("error")) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data["message"] ?? "Error")));
        return;
      }

      setState(() {
        nameController.text = data["name"] ?? "";
        usernameController.text = data["username"] ?? "";
        bioController.text = data["bio"] ?? "";
        roleController.text = data["role"] ?? "";
        avatarUrl = data["avatar_url"];

        // Convert skills to List<String>
        skills = (data["skills"] ?? "")
            .toString()
            .split(",")
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Pick Avatar Image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  /// 🔹 Add Skill
  void addSkill() {
    final text = skillController.text.trim();
    if (text.isNotEmpty && !skills.contains(text)) {
      setState(() {
        skills.add(text);
        skillController.clear();
      });
    }
  }

  /// 🔹 Remove Skill
  void removeSkill(String skill) {
    setState(() {
      skills.remove(skill);
    });
  }

  /// 🔹 Save Profile
  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    try {
      final api = ApiService();

      final data = await api.updateProfile(
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        bio: bioController.text.trim(),
        role: roleController.text.trim(),
        skills: skills.join(","),
        avatarFile: selectedImage,
      );
      await ref.read(profileProvider.notifier).loadProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: saveProfile,
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Avatar
              Center(
                child: GestureDetector(
                  onTap: pickImage, // pick new avatar
                  child: Stack(
                    children: [
                      buildAvatar(
                        size: 85,
                        avatarUrl: avatarUrl,
                        localFile: selectedImage,
                        borderColor: Colors.white,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              /// Name
              _sectionTitle("Name"),
              const SizedBox(height: 8),
              _darkTextField(nameController, "Enter your full name"),
              const SizedBox(height: 20),
              /// Username
              _sectionTitle("Username"),
              const SizedBox(height: 8),
              _darkTextField(usernameController, "Enter your username"),

              const SizedBox(height: 20),

              /// Role
              _sectionTitle("Role"),
              const SizedBox(height: 8),
              _darkTextField(roleController, "Enter your role"),

              const SizedBox(height: 20),

              /// Bio
              _sectionTitle("Bio"),
              const SizedBox(height: 8),
              _darkTextField(bioController, "Write something about you", maxLines: 3),

              const SizedBox(height: 20),

              /// Skills
              _sectionTitle("Skills"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _darkTextField(skillController, "Add a skill")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: addSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Add"),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills
                    .map((skill) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(skill, style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => removeSkill(skill),
                        child: const Icon(Icons.close, size: 16, color: Colors.white70),
                      )
                    ],
                  ),
                ))
                    .toList(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _darkTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white30)),
      ),
    );
  }
}

Widget buildAvatar({
  required double size,
  String? avatarUrl,
  File? localFile,
  Color borderColor = Colors.white,
}) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: 2),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: localFile != null
          ? Image.file(
        localFile,
        fit: BoxFit.cover,
      )
          : (avatarUrl != null && avatarUrl.isNotEmpty
          ? (avatarUrl.toLowerCase().endsWith(".svg")
          ? SvgPicture.network(
        avatarUrl,
        placeholderBuilder: (context) =>
        const Center(child: CircularProgressIndicator()),
        fit: BoxFit.cover,
      )
          : Image.network(
        "http://localhost:8000$avatarUrl",
        fit: BoxFit.cover,
      ))
          : const Icon(Icons.person, size: 50, color: Colors.white)),
    ),
  );
}