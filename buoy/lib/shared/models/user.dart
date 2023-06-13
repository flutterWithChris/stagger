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

  // Create empty user
  factory User.empty() {
    return User(
      id: '',
      email: '',
      name: '',
      photoUrl: '',
      friendIds: [],
    );
  }

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
      'photo_url': photoUrl,
      'friend_ids': friendIds,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photo_url'] ?? '',
      friendIds: List<String>.from(map['friend_ids'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
