import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptModel {
  final String id;
  final String receiptNumber;
  final String collectorName;
  final String subscriberName;
  final String subscriberId;
  final String paymentId;
  final double amount;
  final String paymentMethod;
  final DateTime createdAt;

  const ReceiptModel({required this.id, required this.receiptNumber, required this.collectorName, required this.subscriberName, required this.subscriberId, required this.paymentId, required this.amount, required this.paymentMethod, required this.createdAt});

  factory ReceiptModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final ts = data['createdAt'];
    return ReceiptModel(
      id: doc.id,
      receiptNumber: (data['receiptNumber'] ?? doc.id).toString(),
      collectorName: (data['collectorName'] ?? '').toString(),
      subscriberName: (data['subscriberName'] ?? '').toString(),
      subscriberId: (data['subscriberId'] ?? '').toString(),
      paymentId: (data['paymentId'] ?? '').toString(),
      amount: (data['amount'] is num) ? (data['amount'] as num).toDouble() : double.tryParse((data['amount'] ?? 0).toString()) ?? 0,
      paymentMethod: (data['paymentMethod'] ?? 'نقداً').toString(),
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.tryParse((ts ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {'receiptNumber': receiptNumber, 'collectorName': collectorName, 'subscriberName': subscriberName, 'subscriberId': subscriberId, 'paymentId': paymentId, 'amount': amount, 'paymentMethod': paymentMethod, 'createdAt': Timestamp.fromDate(createdAt)};
}
