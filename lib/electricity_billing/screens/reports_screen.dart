import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/billing_constants.dart';
import '../providers/billing_app_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String period = 'daily';

  DateTime get from {
    final now = DateTime.now();
    if (period == 'yearly') return DateTime(now.year);
    if (period == 'monthly') return DateTime(now.year, now.month);
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get to => DateTime.now();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<BillingAppProvider>();
    final collectorId = app.collector?.id ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SegmentedButton<String>(segments: const [
          ButtonSegment(value: 'daily', label: Text('يومي')),
          ButtonSegment(value: 'monthly', label: Text('شهري')),
          ButtonSegment(value: 'yearly', label: Text('سنوي')),
        ], selected: {period}, onSelectionChanged: (v) => setState(() => period = v.first)),
        const SizedBox(height: 16),
        FutureBuilder(
          future: app.repository.buildReport(collectorId: collectorId, from: from, to: to),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
            final report = snapshot.data!;
            return Column(children: [
              _tile('إجمالي التحصيل', '${report.totalCollection.toStringAsFixed(2)} ${BillingConstants.currency}', Icons.payments_rounded),
              _tile('عدد الفواتير المسددة', '${report.paidBills}', Icons.check_circle_rounded),
              _tile('عدد الفواتير المتأخرة', '${report.overdueBills}', Icons.warning_rounded),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('أعلى المشتركين استهلاكاً', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...report.topConsumers.map((e) => ListTile(leading: const Icon(Icons.bolt_rounded), title: Text(e))),
              ]))),
            ]);
          },
        ),
      ]),
    );
  }

  Widget _tile(String title, String value, IconData icon) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(leading: Icon(icon), title: Text(title), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))));
}
