import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../Constants/constants.dart';
import '../Model/Project_Request_get.dart';
import '../Model/my_project_model.dart';
import '../Services/api-service.dart';

class ProjectDetailPage extends StatefulWidget {
  final MyProject project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  // Local list to manage the requests so we can remove them
  // For now, it's a dummy list. You can populate this from widget.project data.
  List<JoinRequest> requests = []; // Use the Model instead of String
  bool isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => isLoading = true);
    final data = await _apiService.fetchOwnerRequests();
    setState(() {
      requests = data;
      isLoading = false;
    });
  }

  void _showJoiningRequests(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (modalContext) {
        // StatefulBuilder allows the modal to rebuild itself when an item is removed
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Text(
                    "Pending Requests",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Check if list is empty to show a message
                  requests.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No pending requests",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        )
                      : Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: requests.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                              // Inside your ListView.separated:
                              itemBuilder: (context, index) {
                                final request = requests[index];
                                return _buildRequestItem(
                                  context,
                                  request,
                                  onAccept: () async {
                                    // 1. Call API
                                    bool success = await _apiService.updateRequestStatus(request.interactionId, 'accepted');
                                    if (success) {
                                      // 2. Remove from local list inside the modal
                                      setModalState(() => requests.removeAt(index));
                                      // 3. Update the badge count on the main page
                                      setState(() {});
                                    }
                                  },
                                  onReject: () async {
                                    bool success = await _apiService.updateRequestStatus(request.interactionId, 'rejected');
                                    if (success) {
                                      setModalState(() => requests.removeAt(index));
                                      setState(() {});
                                    }
                                  },
                                );
                              }
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.project.title, // Accessing via widget.project
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      _buildMemberBadge(),
                    ],
                  ),
                  Text(
                    "Published on ${widget.project.createdAt}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "About Project",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.project.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Technologies",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.project.techStack
                        .map((tech) => _buildTechChip(tech))
                        .toList(),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _showJoiningRequests(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "All Joining Requests (${requests.length})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  // Helper method for request items
  Widget _buildRequestItem(
    BuildContext context,
    JoinRequest request,
      {required VoidCallback onAccept, required VoidCallback onReject}
  ) {
    return Container(
      // ... same decoration ...
      child: Column(
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 40, // standard CircleAvatar size (radius 20 * 2)
                  height: 40,
                  child: request.avatarUrl != null
                      ? (request.avatarUrl!.toLowerCase().endsWith('.svg')
                      ? SvgPicture.network(
                    '$baseUrl${request.avatarUrl}',
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    '$baseUrl${request.avatarUrl}',
                    fit: BoxFit.cover,
                  ))
                      : Container(
                    color: const Color(0xFF1C1C1E),
                    alignment: Alignment.center,
                    child: Text(
                      request.applicantName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.applicantName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      request.message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Reject/Accept buttons ...
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              // Reject Button
              Expanded(
                child: TextButton.icon(
                  onPressed: onReject,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  label: const Text(
                    "Reject",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    // Vertical padding for height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12), // Gap between the two equal buttons
              // Accept Button
              Expanded(
                child: TextButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(
                    Icons.check,
                    color: Colors.greenAccent,
                    size: 18,
                  ),
                  label: const Text(
                    "Accept",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.greenAccent.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    // Match height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 80,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildMemberBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.group, size: 16, color: Colors.blueAccent),
          const SizedBox(width: 6),
          Text(
            "${widget.project.membersCount}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
