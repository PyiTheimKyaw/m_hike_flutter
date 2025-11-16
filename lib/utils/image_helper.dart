import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from camera or gallery
  static Future<String?> pickImage({
    ImageSource source = ImageSource.camera,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return null;

      // Save image to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(image.path);
      final savedImage = File(path.join(appDir.path, 'hike_images', fileName));

      // Create directory if it doesn't exist
      await savedImage.parent.create(recursive: true);

      // Copy image to app directory
      await File(image.path).copy(savedImage.path);

      return savedImage.path;
    } catch (e) {
      return null;
    }
  }

  /// Show dialog to choose image source
  static Future<String?> showImageSourceDialog() async {
    // This will be called from UI with context
    return null;
  }

  /// Delete image file
  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath != null) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors
      }
    }
  }
}
