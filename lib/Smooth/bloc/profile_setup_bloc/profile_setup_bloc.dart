import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_setup_event.dart';
import 'profile_setup_state.dart';

class ProfileSetupBloc extends Bloc<ProfileSetupEvent, ProfileSetupState> {
  final List<String> _allSuggestions = ["Flutter", "Node.js", "React", "Python", "Java", "UI/UX"];

  ProfileSetupBloc() : super(ProfileSetupState()) {

    on<SkillInputChanged>((event, emit) {
      final filtered = _allSuggestions
          .where((s) => s.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(state.copyWith(filteredSuggestions: event.query.isEmpty ? [] : filtered));
    });

    on<AddSkill>((event, emit) {
      if (!state.selectedSkills.contains(event.skill)) {
        final newSkills = List<String>.from(state.selectedSkills)..add(event.skill);
        emit(state.copyWith(selectedSkills: newSkills, filteredSuggestions: []));
      }
    });

    on<RemoveSkill>((event, emit) {
      final newSkills = List<String>.from(state.selectedSkills)..remove(event.skill);
      emit(state.copyWith(selectedSkills: newSkills));
    });

    on<CheckUsernameAvailability>((event, emit) async {
      emit(state.copyWith(isCheckingUsername: true));
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(isCheckingUsername: false, isUsernameAvailable: true));
    });
  }
}