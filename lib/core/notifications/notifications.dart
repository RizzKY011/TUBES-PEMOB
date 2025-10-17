import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotifications {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: initAndroid);
    await _plugin.initialize(settings);
  }

  static Future<void> showSimple({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _plugin.show(DateTime.now().millisecondsSinceEpoch % 100000, title, body, details);
  }
}


