import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/billing_constants.dart';
import '../models/bill_model.dart';
import '../models/collector_model.dart';
import '../models/payment_model.dart';
import '../models/receipt_model.dart';
import '../models/report_model.dart';
import '../models/square_model.dart';
import '../models/subscriber_model.dart';
import 'billing_calculator.dart';

class ElectricityBillingRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ElectricityBillingRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get users => firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get collectors => firestore.collection('collectors');
  CollectionReference<Map<String, dynamic>> get subscribers => firestore.collection('subscribers');
  CollectionReference<Map<String, dynamic>> get meters => firestore.collection('meters');
  CollectionReference<Map<String, dynamic>> get readings => firestore.collection('readings');
  CollectionReference<Map<String, dynamic>> get bills => firestore.collection('bills');
  CollectionReference<Map<String, dynamic>> get payments => firestore.collection('payments');
  CollectionReference<Map<String, dynamic>> get receipts => firestore.collection('receipts');
  CollectionReference<Map<String, dynamic>> get squares => firestore.collection('squares');
  CollectionReference<Map<String, dynamic>> get reports => firestore.collection('reports');

  Future<CollectorModel?> loadCurrentCollector() async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return null;
    final byUid = await collectors.where('uid', isEqualTo: uid).limit(1).get();
    if (byUid.docs.isNotEmpty) return CollectorModel.fromDoc(byUid.docs.first);
    final doc = await collectors.doc(uid).get();
    if (doc.exists) return CollectorModel.fromDoc(doc);
    final userDoc = await users.doc(uid).get();
    if (!userDoc.exists) return null;
    final data = userDoc.data() ?? <String, dynamic>{};
    if ((data['role'] ?? data['accountType'] ?? '').toString() != 'collector') return null;
    return CollectorModel.fromDoc(userDoc);
  }

  Stream<List<SquareModel>> watchSquares(String collectorId) {
    final query = collectorId.trim().isEmpty ? squares : squares.where('collectorId', isEqualTo: collectorId);
    return query.snapshots().map((snapshot) => snapshot.docs.map(SquareModel.fromDoc).toList());
  }

  Stream<List<SubscriberModel>> watchSubscribersBySquare(String squareId) {
    return subscribers.where('squareId', isEqualTo: squareId).snapshots().map((snapshot) => snapshot.docs.map(SubscriberModel.fromDoc).toList());
  }

  Stream<List<SubscriberModel>> searchSubscribers(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) return subscribers.limit(30).snapshots().map((snapshot) => snapshot.docs.map(SubscriberModel.fromDoc).toList());
    return subscribers.where('searchTokens', arrayContains: normalized.toLowerCase()).limit(50).snapshots().map((snapshot) => snapshot.docs.map(SubscriberModel.fromDoc).toList());
  }

  Future<BillModel> createReadingAndBill({required SubscriberModel subscriber, required String collectorId, required double previousReading, required double currentReading, double adminFees = BillingConstants.defaultAdminFees, double extraFees = 0}) async {
    final consumption = BillingCalculator.consumption(previousReading: previousReading, currentReading: currentReading);
    final currentValue = BillingCalculator.currentValue(consumption);
    final total = BillingCalculator.finalTotal(consumption: consumption, arrears: subscriber.arrears, adminFees: adminFees, extraFees: extraFees);
    final billRef = bills.doc();
    final now = DateTime.now();
    final bill = BillModel(id: billRef.id, subscriberId: subscriber.id, collectorId: collectorId, previousReading: previousReading, currentReading: currentReading, consumption: consumption, kwhPrice: BillingConstants.kwhPrice, arrears: subscriber.arrears, adminFees: adminFees, extraFees: extraFees, currentValue: currentValue, total: total, status: 'unpaid', createdAt: now);
    final batch = firestore.batch();
    batch.set(readings.doc(), {'subscriberId': subscriber.id, 'collectorId': collectorId, 'previousReading': previousReading, 'currentReading': currentReading, 'consumption': consumption, 'createdAt': Timestamp.fromDate(now)});
    batch.set(billRef, bill.toMap());
    batch.update(subscribers.doc(subscriber.id), {'lastReading': previousReading, 'currentReading': currentReading, 'currentBillValue': currentValue, 'updatedAt': FieldValue.serverTimestamp()});
    await batch.commit();
    return bill;
  }

  Future<ReceiptModel> payBill({required BillModel bill, required SubscriberModel subscriber, required CollectorModel collector, required String method}) async {
    if (bill.id.trim().isEmpty || subscriber.id.trim().isEmpty || collector.id.trim().isEmpty) {
      throw StateError('بيانات السداد غير مكتملة');
    }
    final paymentRef = payments.doc();
    final receiptRef = receipts.doc();
    final now = DateTime.now();
    final payment = PaymentModel(id: paymentRef.id, billId: bill.id, subscriberId: subscriber.id, collectorId: collector.id, amount: bill.total, method: method, paidAt: now);
    final receipt = ReceiptModel(id: receiptRef.id, receiptNumber: 'EL-${now.millisecondsSinceEpoch}', collectorName: collector.name, subscriberName: subscriber.fullName, subscriberId: subscriber.id, paymentId: payment.id, amount: bill.total, paymentMethod: method, createdAt: now);
    final batch = firestore.batch();
    batch.set(paymentRef, payment.toMap());
    batch.set(receiptRef, receipt.toMap());
    batch.update(bills.doc(bill.id), {'status': 'paid', 'paidAt': Timestamp.fromDate(now), 'paymentId': payment.id});
    batch.update(subscribers.doc(subscriber.id), {'arrears': 0, 'previousBalance': 0, 'currentBillValue': 0, 'lastPaymentAt': Timestamp.fromDate(now)});
    batch.set(reports.doc('${collector.id}_${now.year}_${now.month}_${now.day}'), {'collectorId': collector.id, 'totalCollection': FieldValue.increment(bill.total), 'paidBills': FieldValue.increment(1), 'updatedAt': Timestamp.fromDate(now)}, SetOptions(merge: true));
    await batch.commit();
    return receipt;
  }

  Future<BillingReport> buildReport({required String collectorId, required DateTime from, required DateTime to}) async {
    final paid = await bills.where('collectorId', isEqualTo: collectorId).where('status', isEqualTo: 'paid').where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from)).where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to)).get();
    final overdue = await bills.where('collectorId', isEqualTo: collectorId).where('status', isEqualTo: 'unpaid').get();
    final all = await bills.where('collectorId', isEqualTo: collectorId).orderBy('consumption', descending: true).limit(5).get();
    return BillingReport(
      totalCollection: paid.docs.fold<double>(0, (sum, doc) => sum + ((doc.data()['total'] as num?)?.toDouble() ?? 0)),
      paidBills: paid.docs.length,
      overdueBills: overdue.docs.length,
      topConsumers: all.docs.map((doc) => '${doc.data()['subscriberId']} - ${doc.data()['consumption']} ك.و').toList(),
    );
  }
}
