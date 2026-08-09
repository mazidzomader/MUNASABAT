class ChecklistItemModel {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;

  const ChecklistItemModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.createdAt,
  });

  factory ChecklistItemModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChecklistItemModel(
      id: documentId,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
    };
  }
}
