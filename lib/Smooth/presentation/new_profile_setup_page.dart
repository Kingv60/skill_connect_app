import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Assuming AppColors is in your constants folder
import '../../New/avtar-page.dart';
import '../../Services/AppColors.dart';
import '../../Services/api-service.dart';
import '../bloc/profile_setup_bloc/profile_setup_bloc.dart';
import '../bloc/profile_setup_bloc/profile_setup_event.dart';
import '../bloc/profile_setup_bloc/profile_setup_state.dart';

class ProfileSetupPage extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const ProfileSetupPage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  final ApiService _apiService = ApiService();
  Timer? _debounce;
  bool _isChecking = false;
  bool _isAvailable = false;
  String _usernameMessage = "";

  final List<String> roleSuggestions = [
    "Developer", "Designer", "Student", "Mentor", "Freelancer", "Project Manager"
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    usernameController.dispose();
    skillController.dispose();
    bioController.dispose();
    roleController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {
      _usernameMessage = "";
      _isAvailable = false;
    });
    if (value.isEmpty) return;

    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      setState(() => _isChecking = true);
      try {
        final result = await _apiService.checkUsernameAvailability(value);
        setState(() {
          _isChecking = false;
          if (result['available'] == true) {
            _isAvailable = true;
            _usernameMessage = "Username is available";
          } else {
            _isAvailable = false;
            _usernameMessage = "Username is already taken";
          }
        });
      } catch (e) {
        setState(() {
          _isChecking = false;
          _usernameMessage = "Error connecting to server";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileSetupBloc(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text("Create Profile",
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<ProfileSetupBloc, ProfileSetupState>(
          listener: (context, state) {},
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 10),

                  /// USERNAME
                  _buildLabel("Username"),
                  _buildCustomField(
                    controller: usernameController,
                    onChanged: _onUsernameChanged,
                    hint: "Choose a unique username",
                    prefixIcon: Icons.alternate_email_rounded,
                    isSuccess: _isAvailable,
                    isError: _usernameMessage.isNotEmpty && !_isAvailable,
                    suffix: _isChecking
                        ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                        : (_usernameMessage.isNotEmpty
                        ? Icon(_isAvailable ? Icons.check_circle : Icons.error,
                        color: _isAvailable ? AppColors.success : AppColors.error)
                        : null),
                  ),
                  if (_usernameMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(_usernameMessage, style: TextStyle(
                          color: _isAvailable ? AppColors.success : AppColors.error,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                    ),

                  const SizedBox(height: 10),

                  /// SKILLS
                  _buildLabel("Skills"),
                  _buildCustomField(
                    controller: skillController,
                    hint: "Add your skills (e.g. Flutter)",
                    prefixIcon: Icons.bolt_rounded,
                    onChanged: (val) => context.read<ProfileSetupBloc>().add(SkillInputChanged(val)),
                    suffix: IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      onPressed: () {
                        if (skillController.text.isNotEmpty) {
                          context.read<ProfileSetupBloc>().add(AddSkill(skillController.text));
                          skillController.clear();
                        }
                      },
                    ),
                  ),

                  // Suggestions
                  if (state.filteredSuggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 8,
                        children: state.filteredSuggestions.map((s) => _buildSuggestionChip(context, s)).toList(),
                      ),
                    ),

                  // Selected Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: state.selectedSkills.map((s) => _buildSkillChip(context, s)).toList(),
                    ),
                  ),



                  /// ROLE
                  _buildLabel("Your Role"),
                  _buildAutocompleteRole(),

                  const SizedBox(height: 10),

                  /// BIO
                  _buildLabel("Bio"),
                  _buildCustomField(
                    controller: bioController,
                    hint: "Tell us about yourself...",
                    prefixIcon: Icons.edit_note_rounded,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 40),

                  /// NEXT BUTTON
                  _buildGradientButton(context, state.selectedSkills),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Final Steps", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
        SizedBox(height: 4),
        Text("Personalize your profile", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildCustomField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    Function(String)? onChanged,
    Widget? suffix,
    bool isError = false,
    bool isSuccess = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isError ? AppColors.error : (isSuccess ? AppColors.success : Colors.white.withOpacity(0.05)),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          icon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String s) {
    return ActionChip(
      label: Text(s, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () {
        context.read<ProfileSetupBloc>().add(AddSkill(s));
        skillController.clear();
      },
    );
  }

  Widget _buildSkillChip(BuildContext context, String s) {
    return Chip(
      label: Text(s, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.surface,
      deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.textMuted),
      onDeleted: () => context.read<ProfileSetupBloc>().add(RemoveSkill(s)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: AppColors.primary.withOpacity(0.3))),
    );
  }

  Widget _buildAutocompleteRole() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        return roleSuggestions.where((role) => role.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) => roleController.text = selection,
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return _buildCustomField(
          controller: controller,
          hint: "e.g. Creative Designer",
          prefixIcon: Icons.work_outline_rounded,
        );
      },
    );
  }

  Widget _buildGradientButton(BuildContext context, List<String> selectedSkills) {
    bool isEnabled = usernameController.text.isNotEmpty && _isAvailable;
    return GestureDetector(
      onTap: () {
        if (!isEnabled) return;
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => AvatarCreatePage(
            name: widget.name, email: widget.email, password: widget.password,
            username: usernameController.text, skills: selectedSkills,
            bio: bioController.text, role: roleController.text,
          ),
        ));
      },
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isEnabled ? AppColors.primaryGradient : null,
          color: isEnabled ? null : AppColors.surface,
          boxShadow: isEnabled ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : [],
        ),
        child: Center(
          child: Text("Continue to Avatar", style: TextStyle(
              color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}