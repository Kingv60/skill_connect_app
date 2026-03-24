// lib/constants.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const String baseUrl = "http://10.57.75.55:8000/api";
const String baseUrlImage = "http://10.57.75.55:8000";


class AppAvatar extends StatelessWidget {
  final String? url;
  final double size;

  const AppAvatar({
    super.key,
    required this.url,
    this.size = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    // 1. Handle Null or Empty
    if (url == null || url!.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Icon(Icons.person, size: size * 0.6, color: Colors.grey[600]),
      );
    }

    final String fullUrl = url!.toLowerCase().contains("http")
        ? url!
        : "$baseUrlImage$url";

    // 2. Handle SVG
    if (url!.toLowerCase().endsWith(".svg")) {
      print(fullUrl);
      return SvgPicture.network(
        fullUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => const Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // 3. Handle Standard Image
    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: Icon(Icons.broken_image, size: size * 0.5),
      ),
    );
  }
}