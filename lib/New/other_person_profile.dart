import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/Constants/constants.dart';
import '../Model/chatModel.dart';
import '../Provider/chat_provider.dart';
import '../Provider/search_provider.dart';
import '../Services/api-service.dart';
import '../message.dart';
import '../profile.dart'; // For SkillChip and VideoListItem components

class OtherPersonProfile extends ConsumerStatefulWidget {
  final int userId;
  const OtherPersonProfile({super.key, required this.userId});

  @override
  ConsumerState<OtherPersonProfile> createState() => _OtherPersonProfileState();
}

class _OtherPersonProfileState extends ConsumerState<OtherPersonProfile> {

  void _navigateToChat(String name, String avatar) {
    // 1. Access the list of chats currently held in your Provider
    final chatsState = ref.read(allChatsProvider);

    chatsState.when(
      data: (chats) {
        // 2. Look for existing chat using userId (safer than name)
        final existingChat = chats.firstWhere(
              (c) => c.userId == widget.userId,
          orElse: () => ChatSummary(
            conversationId: -1,
            name: name,
            avatar: avatar,
            lastMessage: '',
            userId: widget.userId,
            lastTime: '',
          ),
        );

        if (existingChat.conversationId != -1) {
          // ✅ SUCCESS: Navigate to existing chat
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                name: existingChat.name,
                image: existingChat.avatar,
                conversationId: existingChat.conversationId,
                receiverId: widget.userId,
              ),
            ),
          );
        } else {
          // 🆕 NO CHAT EXISTED: Create it using search provider logic
          _createAndNavigate(name, avatar);
        }
      },
      loading: () => null,
      error: (err, stack) => debugPrint("Provider Error: $err"),
    );
  }

  // Helper function to handle the "Get or Create" API call
  Future<void> _createAndNavigate(String name, String avatar) async {
    // We use the logic from your ChatScreen reference
    final int? newId = await ref
        .read(chatSearchProvider.notifier)
        .startConversation(widget.userId);

    if (newId != null && mounted) {
      // Refresh the main chat list so the new chat is tracked immediately
      ref.read(allChatsProvider.notifier).fetchChats();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            name: name,
            image: avatar,
            conversationId: newId,
            receiverId: widget.userId,
          ),
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to connect to chat")),
        );
      }
    }
  }
  Color backgroundColor = const Color(0xff262626);
  Color textColor = Colors.white;

  dynamic otherUserProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadColors();
    _fetchData();
  }

  // Fetch both profile and videos directly from ApiService
  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService().getOtherUserProfile(widget.userId);
      if (mounted) {
        setState(() {
          otherUserProfile = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> loadColors() async {
    final prefs = await SharedPreferences.getInstance();
    int? bg = prefs.getInt('bgColor');
    int? text = prefs.getInt('textColor');
    if (bg != null) backgroundColor = Color(bg);
    if (text != null) textColor = Color(text);
    if (mounted) setState(() {});
  }

  Widget _buildAvatar(String? url) {
    if (url == null || url.isEmpty) {
      return const CircleAvatar(
          backgroundColor: Colors.white10,
          child: Icon(Icons.person, color: Colors.white)
      );
    }






    return ClipOval(
      child: url.toLowerCase().endsWith(".svg")
          ? SvgPicture.network(
        baseUrlImage+url,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => const Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      )
          : Image.network(
        baseUrlImage+url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: Colors.white24, size: 40);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Loading state to prevent "method [] called on null"
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    // 2. Error state if API returns null
    if (otherUserProfile == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("User not found", style: TextStyle(color: Colors.white54)),
              TextButton(onPressed: _fetchData, child: const Text("Retry"))
            ],
          ),
        ),
      );
    }

    final String name = otherUserProfile['name'] ?? "User";
    final String username = otherUserProfile['username'] ?? "creator";
    final String role = otherUserProfile['role'] ?? "Creative Professional";
    final String bio = otherUserProfile['bio'] ?? "No bio available";
    final String avatar = otherUserProfile['avatar'] ?? "";
    final List<dynamic> skills = otherUserProfile['skills'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- TOP BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
                      onPressed: () => Navigator.pop(context)),
                  Text(username, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
            ),

            /// --- PROFILE HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    height: 85, width: 85,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
                    child: _buildAvatar(avatar),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(role, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(bio, style: const TextStyle(color: Colors.white54, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// --- SKILLS ---
            if (skills.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: skills.map((s) => SkillChip(text: s.toString())).toList(),
                ),
              ),

            /// --- ACTION BUTTONS ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _ActionButton(title: "Message", color: Colors.blueAccent, textColor: Colors.white, onTap: () {_navigateToChat(name, avatar);})),
                  const SizedBox(width: 8),
                  Expanded(child: _ActionButton(title: "Follow", textColor: Colors.white, onTap: () {})),
                ],
              ),
            ),

            const Divider(color: Colors.white10),

            /// --- VIDEOS SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("$name's Videos", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: ApiService().getVideosByUserId(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No videos found", style: TextStyle(color: Colors.white38)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => VideoListItem(video: snapshot.data![index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color textColor;
  final Color? color;

  const _ActionButton({required this.title, required this.onTap, required this.textColor, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color ?? Colors.white24),
        ),
        child: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}