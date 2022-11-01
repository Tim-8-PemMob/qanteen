import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {
  NotificationApi();

  static final _notificationService = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

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

  Future<void> showNotification({required int id, required String title, required String body}) async {
    final details = await _notificationDetails();
    await _notificationService.show(id, title, body, details);
  }

}