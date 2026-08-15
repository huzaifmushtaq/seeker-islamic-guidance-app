class WisdomModel {
  final String id;
  final String type;
  final String arabic;
  final String urdu;
  final String reference;

  WisdomModel({
    required this.id,
    required this.type,
    required this.arabic,
    required this.urdu,
    required this.reference,
  });

  factory WisdomModel.fromJson(Map<String, dynamic> json) {
    return WisdomModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      arabic: json['arabic'] ?? '',
      urdu: json['urdu'] ?? '',
      reference: json['reference'] ?? '',
    );
  }
}