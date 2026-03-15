import 'package:flutter/material.dart';
import 'package:skillconnect/message.dart';

class ProjectInfoPage extends StatelessWidget {
  const ProjectInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF000000),
        title: const Text(
          "Project Details",
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

                    const SizedBox(height: 16),

                    /// 🔥 Project Header
                    _darkCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "AI Study Platform",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatusBadge("Open"),
                              const SizedBox(width: 12),
                              const Icon(Icons.group,
                                  size: 18, color: Colors.white70),
                              const SizedBox(width: 4),
                              const Text(
                                "3 / 5 Members",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 📄 Description
                    _sectionTitle("About Project"),
                    const SizedBox(height: 8),
                    _darkCard(
                      child: const Text(
                        "This project aims to build an AI-powered study app "
                            "where users can upload notes and get smart summaries "
                            "and personalized quizzes.",
                        style: TextStyle(
                          height: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🛠 Requirements
                    _sectionTitle("Requirements"),
                    const SizedBox(height: 8),
                    _darkCard(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _DarkChip(label: "Flutter"),
                          _DarkChip(label: "Firebase"),
                          _DarkChip(label: "UI/UX"),
                          _DarkChip(label: "Python"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 👥 Members
                    _sectionTitle("Team Members"),
                    const SizedBox(height: 8),
                    _darkCard(
                      child: Row(
                        children: const [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFF1C1C1E),
                            child:
                            Icon(Icons.person, color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFF1C1C1E),
                            child:
                            Icon(Icons.person, color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFF1C1C1E),
                            child:
                            Icon(Icons.person, color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "+2 more",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            /// 🔹 Bottom Fixed Buttons (Instagram Style)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF000000),
                border: Border(
                  top: BorderSide(color: Colors.white12),
                ),
              ),
              child: Row(
                children: [
                  /// 🔘 Request Button
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Request"),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// 💬 Message Button
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                name: "name",
                                image: "image", conversationId: 1,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Message",
                          style:
                          TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🟢 Status Badge
  static Widget _buildStatusBadge(String status) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 🏷 Section Title
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

  /// 🖤 Dark Card Container
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

/// 🏷 Custom Dark Chip
class _DarkChip extends StatelessWidget {
  final String label;
  const _DarkChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
