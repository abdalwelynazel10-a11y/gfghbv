import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/billing_constants.dart';
import '../core/billing_theme.dart';
import '../providers/billing_app_provider.dart';
import '../widgets/stat_card.dart';
import 'reports_screen.dart';
import 'search_screen.dart';
import 'squares_screen.dart';

class BillingDashboardScreen extends StatelessWidget {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<BillingAppProvider>();
    final collector = app.collector;
    return Scaffold(
      appBar: AppBar(
        title: const Text(BillingConstants.appName),
        actions: [
          IconButton(tooltip: 'بحث', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillingSearchScreen())), icon: const Icon(Icons.search_rounded)),
          IconButton(tooltip: 'خروج', onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: app.loading
          ? const Center(child: CircularProgressIndicator())
          : collector == null
              ? Center(child: Text(app.error ?? 'لا توجد بيانات متحصل'))
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('bills').where('collectorId', isEqualTo: collector.id).snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    final unpaidTotal = docs.where((d) => d.data()['status'] != 'paid').fold<double>(0, (s, d) => s + ((d.data()['total'] as num?)?.toDouble() ?? 0));
                    final receipts = docs.where((d) => d.data()['status'] == 'paid').length;
                    return RefreshIndicator(
                      onRefresh: app.initialize,
                      child: ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          _Header(name: collector.name, employeeNumber: collector.employeeNumber, area: collector.area),
                          const SizedBox(height: 18),
                          GridView.count(
                            crossAxisCount: MediaQuery.sizeOf(context).width > 720 ? 4 : 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                            children: [
                              StatCard(title: 'عدد المشتركين', value: '${collector.assignedSubscribersCount}', icon: Icons.groups_rounded, color: BillingTheme.electricBlue),
                              StatCard(title: 'غير المسدد', value: unpaidTotal.toStringAsFixed(0), icon: Icons.receipt_long_rounded, color: Colors.redAccent),
                              StatCard(title: 'تحصيل اليوم', value: collector.todayCollectionTotal.toStringAsFixed(0), icon: Icons.payments_rounded, color: BillingTheme.successGreen),
                              StatCard(title: 'السندات', value: '$receipts', icon: Icons.fact_check_rounded, color: BillingTheme.powerOrange),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _ActionTile(title: 'إدارة المربعات', subtitle: 'عرض المربعات والمشتركين المكلف بهم', icon: Icons.grid_view_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SquaresScreen()))),
                          const SizedBox(height: 12),
                          _ActionTile(title: 'التقارير', subtitle: 'تقارير يومية وشهرية وسنوية', icon: Icons.analytics_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String employeeNumber;
  final String area;
  const _Header({required this.name, required this.employeeNumber, required this.area});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF071A2E), Color(0xFF0B5FFF)])),
      child: Row(children: [
        const CircleAvatar(radius: 34, backgroundColor: Colors.white24, child: Icon(Icons.electric_bolt_rounded, color: Colors.white, size: 38)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('رقم وظيفي: $employeeNumber • المنطقة: $area', style: const TextStyle(color: Colors.white70)),
        ])),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionTile({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(contentPadding: const EdgeInsets.all(16), leading: Icon(icon), title: Text(title), subtitle: Text(subtitle), trailing: const Icon(Icons.arrow_forward_ios_rounded), onTap: onTap));
  }
}
