class BillingReport {
  final double totalCollection;
  final int paidBills;
  final int overdueBills;
  final List<String> topConsumers;

  const BillingReport({required this.totalCollection, required this.paidBills, required this.overdueBills, required this.topConsumers});
}
