import 'package:flutter/material.dart';
import 'package:skillconnect/Screens/Home.dart';

import '../Services/api-service.dart';


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
  bool isLoading = false;

  Future<void> createProject() async {
    if (titleController.text.isEmpty || aboutController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final api = ApiService();

    bool success = await api.createProject(
      title: titleController.text,
      description: aboutController.text,
      techStack: skills,
      membersCount: maxMembers,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project created successfully")),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create project")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1, color: Colors.white),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: const Text("Create Project",
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 20),

                  const Text("Project Title",
                      style: TextStyle(color: Colors.white)),

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

                  const Text("About Project",
                      style: TextStyle(color: Colors.white)),

                  const SizedBox(height: 8),

                  _darkCard(
                    child: TextField(
                      controller: aboutController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Describe your project",
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text("Requirements",
                      style: TextStyle(color: Colors.white)),

                  const SizedBox(height: 8),

                  _darkCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: skillController,
                                style:
                                const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Add skill",
                                  hintStyle:
                                  TextStyle(color: Colors.white38),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  color: Colors.white),
                              onPressed: () {
                                if (skillController.text.isNotEmpty) {
                                  setState(() {
                                    skills.add(skillController.text);
                                    skillController.clear();
                                  });
                                }
                              },
                            )
                          ],
                        ),

                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 8,
                          children: skills
                              .map((skill) => Chip(
                            label: Text(skill),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                skills.remove(skill);
                              });
                            },
                          ))
                              .toList(),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text("Max Members",
                      style: TextStyle(color: Colors.white)),

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

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : createProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Create Project"),
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget _darkCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}