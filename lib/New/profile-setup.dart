import 'package:flutter/material.dart';

import 'avtar-page.dart';

class ProfileSetupPage extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const ProfileSetupPage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {

  final usernameController = TextEditingController();
  final skillController = TextEditingController();
  final bioController = TextEditingController();
  final roleController = TextEditingController();

  bool usernameAvailable = false;

  /// Selected Skills
  List<String> skills = [];

  /// Skill Suggestions
  List<String> suggestions = [
    "Flutter",
    "Node.js",
    "React",
    "Python",
    "Java",
    "UI/UX",
    "Machine Learning",
    "Firebase",
    "Dart",
    "SQL"
  ];

  List<String> filteredSuggestions = [];

  /// Role Suggestions
  List<String> roleSuggestions = [
    "Developer",
    "Designer",
    "Student",
    "Mentor",
    "Freelancer",
    "Project Manager"
  ];

  /// -----------------------
  /// USERNAME CHECK API
  /// -----------------------
  Future<void> checkUsername() async {

    String username = usernameController.text;

    if (username.isEmpty) return;

    /// Example API call
    /// final response = await ApiService().checkUsername(username);

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      usernameAvailable = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Username available")),
    );
  }

  /// -----------------------
  /// ADD SKILL
  /// -----------------------
  void addSkill(String skill) {

    skill = skill.trim();

    if (skill.isEmpty) return;

    if (!skills.contains(skill)) {
      setState(() {
        skills.add(skill);
      });
    }

    skillController.clear();
    filteredSuggestions.clear();
  }

  /// -----------------------
  /// FILTER SKILLS
  /// -----------------------
  void filterSkills(String value) {

    setState(() {
      filteredSuggestions = suggestions
          .where((skill) =>
          skill.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  /// -----------------------
  /// SUBMIT
  /// -----------------------
  void submitProfile() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarCreatePage(

          /// REGISTER DATA
          name: widget.name,
          email: widget.email,
          password: widget.password,

          /// PROFILE DATA
          username: usernameController.text,
          skills: skills,
          bio: bioController.text,
          role: roleController.text,

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Create Profile"),
        backgroundColor: const Color(0xFFFFFFFF),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          children: [

            /// USERNAME
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF8F94FB)),
              ),

              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Username",
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: checkUsername,
                    child: const Text(
                      "Check",
                      style: TextStyle(color: Color(0xFF8F94FB)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SKILLS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF8F94FB)),
              ),
              child: Row(
                children: [

                  /// INPUT FIELD
                  Expanded(
                    child: TextField(
                      controller: skillController,
                      onChanged: filterSkills,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Add Skills",
                      ),
                    ),
                  ),

                  /// SAVE ICON
                  IconButton(
                    icon: const Icon(Icons.check, color: Color(0xFF8F94FB)),
                    onPressed: () {
                      if (skillController.text.trim().isNotEmpty) {
                        addSkill(skillController.text.trim());
                      }
                    },
                  )
                ],
              ),
            ),

            /// SKILL SUGGESTIONS
            if (filteredSuggestions.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(top: 10),

                child: Wrap(
                  spacing: 10,

                  children: filteredSuggestions.map((skill) {

                    return ActionChip(
                      label: Text(skill),
                      onPressed: () => addSkill(skill),
                    );

                  }).toList(),
                ),
              ),

            const SizedBox(height: 10),

            /// SELECTED SKILLS
            Wrap(
              spacing: 2  ,

              children: skills.map((skill) {

                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Chip(
                    label: Text(skill),

                    deleteIcon: const Icon(Icons.close),

                    onDeleted: () {

                      setState(() {
                        skills.remove(skill);
                      });

                    },
                  ),
                );

              }).toList(),
            ),

            const SizedBox(height: 20),

            /// BIO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF8F94FB)),
              ),

              child: TextField(
                controller: bioController,
                maxLines: 3,

                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Bio (Optional)",
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ROLE (Typable Suggestions)
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {

                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }

                return roleSuggestions.where((role) =>
                    role.toLowerCase().contains(
                        textEditingValue.text.toLowerCase()));
              },

              onSelected: (String selection) {
                roleController.text = selection;
              },

              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF8F94FB)),
                  ),

                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,

                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type Role",
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            /// NEXT BUTTON
            GestureDetector(
              onTap: submitProfile,

              child: Container(
                height: 50,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF8F94FB),
                ),

                child: const Center(
                  child: Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}