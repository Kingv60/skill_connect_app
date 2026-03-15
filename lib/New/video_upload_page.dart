import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/api-service.dart';

class UploadMediaPage extends StatefulWidget {
  @override
  _UploadMediaPageState createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  File? _videoFile;
  File? _thumbFile;
  final _captionController = TextEditingController();
  final _picker = ImagePicker();

  bool _isLoading = false;
  double _uploadProgress = 0.0; // Simulated progress (0.0 to 1.0)

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _videoFile = File(pickedFile.path));
    }
  }

  Future<void> _pickThumbnail() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _thumbFile = File(pickedFile.path));
    }
  }

  void _handleUpload() async {
    if (_videoFile == null || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a video and add a caption")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.5; // You can update this based on your stream
    });

    bool success = await ApiService().uploadMedia(
      mediaFile: _videoFile!,
      thumbnailFile: _thumbFile,
      caption: _captionController.text,
      onProgress: (p) {
        setState(() {
          _uploadProgress = p; // Updates the LinearProgressIndicator
        });
      },
    );

    setState(() {
      _isLoading = false;
      _uploadProgress = success ? 1.0 : 0.0;
    });

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Success!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff262626),
      appBar: AppBar(
        backgroundColor: const Color(0xff262626),
        title: const Text("Create Post", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // --- 1. COMPACT VIDEO SELECTOR ---
            _buildCompactVideoBox(),

            if (_isLoading) ...[
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.white10,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 5),
              Text("${(_uploadProgress * 100).toInt()}% Uploading...",
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],

            const SizedBox(height: 25),

            // --- 2. THUMBNAIL PREVIEW ---
            const Text("Cover Image", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildThumbnailBox(),

            const SizedBox(height: 25),

            // --- 3. CAPTION BOX ---
            TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write a caption...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- 4. PUBLISH BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: _isLoading ? null : _handleUpload,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("PUBLISH POST", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single Line Video Upload Box
  Widget _buildCompactVideoBox() {
    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(_videoFile == null ? Icons.video_call : Icons.check_circle,
                color: _videoFile == null ? Colors.blueAccent : Colors.green),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                _videoFile == null ? "Select Video File" : "Video Selected: ${_videoFile!.path.split('/').last}",
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_videoFile != null) const Icon(Icons.edit, size: 16, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  // Compact Thumbnail Preview Box
  Widget _buildThumbnailBox() {
    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white12),
        ),
        child: _thumbFile == null
            ? const Icon(Icons.add_photo_alternate, color: Colors.orangeAccent, size: 30)
            : ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(_thumbFile!, fit: BoxFit.cover),
        ),
      ),
    );
  }
}