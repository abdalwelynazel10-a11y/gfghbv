import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/billing_constants.dart';
import '../models/subscriber_model.dart';
import '../providers/billing_app_provider.dart';
import '../services/billing_calculator.dart';
import 'bill_screen.dart';

class ReadingEntryScreen extends StatefulWidget {
  final SubscriberModel subscriber;
  const ReadingEntryScreen({super.key, required this.subscriber});

  @override
  State<ReadingEntryScreen> createState() => _ReadingEntryScreenState();
}

class _ReadingEntryScreenState extends State<ReadingEntryScreen> {
  late final TextEditingController previous;
  late final TextEditingController current;
  final adminFees = TextEditingController(text: '0');
  final extraFees = TextEditingController(text: '0');
  bool saving = false;

  @override
  void initState() {
    super.initState();
    previous = TextEditingController(text: widget.subscriber.currentReading.toStringAsFixed(0));
    current = TextEditingController();
  }

  @override
  void dispose() {
    previous.dispose();
    current.dispose();
    adminFees.dispose();
    extraFees.dispose();
    super.dispose();
  }

  double get previousValue => double.tryParse(previous.text) ?? 0;
  double get currentValue => double.tryParse(current.text) ?? 0;
  double get consumption => BillingCalculator.consumption(previousReading: previousValue, currentReading: currentValue);
  double get total => BillingCalculator.finalTotal(consumption: consumption, arrears: widget.subscriber.arrears, adminFees: double.tryParse(adminFees.text) ?? 0, extraFees: double.tryParse(extraFees.text) ?? 0);

  Future<void> save() async {
    if (currentValue < previousValue) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('القراءة الحالية يجب أن تكون أكبر من أو تساوي السابقة')));
      return;
    }
    setState(() => saving = true);
    try {
      final bill = await context.read<BillingAppProvider>().createBill(subscriber: widget.subscriber, previousReading: previousValue, currentReading: currentValue, adminFees: double.tryParse(adminFees.text) ?? 0, extraFees: double.tryParse(extraFees.text) ?? 0);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BillScreen(subscriber: widget.subscriber, bill: bill)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل حفظ القراءة: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدخال القراءة')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: previous, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'القراءة السابقة')),
        const SizedBox(height: 12),
        TextField(controller: current, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'القراءة الحالية'), onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        TextField(controller: adminFees, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الرسوم الإدارية'), onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        TextField(controller: extraFees, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رسوم إضافية'), onChanged: (_) => setState(() {})),
        const SizedBox(height: 18),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
          _row('الاستهلاك', '${consumption.toStringAsFixed(0)} ك.و'),
          _row('سعر الكيلو وات', BillingConstants.kwhPrice.toStringAsFixed(0)),
          _row('الإجمالي النهائي', '${total.toStringAsFixed(2)} ${BillingConstants.currency}'),
        ]))),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: saving ? null : save, icon: saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded), label: const Text('حفظ وإصدار فاتورة')),
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Text(label), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));
}
