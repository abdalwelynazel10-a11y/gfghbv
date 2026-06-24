import 'package:flutter/material.dart';

import '../models/bill_model.dart';
import '../models/collector_model.dart';
import '../models/receipt_model.dart';
import '../models/subscriber_model.dart';
import '../services/billing_notification_service.dart';
import '../services/electricity_billing_repository.dart';

class BillingAppProvider extends ChangeNotifier {
  final ElectricityBillingRepository repository;
  final BillingNotificationService notifications;

  BillingAppProvider({required this.repository, required this.notifications});

  CollectorModel? collector;
  bool loading = false;
  String? error;

  Future<void> initialize() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await notifications.initialize();
      collector = await repository.loadCurrentCollector();
      if (collector == null) error = 'لم يتم العثور على بيانات المتحصل في Firebase';
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<BillModel> createBill({required SubscriberModel subscriber, required double previousReading, required double currentReading, double adminFees = 0, double extraFees = 0}) async {
    final activeCollector = collector;
    if (activeCollector == null) throw StateError('بيانات المتحصل غير محملة');
    final bill = await repository.createReadingAndBill(subscriber: subscriber, collectorId: activeCollector.id, previousReading: previousReading, currentReading: currentReading, adminFees: adminFees, extraFees: extraFees);
    notifyListeners();
    return bill;
  }

  Future<ReceiptModel> payBill({required BillModel bill, required SubscriberModel subscriber, required String method}) async {
    final activeCollector = collector;
    if (activeCollector == null) throw StateError('بيانات المتحصل غير محملة');
    final receipt = await repository.payBill(bill: bill, subscriber: subscriber, collector: activeCollector, method: method);
    await notifications.paymentSaved(bill.total);
    notifyListeners();
    return receipt;
  }
}
