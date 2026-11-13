import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../routes/app_routes.dart';

class PracticeProblem {
  final String id;
  final String name;
  final String number;
  final String platform;
  final String difficulty;
  final String pattern;
  final String description;
  final String url;
  final IconData icon;

  const PracticeProblem({
    required this.id,
    required this.name,
    required this.number,
    required this.platform,
    required this.difficulty,
    required this.pattern,
    required this.description,
    required this.url,
    required this.icon,
  });
}

class PracticeHubScreen extends StatefulWidget {
  const PracticeHubScreen({super.key});

  @override
  State<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends State<PracticeHubScreen> {
  String _selectedFilter = 'All';

  final List<PracticeProblem> _problems = [
    const PracticeProblem(
      id: '1',
      name: 'Permutations',
      number: '46',
      platform: 'LeetCode',
      difficulty: 'Medium',
      pattern: 'Backtracking',
      description: 'Given an array nums of distinct integers, return all the possible permutations.',
      url: 'https://leetcode.com/problems/permutations/',
      icon: Icons.shuffle,
    ),
    const PracticeProblem(
      id: '2',
      name: 'Combination Sum',
      number: '39',
      platform: 'LeetCode',
      difficulty: 'Medium',
      pattern: 'Backtracking',
      description: 'Find all unique combinations in candidates where the candidate numbers sum to target.',
      url: 'https://leetcode.com/problems/combination-sum/',
      icon: Icons.add_circle_outline,
    ),
    const PracticeProblem(
      id: '3',
      name: 'Word Search',
      number: '79',
      platform: 'LeetCode',
      difficulty: 'Medium',
      pattern: 'Backtracking / DFS',
      description: 'Given an m x n grid of characters board and a string word, return true if word exists in the grid.',
      url: 'https://leetcode.com/problems/word-search/',
      icon: Icons.text_format,
    ),
    const PracticeProblem(
      id: '4',
      name: 'N-Queens',
      number: '51',
      platform: 'LeetCode',
      difficulty: 'Hard',
      pattern: 'Backtracking',
      description: 'The n-queens puzzle is the problem of placing n queens on an n x n chessboard such that no two queens attack each other.',
      url: 'https://leetcode.com/problems/n-queens/',
      icon: Icons.grid_on,
    ),
    const PracticeProblem(
      id: '5',
      name: 'Sudoku Solver',
      number: '37',
      platform: 'LeetCode',
      difficulty: 'Hard',
      pattern: 'Backtracking',
      description: 'Write a program to solve a Sudoku puzzle by filling the empty cells.',
      url: 'https://leetcode.com/problems/sudoku-solver/',
      icon: Icons.grid_3x3,
    ),
    const PracticeProblem(
      id: '6',
      name: 'Subsets II',
      number: '90',
      platform: 'LeetCode',
      difficulty: 'Medium',
      pattern: 'Backtracking',
      description: 'Given an integer array nums that may contain duplicates, return all possible subsets.',
      url: 'https://leetcode.com/problems/subsets-ii/',
      icon: Icons.copy_all,
    ),
    const PracticeProblem(
      id: '7',
      name: 'Palindrome Partitioning',
      number: '131',
      platform: 'LeetCode',
      difficulty: 'Medium',
      pattern: 'Backtracking',
      description: 'Partition s such that every substring of the partition is a palindrome.',
      url: 'https://leetcode.com/problems/palindrome-partitioning/',
      icon: Icons.flip,
    ),
    const PracticeProblem(
      id: '8',
      name: 'Letter Combinations',
      number: '17',
      platform: 'LeetCode',
      difficulty: 'Medium',
      pattern: 'Backtracking',
      description: 'Return all possible letter combinations that the number could represent on a phone keypad.',
      url: 'https://leetcode.com/problems/letter-combinations-of-a-phone-number/',
      icon: Icons.phone_android,
    ),
    const PracticeProblem(
      id: '9',
      name: 'Rat in a Maze',
      number: 'GFG-1',
      platform: 'GeeksForGeeks',
      difficulty: 'Medium',
      pattern: 'Backtracking',
      description: 'Find all possible paths that the rat can take to reach from source to destination in the maze.',
      url: 'https://practice.geeksforgeeks.org/problems/rat-in-a-maze-problem/1',
      icon: Icons.route,
    ),
    const PracticeProblem(
      id: '10',
      name: 'M-Coloring Problem',
      number: 'GFG-2',
      platform: 'GeeksForGeeks',
      difficulty: 'Medium',
      pattern: 'Backtracking',
      description: 'Determine if the graph can be colored with at most m colors such that no two adjacent vertices of the graph are colored with the same color.',
      url: 'https://practice.geeksforgeeks.org/problems/m-coloring-problem-1587115620/1',
      icon: Icons.color_lens,
    ),
  ];

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPlatformColor(String platform) {
    if (platform == 'LeetCode') return const Color(0xFFF89F1B);
    if (platform == 'GeeksForGeeks') return const Color(0xFF2F8D46);
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProblems = _selectedFilter == 'All'
        ? _problems
        : _problems.where((p) => p.difficulty == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
  icon: Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
  ),
  tooltip: 'Back',
  onPressed: () => Navigator.of(context).pop(),
),
        title: const Text('Practice Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
            ),
            tooltip: 'Go to Home',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.dashboard, (route) => false),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: ['All', 'Easy', 'Medium', 'Hard'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredProblems.length,
              itemBuilder: (context, index) {
                final problem = filteredProblems[index];
                return _buildProblemCard(problem, index)
                    .animate()
                    .fadeIn(delay: (50 * index).ms)
                    .slideY(begin: 0.2, end: 0, delay: (50 * index).ms);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCard(PracticeProblem problem, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchUrl(problem.url),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      problem.icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${problem.number}. ${problem.name}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildBadge(
                              problem.platform,
                              _getPlatformColor(problem.platform),
                              true,
                            ),
                            _buildBadge(
                              problem.difficulty,
                              _getDifficultyColor(problem.difficulty),
                              false,
                            ),
                            _buildBadge(
                              problem.pattern,
                              Theme.of(context).colorScheme.secondary,
                              false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                problem.description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Solve on ${problem.platform}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, bool filled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.1) : Colors.transparent,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
