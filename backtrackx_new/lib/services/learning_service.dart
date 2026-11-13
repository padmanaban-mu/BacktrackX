import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
// No API imports needed for offline mode

/// Fetches lessons and quizzes from local data.
/// Works completely offline.
class LearningService {

  // ---- Lessons -------------------------------------------------------

  Future<List<LessonModel>> getLessons({String? token}) async {
    // Return mock data directly for offline mode
    return _mockLessons();
  }

  Future<LessonModel> getLessonById(String id, {String? token}) async {
    final lessons = _mockLessons();
    return lessons.firstWhere(
      (l) => l.id == id,
      orElse: () => lessons.first,
    );
  }

  // ---- Quizzes -------------------------------------------------------

  Future<List<QuizModel>> getQuizForLesson(String lessonId, {String? token}) async {
    // Return mock data directly for offline mode
    return _mockQuizzes(lessonId);
  }

  // ---- Mock fallback data --------------------------------------------

  List<LessonModel> _mockLessons() {
    return const [
      LessonModel(
        id: '1',
        title: 'Introduction to Recursion',
        description: 'Basics of recursive thinking.',
        content:
            '{"type":"text","body":"Learn how recursive functions call themselves with smaller inputs."}\n{"type":"diagram","diagramType":"tree","caption":"Recursive Call Tree"}',
        order: 1,
        isCompleted: false,
      ),
      LessonModel(
        id: '2',
        title: 'Understanding Backtracking',
        description: 'What backtracking is and when to use it.',
        content:
            '{"type":"text","body":"Backtracking explores all possibilities and abandons a path if it is invalid."}\n{"type":"diagram","diagramType":"maze","caption":"Backtracking through a maze"}',
        order: 2,
        isCompleted: false,
      ),
      LessonModel(
        id: '3',
        title: 'N-Queens Problem',
        description: 'Classic backtracking example.',
        content:
            '{"type":"text","body":"Place N queens on an NxN chessboard so that no two queens threaten each other."}\n{"type":"diagram","diagramType":"nqueens","caption":"4-Queens Configuration"}',
        order: 3,
        isCompleted: false,
      ),
      LessonModel(
        id: '4',
        title: 'Sudoku Solving',
        description: 'How backtracking solves Sudoku.',
        content:
            '{"type":"text","body":"Sudoku is essentially a constraint satisfaction problem solved by backtracking."}\n{"type":"diagram","diagramType":"tree","caption":"Decision tree for Sudoku cells"}',
        order: 4,
        isCompleted: false,
      ),
      LessonModel(
        id: '5',
        title: 'Practice Hub – Placement Problems',
        description: 'Curated LeetCode & Codeforces backtracking problems.',
        content:
            '{"type":"text","body":"Practice backtracking on real interview problems."}\n{"type":"practice","problems":[{"name":"LeetCode 46 – Permutations","url":"https://leetcode.com/problems/permutations/"},{"name":"LeetCode 39 – Combination Sum","url":"https://leetcode.com/problems/combination-sum/"},{"name":"LeetCode 79 – Word Search","url":"https://leetcode.com/problems/word-search/"},{"name":"LeetCode 51 – N-Queens","url":"https://leetcode.com/problems/n-queens/"}]}',
        order: 5,
        isCompleted: false,
      ),
    ];
  }

