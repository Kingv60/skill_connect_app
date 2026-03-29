import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../Constants/constants.dart';
import '../New/other_person_profile.dart';
import '../Provider/search_provider.dart';

class UserSearchScreen extends ConsumerWidget {
  const UserSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(chatSearchProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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

        title: _buildSearchBar(ref),
      ),
      body: searchResults.isEmpty
          ? const Center(child: Text("Search for creators", style: TextStyle(color: Colors.white54)))
          : _buildResultsList(searchResults),
    );
  }

  // 🔍 THE CHAT-STYLE SEARCH BAR
  // 🔍 THE CHAT-STYLE SEARCH BAR
  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          // 🔴 NEW LOGIC: Only call API if length is more than 2
          if (value.trim().length > 2) {
            ref.read(chatSearchProvider.notifier).searchUsers(value);
          } else if (value.trim().isEmpty) {
            // Optional: Clear results if user deletes everything
            ref.read(chatSearchProvider.notifier).clearSearch();
          }
        },
        decoration: const InputDecoration(
          hintText: "Search creators...",
          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // 📝 RESULTS LIST
  Widget _buildResultsList(List<dynamic> results) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];

        // 1. Fix Localhost and handle URL formatting
        String avatarUrl = user['avatar'] ?? "";
        if (avatarUrl.contains("localhost")) {
          avatarUrl = avatarUrl;
        }
        // Ensure it has the full http prefix if it's just a path
        if (!avatarUrl.startsWith("http") && avatarUrl.isNotEmpty) {
          avatarUrl = baseUrlImage+avatarUrl;
        }

        return ListTile(
          onTap: () {
            // Ensure we extract the ID correctly from the search response
            final userId = results[index]['user_id'];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherPersonProfile(userId: int.parse(userId.toString())),
              ),
            );
          },
          leading: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1A1A1A),
            ),
            child: ClipOval(
              child: avatarUrl.toLowerCase().endsWith(".svg")
                  ? SvgPicture.network(
                avatarUrl,
                fit: BoxFit.cover,
                placeholderBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : Image.network(

                avatarUrl.isNotEmpty ? baseUrl+avatarUrl : "https://picsum.photos/200",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.person, color: Colors.white38),
              ),
            ),
          ),
          title: Text(
            user['name'] ?? "User",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "@${user['username'] ?? 'creator'}",
            style: const TextStyle(color: Color(0xFF8F94FB), fontSize: 12),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        );
      },
    );
  }
}