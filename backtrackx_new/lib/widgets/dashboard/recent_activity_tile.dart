import 'package:flutter/material.dart';

/// One row inside the "Recent Activity" list -- a checkmark icon,
/// activity text, and a relative time. Data is placeholder for now;
/// Module 6 (Progress Tracker) will log real activity here.
class RecentActivityTile extends StatelessWidget {
  final String text;
  final String time;

  const RecentActivityTile({super.key, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Color(0xFFE6FCF5), shape: BoxShape.circle),
            child: Icon(Icons.check, color: Theme.of(context).colorScheme.tertiary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
