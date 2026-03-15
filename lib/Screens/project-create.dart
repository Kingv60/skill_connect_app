import 'package:flutter/material.dart';

class ProjectCreatePage extends StatefulWidget {
  const ProjectCreatePage({super.key});

  @override
  State<ProjectCreatePage> createState() => _ProjectCreatePageState();
}

class _ProjectCreatePageState extends State<ProjectCreatePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController skillController = TextEditingController();

  List<String> skills = [];
  int maxMembers = 5;
  bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: const Text(
          "Create Project",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [

            /// 🔹 Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 20),

                    /// 📌 Project Title
                    _sectionTitle("Project Title"),
                    const SizedBox(height: 8),
                    _darkCard(
                      child: TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Enter project title",
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 📄 About Project
                    _sectionTitle("About Project"),
                    const SizedBox(height: 8),
                    _darkCard(
                      child: TextField(
                        controller: aboutController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Describe your project...",
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🛠 Requirements
                    _sectionTitle("Requirements"),
                    const SizedBox(height: 8),
                    _darkCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: skillController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: "Add skill (e.g. Flutter)",
                                    hintStyle:
                                    TextStyle(color: Colors.white38),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (skillController.text.isNotEmpty) {
                                    setState(() {
                                      skills.add(skillController.text);
                                      skillController.clear();
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add,
                                    color: Colors.white),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: skills
                                .map((e) => _DarkChip(
                              label: e,
                              onRemove: () {
                                setState(() {
                                  skills.remove(e);
                                });
                              },
                            ))
                                .toList(),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 👥 Max Members
                    _sectionTitle("Max Members"),
                    const SizedBox(height: 8),
                    _darkCard(
                      child: DropdownButton<int>(
                        dropdownColor: const Color(0xFF121212),
                        value: maxMembers,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white),
                        items: List.generate(
                          10,
                              (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text("${index + 1} Members"),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            maxMembers = value!;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔄 Status Toggle
                    _sectionTitle("Project Status"),
                    const SizedBox(height: 8),
                    _darkCard(
                      child: SwitchListTile(
                        value: isOpen,
                        activeColor: Colors.greenAccent,
                        title: Text(
                          isOpen ? "Open" : "Closed",
                          style:
                          const TextStyle(color: Colors.white),
                        ),
                        onChanged: (value) {
                          setState(() {
                            isOpen = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            /// 🔹 Bottom Fixed Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF000000),
                border: Border(
                  top: BorderSide(color: Colors.white12),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    print("Title: ${titleController.text}");
                    print("About: ${aboutController.text}");
                    print("Skills: $skills");
                    print("Max Members: $maxMembers");
                    print("Status: ${isOpen ? "Open" : "Closed"}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Create Project"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  static Widget _darkCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

/// 🏷 Chip with remove option
class _DarkChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _DarkChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 16, color: Colors.white70),
          )
        ],
      ),
    );
  }
}