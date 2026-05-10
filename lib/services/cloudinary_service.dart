import 'dart:typed_data';
import 'package:dio/dio.dart';

class CloudinaryService {
  // TODO: Create a free account at cloudinary.com
  // TODO: Replace with your Cloudinary Cloud Name (Dashboard -> Product Environment -> Cloud Name)
  static const String _cloudName = 'dcmrxkxkb';
  
  // TODO: Replace with your Cloudinary Upload Preset
  // Go to Settings -> Upload -> Add upload preset
  // Set "Signing Mode" to "Unsigned" and give it a name (e.g., 'fyp_uploads')
  static const String _uploadPreset = 'fyphelper';

  /// Uploads a file to Cloudinary and returns the secure public URL
  static Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String folder,
    void Function(double)? onProgress,
  }) async {
    final dio = Dio();
    final url = 'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload';

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      'upload_preset': _uploadPreset,
      'folder': folder, // Organizes files in Cloudinary folders
    });

    try {
      final response = await dio.post(
        url,
        data: formData,
        onSendProgress: (int sent, int total) {
          if (onProgress != null && total > 0) {
            final progress = sent / total;
            onProgress(progress);
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Cloudinary returns the secure HTTPS URL under the 'secure_url' key
        return response.data['secure_url'] as String;
      } else {
        throw Exception('Failed to upload: ${response.statusMessage}');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      throw Exception('Cloudinary upload error: $e');
    }
  }
}
