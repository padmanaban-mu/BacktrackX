/// Represents a single lesson in the learning module.
class LessonModel {
  final String id;
  final String title;
  final String description;
  final String content; // markdown or plain text content
  final int order; // display order
  final bool isCompleted;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.order,
    this.isCompleted = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      order: json['order'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'order': order,
      'isCompleted': isCompleted,
    };
  }
}
