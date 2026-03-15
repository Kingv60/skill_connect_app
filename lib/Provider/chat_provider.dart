import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../Model/chatModel.dart';
import '../Services/api-service.dart';

// 1. Keep your ApiService provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// 2. Change allChatsProvider to a StateNotifierProvider
final allChatsProvider = StateNotifierProvider<AllChatsNotifier, AsyncValue<List<ChatSummary>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AllChatsNotifier(apiService);
});

class AllChatsNotifier extends StateNotifier<AsyncValue<List<ChatSummary>>> {
  final ApiService _api;
  Timer? _pollingTimer;

  AllChatsNotifier(this._api) : super(const AsyncValue.loading()) {
    fetchChats(); // Initial fetch
    _startPolling(); // Start the 5-second auto-refresh
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    // Poll every 5 seconds for the main list
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollChats();
    });
  }

  Future<void> _pollChats() async {
    try {
      final latestChats = await _api.fetchAllChats();

      state.whenData((currentChats) {
        // Only update the state if something actually changed
        // We check length or if the first message (latest) is different
        if (latestChats.length != currentChats.length ||
            (latestChats.isNotEmpty && currentChats.isNotEmpty &&
                latestChats.first.lastMessage != currentChats.first.lastMessage)) {
          state = AsyncValue.data(latestChats);
        }
      });
    } catch (e) {
      // We don't push error state during polling to avoid breaking the UI
      print("Silent poll failed: $e");
    }
  }

  Future<void> fetchChats() async {
    // Used for initial load or manual pull-to-refresh
    try {
      final res = await _api.fetchAllChats();
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Stop the timer when the provider is destroyed
    super.dispose();
  }
}