class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profileImage;
  final int streak;
  final int dhikrCount;
  final int lessonsCompleted;

  final int quranProgress;
  final int booksProgress;
  final int classesProgress;

  final List<dynamic> favoriteBooks;
  final List<dynamic> favoriteAudio;
  final List<dynamic> favoriteDuas;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.streak,
    required this.dhikrCount,
    required this.lessonsCompleted,
    required this.quranProgress,
    required this.booksProgress,
    required this.classesProgress,
    required this.favoriteBooks,
    required this.favoriteAudio,
    required this.favoriteDuas,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      profileImage: map["profileImage"] ?? "",
      streak: map["streak"] ?? 0,
      dhikrCount: map["dhikrCount"] ?? 0,
      lessonsCompleted: map["lessonsCompleted"] ?? 0,

      quranProgress: map["progress"]?["quran"] ?? 0,
      booksProgress: map["progress"]?["books"] ?? 0,
      classesProgress: map["progress"]?["classes"] ?? 0,

      favoriteBooks: List<dynamic>.from(map["favorites"]?["books"] ?? []),

      favoriteAudio: List<dynamic>.from(map["favorites"]?["audio"] ?? []),

      favoriteDuas: List<dynamic>.from(map["favorites"]?["duas"] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "profileImage": profileImage,
      "streak": streak,
      "dhikrCount": dhikrCount,
      "lessonsCompleted": lessonsCompleted,

      "progress": {
        "quran": quranProgress,
        "books": booksProgress,
        "classes": classesProgress,
      },

      "favorites": {
        "books": favoriteBooks,
        "audio": favoriteAudio,
        "duas": favoriteDuas,
      },
    };
  }
}
