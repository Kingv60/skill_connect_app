import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/chatModel.dart';
import '../Model/message_model.dart';
import '../Model/startConservation.dart';
import 'package:http_parser/http_parser.dart';

import 'helperclass.dart';

class ApiService {
  /// ===========================
  /// 🔹 BASE CONFIG
  /// ===========================
  static const String baseUrl = "http://localhost:8000/api";

  static String? token;
  static int? userId;

  /// ===========================
  /// 🔹 COMMON HEADERS
  /// ===========================
  static Map<String, String> get headers {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// ===========================
  /// 🔹 LOAD TOKEN & USERID FROM STORAGE
  /// ===========================
  static Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    userId = prefs.getInt("user_id");
    print("Loaded from prefs => token: $token, userId: $userId");
  }

  /// ===========================
  /// 1.. LOGIN FUNCTION
  /// ===========================
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");
    print("🚀 LOGIN REQUEST: $url");
    print("Headers: $headers");
    print("Body: ${jsonEncode({'email': email, 'password': password})}");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"email": email, "password": password}),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      token = data["token"];
      userId = data["user_id"];

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token!);
      await prefs.setInt("user_id", userId!);
      print("✅ Token and UserId saved to SharedPreferences");

      return data;
    } else {
      throw Exception(data["message"] ?? "Login failed");
    }
  }

  /// ===========================
  /// 2.. REGISTER FUNCTION
  /// ===========================
  Future<Map<String, dynamic>> registerUser(String name, String email,
      String password) async {
    final url = Uri.parse("$baseUrl/auth/register");
    print("🚀 REGISTER REQUEST: $url");
    print("Headers: $headers");
    print("Body: ${jsonEncode(
        {'name': name, 'email': email, 'password': password})}");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      token = data["token"];
      userId = data["user_id"] ?? data["user"]["user_id"];

      // ✅ Save token and userId in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token!);
      await prefs.setInt("user_id", userId!);
      print("✅ REGISTER SUCCESS: token=$token, userId=$userId saved to prefs");

      return data;
    } else {
      throw Exception(data["message"] ?? "Registration failed");
    }
  }


  /// ===========================
  /// 3.. CREATE PROFILE FUNCTION
  /// ===========================
  Future<Map<String, dynamic>> createProfile({
    required String username,
    required String skills,
    required String role,
    String? bio,
    File? avatarFile,
  }) async {
    final url = Uri.parse("$baseUrl/profile");
    print("🚀 CREATE PROFILE REQUEST: $url");
    print("Headers: Authorization: Bearer $token");
    print(
        "Fields => username: $username, skills: $skills, role: $role, bio: $bio");
    print("Avatar file: ${avatarFile?.path}");

    try {
      var request = http.MultipartRequest("POST", url);
      request.headers["Authorization"] = "Bearer $token";

      request.fields["username"] = username;
      request.fields["skills"] = skills;
      request.fields["role"] = role;
      if (bio != null && bio.isNotEmpty) request.fields["bio"] = bio;

      if (avatarFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath("avatar", avatarFile.path));
      }

      final streamedResponse = await request.send();
      final responseData = await streamedResponse.stream.bytesToString();

      print("STATUS CODE: ${streamedResponse.statusCode}");
      print("RESPONSE BODY: $responseData");

      final data = jsonDecode(responseData);

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Profile creation failed");
      }
    } catch (e) {
      print("CREATE PROFILE ERROR: $e");
      rethrow;
    }
  }

  /// ===========================
  /// 4.. DELETE USER FUNCTION
  /// ===========================
  Future<void> deleteUser(int userId) async {
    final url = Uri.parse("$baseUrl/auth/users/$userId");
    print("🚀 DELETE USER REQUEST: $url");
    print("Headers: $headers");

    try {
      final response = await http.delete(url, headers: headers);
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ User deleted successfully");
      } else {
        print("❌ Failed to delete user");
      }
    } catch (e) {
      print("DELETE USER ERROR: $e");
    }
  }


  /// ===========================
  /// 5.. Profile Get  FUNCTION
  /// ===========================
  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse("$baseUrl/profile");

    print("🚀 GET PROFILE REQUEST: $url");
    print("Headers: $headers");

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "error": true,
          "message": jsonDecode(response.body)["message"] ??
              "Failed to fetch profile"
        };
      }
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  /// ===========================
  /// 5.. START CONVERSATION
  /// ===========================
  Future<StartConversationResponse> startConversation(int receiverId) async {
    final url = Uri.parse('$baseUrl/messages/start');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // Replace with your actual token logic
        },
        body: jsonEncode({
          'receiver_id': receiverId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // This handles both a fresh creation and the "already exists" response
        return StartConversationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to start conversation: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  /// ===========================
  /// 6.. Get Messages of Specific Person
  /// ===========================

  Future<List<MessageModel>> getMessages(int conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/messages/$conversationId'),
      headers: {'Authorization': 'Bearer $token'},
    );


    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((m) => MessageModel.fromJson(m)).toList();
    }
    throw Exception("Failed to load messages");
  }

  /// ===========================
  /// 7.. SEND MESSAGE
  /// ===========================

  // Send Message
  Future<MessageModel?> sendMessage(int conversationId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "conversation_id": conversationId,
        "message": message,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MessageModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// ===========================
  /// 8.. ALL CHATS MESSAGE
  /// ===========================
  Future<List<ChatSummary>> fetchAllChats() async {
    final url = Uri.parse('$baseUrl/messages/chats');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((chat) => ChatSummary.fromJson(chat)).toList();
      } else {
        throw Exception("Failed to load chats");
      }
    } catch (e) {
      throw Exception("Error fetching chats: $e");
    }
  }



  /// ===========================
  /// 9.. SEARCH SUGGESTIONS
  /// ===========================
  Future<List<dynamic>> searchUsers(String query) async {
    print("API SEARCH: $query");

    final url = Uri.parse("$baseUrl/users/search?query=$query");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("API RESPONSE: ${response.body}");

    return jsonDecode(response.body);
  }

  /// ===========================
  /// 10.. GET GLOBAL FEED
  /// ===========================
  Future<List<dynamic>> getFeed() async {
    final response = await http.get(Uri.parse("$baseUrl/feed"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load feed");
    }
  }

  /// 2. GET MY POSTS (Requires Token)
  Future<List<dynamic>> getMyFeed() async {
    print("API MY FEED: Fetching user-specific videos...");

    // Update this URL to your 'My Videos' endpoint
    final url = Uri.parse("$baseUrl/media/me");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    print("API MY FEED RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return []; // Return empty list if unauthorized or error
    }
  }

  /// ===========================
  /// 11.. UPLOAD VIDEO FOR COURSE
  /// ===========================
  Future<bool> uploadMedia({
    required File mediaFile,
    File? thumbnailFile,
    required String caption,
    required Function(double progress) onProgress,
  }) async {
    try {
      // 1. Get the token exactly like your search function


      final url = Uri.parse("$baseUrl/media/upload");

      // 2. Initialize the progress-aware request
      var request = MultipartRequestWithProgress(
        'POST',
        url,
        onProgress: (bytes, total) {
          onProgress(bytes / total);
        },
      );

      // 3. Apply your Header Logic
      request.headers.addAll({
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      });

      // 4. Add Fields
      request.fields['caption'] = caption;

      // 5. Add Media File
      String ext = mediaFile.path.split('.').last.toLowerCase();
      request.files.add(await http.MultipartFile.fromPath(
        'media',
        mediaFile.path,
        contentType: MediaType(ext == 'mp4' ? 'video' : 'image', ext),
      ));

      // 6. Add Thumbnail (If exists)
      if (thumbnailFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'thumbnail',
          thumbnailFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // 7. Send and Print Response (like your search function)
      print("API SEARCH (Upload): $url");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("API RESPONSE: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      print("UPLOAD ERROR: $e");
      return false;
    }
  }

  /// ===========================
  /// 12.. DELETE VIDEO FROM COURSE
  /// ===========================
  Future<bool> deletePost(String token, int postId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/delete/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }
  /// Update Profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String username,
    required String skills,
    required String bio,
    required String role,
    File? avatarFile, // optional
  }) async {
    final url = Uri.parse("$baseUrl/profile"); // your updateProfile route

    var request = http.MultipartRequest("PUT", url);

    // Headers
    request.headers["Authorization"] = "Bearer $token";

    // Text fields
    request.fields["name"] = name;
    request.fields["username"] = username;
    request.fields["skills"] = skills;
    request.fields["bio"] = bio;
    request.fields["role"] = role;

    // Avatar file (optional)
    if (avatarFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "avatar", // must match your backend field
          avatarFile.path,
        ),
      );
    }



    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update profile: ${response.body}");
    }
  }

  /// ===========================
  /// 13.. GET OTHER PERSON PROFILE
  /// ===========================
  Future<Map<String, dynamic>?> getOtherUserProfile(int userId) async {
    try {
      // 1. Send the request
      final response = await http.get(
        Uri.parse("$baseUrl/other-profile/$userId"),
      );
      print("🚀 API REQUEST: GET $Uri");
      // 🔍 DEBUG: Print the response
      print("📡 API RESPONSE CODE: ${response.statusCode}");
      print("📦 API RESPONSE BODY: ${response.body}");
      print("-----------------------------------------");

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        // 2. Fix localhost for mobile images
        if (data['avatar'] != null && data['avatar'].contains("localhost")) {
          // Change localhost to 10.0.2.2 for Android Emulator
          data['avatar'] = data['avatar'];
        }

        return data;
      } else {
        print("Server Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Fetch Error: $e");
      return null;
    }
  }

  /// ===========================
  /// 14.. GET SPECIFIC PERSON VIDEOS
  /// ===========================
  Future<List<dynamic>> getVideosByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/other-profile/videos/$userId"),
      );

      if (response.statusCode == 200) {
        List<dynamic> videos = json.decode(response.body);

        // Fix localhost in thumbnail and media URLs
        return videos.map((v) {
          if (v['thumbnail_url'] != null) {
            v['thumbnail_url'] = v['thumbnail_url'];
          }
          if (v['media_url'] != null) {
            v['media_url'] = v['media_url'];
          }
          return v;
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}