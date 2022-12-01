import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  NotificationService();

  static String serverKey = 'AAAAPMp-SoM:APA91bEtAQ5cnlf6iD9A-QUPaiXsmU7u6-MOaEBmTAZAe07xV9cpLpgJWAga6l2ZSegiNN0KSyTQ9ZO1wMa7QR6Ys6sOdKCc8xPHCxQYv5C7ZRyPDfZtTSPfkccbS9v84_xMDup7rH8a ';

  static final _notificationService = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('icon');

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _notificationService.initialize(settings);
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );

    return NotificationDetails(android: androidNotificationDetails);
  }

  Future<void> showNotification({required RemoteMessage message}) async {
    final details = await _notificationDetails();
    Random random = new Random();
    int id = random.nextInt(1000);
    await _notificationService.show(id, message.notification!.title, message.notification!.body, details);
  }

  Future<void> sendNotification({required String title,required String message, required String token}) async {
    final data = {
      'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
      'id' : '1',
      'status' : 'message',
      'message' : message,
    };

    try {
      http.Response res = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type' : 'application/json',
          'Authorization' : 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification' : <String, dynamic>{'body' : message, 'title': title},
            'priority' : 'high',
            'data' : data,
            'to' : token,
          }
        ),
      );
      
      print(res.body);
      if (res.statusCode == 200) {
        print("Notif Sended");
      } else {
        print(res.statusCode);
      }
    } catch(e) {
      print('exception $e');
    }
  }

}