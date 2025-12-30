import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Centralized image handling utilities
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Pick a single image from gallery
  Future<XFile?> pickFromGallery({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: imageQuality,
    );
  }

  /// Pick a single image from camera
  Future<XFile?> pickFromCamera({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    return _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  /// Pick multiple images from gallery
  Future<List<XFile>> pickMultipleFromGallery({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    return _picker.pickMultiImage(
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: imageQuality,
      limit: limit,
    );
  }

  /// Show bottom sheet to choose image source
  Future<XFile?> pickWithDialog(
    BuildContext context, {
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return null;

    return _picker.pickImage(
      source: source,
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: imageQuality,
    );
  }

  /// Compress an image file
  Future<File?> compressImage(
    File file, {
    int quality = 85,
    int? minWidth,
    int? minHeight,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.path,
      '${DateTime.now().millisecondsSinceEpoch}.${format.name}',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: minWidth ?? 1920,
      minHeight: minHeight ?? 1080,
      format: format,
    );

    return result != null ? File(result.path) : null;
  }

  /// Compress image from bytes
  Future<Uint8List?> compressBytes(
    Uint8List bytes, {
    int quality = 85,
    int? minWidth,
    int? minHeight,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    return FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      minWidth: minWidth ?? 1920,
      minHeight: minHeight ?? 1080,
      format: format,
    );
  }

  /// Get file size in MB
  double getFileSizeMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Clear cached images
  Future<void> clearCache() async {
    await CachedNetworkImage.evictFromCache('');
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.listSync().forEach((file) {
        if (file is File && file.path.contains('cached')) {
          file.deleteSync();
        }
      });
    }
  }
}

/// Cached network image widget with loading and error states
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Map<String, String>? headers;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.backgroundColor,
    this.headers,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: headers,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(context),
      errorWidget: (context, url, error) => errorWidget ?? _buildError(context),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    if (backgroundColor != null) {
      image = Container(color: backgroundColor, child: image);
    }

    return image;
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.errorContainer,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onErrorContainer,
        size: (width ?? height ?? 48) * 0.4,
      ),
    );
  }
}

/// Avatar widget with network image, fallback to initials
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: AppNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          errorWidget: _buildInitials(context),
        ),
      );
    }

    return _buildInitials(context);
  }

  Widget _buildInitials(BuildContext context) {
    final initials = _getInitials(name ?? '');
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color:
                foregroundColor ??
                Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

/// Image preview dialog
class ImagePreviewDialog extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const ImagePreviewDialog({super.key, required this.imageUrl, this.heroTag});

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? heroTag,
  }) {
    return showDialog(
      context: context,
      builder: (context) =>
          ImagePreviewDialog(imageUrl: imageUrl, heroTag: heroTag),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black87),
          ),
          InteractiveViewer(
            child: Center(
              child: heroTag != null
                  ? Hero(
                      tag: heroTag!,
                      child: AppNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                      ),
                    )
                  : AppNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
