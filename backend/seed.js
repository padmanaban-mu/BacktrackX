const mongoose = require('mongoose');
const Lesson = require('./models/Lesson');
const Quiz = require('./models/Quiz');

mongoose.connect('mongodb://127.0.0.1:27017/backtrackx')
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

const seedDatabase = async () => {
  try {
    await Lesson.deleteMany({});
    await Quiz.deleteMany({});

    console.log('Cleared existing lessons and quizzes');

    const lessonsData = [
      {
        title: 'Introduction to Recursion & State Space Trees',
        description: 'Learn the fundamentals of recursion and how state space trees represent the execution flow.',
        content: `{"type":"text","body":"Recursion is a method where the solution to a problem depends on solutions to smaller instances of the same problem."}\n{"type":"diagram","diagramType":"tree","caption":"A simple state space tree for a recursive function."}\n{"type":"text","body":"State space trees help visualize the sequence of recursive calls."}`,
        order: 1,
        category: 'backtracking',
        tags: ['recursion', 'trees']
      },
      {
        title: 'Understanding Backtracking - Bounding Functions',
        description: 'Dive into backtracking and learn how bounding functions prune the search space.',
        content: `{"type":"text","body":"Backtracking builds candidates to the solutions, and abandons a candidate ('backtracks') as soon as it determines that the candidate cannot possibly be completed to a valid solution."}\n{"type":"text","body":"Bounding functions check constraints to early-exit invalid paths."}`,
        order: 2,
        category: 'backtracking',
        tags: ['bounding', 'pruning']
      },
      {
        title: 'N-Queens Problem - Constraint Satisfaction',
        description: 'Solve the classic N-Queens problem using backtracking constraints.',
        content: `{"type":"text","body":"The N-Queens problem asks to place N chess queens on an N×N chessboard so that no two queens threaten each other."}\n{"type":"diagram","diagramType":"board","caption":"N-Queens board representation."}\n{"type":"text","body":"Constraints: no two queens share the same row, column, or diagonal."}`,
        order: 3,
        category: 'backtracking',
        tags: ['n-queens', 'constraints']
      },
      {
        title: 'Sudoku Solving - Backtracking on Grids',
        description: 'Apply backtracking to solve 9x9 Sudoku puzzles.',
        content: `{"type":"text","body":"Sudoku is solved by assigning numbers from 1 to 9 to empty cells."}\n{"type":"text","body":"Before assigning, we check if the number is already present in the current row, column, or 3x3 subgrid."}\n{"type":"diagram","diagramType":"grid","caption":"Sudoku solving process."}`,
        order: 4,
        category: 'backtracking',
        tags: ['sudoku', 'grid']
      },
      {
        title: 'Practice Hub - LeetCode & Codeforces Problems',
        description: 'Practice real-world backtracking problems from competitive programming.',
        content: `{"type":"text","body":"Problems to practice:\\n- LeetCode 46: Permutations\\n- LeetCode 39: Combination Sum\\n- LeetCode 79: Word Search\\n- LeetCode 51: N-Queens\\n- Codeforces: Rat in a Maze style problems"}`,
        order: 5,
        category: 'backtracking',
        tags: ['practice', 'leetcode', 'codeforces']
      }
    ];

    const lessons = await Lesson.insertMany(lessonsData);
    console.log('Inserted 5 lessons');

    const quizzesData = [
      // Lesson 1 Quizzes
      {
        lessonId: lessons[0]._id,
        question: 'What is a state space tree?',
        options: ['A tree data structure for storing states', 'A visualization of the sequence of recursive calls', 'A binary search tree', 'A DOM tree'],
        correctIndex: 1,
        explanation: 'State space trees map out all possible states (recursive calls) a program can reach.'
      },
      {
        lessonId: lessons[0]._id,
        question: 'What is the base case in recursion?',
        options: ['The first function call', 'The condition that terminates the recursive calls', 'The worst-case time complexity', 'The return type'],
        correctIndex: 1,
        explanation: 'A base case stops the recursion from continuing infinitely.'
      },
      {
        lessonId: lessons[0]._id,
        question: 'Which of the following problems is best solved using recursion?',
        options: ['Finding the maximum element in a sorted array', 'Tower of Hanoi', 'Linear search', 'Calculating the sum of two integers'],
        correctIndex: 1,
        explanation: 'Tower of Hanoi is a classic problem naturally suited for recursion.'
      },
      // Lesson 2 Quizzes
      {
        lessonId: lessons[1]._id,
        question: 'What is the primary purpose of a bounding function in backtracking?',
        options: ['To increase the search space', 'To prune the search space by eliminating invalid paths early', 'To sort the data', 'To calculate the time complexity'],
        correctIndex: 1,
        explanation: 'Bounding functions prevent the algorithm from exploring paths that will definitely not lead to a valid solution.'
      },
      {
        lessonId: lessons[1]._id,
        question: 'How does backtracking differ from naive depth-first search (DFS)?',
        options: ['Backtracking does not use a stack', 'Backtracking stops exploring paths early using constraints', 'DFS is faster', 'Backtracking only works on graphs'],
        correctIndex: 1,
        explanation: 'Backtracking is essentially DFS with pruning (bounding).'
      },
      {
        lessonId: lessons[1]._id,
        question: 'In backtracking, what happens when a dead end is reached?',
        options: ['The algorithm crashes', 'The algorithm restarts from the beginning', 'The algorithm abandons the current candidate and goes back to the previous step', 'The algorithm skips to the next level'],
        correctIndex: 2,
        explanation: 'This is the "backtrack" step: undoing the last choice and trying another option.'
      },
      // Lesson 3 Quizzes
      {
        lessonId: lessons[2]._id,
        question: 'In the N-Queens problem, how many queens are placed on an N x N board?',
        options: ['1', 'N', 'N^2', '2N'],
        correctIndex: 1,
        explanation: 'The problem requires placing exactly N queens.'
      },
      {
        lessonId: lessons[2]._id,
        question: 'Which of the following is NOT a constraint in the standard N-Queens problem?',
        options: ['No two queens share the same row', 'No two queens share the same column', 'No two queens share the same color square', 'No two queens share the same diagonal'],
        correctIndex: 2,
        explanation: 'The color of the squares does not affect the constraints in N-Queens.'
      },
      {
        lessonId: lessons[2]._id,
        question: 'What is the maximum number of solutions for 4-Queens?',
        options: ['0', '1', '2', '4'],
        correctIndex: 2,
        explanation: 'There are 2 distinct valid configurations for a 4x4 board.'
      },
      // Lesson 4 Quizzes
      {
        lessonId: lessons[3]._id,
        question: 'When solving Sudoku with backtracking, when do we place a number in a cell?',
        options: ['Randomly', 'Only if it is not present in the current row, column, and 3x3 subgrid', 'Only if the cell is in the first row', 'When the number is prime'],
        correctIndex: 1,
        explanation: 'Sudoku rules require uniqueness in the row, column, and subgrid.'
      },
      {
        lessonId: lessons[3]._id,
        question: 'What is the time complexity of a naive backtracking Sudoku solver?',
        options: ['O(1)', 'O(N^2)', 'O(9^(N*N))', 'O(log N)'],
        correctIndex: 2,
        explanation: 'In the worst case, we try 9 possibilities for each empty cell.'
      },
      {
        lessonId: lessons[3]._id,
        question: 'Which empty cell is usually best to fill first to optimize a Sudoku solver?',
        options: ['The top-left cell', 'The cell with the fewest valid possibilities (MRV heuristic)', 'The cell in the middle', 'The cell with the most possibilities'],
        correctIndex: 1,
        explanation: 'Minimum Remaining Values (MRV) heuristic minimizes branching factor.'
      },
      // Lesson 5 Quizzes
      {
        lessonId: lessons[4]._id,
        question: 'LeetCode 46: Permutations can be solved by:',
        options: ['Sorting the array', 'Swapping elements recursively and backtracking', 'Binary search', 'Dynamic programming'],
        correctIndex: 1,
        explanation: 'Generating all permutations is a classic backtracking problem using swaps or a visited array.'
      },
      {
        lessonId: lessons[4]._id,
        question: 'In LeetCode 39: Combination Sum, can you use the same number multiple times?',
        options: ['Yes', 'No', 'Only twice', 'Depends on the number'],
        correctIndex: 0,
        explanation: 'The problem statement allows unlimited use of the same candidate number.'
      },
      {
        lessonId: lessons[4]._id,
        question: 'For grid-based problems like Word Search (LeetCode 79) or Rat in a Maze, what is crucial to prevent infinite loops?',
        options: ['Using a queue', 'Sorting the grid', 'Marking visited cells', 'Increasing the grid size'],
        correctIndex: 2,
        explanation: 'Marking cells as visited ensures we don\'t traverse back and forth between adjacent cells endlessly.'
      }
    ];

    await Quiz.insertMany(quizzesData);
    console.log('Inserted 15 quizzes (3 per lesson)');

    process.exit(0);
  } catch (err) {
    console.error('Seeding failed:', err);
    process.exit(1);
  }
};

seedDatabase();
