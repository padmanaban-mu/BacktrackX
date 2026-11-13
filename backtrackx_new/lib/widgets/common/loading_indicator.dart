import 'package:flutter/material.dart';

/// A simple centered spinner with an optional message, available for any
/// screen that needs a full-area loading state.
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
