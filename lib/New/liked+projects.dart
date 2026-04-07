import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/New/project-info.dart';
import '../Model/liked_project.dart';

import '../Services/AppColors.dart';
import '../Services/api-service.dart';

class LikedProjectsPage extends StatefulWidget {
  const LikedProjectsPage({super.key});

  @override
  State<LikedProjectsPage> createState() => _LikedProjectsPageState();
}

class _LikedProjectsPageState extends State<LikedProjectsPage> {
  final ApiService _apiService = ApiService();
  late Future<List<LikedProject>> _likedProjectsFuture;

  @override
  void initState() {
    super.initState();
    _likedProjectsFuture = _apiService.getLikedProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "LIKED PROJECTS",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<LikedProject>>(
        future: _likedProjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (snapshot.hasError) {
            return _buildErrorState("Something went wrong");
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final projects = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return _buildProjectCard(projects[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(LikedProject project) {
    return GestureDetector(
      onTap: () {
        // Navigate to Project Info Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectInfoPage(
              projectId: project.projectId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textMuted.withOpacity(0.1)),
          // Adding a subtle splash effect simulation with a shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: ClipOval(
                    child: _buildAvatarImage(project.avatarUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "@${project.username}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.favorite, color: AppColors.error, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.techStack.map((tech) => _buildTechChip(tech)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.accentBlue, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.heart_broken_outlined, size: 80, color: AppColors.textMuted.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            "No liked projects yet",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: AppColors.error)),
    );
  }
  Widget _buildAvatarImage(String? url) {

    // 1. Handle Null or Empty URL
    if (url == null || url.isEmpty) {
      return const Icon(
          Icons.person_rounded,
          color: AppColors.textSecondary,
          size: 24
      );
    }

    final String fullUrl = "$baseUrlImage$url";

    // 2. Handle SVG Files
    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        fullUrl,
        fit: BoxFit.cover,
        width: 44, // radius * 2
        height: 44,
        placeholderBuilder: (context) => const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // 3. Handle Standard Network Images (JPG/PNG)
    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      width: 44,
      height: 44,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_rounded),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}