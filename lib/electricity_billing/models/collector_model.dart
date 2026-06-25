import 'package:cloud_firestore/cloud_firestore.dart';

class CollectorModel {
  final String id;
  final String uid;
  final String name;
  final String employeeNumber;
  final String area;
  final int assignedSubscribersCount;
  final double todayCollectionTotal;

  const CollectorModel({required this.id, required this.uid, required this.name, required this.employeeNumber, required this.area, required this.assignedSubscribersCount, required this.todayCollectionTotal});

  factory CollectorModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CollectorModel(
      id: doc.id,
      uid: (data['uid'] ?? doc.id).toString(),
      name: (data['name'] ?? data['fullName'] ?? 'متحصل').toString(),
      employeeNumber: (data['employeeNumber'] ?? data['jobNumber'] ?? '').toString(),
      area: (data['area'] ?? '').toString(),
      assignedSubscribersCount: int.tryParse((data['assignedSubscribersCount'] ?? 0).toString()) ?? 0,
      todayCollectionTotal: (data['todayCollectionTotal'] is num) ? (data['todayCollectionTotal'] as num).toDouble() : double.tryParse((data['todayCollectionTotal'] ?? 0).toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'uid': uid, 'name': name, 'employeeNumber': employeeNumber, 'area': area, 'assignedSubscribersCount': assignedSubscribersCount, 'todayCollectionTotal': todayCollectionTotal};
}
