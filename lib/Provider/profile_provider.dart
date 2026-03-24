
import 'package:flutter_riverpod/legacy.dart';

import '../Model/profile_model.dart';
import '../Services/api-service.dart';


class ProfileNotifier extends StateNotifier<ProfileModel?> {
  ProfileNotifier() : super(null);

  final ApiService api = ApiService();

  Future<void> loadProfile() async {
    await ApiService.loadUserFromPrefs();

    final data = await api.getProfile();

    print("PROFILE RESPONSE: $data");

    if (data["error"] != true) {
      state = ProfileModel.fromJson(data);
    } else {
      print("Profile API error");
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }
}

final profileProvider =
StateNotifierProvider<ProfileNotifier, ProfileModel?>((ref) {
  return ProfileNotifier();
});