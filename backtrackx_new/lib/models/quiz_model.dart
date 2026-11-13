/// A single quiz question tied to a lesson.
class QuizModel {
  final String id;
  final String lessonId;
  final String question;
  final List<String> options; // 4 multiple-choice options
  final int correctIndex; // index of correct answer (0-3)
  final String explanation; // why this answer is correct

  const QuizModel({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }
}
