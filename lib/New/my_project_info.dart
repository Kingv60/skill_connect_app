import 'dart:ui';
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
  List<JoinRequest> requests = [];
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
      backgroundColor: Colors.transparent, // For Glassmorphism
      isScrollControlled: true,
      builder: (modalContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161618).withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Incoming Requests",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        _badge(requests.length.toString()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    requests.isEmpty
                        ? _emptyRequests()
                        : Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: requests.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return _buildRequestItem(
                            context,
                            request,
                            onAccept: () async {
                              bool success = await _apiService.updateRequestStatus(request.interactionId, 'accepted');
                              if (success) {
                                setModalState(() => requests.removeAt(index));
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
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF000000),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.project.title,
                            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1),
                          ),
                        ),
                        _buildMemberBadge(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Launched on ${widget.project.createdAt}",
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 32),
                    _sectionTitle("Description"),
                    Text(
                      widget.project.description,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 32),
                    _sectionTitle("Core Technologies"),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.project.techStack.map((tech) => _buildTechChip(tech)).toList(),
                    ),
                    const SizedBox(height: 40),
                    _buildMainButton(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, JoinRequest request, {required VoidCallback onAccept, required VoidCallback onReject}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(request),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.applicantName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(request.message, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _requestButton("Decline", Icons.close, Colors.redAccent, onReject)),
              const SizedBox(width: 12),
              Expanded(child: _requestButton("Approve", Icons.check_rounded, Colors.greenAccent, onAccept)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(JoinRequest request) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
      child: ClipOval(
        child: request.avatarUrl != null
            ? (request.avatarUrl!.toLowerCase().endsWith('.svg')
            ? SvgPicture.network('$baseUrl${request.avatarUrl}', fit: BoxFit.cover)
            : Image.network('$baseUrl${request.avatarUrl}', fit: BoxFit.cover))
            : Center(child: Text(request.applicantName[0], style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _requestButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E3192), Color(0xFF1BFFFF), Color(0xFFD4145A)],
        ),
      ),
      child: Stack(
        children: [
          Center(child: Icon(Icons.rocket_launch_rounded, size: 100, color: Colors.white.withOpacity(0.2))),
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.5)]))),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.indigoAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: () => _showJoiningRequests(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigoAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mail_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text("Review Requests (${requests.length})", style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
    );
  }

  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildMemberBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
      child: Row(
        children: [
          const Icon(Icons.group_rounded, size: 18, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text("${widget.project.membersCount}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _badge(String count) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
      child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _emptyRequests() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Text("No pending talent requests", style: TextStyle(color: Colors.white38, fontSize: 16)),
    );
  }
}