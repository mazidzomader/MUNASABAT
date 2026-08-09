class MemoryModel {
  final String id;
  final String type; // "photo" | "video"
  final String url;
  final String uploadedBy;
  final DateTime? createdAt;
  final List<String> likes; // userIds

  const MemoryModel({
    required this.id,
    required this.type,
    required this.url,
    required this.uploadedBy,
    this.createdAt,
    this.likes = const [],
  });

  factory MemoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MemoryModel(
      id: documentId,
      type: map['type'] as String,
      url: map['url'] as String,
      uploadedBy: map['uploadedBy'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
      likes: List<String>.from(map['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
      'uploadedBy': uploadedBy,
      'createdAt': createdAt,
      'likes': likes,
    };
  }
}
