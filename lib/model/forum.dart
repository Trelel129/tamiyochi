const String tableForum = 'forum';

class ForumFields {
  static final List<String> values = [id, title, text, image, time];

  static const String id = '_id';
  static const String title = 'title';
  static const String image = 'image';
  static const String text = 'text';
  static const String email = 'email';
  static const String time = 'time';
}

class Forum {
  final int? id;
  final String title;
  final String text;
  final String image;
  final String email;
  final DateTime createdTime;

  const Forum({
    this.id,
    required this.title,
    required this.text,
    required this.image,
    required this.email,
    required this.createdTime,
  });

  Forum copy({
    int? id,
    String? title,
    String? text,
    String? image,
    String? email,
    DateTime? createdTime,
  }) =>
      Forum(
        id: id ?? this.id,
        title: title ?? this.title,
        text: text ?? this.text,
        image: image ?? this.image,
        email: email ?? this.email,
        createdTime: createdTime ?? this.createdTime,
      );

  static Forum fromJson(Map<String, Object?> json) => Forum(
        id: json[ForumFields.id] as int?,
        title: json[ForumFields.title] as String,
        text: json[ForumFields.text] as String,
        image: json[ForumFields.image] as String,
        email: json[ForumFields.email] as String,
        createdTime: DateTime.parse(json[ForumFields.time] as String),
      );

  Map<String, Object?> toJson() => {
        ForumFields.id: id,
        ForumFields.title: title,
        ForumFields.text: text,
        ForumFields.image: image,
        ForumFields.email: email,
        ForumFields.time: createdTime.toIso8601String(),
      };
}
