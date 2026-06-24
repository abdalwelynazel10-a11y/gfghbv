import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/billing_constants.dart';
import '../models/bill_model.dart';
import '../models/subscriber_model.dart';
import '../providers/billing_app_provider.dart';
import '../services/receipt_pdf_service.dart';

class BillScreen extends StatefulWidget {
  final SubscriberModel subscriber;
  final BillModel bill;
  const BillScreen({super.key, required this.subscriber, required this.bill});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  String method = 'نقداً';
  bool paying = false;

  Future<void> pay() async {
    setState(() => paying = true);
    try {
      final receipt = await context.read<BillingAppProvider>().payBill(bill: widget.bill, subscriber: widget.subscriber, method: method);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Icon(Icons.verified_rounded, size: 54, color: Colors.green),
            Text('تم إنشاء سند رقم ${receipt.receiptNumber}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: () => ReceiptPdfService().shareReceipt(receipt), icon: const Icon(Icons.share_rounded), label: const Text('مشاركة السند PDF')),
            OutlinedButton.icon(onPressed: () => ReceiptPdfService().printReceipt(receipt), icon: const Icon(Icons.print_rounded), label: const Text('طباعة السند')),
            OutlinedButton.icon(onPressed: () => ReceiptPdfService().sendViaWhatsApp(receipt, widget.subscriber.phone), icon: const Icon(Icons.chat_rounded), label: const Text('إرسال عبر واتساب')),
            OutlinedButton.icon(onPressed: () => ReceiptPdfService().sendViaTelegram(receipt), icon: const Icon(Icons.send_rounded), label: const Text('إرسال عبر تيليجرام')),
          ]),
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل السداد: $e')));
    } finally {
      if (mounted) setState(() => paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = <String, String>{
      'اسم المشترك': widget.subscriber.fullName,
      'رقم المشترك': widget.subscriber.subscriberNumber,
      'رقم العداد': widget.subscriber.meterNumber,
      'الاستهلاك': '${widget.bill.consumption.toStringAsFixed(0)} ك.و',
      'المتأخرات': widget.bill.arrears.toStringAsFixed(2),
      'القيمة الحالية': widget.bill.currentValue.toStringAsFixed(2),
      'الإجمالي': '${widget.bill.total.toStringAsFixed(2)} ${BillingConstants.currency}',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('الفاتورة')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Icon(Icons.receipt_long_rounded, size: 56),
              Text(BillingConstants.appName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              ...rows.entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Text(e.key), const Spacer(), Flexible(child: Text(e.value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold)))]))),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: method, decoration: const InputDecoration(labelText: 'طريقة الدفع'), items: const ['نقداً', 'تحويل بنكي', 'محفظة إلكترونية'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => method = v ?? method)),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: paying ? null : pay, icon: paying ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.payments_rounded), label: const Text('تسجيل السداد وإصدار سند')),
      ]),
    );
  }
}
