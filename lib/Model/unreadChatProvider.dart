import 'package:flutter_riverpod/legacy.dart';

final unreadChatProvider =
StateNotifierProvider<UnreadChatNotifier, Set<int>>((ref) {
  return UnreadChatNotifier();
});

class UnreadChatNotifier extends StateNotifier<Set<int>> {
  UnreadChatNotifier() : super({});

  void markUnread(int conversationId) {
    state = {...state, conversationId};
  }

  void markRead(int conversationId) {
    final newState = {...state};
    newState.remove(conversationId);
    state = newState;
  }
}