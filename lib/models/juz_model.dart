class JuzModel {
  final int id;
  final String name;

  const JuzModel({
    required this.id,
    required this.name,
  });

  factory JuzModel.fromJson(Map<String, dynamic> json) {
    return JuzModel(
      id: json["id"],
      name: json["name"],
    );
  }
}