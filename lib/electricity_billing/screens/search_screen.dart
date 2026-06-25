import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscriber_model.dart';
import '../providers/billing_app_provider.dart';
import 'subscriber_details_screen.dart';

class BillingSearchScreen extends StatefulWidget {
  const BillingSearchScreen({super.key});

  @override
  State<BillingSearchScreen> createState() => _BillingSearchScreenState();
}

class _BillingSearchScreenState extends State<BillingSearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final repository = context.read<BillingAppProvider>().repository;
    return Scaffold(
      appBar: AppBar(title: const Text('بحث سريع')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(autofocus: true, decoration: const InputDecoration(hintText: 'اسم المشترك / رقم المشترك / رقم العداد / الهاتف', prefixIcon: Icon(Icons.search_rounded)), onChanged: (v) => setState(() => query = v)),
        ),
        Expanded(
          child: StreamBuilder<List<SubscriberModel>>(
            stream: repository.searchSubscribers(query),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final subscribers = snapshot.data!;
              if (subscribers.isEmpty) return const Center(child: Text('لا توجد نتائج'));
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: subscribers.length,
                itemBuilder: (context, index) {
                  final s = subscribers[index];
                  return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(title: Text(s.fullName), subtitle: Text('${s.subscriberNumber} • ${s.meterNumber} • ${s.phone}'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriberDetailsScreen(subscriber: s)))));
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
