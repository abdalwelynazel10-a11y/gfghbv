import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BillingNotificationService {
  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await plugin.initialize(settings);
  }

  Future<void> overdueBill(String subscriberName) async {
    await plugin.show(1001, 'فاتورة متأخرة', 'المشترك $subscriberName لديه فاتورة غير مسددة', const NotificationDetails(android: AndroidNotificationDetails('billing_overdue', 'فواتير متأخرة', importance: Importance.high)));
  }

  Future<void> paymentSaved(double amount) async {
    await plugin.show(1002, 'تم تسجيل سداد', 'تم تحصيل مبلغ ${amount.toStringAsFixed(2)}', const NotificationDetails(android: AndroidNotificationDetails('billing_payments', 'السداد', importance: Importance.high)));
  }
}
