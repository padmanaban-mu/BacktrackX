/// A single step in the backtracking visualization.
/// action can be: 'place' (try a number), 'valid' (number works),
/// 'invalid' (number doesn't work), 'backtrack' (undo and go back)
class BacktrackStepModel {
  final int stepIndex;
  final int row;
  final int col;
  final int value; // the number being placed (1-9) or 0 for removal
  final bool isValid; // did this placement pass the constraint check?
  final String action; // 'place', 'valid', 'invalid', 'backtrack'
  final String explanation; // human-readable explanation of what's happening

  const BacktrackStepModel({
    required this.stepIndex,
    required this.row,
    required this.col,
    required this.value,
    required this.isValid,
    required this.action,
    required this.explanation,
  });

  factory BacktrackStepModel.fromJson(Map<String, dynamic> json) {
    return BacktrackStepModel(
      stepIndex: json['stepIndex'] as int,
      row: json['row'] as int,
      col: json['col'] as int,
      value: json['value'] as int,
      isValid: json['isValid'] as bool,
      action: json['action'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepIndex': stepIndex,
      'row': row,
      'col': col,
      'value': value,
      'isValid': isValid,
      'action': action,
      'explanation': explanation,
    };
  }
}
