import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class FileAttachmentService {
  /// Pick multiple images from gallery
  static Future<List<String>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    return images.map((img) => img.path).toList();
  }

  /// Pick a single image from camera or gallery
  static Future<String?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    return image?.path;
  }

  /// Pick multiple PDF files
  static Future<List<String>> pickPDFs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      return result.paths.whereType<String>().toList();
    }
    return [];
  }

  /// Check if a file exists at the given path
  static bool fileExists(String path) {
    try {
      return File(path).existsSync();
    } catch (e) {
      return false;
    }
  }

  /// Get file name from path
  static String getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }
}
