import '../core/billing_constants.dart';

class BillingCalculator {
  static double consumption({required double previousReading, required double currentReading}) {
    final value = currentReading - previousReading;
    return value < 0 ? 0 : value;
  }

  static double currentValue(double consumption) => consumption * BillingConstants.kwhPrice;

  static double finalTotal({required double consumption, required double arrears, required double adminFees, required double extraFees}) {
    return currentValue(consumption) + arrears + adminFees + extraFees;
  }
}
