class UserModel {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final List<String> hostedEventIds;
  final List<String> attendedEventIds;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.hostedEventIds = const [],
    this.attendedEventIds = const [],
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      photoUrl: map['photoUrl'] as String?,
      hostedEventIds: List<String>.from(map['hostedEventIds'] ?? []),
      attendedEventIds: List<String>.from(map['attendedEventIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'hostedEventIds': hostedEventIds,
      'attendedEventIds': attendedEventIds,
      'createdAt': createdAt,
    };
  }
}
