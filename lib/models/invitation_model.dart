class InvitationModel {
  final String id;
  final String eventId;
  final String guestId;
  final String qrToken;
  final DateTime? createdAt;

  const InvitationModel({
    required this.id,
    required this.eventId,
    required this.guestId,
    required this.qrToken,
    this.createdAt,
  });

  factory InvitationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return InvitationModel(
      id: documentId,
      eventId: map['eventId'] as String,
      guestId: map['guestId'] as String,
      qrToken: map['qrToken'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'guestId': guestId,
      'qrToken': qrToken,
      'createdAt': createdAt,
    };
  }
}
