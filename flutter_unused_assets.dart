import 'dart:io';

void main() {
  final assetDirectory = Directory('assets');
  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  if (!assetDirectory.existsSync()) {
    print('Assets directory does not exist.');
    return;
  }

  final assetFiles = assetDirectory
      .listSync(recursive: true)
      .whereType<File>()
      .map(
          (file) => file.path.replaceAll('\\', '/').replaceFirst('assets/', ''))
      .toSet();

  final usedAssets = <String>{};

  for (var file in dartFiles) {
    final content = File(file.path).readAsStringSync();
    for (var asset in assetFiles) {
      if (content.contains(asset)) {
        usedAssets.add(asset);
      }
    }
  }

  final unusedAssets = assetFiles.difference(usedAssets);

  if (unusedAssets.isEmpty) {
    print('No unused assets found.');
  } else {
    print('Unused assets:');
    for (var asset in unusedAssets) {
      print(' - $asset');
    }
    
    print('\nWould you like to delete these unused assets? (y/n)');
    final response = stdin.readLineSync()?.toLowerCase();
    
    if (response == 'y') {
      for (var asset in unusedAssets) {
        final file = File('assets/$asset');
        if (file.existsSync()) {
          file.deleteSync();
          print('Deleted: $asset');
        }
      }
      print('Deletion complete.');
    } else {
      print('No files were deleted.');
    }
  }
}
