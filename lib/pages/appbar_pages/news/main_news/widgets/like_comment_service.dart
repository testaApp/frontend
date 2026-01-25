import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../../models/news.dart';

class LikeCommentService {
  static const String _boxName = 'like_comment_box';
  late Box<News> _box;

  Future<void> init() async {
    _box = await Hive.openBox<News>(_boxName);
  }

  Future<void> toggleLike(String newsId, String userId) async {
    final news = _box.get(newsId);
    if (news != null) {
      final likedUsers = Hive.box<List<String>>('liked_users');
      final userLikes = likedUsers.get(newsId) ?? [];

      if (userLikes.contains(userId)) {
        userLikes.remove(userId);
        news.likeCount--;
      } else {
        userLikes.add(userId);
        news.likeCount++;
      }

      await likedUsers.put(newsId, userLikes);
      await _box.put(newsId, news);
    }
  }

  Future<void> addComment(
      String newsId, String text, String userId, String username) async {
    final news = _box.get(newsId);
    if (news != null) {
      final comment = Comment(
        id: const Uuid().v4(),
        text: text,
        userId: userId,
        username: username,
        timestamp: DateTime.now(),
      );
      news.comments.add(comment);
      await _box.put(newsId, news);
    }
  }

  Future<List<Comment>> getComments(String newsId) async {
    final news = _box.get(newsId);
    return news?.comments ?? [];
  }

  bool isLikedByUser(String newsId, String userId) {
    final likedUsers = Hive.box<List<String>>('liked_users');
    final userLikes = likedUsers.get(newsId) ?? [];
    return userLikes.contains(userId);
  }

  int getLikeCount(String newsId) {
    final news = _box.get(newsId);
    return news?.likeCount ?? 0;
  }
}
