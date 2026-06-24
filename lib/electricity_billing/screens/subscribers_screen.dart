import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/square_model.dart';
import '../models/subscriber_model.dart';
import '../providers/billing_app_provider.dart';
import 'subscriber_details_screen.dart';

class SubscribersScreen extends StatelessWidget {
  final SquareModel square;
  const SubscribersScreen({super.key, required this.square});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<BillingAppProvider>().repository;
    return Scaffold(
      appBar: AppBar(title: Text(square.name)),
      body: StreamBuilder<List<SubscriberModel>>(
        stream: repository.watchSubscribersBySquare(square.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final subscribers = snapshot.data!;
          if (subscribers.isEmpty) return const Center(child: Text('لا يوجد مشتركون في هذا المربع'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subscribers.length,
            itemBuilder: (context, index) {
              final subscriber = subscribers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                  title: Text(subscriber.fullName),
                  subtitle: Text('مشترك: ${subscriber.subscriberNumber} • عداد: ${subscriber.meterNumber}\n${subscriber.phone}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriberDetailsScreen(subscriber: subscriber))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
