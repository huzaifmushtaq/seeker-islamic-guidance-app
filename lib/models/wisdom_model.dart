class WisdomModel {
  final String id;
  final String type;
  final String text;
  final String reference;

  const WisdomModel({
    required this.id,
    required this.type,
    required this.text,
    required this.reference,
  });

  factory WisdomModel.fromJson(Map<String, dynamic> json) {
    return WisdomModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      text: json['text'] ?? '',
      reference: json['reference'] ?? '',
    );
  }
}
