class AzkarModel {
  final String id;
  final String category;
  final String arabic;
  final String benefit;
  final String reference;
  final int targetCount;

  const AzkarModel({
    required this.id,
    required this.category,
    required this.arabic,
    required this.benefit,
    required this.reference,
    required this.targetCount,
  });

  factory AzkarModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AzkarModel(
      // The original JSON has no ID,
      // so we generate one later from the index.
      id: json["id"]?.toString() ?? "",

      category: json["category"]?.toString() ?? "",

      arabic: json["zekr"]?.toString() ?? "",

      benefit: json["description"]?.toString() ?? "",

      reference: json["reference"]?.toString() ?? "",

      targetCount:
          int.tryParse(
                json["count"]?.toString() ?? "1",
              ) ??
              1,
    );
  }
}