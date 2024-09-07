class PublicKeyEntry {
  String? id;
  String userId;
  String publicKey;
  DateTime createdAt;

  PublicKeyEntry({
    this.id,
    required this.userId,
    required this.publicKey,
    required this.createdAt,
  });

  PublicKeyEntry copyWith({
    String? id,
    String? userId,
    String? publicKey,
    DateTime? createdAt,
  }) {
    return PublicKeyEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'publicKey': publicKey,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PublicKeyEntry.fromMap(Map<String, dynamic> map) {
    return PublicKeyEntry(
      id: map['id'],
      userId: map['userId'],
      publicKey: map['publicKey'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}
