const String tableMovie = 'movie';

class MovieFields {
  static final List<String> values = [
    id,
    name,
    description,
    image,
    time
  ];

  static const String id = '_id';
  static const String name = 'name';
  static const String image = 'image';
  static const String description = 'description';
  static const String time = 'time';
}

class Movie {
  final int? id;
  final String name;
  final String description;
  final String image;
  final DateTime createdTime;

  const Movie({
    this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.createdTime,
  });

  Movie copy({
    int? id,
    bool? isImportant,
    int? number,
    String? name,
    String? description,
    String? image,
    DateTime? createdTime,
  }) =>
      Movie(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        image: image ?? this.image,
        createdTime: createdTime ?? this.createdTime,
      );

  static Movie fromJson(Map<String, Object?> json) => Movie(
    id: json[MovieFields.id] as int?,
    name: json[MovieFields.name] as String,
    description: json[MovieFields.description] as String,
    image: json[MovieFields.image] as String,
    createdTime: DateTime.parse(json[MovieFields.time] as String),
  );

  Map<String, Object?> toJson() => {
    MovieFields.id: id,
    MovieFields.name: name,
    MovieFields.description: description,
    MovieFields.image: image,
    MovieFields.time: createdTime.toIso8601String(),
  };
}