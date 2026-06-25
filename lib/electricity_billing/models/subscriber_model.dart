import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriberModel {
  final String id;
  final String squareId;
  final String fullName;
  final String subscriberNumber;
  final String meterNumber;
  final String phone;
  final String address;
  final String meterStatus;
  final double lastReading;
  final double currentReading;
  final double arrears;
  final double previousBalance;
  final double currentBillValue;

  const SubscriberModel({required this.id, required this.squareId, required this.fullName, required this.subscriberNumber, required this.meterNumber, required this.phone, required this.address, required this.meterStatus, required this.lastReading, required this.currentReading, required this.arrears, required this.previousBalance, required this.currentBillValue});

  double get consumption => currentReading - lastReading < 0 ? 0 : currentReading - lastReading;

  factory SubscriberModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    double d(String key) => (data[key] is num) ? (data[key] as num).toDouble() : double.tryParse((data[key] ?? 0).toString()) ?? 0;
    return SubscriberModel(
      id: doc.id,
      squareId: (data['squareId'] ?? '').toString(),
      fullName: (data['fullName'] ?? data['name'] ?? '').toString(),
      subscriberNumber: (data['subscriberNumber'] ?? '').toString(),
      meterNumber: (data['meterNumber'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      meterStatus: (data['meterStatus'] ?? 'نشط').toString(),
      lastReading: d('lastReading'),
      currentReading: d('currentReading'),
      arrears: d('arrears'),
      previousBalance: d('previousBalance'),
      currentBillValue: d('currentBillValue'),
    );
  }

  Map<String, dynamic> toMap() => {'squareId': squareId, 'fullName': fullName, 'subscriberNumber': subscriberNumber, 'meterNumber': meterNumber, 'phone': phone, 'address': address, 'meterStatus': meterStatus, 'lastReading': lastReading, 'currentReading': currentReading, 'arrears': arrears, 'previousBalance': previousBalance, 'currentBillValue': currentBillValue};
}
