import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../../util/auth/tokens.dart';
import '../../util/baseUrl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Notification> notifications = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    String url = BaseUrl().url;
    String accessToken = await getAccessToken();

    try {
      final response = await http.get(
        Uri.parse('$url/api/user/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'accesstoken': accessToken,
        },
      );

      print('Response status: ${response.statusCode}');
      print(
          'Response body: ${response.body.substring(0, min(200, response.body.length))}...');

      if (response.statusCode == 200) {
        final List<dynamic> notificationData = json.decode(response.body);
        setState(() {
          notifications = notificationData
              .map((data) => Notification.fromJson(data))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load notifications. Please try again later.\nError: $e';
      });
    }
  }

  void _handleNotificationTap(Notification notification) {
    context.pushNamed(
      notification.route, // The named route
      pathParameters: {
        'id': notification.id
      }, // Pass the ID as a path parameter
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: fetchNotifications,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchNotifications,
                  child: notifications.isEmpty
                      ? const Center(child: Text('No notifications'))
                      : ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return ListTile(
                              leading: notification.imageUrl != null
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(notification.imageUrl!),
                                      onBackgroundImageError: (e, s) {
                                        print('Error loading image: $e');
                                      },
                                    )
                                  : const Icon(Icons.notifications),
                              title: Text(notification.title),
                              subtitle: Text(notification.body),
                              trailing: Text(
                                formatTimeForNews(notification.date),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              onTap: () => _handleNotificationTap(notification),
                            );
                          },
                        ),
                ),
    );
  }

  String formatTimeForNews(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Notification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String route;
  final String group;
  final DateTime date;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.route,
    required this.group,
    required this.date,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      imageUrl: json['imageUrl'],
      route: json['route'],
      group: json['group'],
      date: DateTime.parse(json['date']),
    );
  }
}
