import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/square_model.dart';
import '../providers/billing_app_provider.dart';
import 'subscribers_screen.dart';

class SquaresScreen extends StatelessWidget {
  const SquaresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<BillingAppProvider>();
    final collectorId = app.collector?.id ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المربعات')),
      body: StreamBuilder<List<SquareModel>>(
        stream: app.repository.watchSquares(collectorId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final squares = snapshot.data!;
          if (squares.isEmpty) return const Center(child: Text('لا توجد مربعات مكلف بها'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: squares.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _SquareCard(square: squares[index]),
          );
        },
      ),
    );
  }
}

class _SquareCard extends StatelessWidget {
  final SquareModel square;
  const _SquareCard({required this.square});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(child: Text('${square.subscribersCount}')),
        title: Text(square.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('عدد المشتركين: ${square.subscribersCount}\n${square.area}'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubscribersScreen(square: square))),
      ),
    );
  }
}
