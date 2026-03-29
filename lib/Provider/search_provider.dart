
import 'package:flutter_riverpod/legacy.dart';
import '../Services/api-service.dart';


final chatSearchProvider = StateNotifierProvider<ChatSearchNotifier, List<dynamic>>((ref) {
  return ChatSearchNotifier();
});

class ChatSearchNotifier extends StateNotifier<List<dynamic>> {
  ChatSearchNotifier() : super([]);

  final ApiService _apiService = ApiService();

  // REAL API CALL: Hits the server and updates the 'state' list
  Future<void> searchUsers(String query) async {

    try {
      final results = await _apiService.searchUsers(query);
      state = results; // Update state with real data from DB
    } catch (e) {
      print("Search Error: $e");
      state = [];
    }
  }

  void clearSearch() {
    state = []; // This resets the list to empty
  }

  // API CALL: Creates or gets a conversation ID for the selected user
  Future<int?> startConversation(int userId) async {
    final response = await _apiService.startConversation(userId);
    return response.conversationId;
  }
}