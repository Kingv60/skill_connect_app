import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:skillconnect/Constants/constants.dart';

import '../Model/single_project_model.dart';
import '../Services/api-service.dart';
import '../message.dart';

class ProjectInfoPage extends StatefulWidget {
  final int projectId;

  const ProjectInfoPage({super.key, required this.projectId});

  @override
  State<ProjectInfoPage> createState() => _ProjectInfoPageState();
}

class _ProjectInfoPageState extends State<ProjectInfoPage> {
  late Future<SingleProjectGet?> projectFuture;

  @override
  void initState() {
    super.initState();
    // Assuming you have a way to get the token, e.g., from a Provider or Secure Storage
    projectFuture = ApiService().getProjectDetails(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
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
        centerTitle: true,
        title: const Text(
          "Project Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<SingleProjectGet?>(
          future: projectFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text(
                  "Failed to load project",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
        
            final project = snapshot.data!;
            return _buildContent(project);
          },
        ),
      ),
    );
  }

  Widget _buildContent(SingleProjectGet project) {
    final String fullAvatarUrl = project.avatarUrl.startsWith('http')
        ? project.avatarUrl
        : baseUrlImage + project.avatarUrl;

    // Print for debugging as requested
    debugPrint("DEBUG: Project Details Avatar URL -> $fullAvatarUrl");
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                /// 👤 Owner Info Row
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 40, // 2 * radius
                        height: 40,
                        child: project.avatarUrl.toLowerCase().endsWith('.svg')
                            ? SvgPicture.network(
                                baseUrlImage+project.avatarUrl,
                                fit: BoxFit.cover,
                                placeholderBuilder: (BuildContext context) =>
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                              )
                            : Image.network(
                                baseUrlImage+project.avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white54,
                                    ),
                              ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Posted on ${DateFormat('MMM dd, yyyy').format(project.createdAt)}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// 🔥 Project Title & Status
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusBadge("Active"),
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.group_outlined,
                      size: 20,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${project.membersCount} Members Involved",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// 📄 Description
                _sectionTitle("Overview"),
                const SizedBox(height: 10),
                Text(
                  project.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 30),

                /// 🛠 Tech Stack
                _sectionTitle("Tech Stack"),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: project.techStack
                      .map((tech) => _DarkChip(label: tech))
                      .toList(),
                ),

                const SizedBox(height: 30),

                /// 👥 Team Section (Mockup based on data)
                _sectionTitle("Team"),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _stackedAvatars(project.membersCount),
                      const SizedBox(width: 12),
                      Text(
                        "${project.membersCount} developers building this",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        /// 🔹 Bottom Action Bar
        _bottomActionBar(project),
      ],
    );
  }

  Widget _bottomActionBar(SingleProjectGet project) {
    return
    /// 🔹 Bottom Fixed Buttons (Premium Instagram Style)
    Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      // Extra bottom padding for modern devices
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          /// 🔘 Request/Join Button
          Expanded(
            child: SizedBox(
              height: 35,
              child: // Inside your _bottomActionBar widget
              ElevatedButton(
                onPressed: () async {
                  // 1. Show a loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sending request..."), duration: Duration(seconds: 1)),
                  );

                  // 2. Call the API (Pass your actual logic for ID and Token)
                  bool success = await ApiService().sendJoinRequest(
                    projectId: project.projectId,
                    message: "I’d like to join as frontend dev.",
                  );

                  // 3. Show Result
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Request sent successfully!"),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text("Failed to send request. Try again."),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Request"),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// 💬 Message Button
          Expanded(
            child: SizedBox(
              height: 35,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        name: project.username, // Dynamic from API
                        image: project.avatarUrl, // Dynamic from API
                        conversationId: project.ownerId, receiverId: project.ownerId, // Using owner_id from API
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Message",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stackedAvatars(int count) {
    return SizedBox(
      width: 70,
      height: 30,
      child: Stack(
        children: List.generate(count > 3 ? 3 : count, (index) {
          return Positioned(
            left: index * 18,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey[900],
              child: const Icon(Icons.person, size: 16, color: Colors.white54),
            ),
          );
        }),
      ),
    );
  }

  static Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  final String label;

  const _DarkChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
