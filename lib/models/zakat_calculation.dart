class ZakatCalculation {
  final double goldValue;
  final double silverValue;
  final double cash;
  final double bankSavings;
  final double receivables;
  final double investments;
  final double businessInventory;
  final double otherZakatable;
  final double deductibleLiabilities;
  final double nisab;
  final double zakatableWealth;
  final double zakatDue;
  final bool eligible;
  final bool haulComplete;
  final String nisabBasis;

  const ZakatCalculation({
    required this.goldValue,
    required this.silverValue,
    required this.cash,
    required this.bankSavings,
    required this.receivables,
    required this.investments,
    required this.businessInventory,
    required this.otherZakatable,
    required this.deductibleLiabilities,
    required this.nisab,
    required this.zakatableWealth,
    required this.zakatDue,
    required this.eligible,
    required this.haulComplete,
    required this.nisabBasis,
  });

  double get grossAssets =>
      goldValue +
      silverValue +
      cash +
      bankSavings +
      receivables +
      investments +
      businessInventory +
      otherZakatable;
}