  List<QuizModel> _mockQuizzes(String lessonId) {
    switch (lessonId) {
      case '1':
        return [
          QuizModel(
            id: '${lessonId}_q1',
            lessonId: lessonId,
            question: 'What is the base case in recursion?',
            options: const [
              'The condition where the function stops calling itself',
              'The first line of the function',
              'The variable initialized at the start',
              'An infinite loop'
            ],
            correctIndex: 0,
            explanation: 'The base case is crucial to stop the recursion and prevent stack overflow errors.',
          ),
          QuizModel(
            id: '${lessonId}_q2',
            lessonId: lessonId,
            question: 'What data structure is used behind the scenes to manage recursive calls?',
            options: const ['Queue', 'Linked List', 'Stack', 'Tree'],
            correctIndex: 2,
            explanation: 'The call stack keeps track of the active subroutines in a computer program.',
          ),
          QuizModel(
            id: '${lessonId}_q3',
            lessonId: lessonId,
            question: 'Which of the following problems is best solved using simple recursion?',
            options: const ['Sorting an array of 2 elements', 'Calculating Factorial', 'Finding a user in a database', 'Rendering a UI'],
            correctIndex: 1,
            explanation: 'Factorial is a classic example of a problem naturally defined recursively (n! = n * (n-1)!).',
          ),
        ];
      case '2':
        return [
          QuizModel(
            id: '${lessonId}_q1',
            lessonId: lessonId,
            question: 'How does backtracking differ from a brute-force approach?',
            options: const [
              'It is slower',
              'It does not guarantee a solution',
              'It prunes invalid paths early',
              'It requires more memory'
            ],
            correctIndex: 2,
            explanation: 'Backtracking stops exploring a path as soon as it determines it cannot lead to a valid solution.',
          ),
          QuizModel(
            id: '${lessonId}_q2',
            lessonId: lessonId,
            question: 'What is a bounding function in backtracking?',
            options: const [
              'A function that limits recursion depth',
              'A condition that prunes invalid branches early',
              'A hash function for memoization',
              'A loop boundary condition'
            ],
            correctIndex: 1,
            explanation: 'A bounding function checks constraints early to prune dead-end branches before exploring them fully.',
          ),
          QuizModel(
            id: '${lessonId}_q3',
            lessonId: lessonId,
            question: 'What happens when a constraint is violated in backtracking?',
            options: const [
              'Program crashes',
              'It skips the step',
              'It undoes the choice and tries another path',
              'It throws an error'
            ],
            correctIndex: 2,
            explanation: 'The algorithm undoes (backtracks) the last choice and explores the next alternative.',
          ),
        ];
      case '3':
        return [
          QuizModel(
            id: '${lessonId}_q1',
            lessonId: lessonId,
            question: 'In the N-Queens problem, which of these is NOT a constraint?',
            options: const [
              'No two queens in the same row',
              'No two queens in the same column',
              'No two queens in the same diagonal',
              'No two queens of the same color'
            ],
            correctIndex: 3,
            explanation: 'All queens are considered identical. The constraints apply to rows, columns, and diagonals.',
          ),
          QuizModel(
            id: '${lessonId}_q2',
            lessonId: lessonId,
            question: 'What is the time complexity of the N-Queens backtracking algorithm?',
            options: const ['O(n!)', 'O(n²)', 'O(2^n)', 'O(n log n)'],
            correctIndex: 0,
            explanation: 'In the worst case, there are approximately n! permutations to explore before finding a solution.',
          ),
          QuizModel(
            id: '${lessonId}_q3',
            lessonId: lessonId,
            question: 'If you place a queen at (row 1, col 1), which cell is safe from it?',
            options: const ['(row 2, col 2)', '(row 1, col 4)', '(row 3, col 1)', '(row 2, col 3)'],
            correctIndex: 3,
            explanation: '(2,3) is safe. (2,2) is on the diagonal, (1,4) is on the row, and (3,1) is on the column.',
          ),
        ];
      case '4':
        return [
          QuizModel(
            id: '${lessonId}_q1',
            lessonId: lessonId,
            question: 'Which is a constraint when solving a standard 9x9 Sudoku?',
            options: const [
              'Each 3x3 subgrid must sum to 45',
              'Each row must contain digits 1-9 without repetition',
              'Diagonals must contain unique digits',
              'Even numbers cannot touch each other'
            ],
            correctIndex: 1,
            explanation: 'A fundamental Sudoku rule is that each row, column, and 3x3 box must contain digits 1-9 exactly once.',
          ),
          QuizModel(
            id: '${lessonId}_q2',
            lessonId: lessonId,
            question: 'When backtracking in Sudoku, what do you do after a cell leads to a dead end?',
            options: const [
              'Reset the entire board',
              'Skip the cell and leave it empty',
              'Erase the cell (set to 0) and go back to the previous cell',
              'Try the next available cell'
            ],
            correctIndex: 2,
            explanation: 'Backtracking requires undoing the state (erasing the cell) so the previous cell can try a new candidate digit.',
          ),
          QuizModel(
            id: '${lessonId}_q3',
            lessonId: lessonId,
            question: 'Is Backtracking the most efficient way to solve Sudoku?',
            options: const [
              'Yes, it is the fastest theoretical approach',
              'No, combined with constraint propagation (like human strategies) it is much faster',
              'Yes, it solves any puzzle instantly',
              'No, random guessing is faster'
            ],
            correctIndex: 1,
            explanation: 'While backtracking guarantees a solution, combining it with logical deduction (constraint propagation) vastly reduces the search space.',
          ),
        ];
      default:
        // Default questions for Practice Hub or unknown lessons
        return [
          QuizModel(
            id: '${lessonId}_q1',
            lessonId: lessonId,
            question: 'Which data structure is typically used to represent the "current path" when finding all subsets?',
            options: const ['Array/List', 'HashMap', 'Binary Tree', 'Graph'],
            correctIndex: 0,
            explanation: 'A dynamic array or list is usually used to build the current subset, adding and removing elements as you backtrack.',
          ),
          QuizModel(
            id: '${lessonId}_q2',
            lessonId: lessonId,
            question: 'Why do we often pass the "current index" to a backtracking function?',
            options: const [
              'To keep track of memory usage',
              'To avoid processing the same elements or generating permutations instead of combinations',
              'To speed up math operations',
              'To debug the call stack'
            ],
            correctIndex: 1,
            explanation: 'Passing the current index ensures the recursion only looks forward, preventing duplicate combinations like [1,2] and [2,1].',
          ),
          QuizModel(
            id: '${lessonId}_q3',
            lessonId: lessonId,
            question: 'In "Word Search", why do we temporarily modify the board cell to a special character (e.g., "#")?',
            options: const [
              'To optimize string comparisons',
              'To prevent the algorithm from revisiting the same cell in the current path',
              'To mark the end of the word',
              'To delete characters we do not need'
            ],
            correctIndex: 1,
            explanation: 'Modifying the cell acts as a "visited" flag for the current DFS path, which is reverted during the backtracking step.',
          ),
        ];
    }
  }
}
