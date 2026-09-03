import '../models/zakat_calculation.dart';

class ZakatService {
  static const double zakatRate = 0.025;
  static const double goldNisabGrams = 87.48;
  static const double silverNisabGrams = 612.36;

  ZakatCalculation calculate({
    required double goldValue,
    required double silverValue,
    required double cash,
    required double bankSavings,
    required double receivables,
    required double investments,
    required double businessInventory,
    required double otherZakatable,
    required double deductibleLiabilities,
    required double nisab,
    required String nisabBasis,
    required bool haulComplete,
  }) {
    final gross = goldValue +
        silverValue +
        cash +
        bankSavings +
        receivables +
        investments +
        businessInventory +
        otherZakatable;

    final double liabilities =
    deductibleLiabilities < 0 ? 0.0 : deductibleLiabilities;
    final net = (gross - liabilities).clamp(0, double.infinity).toDouble();
    final reachesNisab = nisab > 0 && net >= nisab;
    final eligible = reachesNisab && haulComplete;
    final due = eligible ? net * zakatRate : 0.0;

    return ZakatCalculation(
      goldValue: goldValue,
      silverValue: silverValue,
      cash: cash,
      bankSavings: bankSavings,
      receivables: receivables,
      investments: investments,
      businessInventory: businessInventory,
      otherZakatable: otherZakatable,
      deductibleLiabilities: liabilities,
      nisab: nisab,
      zakatableWealth: net,
      zakatDue: due,
      eligible: eligible,
      haulComplete: haulComplete,
      nisabBasis: nisabBasis,
    );
  }
}
