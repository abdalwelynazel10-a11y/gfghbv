import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String billId;
  final String subscriberId;
  final String collectorId;
  final double amount;
  final String method;
  final DateTime paidAt;

  const PaymentModel({required this.id, required this.billId, required this.subscriberId, required this.collectorId, required this.amount, required this.method, required this.paidAt});

  Map<String, dynamic> toMap() => {'billId': billId, 'subscriberId': subscriberId, 'collectorId': collectorId, 'amount': amount, 'method': method, 'paidAt': Timestamp.fromDate(paidAt)};
}
