import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<AssetEntity> mediaList = [];
  File? selectedFile;
  bool isVideo = false;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> requestPermission() async {
    final PermissionState ps =
    await PhotoManager.requestPermissionExtend();

    if (ps == PermissionState.authorized ||
        ps == PermissionState.limited) {
      await loadGallery();
    } else {
      print("Permission denied");
      await PhotoManager.openSetting();
    }
  }


  Future<void> loadGallery() async {
    List<AssetPathEntity> albums =
    await PhotoManager.getAssetPathList(type: RequestType.common);

    List<AssetEntity> media =
    await albums.first.getAssetListPaged(page: 0, size: 100);

    setState(() {
      mediaList = media;
    });
  }

  Future<void> selectMedia(AssetEntity asset) async {
    final file = await asset.file;

    if (file == null) return;

    setState(() {
      selectedFile = file;
      isVideo = asset.type == AssetType.video;
    });

    if (isVideo) {
      _controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text("Recents",
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [

          /// 🔥 PREVIEW (Instagram style square)
          Container(
            height: MediaQuery.of(context).size.width,
            width: double.infinity,
            color: Colors.black,
            child: selectedFile == null
                ? const Center(
                child: Icon(Icons.image,
                    size: 60, color: Colors.white38))
                : isVideo
                ? _controller != null &&
                _controller!.value.isInitialized
                ? AspectRatio(
              aspectRatio:
              _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
                : const Center(
                child: CircularProgressIndicator())
                : Image.file(selectedFile!,
                fit: BoxFit.cover),
          ),

          /// 🔥 GRID GALLERY
          Expanded(
            child: GridView.builder(
              itemCount: mediaList.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                final asset = mediaList[index];

                return FutureBuilder(
                  future: asset.thumbnailDataWithSize(
                      const ThumbnailSize(200, 200)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(color: Colors.black12);
                    }

                    return GestureDetector(
                      onTap: () => selectMedia(asset),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (asset.type == AssetType.video)
                            const Positioned(
                              right: 5,
                              bottom: 5,
                              child: Icon(Icons.videocam,
                                  color: Colors.white, size: 18),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
