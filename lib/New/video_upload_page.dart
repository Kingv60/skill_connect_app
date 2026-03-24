import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/api-service.dart';

enum UploadType { video, course }

class UploadMediaPage extends StatefulWidget {
  @override
  _UploadMediaPageState createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  // --- 1. DATA & STATE ---
  List<dynamic> _dynamicCourses = [];
  bool _isFetchingCourses = true;
  UploadType _selectedType = UploadType.video;
  String? _selectedCourseId;
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

  // --- 2. METHODS ---

  Future<void> _pickFile(bool isVideo) async {
    final pickedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isVideo) {
          _videoFile = File(pickedFile.path);
        } else {
          _thumbFile = File(pickedFile.path);
        }
      });
    }
  }

  void _handlePublish() async {
    if (_selectedType == UploadType.video) {
      // UPDATED VALIDATION: Check for video AND thumbnail
      if (_videoFile == null || _videoThumbFile == null || _videoTitleController.text.isEmpty) {
        _showSnackBar("Please select a video, a thumbnail, and enter a title.");
        return;
      }
    } else {
      if (_courseTitleController.text.isEmpty || _thumbFile == null) {
        _showSnackBar("Course Title and Thumbnail are required.");
        return;
      }
    }

    setState(() => _isLoading = true);
    bool success = false;

    try {
      if (_selectedType == UploadType.course) {
        success = await ApiService().createCourse(
          title: _courseTitleController.text,
          description: _courseDescController.text,
          level: _levelController.text.isEmpty ? "Beginner" : _levelController.text,
          language: _langController.text.isEmpty ? "English" : _langController.text,
          thumbnail: _thumbFile!,
        );
      } else {
        // UPDATED API CALL: Pass the video thumbnail
        success = await ApiService().uploadVideo(
          videoFile: _videoFile!,
          thumbnailFile: _videoThumbFile!, // <--- Add this parameter
          title: _videoTitleController.text,
          description: _videoDescController.text.isEmpty ? "No description" : _videoDescController.text,
          courseId: _selectedCourseId ?? "0",
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      }
    } catch (e) {
      debugPrint("Error during publish: $e");
    }

    if (mounted) setState(() => _isLoading = false);
    // ... rest of your success/fail logic
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff262626),
      appBar: AppBar(
        backgroundColor: const Color(0xff262626),
        elevation: 0,
        title: Text(
          _selectedType == UploadType.video ? "Upload Video" : "Create Course",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildTypeSelector(),
            const SizedBox(height: 25),

            if (_selectedType == UploadType.video) ...[
              _buildVideoForm(),
              const SizedBox(height: 20),
              const Text("Link to Course (Optional)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildCourseDropdown(),
            ] else ...[
              _buildCourseForm(),
            ],

            const SizedBox(height: 30),
            _buildPublishButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 3. UI COMPONENTS ---

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UploadType>(
          value: _selectedType,
          dropdownColor: const Color(0xff333333),
          icon: const Icon(Icons.layers, color: Colors.blueAccent),
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: UploadType.video, child: Text("Upload Video Post", style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: UploadType.course, child: Text("Create New Course", style: TextStyle(color: Colors.white))),
          ],
          onChanged: (val) {
            setState(() {
              _selectedType = val!;
              // Reset all files and selected IDs to avoid "Value not in items" errors
              _thumbFile = null;
              _videoFile = null;
              _selectedCourseId = "0";
            });
          },
        ),
      ),
    );
  }

  Widget _buildVideoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Video", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildCompactFileBox(true),
        const SizedBox(height: 20),

        const Text("Video Thumbnail (Cover)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        // New Thumbnail Picker for Video
        _buildVideoThumbnailPicker(),

        if (_isLoading) _buildProgressBar(),
        const SizedBox(height: 25),
        const Text("Video Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildTextField(_videoTitleController, "Video Title...", 1),
        const SizedBox(height: 10),
        _buildTextField(_videoDescController, "Video Description...", 3),
      ],
    );
  }

// New widget to pick the thumbnail for a video
  Widget _buildVideoThumbnailPicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await _picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() => _videoThumbFile = File(picked.path));
        }
      },
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: _videoThumbFile == null
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: Colors.blueAccent, size: 30),
            Text("Tap to add video cover", style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.file(_videoThumbFile!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildCourseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Course Thumbnail", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildThumbnailBox(),
        const SizedBox(height: 20),
        _buildTextField(_courseTitleController, "Course Title (e.g. React Advanced)", 1),
        const SizedBox(height: 15),
        _buildTextField(_courseDescController, "Advanced React patterns...", 3),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildTextField(_levelController, "Level (Advanced)", 1)),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_langController, "Language (English)", 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseDropdown() {
    if (_isFetchingCourses) {
      return const LinearProgressIndicator();
    }

    // 1. Prepare the list of items
    // We manually add the "No Course" option with ID "0"
    List<DropdownMenuItem<String>> dropdownItems = [
      const DropdownMenuItem<String>(
        value: "0",
        child: Text("No Course (General Video)", style: TextStyle(color: Colors.orangeAccent)),
      ),
    ];

    // 2. Add the dynamic courses from the API
    dropdownItems.addAll(_dynamicCourses.map((course) {
      return DropdownMenuItem<String>(
        value: course['course_id'].toString(),
        child: Text(course['title'] ?? "Untitled Course"),
      );
    }).toList());

    // 3. Safety Check: If current selection isn't in the new list, default to "0"
    bool valueExists = dropdownItems.any((item) => item.value == _selectedCourseId);
    String safeValue = valueExists ? _selectedCourseId! : "0";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          dropdownColor: const Color(0xff333333),
          value: safeValue, // This will now always be at least "0"
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(border: InputBorder.none),
          items: dropdownItems,
          onChanged: (newValue) {
            setState(() => _selectedCourseId = newValue);
          },
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
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildThumbnailBox() {
    return GestureDetector(
      onTap: () => _pickFile(false),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white12),
        ),
        child: _thumbFile == null
            ? const Icon(Icons.add_a_photo, color: Colors.orangeAccent, size: 30)
            : ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(_thumbFile!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildCompactFileBox(bool isVideo) {
    return GestureDetector(
      onTap: () => _pickFile(true),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(isVideo ? Icons.movie : Icons.image, color: Colors.blueAccent),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                _videoFile == null ? "Select Video File" : "Video: ${_videoFile!.path.split('/').last}",
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_videoFile != null) const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: LinearProgressIndicator(value: _uploadProgress, color: Colors.blueAccent, backgroundColor: Colors.white10),
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: _isLoading ? null : _handlePublish,
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("PUBLISH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}