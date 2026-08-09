class EventModel {
  final String id;
  final String hostId;
  final String title;
  final DateTime date;
  final String venueName;
  final Map<String, double>? venueLatLng;
  final String? description;
  final String? coverImageUrl;
  final DateTime? createdAt;
  final String privacy; // "public" or "private"

  const EventModel({
    required this.id,
    required this.hostId,
    required this.title,
    required this.date,
    required this.venueName,
    this.venueLatLng,
    this.description,
    this.coverImageUrl,
    this.createdAt,
    this.privacy = 'private',
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
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
      privacy: map['privacy'] as String? ?? 'private',
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
      'createdAt': createdAt,
      'privacy': privacy,
    };
  }
}
