import 'dart:convert';

class User {
  final String? id;
  final String? email;
  final String? name;
  final String? photoUrl;
  final List<String>? friendIds;
  User({
    this.id,
    this.email,
    this.name,
    this.photoUrl,
    this.friendIds,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    List<String>? friendIds,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      friendIds: friendIds ?? this.friendIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'friendIds': friendIds,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      friendIds: List<String>.from(map['friendIds'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
