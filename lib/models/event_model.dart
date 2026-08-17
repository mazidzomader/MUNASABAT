class EventModel {
  final String id;
  final String hostId;
  final String title;
  final DateTime date;
  final String venueName;
  final Map<String, double>? venueLatLng;
  final String? description;
  final String? coverImageUrl;
  final int? totalBudget;
  final DateTime? createdAt;
  final String privacy; // "public" or "private"
  final String? eventCode;
  final String? qrToken;

  const EventModel({
    required this.id,
    required this.hostId,
    required this.title,
    required this.date,
    required this.venueName,
    this.venueLatLng,
    this.description,
    this.coverImageUrl,
    this.totalBudget,
    this.createdAt,
    this.privacy = 'private',
    this.eventCode,
    this.qrToken,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EventModel(
      id: documentId,
      hostId: map['hostId'] as String,
      title: map['title'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(
          map['date'].millisecondsSinceEpoch),
      venueName: map['venueName'] as String,
      venueLatLng: map['venueLatLng'] != null
          ? {
              'lat': map['venueLatLng']['lat'] as double,
              'lng': map['venueLatLng']['lng'] as double,
            }
          : null,
      description: map['description'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      totalBudget: map['totalBudget'] as int?,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
      privacy: map['privacy'] as String? ?? 'private',
      eventCode: map['eventCode'] as String?,
      qrToken: map['qrToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hostId': hostId,
      'title': title,
      'date': date,
      'venueName': venueName,
      'venueLatLng': venueLatLng,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'totalBudget': totalBudget,
      'createdAt': createdAt,
      'privacy': privacy,
      'eventCode': eventCode,
      'qrToken': qrToken,
    };
  }

  EventModel copyWith({
    String? id,
    String? hostId,
    String? title,
    DateTime? date,
    String? venueName,
    Map<String, double>? venueLatLng,
    String? description,
    String? coverImageUrl,
    int? totalBudget,
    DateTime? createdAt,
    String? privacy,
    String? eventCode,
    String? qrToken,
  }) {
    return EventModel(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      title: title ?? this.title,
      date: date ?? this.date,
      venueName: venueName ?? this.venueName,
      venueLatLng: venueLatLng ?? this.venueLatLng,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      totalBudget: totalBudget ?? this.totalBudget,
      createdAt: createdAt ?? this.createdAt,
      privacy: privacy ?? this.privacy,
      eventCode: eventCode ?? this.eventCode,
      qrToken: qrToken ?? this.qrToken,
    );
  }
}
