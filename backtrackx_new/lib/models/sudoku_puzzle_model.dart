/// Represents a Sudoku puzzle with its initial grid and solution.
class SudokuPuzzleModel {
  final String id;
  final String name;
  final String difficulty; // 'easy', 'medium', 'hard'
  final List<List<int>> initialGrid; // 9x9, 0 = empty
  final List<List<int>>? solution; // solved grid (nullable until solved)

  const SudokuPuzzleModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.initialGrid,
    this.solution,
  });

  factory SudokuPuzzleModel.fromJson(Map<String, dynamic> json) {
    return SudokuPuzzleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      initialGrid: (json['initialGrid'] as List<dynamic>)
          .map((row) => List<int>.from(row as List<dynamic>))
          .toList(),
      solution: json['solution'] != null
          ? (json['solution'] as List<dynamic>)
              .map((row) => List<int>.from(row as List<dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'initialGrid': initialGrid,
      'solution': solution,
    };
  }
}
