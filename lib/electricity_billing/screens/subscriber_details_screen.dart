import 'package:flutter/material.dart';

import '../core/billing_constants.dart';
import '../models/subscriber_model.dart';
import 'reading_entry_screen.dart';

class SubscriberDetailsScreen extends StatelessWidget {
  final SubscriberModel subscriber;
  const SubscriberDetailsScreen({super.key, required this.subscriber});

  @override
  Widget build(BuildContext context) {
    final rows = <String, String>{
      'الاسم الكامل': subscriber.fullName,
      'رقم المشترك': subscriber.subscriberNumber,
      'رقم العداد': subscriber.meterNumber,
      'الهاتف': subscriber.phone,
      'العنوان': subscriber.address,
      'حالة العداد': subscriber.meterStatus,
      'آخر قراءة': subscriber.lastReading.toStringAsFixed(0),
      'القراءة الحالية': subscriber.currentReading.toStringAsFixed(0),
      'الاستهلاك': subscriber.consumption.toStringAsFixed(0),
      'المتأخرات': '${subscriber.arrears.toStringAsFixed(2)} ${BillingConstants.currency}',
      'الرصيد السابق': '${subscriber.previousBalance.toStringAsFixed(2)} ${BillingConstants.currency}',
      'قيمة الفاتورة الحالية': '${subscriber.currentBillValue.toStringAsFixed(2)} ${BillingConstants.currency}',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('بيانات المشترك')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingEntryScreen(subscriber: subscriber))), icon: const Icon(Icons.speed_rounded), label: const Text('إدخال قراءة جديدة')),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: rows.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Flexible(child: Text(e.value, textAlign: TextAlign.end))]),
              )).toList()),
            ),
          ),
        ],
      ),
    );
  }
}
