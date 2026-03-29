import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import '../Services/AppColors.dart';
import '../Services/api-service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with SingleTickerProviderStateMixin {
  List<AssetEntity> mediaList = [];
  File? selectedFile;
  bool isVideo = false;
  VideoPlayerController? _videoController;
  bool isFinalStep = false;
  bool isUploading = false;

  late TabController _tabController;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(); // Added for Posts

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestPermission();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    _locationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ... (Permission and Gallery loading logic remains the same) ...
  Future<void> _requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth || ps.hasAccess) {
      await _loadGallery();
    } else {
      await PhotoManager.openSetting();
    }
  }

  Future<void> _loadGallery() async {
    // Use .all to get every media type available
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.all,
      filterOption: FilterOptionGroup(
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)], // Newest first
      ),
    );

    if (albums.isNotEmpty) {
      // Increase size or implement a ScrollController to load more pages
      List<AssetEntity> media = await albums.first.getAssetListPaged(page: 0, size: 500);
      setState(() {
        mediaList = media;
      });
      if (media.isNotEmpty) _selectMedia(media.first);
    }
  }

  Future<void> _selectMedia(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return;

    await _videoController?.dispose();
    setState(() {
      selectedFile = file;
      isVideo = asset.type == AssetType.video;
    });

    if (isVideo) {
      _videoController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.setLooping(true);
          _videoController!.play();
        });
    }
  }

  void _handleShare() async {
    if (selectedFile == null) return;
    setState(() => isUploading = true);

    bool success = false;

    // ✅ Switch between Post and Reel API based on Tab index
    if (_tabController.index == 0) {
      // API call for POST (Image or Video)
      success = await ApiService().createMediaPost(
        caption: _captionController.text,
        mediaFile: selectedFile!,
        location: _locationController.text,
      );
    } else {
      // API call for REEL
      success = await ApiService().uploadReel(
        caption: _captionController.text,
        videoFile: selectedFile!,
      );
    }

    if (mounted) {
      setState(() => isUploading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_tabController.index == 0 ? "Post Shared!" : "Reel Shared!"),
                backgroundColor: AppColors.success)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload failed"), backgroundColor: AppColors.error)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: isFinalStep ? _buildFinalizeView() : _buildGalleryView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldBg,
      elevation: 0,
      centerTitle: true,
      leading: isFinalStep
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => setState(() => isFinalStep = false),
      )
          : null,
      title: Text(
        isFinalStep ? "Finalize" : "Create",
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      // ✅ Added TabBar to switch between Post and Reel
      bottom: isFinalStep
          ? null
          : TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        tabs: const [
          Tab(text: "Post"),
          Tab(text: "Reel"),
        ],
      ),
      actions: [
        if (selectedFile != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  if (isFinalStep) {
                    _handleShare();
                  } else {
                    setState(() => isFinalStep = true);
                    _videoController?.pause();
                  }
                },
                child: isUploading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                  isFinalStep ? "Share" : "Next",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ... (_buildGalleryView remains the same) ...
  Widget _buildGalleryView() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.width,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: (isVideo && _videoController?.value.isInitialized == true)
              ? Center(child: AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)))
              : selectedFile != null
              ? Image.file(selectedFile!, fit: BoxFit.cover)
              : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Media", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.textSecondary, size: 20),
              )
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mediaList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final asset = mediaList[index];
              return GestureDetector(
                onTap: () => _selectMedia(asset),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: selectedFile?.path == asset.relativePath ? Border.all(color: AppColors.primary, width: 3) : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _AssetThumbnail(asset: asset),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFinalizeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90, height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: selectedFile != null ? DecorationImage(image: FileImage(selectedFile!), fit: BoxFit.cover) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // ✅ Added Location Field for Posts
          if (_tabController.index == 0)
            TextField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                hintText: "Add Location",
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          const SizedBox(height: 12),
          _buildSettingsTile(Icons.person_add_alt_1_outlined, "Tag People"),
          _buildSettingsTile(Icons.music_note_outlined, "Add Music"),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
        ],
      ),
    );
  }
}

// ... (_AssetThumbnail remains the same) ...
class _AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  const _AssetThumbnail({required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(snapshot.data!, fit: BoxFit.cover),
              if (asset.type == AssetType.video)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                  ),
                ),
            ],
          );
        }
        return Container(color: AppColors.surface);
      },
    );
  }
}