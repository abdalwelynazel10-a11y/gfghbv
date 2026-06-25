import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  final String id;
  final String subscriberId;
  final String collectorId;
  final double previousReading;
  final double currentReading;
  final double consumption;
  final double kwhPrice;
  final double arrears;
  final double adminFees;
  final double extraFees;
  final double currentValue;
  final double total;
  final String status;
  final DateTime createdAt;

  const BillModel({required this.id, required this.subscriberId, required this.collectorId, required this.previousReading, required this.currentReading, required this.consumption, required this.kwhPrice, required this.arrears, required this.adminFees, required this.extraFees, required this.currentValue, required this.total, required this.status, required this.createdAt});

  factory BillModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    double d(String k) => (data[k] is num) ? (data[k] as num).toDouble() : double.tryParse((data[k] ?? 0).toString()) ?? 0;
    final ts = data['createdAt'];
    return BillModel(
      id: doc.id,
      subscriberId: (data['subscriberId'] ?? '').toString(),
      collectorId: (data['collectorId'] ?? '').toString(),
      previousReading: d('previousReading'),
      currentReading: d('currentReading'),
      consumption: d('consumption'),
      kwhPrice: d('kwhPrice'),
      arrears: d('arrears'),
      adminFees: d('adminFees'),
      extraFees: d('extraFees'),
      currentValue: d('currentValue'),
      total: d('total'),
      status: (data['status'] ?? 'unpaid').toString(),
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.tryParse((ts ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {'subscriberId': subscriberId, 'collectorId': collectorId, 'previousReading': previousReading, 'currentReading': currentReading, 'consumption': consumption, 'kwhPrice': kwhPrice, 'arrears': arrears, 'adminFees': adminFees, 'extraFees': extraFees, 'currentValue': currentValue, 'total': total, 'status': status, 'createdAt': Timestamp.fromDate(createdAt)};
}
