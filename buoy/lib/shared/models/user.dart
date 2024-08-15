import 'dart:convert';

class User {
  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? photoUrl;

  User({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.photoUrl,
  });

  // Create empty user
  factory User.empty() {
    return User(
      id: '',
      email: '',
      firstName: '',
      photoUrl: '',
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      photoUrl: map['photo_url'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
