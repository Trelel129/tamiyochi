import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final bool isImportant;
  final String title;
  final String description;
  final String image;
  final DateTime createdTime;

  Movie({
    required this.id,
    required this.isImportant,
    required this.title,
    required this.description,
    required this.image,
    required this.createdTime,
  });

  Movie copy({
    String? id,
    bool? isImportant,
    String? title,
    String? description,
    String? image,
    DateTime? createdTime,
  }) =>
      Movie(
        id: id ?? this.id,
        isImportant: isImportant ?? this.isImportant,
        title: title ?? this.title,
        description: description ?? this.description,
        image: image ?? this.image,
        createdTime: createdTime ?? this.createdTime,
      );

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      isImportant: json['isImportant'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      createdTime: (json['createdTime'] as Timestamp).toDate(),
    );
  }

  factory Movie.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      isImportant: data['isImportant'],
      title: data['title'],
      description: data['description'],
      image: data['image'],
      createdTime: (data['createdTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isImportant': isImportant,
      'title': title,
      'description': description,
      'image': image,
      'createdTime': Timestamp.fromDate(createdTime),
    };
  }
}
