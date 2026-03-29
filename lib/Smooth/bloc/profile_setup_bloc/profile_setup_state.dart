class ProfileSetupState {
  final bool isCheckingUsername;
  final bool isUsernameAvailable;
  final String usernameMessage; // <--- THIS WAS MISSING
  final List<String> selectedSkills;
  final List<String> filteredSuggestions;

  ProfileSetupState({
    this.isCheckingUsername = false,
    this.isUsernameAvailable = false,
    this.usernameMessage = "", // Default to empty string
    this.selectedSkills = const [],
    this.filteredSuggestions = const [],
  });

  // This method allows the Bloc to update only specific fields
  ProfileSetupState copyWith({
    bool? isCheckingUsername,
    bool? isUsernameAvailable,
    String? usernameMessage, // <--- ADD THIS
    List<String>? selectedSkills,
    List<String>? filteredSuggestions,
  }) {
    return ProfileSetupState(
      isCheckingUsername: isCheckingUsername ?? this.isCheckingUsername,
      isUsernameAvailable: isUsernameAvailable ?? this.isUsernameAvailable,
      usernameMessage: usernameMessage ?? this.usernameMessage, // <--- AND THIS
      selectedSkills: selectedSkills ?? this.selectedSkills,
      filteredSuggestions: filteredSuggestions ?? this.filteredSuggestions,
    );
  }
}