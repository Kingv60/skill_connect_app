import 'package:flutter/material.dart';
import '../Model/my_project_model.dart';
import '../Services/api-service.dart';
import 'my_project_info.dart'; // Ensure this points to the Detail Page we styled

class MyProjectsPage extends StatefulWidget {
  const MyProjectsPage({super.key});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  List<MyProject> projects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final data = await ApiService().getMyProjects();
    setState(() {
      projects = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        title: const Text(
          "My Projects",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,color: Colors.white),
        ),
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
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF0F0F10),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => fetchProjects(),
          )
        ],
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      )
          : projects.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.work_outline, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No Project Yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchProjects,
        color: Colors.blueAccent,
        child: ListView.builder(
          itemCount: projects.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemBuilder: (context, index) {
            return _buildProjectCard(projects[index]);
          },
        ),
      ),
    );
  }

  Widget _buildProjectCard(MyProject project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title and Status Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right, color: Colors.white38),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Footer: Tech Stack Preview & Member Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Show first 2-3 techs as mini-chips
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: project.techStack.take(3).map((tech) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tech,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Member Icon
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        "${project.membersCount}",
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}