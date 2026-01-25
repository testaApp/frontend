import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String?> downloadAndSaveImage(String imageUrl, String fileName) async {
  try {
    // Request appropriate permissions based on Android version
    if (Platform.isAndroid) {
      if (await Permission.photos.status.isDenied) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          print('Photos permission denied by user');
          return null;
        }
      }
    }

    // Get the proper directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      String newPath = '';
      List<String> paths = directory!.path.split('/');
      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != 'Android') {
          newPath += '/$folder';
        } else {
          break;
        }
      }
      newPath = '$newPath/Pictures/TestApp';
      directory = Directory(newPath);
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // Create directory if it doesn't exist
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Download and save the image
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      print('Failed to download image: ${response.statusCode}');
      return null;
    }

    final File file = File('${directory.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes);

    print('Image saved successfully at: ${file.path}');
    return file.path;
  } catch (e) {
    print('Error saving image: $e');
    return null;
  }
}
