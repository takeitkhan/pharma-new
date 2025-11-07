import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static Future<void> sendTopicNotification({
    required String title,
    required String body,
    required String topic,
  }) async {
    const serverKey =
        "AAAA11afjE8:APA91bHvhOsfthYzR0RRlZ2pwdRwwvBeS0FOvpaI5_sdU8X5TYFwVpGoRr39WrZf9N5OTysmzc8ltc-hmpNnNAwiwmvdqgJAxK0mPRiEyn4OzmWM4muCvfW0mi7SWHrCUTFvo7eA7DdO"; // Replace with your server key
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'notification': {'title': title, 'body': body},
        'to': '/topics/$topic',
      }),
    );

    if (response.statusCode != 200) {
      print("Error sending notification: ${response.body}");
    } else {
      print("Notification sent successfully to $topic");
    }
  }
}
