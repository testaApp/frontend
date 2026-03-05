import 'package:http/http.dart' as http;

import 'package:blogapp/models/Live_Tv_model.dart';

Future<List<LivetvModel>> parseM3U(String url) async {
  try {
    if (!url.endsWith('.m3u') && !url.endsWith('.m3u8')) {
      throw const FormatException(
          'Invalid URL. Please enter a valid M3U/M3U8 link.');
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load the M3U file.');
    }

    List<LivetvModel> channels = [];
    final lines = response.body.split('\n');

    String? title;
    String? logo;
    String? groupTitle;
    String? tvgId;

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('#EXTINF')) {
        final attributes = line.split(',');
        title = attributes.length > 1 ? attributes[1].trim() : 'Unknown Title';

        final logoMatches = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line);
        logo = logoMatches != null ? logoMatches.group(1) : '';

        final groupMatches = RegExp(r'group-title="([^"]*)"').firstMatch(line);
        groupTitle =
            groupMatches != null ? groupMatches.group(1) : 'User Added';

        final tvgIdMatches = RegExp(r'tvg-id="([^"]*)"').firstMatch(line);
        tvgId = tvgIdMatches != null ? tvgIdMatches.group(1) : 'unknown';
      } else if (line.startsWith('http') && title != null) {
        channels.add(LivetvModel(
          id: line,
          tvgId: tvgId ?? 'unknown',
          tvgLogo: logo ?? '',
          groupTitle: groupTitle ?? 'User Added',
          title: title,
          url: line.trim(),
          updatedAt: DateTime.now(),
        ));
        title = null; // Reset title for next entry
        logo = null;
        groupTitle = null;
        tvgId = null;
      }
    }

    return channels;
  } catch (e) {
    rethrow; // Pass the error back to the Bloc for handling
  }
}
