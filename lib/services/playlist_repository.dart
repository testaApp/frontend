import 'package:blogapp/shared/constants/links.dart';

abstract class PlaylistRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();

  Future<List<Map<String, String>>> AnotherPlaylist();
  Future<Map<String, String>> fetchAnotherSong();
}

class DemoPlaylist extends PlaylistRepository {
  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist() async {
    List<Map<String, String>> songModelList = carddata
        .map((card) => <String, String>{
              'id': '8',
              'title': card['title']!,
              'artist': 'መንሱር',
              'avatar': 'file://assets/mensur.png' ?? '',
              'uri': card['audioUrl']!
            })
        .toList();

    return songModelList;
  }

  @override
  Future<List<Map<String, String>>> AnotherPlaylist() async {
    List<Map<String, String>> songModelList = carddata
        .map((card) => <String, String>{
              'id': '8',
              'title': card['title']!,
              'artist': 'መንሱር',
              'avatar': 'file://asset/mensur.png',
              'uri': card['audioUrl']!
            })
        .toList();
////print(songModelList);
////print("fetch another playlist");
////print("-------------------");
    List<Map<String, String>> newSongModelList =
        List.from(songModelList.reversed);
    return newSongModelList;
  }

  Future<List<Map<String, String>>> fetchLivePlaylist(
      Map<String, String> livedata) async {
    List<Map<String, String>> songModelList = carddata
        .map((card) => <String, String>{
              'id': card['id'] ?? '',
              'title': card['title']!,
              'artist': card['name'] ?? '',
              'avatar': "file://assets/${card['uri']}" ?? '',
              'uri': card['audioUrl'] ?? ''
            })
        .toList();

    return songModelList;
  }

  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    return _nextSong();
  }

  var _songIndex = 0;
  static const _maxSongNumber = 16;

  Map<String, String> _nextSong() {
    _songIndex = (_songIndex % _maxSongNumber) + 1;
    return {
      'id': _songIndex.toString().padLeft(3, '0'),
      'title': 'Song $_songIndex',
      'album': 'SoundHelix',
      'url':
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$_songIndex.mp3',
    };
  }
}
