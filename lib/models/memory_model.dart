class MemoryModel {
  final String id;
  final String eventId;
  final String uploaderId;
  final String uploaderName;
  final String base64Data;
  final DateTime timestamp;

  MemoryModel({
    required this.id,
    required this.eventId,
    required this.uploaderId,
    required this.uploaderName,
    required this.base64Data,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'base64Data': base64Data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MemoryModel.fromMap(Map<String, dynamic> map, String id) {
    return MemoryModel(
      id: id,
      eventId: map['eventId'] ?? '',
      uploaderId: map['uploaderId'] ?? '',
      uploaderName: map['uploaderName'] ?? 'Guest',
      base64Data: map['base64Data'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    );
  }
}
