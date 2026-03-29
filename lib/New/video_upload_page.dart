import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/AppColors.dart';
import '../Services/api-service.dart';

enum UploadType { video, course }

class UploadMediaPage extends StatefulWidget {
  const UploadMediaPage({super.key});

  @override
  _UploadMediaPageState createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  // --- 1. DATA & STATE ---
  List<dynamic> _dynamicCourses = [];
  bool _isFetchingCourses = true;
  UploadType _selectedType = UploadType.video;
  String? _selectedCourseId = "0";
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  final _picker = ImagePicker();

  // Video Specific
  File? _videoFile;
  File? _videoThumbFile;
  final _videoTitleController = TextEditingController();
  final _videoDescController = TextEditingController();

  // Course Specific
  File? _thumbFile;
  final _courseTitleController = TextEditingController();
  final _courseDescController = TextEditingController();
  final _levelController = TextEditingController();
  final _langController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailableCourses();
  }

  @override
  void dispose() {
    _videoTitleController.dispose();
    _videoDescController.dispose();
    _courseTitleController.dispose();
    _courseDescController.dispose();
    _levelController.dispose();
    _langController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableCourses() async {
    if (!mounted) return;
    setState(() => _isFetchingCourses = true);
    try {
      final data = await ApiService().getMyCreatedCourses();
      if (mounted) {
        setState(() {
          _dynamicCourses = data;
          _isFetchingCourses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingCourses = false);
        _showSnackBar("Could not load your courses.");
      }
    }
  }

  Future<void> _pickFile(bool isVideo) async {
    final pickedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isVideo) {
          _videoFile = File(pickedFile.path);
        } else {
          // If in Course mode, update _thumbFile
          // If in Video mode (for cover), update _videoThumbFile
          if (_selectedType == UploadType.course) {
            _thumbFile = File(pickedFile.path);
          } else {
            _videoThumbFile = File(pickedFile.path);
          }
        }
      });
    }
  }

  void _handlePublish() async {
    // Trim controllers to avoid whitespace-only titles passing validation
    final vTitle = _videoTitleController.text.trim();
    final cTitle = _courseTitleController.text.trim();

    if (_selectedType == UploadType.video) {
      if (_videoFile == null) {
        _showSnackBar("Please select a video file.");
        return;
      }
      if (_videoThumbFile == null) {
        _showSnackBar("Please upload a video cover (thumbnail).");
        return;
      }
      if (vTitle.isEmpty) {
        _showSnackBar("Please enter a video title.");
        return;
      }
    } else {
      if (_thumbFile == null) {
        _showSnackBar("Please upload a course thumbnail.");
        return;
      }
      if (cTitle.isEmpty) {
        _showSnackBar("Please enter a course title.");
        return;
      }
    }

    setState(() => _isLoading = true);
    bool success = false;

    try {
      if (_selectedType == UploadType.course) {
        success = await ApiService().createCourse(
          title: cTitle,
          description: _courseDescController.text.trim(),
          level: _levelController.text.isEmpty ? "Beginner" : _levelController.text.trim(),
          language: _langController.text.isEmpty ? "English" : _langController.text.trim(),
          thumbnail: _thumbFile!,
        );
      } else {
        success = await ApiService().uploadVideo(
          videoFile: _videoFile!,
          thumbnailFile: _videoThumbFile!,
          title: vTitle,
          description: _videoDescController.text.isEmpty ? "No description" : _videoDescController.text.trim(),
          courseId: _selectedCourseId ?? "0",
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      }

      if (success && mounted) {
        _showSnackBar("Published successfully!");
        Future.delayed(const Duration(milliseconds: 600), () => Navigator.pop(context, true));
      } else if (mounted) {
        _showSnackBar("Server error. Please try again.");
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) _showSnackBar("An error occurred.");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _selectedType == UploadType.video ? "Upload Video" : "New Course",
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            _buildTypeSelector(),
            const SizedBox(height: 30),

            if (_selectedType == UploadType.video) ...[
              _buildVideoForm(),
              const SizedBox(height: 25),
              _sectionHeader("Connect to Course (Optional)"),
              _buildCourseDropdown(),
            ] else ...[
              _buildCourseForm(),
            ],

            const SizedBox(height: 40),
            _buildPublishButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildSelectorTab(UploadType.video, "Video Post", Icons.videocam_rounded),
          _buildSelectorTab(UploadType.course, "Full Course", Icons.school_rounded),
        ],
      ),
    );
  }

  Widget _buildSelectorTab(UploadType type, String label, IconData icon) {
    bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedType = type;
          // Logic: We DO NOT reset files here so user doesn't lose data if they toggle tabs.
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Video File"),
        _buildCompactFileBox(true),
        const SizedBox(height: 25),

        _sectionHeader("Video Cover (Thumbnail)"),
        _buildMediaPicker(isForVideoCover: true),

        if (_isLoading && _uploadProgress > 0) _buildProgressBar(),
        const SizedBox(height: 30),
        _sectionHeader("Details"),
        _buildTextField(_videoTitleController, "Enter catchy title...", 1),
        const SizedBox(height: 15),
        _buildTextField(_videoDescController, "Tell viewers what this is about...", 3),
      ],
    );
  }

  Widget _buildCourseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Course Thumbnail"),
        _buildMediaPicker(isForVideoCover: false),
        const SizedBox(height: 25),
        _sectionHeader("Course Information"),
        _buildTextField(_courseTitleController, "Course Title (e.g. Flutter Masterclass)", 1),
        const SizedBox(height: 15),
        _buildTextField(_courseDescController, "What will students learn?", 3),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildTextField(_levelController, "Level", 1)),
            const SizedBox(width: 15),
            Expanded(child: _buildTextField(_langController, "Language", 1)),
          ],
        ),
      ],
    );
  }

  // Unified Picker for Images (Covers or Thumbnails)
  Widget _buildMediaPicker({required bool isForVideoCover}) {
    File? displayFile = isForVideoCover ? _videoThumbFile : _thumbFile;

    return GestureDetector(
      onTap: () => _pickFile(false),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: displayFile != null ? AppColors.primary.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
          image: displayFile != null ? DecorationImage(image: FileImage(displayFile), fit: BoxFit.cover) : null,
        ),
        child: displayFile == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 12),
            const Text("Upload Cover Image", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        )
            : Container(
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(10),
          child: const CircleAvatar(backgroundColor: AppColors.primary, radius: 15, child: Icon(Icons.edit, size: 15, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    if (_isFetchingCourses) return const LinearProgressIndicator(color: AppColors.primary, backgroundColor: AppColors.surface);

    List<DropdownMenuItem<String>> dropdownItems = [
      const DropdownMenuItem(value: "0", child: Text("General / No Course", style: TextStyle(color: AppColors.secondary))),
    ];

    dropdownItems.addAll(_dynamicCourses.map((course) {
      return DropdownMenuItem(value: course['course_id'].toString(), child: Text(course['title'] ?? "Untitled Course"));
    }).toList());

    String safeValue = dropdownItems.any((item) => item.value == _selectedCourseId) ? _selectedCourseId! : "0";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.drawerBg,
          value: safeValue,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          isExpanded: true,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          items: dropdownItems,
          onChanged: (newValue) => setState(() => _selectedCourseId = newValue),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, int lines) {
    return TextField(
      controller: controller,
      maxLines: lines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.03))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
      ),
    );
  }

  Widget _buildCompactFileBox(bool isVideo) {
    return GestureDetector(
      onTap: () => _pickFile(true),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _videoFile != null ? AppColors.primary.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_fill_rounded, color: _videoFile != null ? AppColors.primary : AppColors.textMuted, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                _videoFile == null ? "Select Video Content" : _videoFile!.path.split('/').last,
                style: TextStyle(color: _videoFile == null ? AppColors.textMuted : AppColors.textPrimary, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_videoFile != null) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Uploading... ${(_uploadProgress * 100).toInt()}%", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: _uploadProgress, color: AppColors.primary, backgroundColor: AppColors.surface),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: _isLoading ? null : AppColors.primaryGradient,
        color: _isLoading ? AppColors.surface : null,
        boxShadow: [
          if (!_isLoading) BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _isLoading ? null : _handlePublish,
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("PUBLISH CONTENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
    );
  }
}