import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/Model/globalFeed_model.dart';

import '../Model/Post_model.dart';
import '../Model/Project_Request_get.dart';
import '../Model/chatModel.dart';
import '../Model/liked_project.dart';
import '../Model/media_post_model.dart';
import '../Model/message_model.dart';
import '../Model/my_project_model.dart';
import '../Model/other_person_reel_model.dart';
import '../Model/reel_model.dart';
import '../Model/single_project_model.dart';
import '../Model/startConservation.dart';
import 'package:http_parser/http_parser.dart';

import 'helperclass.dart';

class ApiService {
  /// ===========================
  /// 🔹 BASE CONFIG
  /// ===========================
  static const String baseUrl = "http://10.42.226.55:8000/api";

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

  /// Username Check API
  Future<Map<String, dynamic>> checkUsernameAvailability(String username) async {
    final url = Uri.parse('$baseUrl/auth/check-username');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': username}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Returns {"available": true, "message": "Username is available"}
        return jsonDecode(response.body);
      } else {
        return {'available': false, 'message': "Server Error"};
      }
    } catch (e) {
      return {'available': false, 'message': "Connection Failed"};
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


  Future<List<dynamic>?> getPostComments(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/mediaPost/comments/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['comments']; // This matches the "comments" key in your Express res.json
      }
      return null;
    } catch (e) {
      print("Error fetching comments: $e");
      return null;
    }
  }


  /// Message reaction post

  Future<Map<String, dynamic>?> toggleReaction(int messageId, String emoji) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/messages/react"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Ensure you have the user's token stored
        },
        body: jsonEncode({
          "message_id": messageId,
          "emoji": emoji,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error toggling reaction: ${response.body}");
        return null;
      }
    } catch (e) {
      print("ApiService Exception: $e");
      return null;
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

  /// ===========================
  /// 6.. Get Messages of Specific Person (Updated)
  /// ===========================
  Future<List<MessageModel>> getMessages(int conversationId) async {
    final url = Uri.parse('$baseUrl/messages/messages/$conversationId');

    print("🚀 GET MESSAGES REQUEST: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("STATUS CODE: ${response.statusCode}");

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        // This maps the JSON to your MessageModel which now includes:
        // message, file_url, file_name, message_type, and reactions
        return data.map((m) => MessageModel.fromJson(m)).toList();
      } else {
        print("❌ FAILED TO LOAD MESSAGES: ${response.body}");
        return []; // Return empty list instead of crashing the UI
      }
    } catch (e) {
      print("⚠️ GET MESSAGES ERROR: $e");
      return []; // Return empty list on connection error
    }
  }

  /// ===========================
  /// 7.. SEND MESSAGE
  /// ===========================

  // Send Message
  /// ===========================
  /// 7.. SEND MESSAGE (UPDATED for Files/Images/Videos)
  /// ===========================
  Future<MessageModel?> sendMessage(
      int conversationId,
      String? message, {
        File? file,
        String type = 'text',
      }) async {
    final url = Uri.parse('$baseUrl/messages/send');

    try {
      // 1. Create Multipart Request
      var request = http.MultipartRequest('POST', url);
      print("Send Message");

      // 2. Add Authorization Header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        // Do NOT set Content-Type here; MultipartRequest sets it automatically
      });

      // 3. Add Text Fields (All must be Strings)
      request.fields['conversation_id'] = conversationId.toString();
      request.fields['message'] = message ?? "";
      request.fields['message_type'] = type;

      // 4. Attach the File (if one exists)
      if (file != null) {
        // We use fromPath to stream the file from disk
        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // This MUST match upload.single('file') in your Node.js code
            file.path,
            // Automatically detect mime type or use helper
            contentType: _getMediaType(file.path),
          ),
        );
      }

      // 5. Send and await response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("SEND MESSAGE STATUS: ${response.statusCode}");
      print("SEND MESSAGE BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print("Exception in sendMessage: $e");
      return null;
    }
  }

  /// Helper to determine the file type for the backend
  MediaType? _getMediaType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream');
    }
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
  /// ===========================
  /// 17.. UPLOAD VIDEO TO COURSE
  /// ===========================
  Future<bool> uploadVideo({
    required File videoFile,
    required File thumbnailFile, // Added this parameter
    required String title,
    String? description,
    String? courseId,
    required Function(double progress) onProgress,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt("user_id");
    final url = Uri.parse("$baseUrl/videos/$userId");
    print("🚀 UPLOAD VIDEO REQUEST: $url");


    try {
      var request = http.MultipartRequest('POST', url);

      // --- Headers ---
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // --- Text Fields ---
      request.fields['name'] = title;
      request.fields['description'] = description ?? "";
      request.fields['course_id'] = (courseId == null || courseId.isEmpty) ? "0" : courseId;

      // --- Video File ---
      request.files.add(
        await http.MultipartFile.fromPath(
          'video', // Matches backend req.files['video']
          videoFile.path,
        ),
      );

      // --- NEW: Thumbnail File ---
      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail', // Matches backend req.files['thumbnail']
          thumbnailFile.path,
        ),
      );

      // --- Send Request ---
      var streamedResponse = await request.send();

      // Logic for progress tracking (Simplified)
      // Note: To get real progress, you'd need a custom MultipartRequest class,
      // but we can simulate completion here for now.
      onProgress(1.0);

      var response = await http.Response.fromStream(streamedResponse);

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("UPLOAD VIDEO ERROR: $e");
      return false;
    }
  }

  /// Video by time
  Future<List<dynamic>> getAllVideosLatest() async {
    // 1. Get the user_id from local storage
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt("user_id");

    // 2. REQUIRED: Construct the URL with the query parameter
    // This turns it into: .../api/videos/all-latest?user_id=5
    final url = Uri.parse("$baseUrl/videos/all-latest?user_id=$userId");
    print("📡 Fetching Latest Videos for User $userId: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          return data['videos'] ?? [];
        }
      }

      print("❌ Error: ${response.statusCode}");
      return [];
    } catch (e) {
      print("⚠️ Connection Error: $e");
      return [];
    }
  }

  /// Enroll Api
  Future<Map<String, dynamic>> enrollInCourse(int courseId) async {
    final url = Uri.parse("$baseUrl/courses/enroll");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"course_id": courseId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Logic for both "New Enrollment" and "Already Enrolled"
        return {
          "success": true,
          "message": data['message'] ?? "Enrolled successfully!"
        };
      } else {
        return {
          "success": false,
          "message": data['error'] ?? data['message'] ?? "Failed to enroll."
        };
      }
    } catch (e) {
      print("❌ ENROLL ERROR: $e");
      return {"success": false, "message": "Connection error."};
    }
  }


  /// Video View Count API
  Future<Map<String, dynamic>?> updateVideoView({
    required int videoId,
    required int userId,
    required int watchedSeconds,
  }) async {
    final url = Uri.parse("$baseUrl/videos/view-update");
   print("🌐 Calling API: $url");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "video_id": videoId,
          "user_id": userId,
          "watched_seconds": watchedSeconds,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Server Error: ${response.body}");
        return null;
      }
    } catch (e) {

      return null;
    }
  }

  /// Get View Count and Details for a Specific Video
  Future<Map<String, dynamic>?> getVideoViews(int videoId) async {
    final url = Uri.parse("$baseUrl/videos/views/$videoId");

    print("📡 Fetching Views for Video: $videoId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      print("📡 View Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Return pura map taaki aap total_views aur details dono use kar sakein
        return data;
      } else {
        print("❌ Server Error while fetching views: ${response.body}");
        return null;
      }
    } catch (e) {
      print("🚨 Connection Error (View API): $e");
      return null;
    }
  }

  /// Get Reel By user id for Other person profile
  Future<List<OtherPersonReel>> fetchReelsByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/reels/$userId"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);

        // List of JSON ko List of OtherPersonReel mein map karna
        return body
            .map((dynamic item) => OtherPersonReel.fromJson(item))
            .toList();
      } else {
        debugPrint("❌ Failed to load reels: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("🔥 Api Error: $e");
      return [];
    }
  }

  /// Get Post by user id for other person
  Future<List<dynamic>> getPostsByUserId(int userId) async {
    try {
      // URL ko apne backend ke hisaab se check karein
      // Agar app.js mein prefix hai toh: "$baseUrl/api/posts/user/$userId"
      final response = await http.get(
        Uri.parse("$baseUrl/posts/mediaPost/user/$userId"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Backend se humne { "posts": [...] } bheja hai
        return data['posts'] ?? [];
      } else {
        debugPrint("Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching user posts: $e");
      return [];
    }
  }


  /// Get Video By user id in other person profile
  Future<List<dynamic>> getVideoByUserIdOther(int userId) async {

    final url = Uri.parse("$baseUrl/videos/user/$userId");

    print("📡 FETCHING VIDEOS FOR USER: $userId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          // Agar auth required hai toh niche wali line uncomment karein:
          // "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data; // Yeh list of videos return karega
      } else {
        print("❌ SERVER ERROR: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ CONNECTION ERROR: $e");
      return [];
    }
  }

  /// Get all Enrolled course
  Future<List<dynamic>> getMyJoinedCourses() async {
    final url = Uri.parse("$baseUrl/courses/my-courses/list");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // Direct decode as a List because your JSON starts with [
        final List<dynamic> decodedList = jsonDecode(response.body);
        return decodedList;
      } else {
        print("❌ Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("⚠️ API Connection Error: $e");
      return [];
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
      final url = Uri.parse("$baseUrl/videos/course/$userId");



      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the body
        final decodedData = json.decode(response.body);

        List<dynamic> videos = [];

        // Logic to handle if backend returns a Map {videos: []} or a List []
        if (decodedData is List) {
          videos = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('videos')) {
          videos = decodedData['videos'];
        }


        return videos.map((v) {
          // You can add URL prefixing logic here if needed
          return v;
        }).toList();
      } else {
        // Print the status code and body to see what the server is complaining about


        return [];
      }
    } catch (e, stacktrace) {
      // This prints the actual error (e.g., FormatException, SocketException)
      print("---------- API ERROR ----------");
      print("Error: $e");
      print("Stacktrace: $stacktrace");
      print("-------------------------------");
      return [];
    }
  }

  /// ===========================
  /// 14.. Project Create
  /// ===========================

  Future<bool> createProject({
    required String title,
    required String description,
    required List<String> techStack,
    required int membersCount,
  }) async {

    final url = Uri.parse("$baseUrl/projects/create");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": title,
          "description": description,
          "tech_stack": techStack,
          "members_count": membersCount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }


  Future<List<MyProject>> getMyProjects() async {

    final url = Uri.parse("$baseUrl/projects/my-projects");

    try {

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("URL: $url");
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {

        List data = jsonDecode(response.body);

        return data.map((e) => MyProject.fromJson(e)).toList();

      } else {
        throw Exception("Failed to load projects ${response.statusCode}");
      }

    } catch (e) {
      print("API ERROR: $e");
      rethrow;
    }
  }

  Future<List<JoinRequest>> fetchOwnerRequests() async {
    final url = Uri.parse('$baseUrl/projects/owner-requests');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // If required
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => JoinRequest.fromJson(json)).toList();
      } else {
        print("Server Error Code: ${response.statusCode}");
        print("Server Response: ${response.body}");
        throw Exception("Failed to load requests: ${response.statusCode}");

      }
    } catch (e) {
      print("Error fetching requests: $e");
      return [];
    }
  }

  // Inside your ApiService class
  Future<bool> updateRequestStatus(int interactionId, String status) async {
    // Use 10.0.2.2 for Android Emulator, or localhost for iOS/Web
    final url = Uri.parse('$baseUrl/projects/request/$interactionId');

    // Get your token from wherever you store it (SharedPreferences, etc.)


    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}), // status is 'accepted' or 'rejected'
      );
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("--- API CALL END ---");

      return response.statusCode == 200;
    } catch (e) {
      print("API Error: $e");
      return false;
    }
  }


  Future<List<GlobalFeed>> fetchGlobalFeed({bool filterBySkill = false}) async {
    // Use replace to add the query parameter: ?filter_by_skill=true/false
    final url = Uri.parse('$baseUrl/projects/feed').replace(
      queryParameters: {
        'filter_by_skill': filterBySkill.toString(),
      },
    );

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
        return data.map((json) => GlobalFeed.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load feed");
      }
    } catch (e) {
      print("Feed Error: $e");
      return [];
    }
  }

  Future<SingleProjectGet?> getProjectDetails(int id) async {
    final url = Uri.parse('$baseUrl/projects/details/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Passing the token here
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SingleProjectGet.fromJson(data);
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception caught: $e");
      return null;
    }
  }

  /// Project Like Api
  Future<Map<String, dynamic>?> toggleLikeProject(int projectId) async {
    final url = Uri.parse('$baseUrl/projects/toggle-like');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'project_id': projectId,
        }),
      );

      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        // Returns {"message": "Liked", "is_liked": true}
        // or {"message": "Unliked", "is_liked": false}
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  /// Project Discard Api
  Future<void> discardProject(int projectId) async {
    final url = Uri.parse('$baseUrl/projects/discard');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'project_id': projectId}),
      );

      print(jsonDecode(response.body));

      if (response.statusCode != 200) {
        throw Exception('Failed to discard project');
      }
    } catch (e) {
      throw Exception('Error calling discard API: $e');
    }
  }

  /// Get Liked Project
  Future<List<LikedProject>> getLikedProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects/liked'),
      headers: { 'Authorization': 'Bearer $token' },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => LikedProject.fromJson(item)).toList();
    } else {
      throw "Unable to retrieve liked projects.";
    }
  }


  /// Post Section API
  /// ===========================
  /// 🔹 POST MEDIA & INTERACTIONS
  /// ===========================

  /// 1. CREATE MEDIA POST (Image or Video)
  Future<bool> createMediaPost({
    required File mediaFile,
    required String caption,
    String? location,
  }) async {
    final url = Uri.parse("$baseUrl/posts/mediaPost");
    print("🚀 CREATE MEDIA POST: $url");

    try {
      var request = http.MultipartRequest("POST", url);
      request.headers["Authorization"] = "Bearer $token";

      request.fields["caption"] = caption;
      if (location != null) request.fields["location"] = location;

      // Detect mime type (video or image)
      String extension = mediaFile.path.split('.').last.toLowerCase();
      String type = (extension == 'mp4' || extension == 'mov') ? 'video' : 'image';

      request.files.add(
        await http.MultipartFile.fromPath(
          "media", // Matches backend upload.single("media")
          mediaFile.path,
          contentType: MediaType(type, extension),
        ),
      );


      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("📡 SERVER STATUS: ${response.statusCode}");
      print("📦 SERVER RESPONSE: ${response.body}");

      print("STATUS: ${response.statusCode}");
      return response.statusCode == 201;
    } catch (e) {

      print("CREATE POST ERROR: $e");
      return false;
    }
  }

  /// 2. GET GLOBAL MEDIA FEED
  Future<List<Post>> fetchFeed() async {
    final url = Uri.parse('$baseUrl/posts/mediaPost/feed');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Assuming it's a Bearer token
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> postsJson = data['posts'];

        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load feed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  /// 3. GET MY MEDIA POSTS
  Future<List<dynamic>> getMyMediaPosts() async {
    final url = Uri.parse("$baseUrl/posts/mediaPost/my");
    try {
      final response = await http.get(url,headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Assuming it's a Bearer token
      },);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["posts"] ?? [];
      }
      return [];
    } catch (e) {
      print("MY POSTS ERROR: $e");
      return [];
    }
  }

  /// get Global feed
  // 1. Change return type to Future<List<MyPost>>
  Future<List<MyPost>> fetchMyPosts() async {
    final response = await http.get(
      Uri.parse("$baseUrl/posts/mediaPost/my"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['posts'];

      // 2. Map using MyPost.fromJson
      return data.map((json) => MyPost.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }

  Future<bool> deleteMediaPost(int postId) async {
    try {
      final response = await http.delete(
        // Ensure the URL matches your backend exactly
        Uri.parse("$baseUrl/posts/mediaPost/delete/$postId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("Delete Status: ${response.statusCode}");
      print("Delete Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Delete Error: $e");
      return false;
    }
  }

  /// 4. TOGGLE LIKE (Like/Unlike)
  Future<bool> togglePostLike(int postId) async {
    final url = Uri.parse("$baseUrl/posts/like");
    print(url);
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({"post_id": postId}),
      );
      print(response.body);
      return response.statusCode == 200;

    } catch (e) {
      print("LIKE ERROR: $e");
      return false;
    }

  }

  /// 5. ADD COMMENT
  Future<Map<String, dynamic>?> addPostComment(int postId, String text) async {
    final url = Uri.parse("$baseUrl/posts/comment");
    print(url);
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "post_id": postId,
          "comment_text": text,
        }),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("COMMENT ERROR: $e");
      return null;
    }
  }



  /// Create Course
  /// ===========================
  /// 15.. CREATE COURSE
  /// ===========================
  Future<bool> createCourse({
    required String title,
    required String description,
    required String level,
    required String price,
    required String language,
    required File thumbnail,
  }) async {
    final url = Uri.parse("$baseUrl/courses/create");
    print("🚀 CREATE COURSE REQUEST: $url");

    try {
      var request = http.MultipartRequest('POST', url);

       // --- Headers ---
       // Using your class-level token variable
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // --- Text Fields ---
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['level'] = level;
      request.fields['language'] = language;
      request.fields['price'] = price;

      // --- File Field (Optimized) ---
      // Using fromPath is cleaner than manual ByteStreams for local files
      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail',
          thumbnail.path,
          contentType: MediaType('image', thumbnail.path.split('.').last),
        ),
      );

      // --- Send Request ---
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Course Created Successfully");
        return true;
      } else {
        print("❌ Failed to create course: ${response.body}");
        return false;
      }
    } catch (e) {
      print("CREATE COURSE ERROR: $e");
      return false;
    }
  }

  ///Get use specific Courses
  /// ===========================
  /// 16.. GET MY CREATED COURSES
  /// ===========================
  Future<List<dynamic>> getMyCreatedCourses() async {
    final url = Uri.parse("$baseUrl/courses/my-created-courses");
    print("🚀 GET MY COURSES REQUEST: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        // 1. Decode the body into a Map
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 2. Extract the 'courses' list from the Map
        // If 'courses' is null or missing, return an empty list []
        return responseData['courses'] ?? [];
      } else {
        print("❌ Failed to fetch my courses: ${response.body}");
        return [];
      }
    } catch (e) {
      print("GET MY COURSES ERROR: $e");
      return [];
    }
  }

  /// Get video by course id
  Future<List<dynamic>> getVideosByCourse(int courseId) async {
    final url = Uri.parse("$baseUrl/videos/course/$courseId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Extracts the 'videos' array from your JSON response
        return data['videos'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("API Error fetching course videos: $e");
      return [];
    }
  }

  /// check enrollment
  Future<bool> checkEnrollment(int courseId) async {
    final url = Uri.parse("$baseUrl/courses/check-enrollment/$courseId");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['enrolled'] ?? false;
    } else {
      throw Exception("Failed to check enrollment");
    }
  }

  Future<bool> markPostAsRead(int postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/mark-read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Ensure token is passed
        },
        body: jsonEncode({'post_id': postId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<int> getUserTotalViews(int userId) async {
    try {
      final url = Uri.parse("$baseUrl/videos/users/$userId/total-views");
      final res = await http.get(url);
      print(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print("API Response: $data"); // Debug

        final totalViewsRaw = data['total_views'];

        // total_views ko int me parse karo
        if (totalViewsRaw is int) return totalViewsRaw;
        if (totalViewsRaw is String) return int.tryParse(totalViewsRaw) ?? 0;

        return 0;
      } else {
        print("Status Code: ${res.statusCode}");
        return 0;
      }
    } catch (e) {
      print("Error: $e");
      return 0;
    }
  }
  /// Create reel
  Future<bool> uploadReel({
    required String caption,
    required File videoFile,
  }) async {
    final url = Uri.parse("$baseUrl/reels");

    try {
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['caption'] = caption;

      // Ensure we are sending it as a video/mp4
      request.files.add(
        await http.MultipartFile.fromPath(
          'reel',
          videoFile.path,
          contentType: MediaType('video', 'mp4'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Upload Error: $e");
      return false;
    }
  }
  /// Get Other Person Course by user_id
  Future<List<dynamic>> getCoursesByUserId(int userId) async {
    final url = Uri.parse("$baseUrl/courses/user/$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['courses']; // return course list
      } else {
        throw Exception("Failed to load courses");
      }
    } catch (e) {
      print("Error fetching courses: $e");
      return [];
    }
  }

  /// Get All reels
  Future<List<Reel>> fetchMyReels() async {
    final url = Uri.parse("$baseUrl/reels/my");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Reel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load reels: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching reels: $e");
      return [];
    }
  }




  /// Get Reel
  Future<List<Reel>> fetchReels() async {
    final url = Uri.parse('$baseUrl/reels/feed');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Passing the token here
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Reel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load reels. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // 1. POST VIEW: Send watch time to the server
  // Called when a user watches a reel
  // 1. Update Reel View (POST)
// Sends watch duration to the server
  Future<void> updateReelView(int reelId, int seconds) async {
    final url = Uri.parse('$baseUrl/reels/$reelId/view');
    final body = jsonEncode({'watchedseconds': seconds});

    print("🚀 API CALL [POST]: $url");
    print("📦 BODY: $body");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print("📥 RESPONSE [${response.statusCode}]: ${response.body}");

      if (response.statusCode != 200) {
        print("⚠️ Warning: View update failed");
      }
    } catch (e) {
      print("❌ ERROR in updateReelView: $e");
    }
  }

// 2. Get View Stats (GET)
// Returns stats like total views for the analytics popup
  Future<Map<String, dynamic>> getReelViewStats(int reelId) async {
    final url = Uri.parse('$baseUrl/reels/$reelId/views');

    print("🚀 API CALL [GET]: $url");

    try {
      final response = await http.get(url);

      print("📥 RESPONSE [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load view stats");
      }
    } catch (e) {
      print("❌ ERROR in getReelViewStats: $e");
      rethrow;
    }
  }

// 3. Toggle Like (POST)
  Future<Map<String, dynamic>> toggleLikeReel(int reelId) async {
    final url = Uri.parse('$baseUrl/reels/$reelId/like');

    print("🚀 API CALL [POST]: $url");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📥 RESPONSE [${response.statusCode}]: ${response.body}");
      return json.decode(response.body);
    } catch (e) {
      print("❌ ERROR in toggleLikeReel: $e");
      rethrow;
    }
  }

// 4. Get Comments (GET)
  Future<List<dynamic>> getReelComments(int reelId) async {
    final url = Uri.parse('$baseUrl/reels/$reelId/getcomments');

    print("🚀 API CALL [GET]: $url");

    try {
      final response = await http.get(url);

      print("📥 RESPONSE [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception("Failed to load comments");
    } catch (e) {
      print("❌ ERROR in getReelComments: $e");
      rethrow;
    }
  }

// 5. Add Comment (POST)
  Future<void> addComment(int reelId, String text) async {
    final url = Uri.parse('$baseUrl/reels/$reelId/comment');
    final body = jsonEncode({'comment_text': text});

    print("🚀 API CALL [POST]: $url");
    print("📦 BODY: $body");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print("📥 RESPONSE [${response.statusCode}]: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception("Failed to post comment");
      }
    } catch (e) {
      print("❌ ERROR in addComment: $e");
      rethrow;
    }
  }
  ///
    Future<bool> sendJoinRequest({
      required int projectId,
      required String message,
    }) async {
      final url = Uri.parse('$baseUrl/projects/request');

      print(url);

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "project_id": projectId,
            "message": message,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success!
          return true;
        } else {
          print("Request failed: ${response.body}");
          return false;
        }
      } catch (e) {
        print("Error sending request: $e");
        return false;
      }
    }
  }