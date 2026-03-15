import 'dart:async'; // Needed for Timer
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../Services/api-service.dart';
import '../Model/message_model.dart';

final messagesProvider = StateNotifierProvider.family<MessageNotifier, AsyncValue<List<MessageModel>>, int>((ref, id) {
  return MessageNotifier(id);
});

class MessageNotifier extends StateNotifier<AsyncValue<List<MessageModel>>> {
  final int conversationId;
  final ApiService _api = ApiService();
  Timer? _pollingTimer;

  MessageNotifier(this.conversationId) : super(const AsyncValue.loading()) {
    fetchMessages(); // Initial load
    _startPolling(); // Start the 2-second timer
  }

  void _startPolling() {
    // Cancel any existing timer just in case
    _pollingTimer?.cancel();

    // Create a timer that runs every 2 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _pollMessages();
    });
  }

  // Quietly fetch messages without showing a loading state
  Future<void> _pollMessages() async {
    try {
      final res = await _api.getMessages(conversationId);

      state.whenData((currentMessages) {
        // Only update the UI if the number of messages has changed
        // This prevents unnecessary UI rebuilds
        if (res.length != currentMessages.length) {
          state = AsyncValue.data(res);
        }
      });
    } catch (e) {
      // We don't update state with error during polling
      // to avoid interrupting the user's view.
      print("Polling error: $e");
    }
  }

  Future<void> fetchMessages() async {
    // This is used for the very first load or manual refreshes
    try {
      final res = await _api.getMessages(conversationId);
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addMessage(MessageModel msg) {
    state.whenData((list) => state = AsyncValue.data([...list, msg]));
  }

  @override
  void dispose() {
    // CRITICAL: Stop the timer when the user leaves the chat page
    // Otherwise, it will keep calling the API forever in the background!
    _pollingTimer?.cancel();
    super.dispose();
  }
}