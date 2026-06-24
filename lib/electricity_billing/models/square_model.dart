import 'package:cloud_firestore/cloud_firestore.dart';

class SquareModel {
  final String id;
  final String name;
  final String area;
  final String collectorId;
  final int subscribersCount;

  const SquareModel({required this.id, required this.name, required this.area, required this.collectorId, required this.subscribersCount});

  factory SquareModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return SquareModel(
      id: doc.id,
      name: (data['name'] ?? 'مربع').toString(),
      area: (data['area'] ?? '').toString(),
      collectorId: (data['collectorId'] ?? '').toString(),
      subscribersCount: int.tryParse((data['subscribersCount'] ?? 0).toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'area': area, 'collectorId': collectorId, 'subscribersCount': subscribersCount};
}
