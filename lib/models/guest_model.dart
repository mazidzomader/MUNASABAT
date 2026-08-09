class GuestModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String status; // "pending" | "accepted" | "declined" | "checked_in"
  final String? invitationId;
  final DateTime? checkedInAt;

  const GuestModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.status = 'pending',
    this.invitationId,
    this.checkedInAt,
  });

  factory GuestModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GuestModel(
      id: documentId,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      status: map['status'] as String? ?? 'pending',
      invitationId: map['invitationId'] as String?,
      checkedInAt: map['checkedInAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['checkedInAt'].millisecondsSinceEpoch)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'status': status,
      'invitationId': invitationId,
      'checkedInAt': checkedInAt,
    };
  }
}
