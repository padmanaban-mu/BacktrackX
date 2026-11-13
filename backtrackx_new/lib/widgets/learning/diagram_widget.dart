import 'package:flutter/material.dart';
import 'dart:math' as math;

class DiagramWidget extends StatefulWidget {
  final String diagramType;

  const DiagramWidget({super.key, required this.diagramType});

  @override
  State<DiagramWidget> createState() => _DiagramWidgetState();
}

class _DiagramWidgetState extends State<DiagramWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 4)
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            CustomPainter? painter;
            if (widget.diagramType == 'tree') {
              painter = _TreePainter(animationValue: _controller.value, context: context);
            } else if (widget.diagramType == 'nqueens') {
              painter = _NQueensPainter(animationValue: _controller.value, context: context);
            } else if (widget.diagramType == 'graph') {
              painter = _GraphPainter(animationValue: _controller.value, context: context);
            } else {
              // Default fallback
              painter = _TreePainter(animationValue: _controller.value, context: context);
            }
            
            return CustomPaint(painter: painter);
          },
        ),
      ),
    );
  }
}

class _NQueensPainter extends CustomPainter {
  final double animationValue;
  final BuildContext context;

  _NQueensPainter({required this.animationValue, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = math.min(size.width, size.height) - 40;
    final cellSize = boardSize / 4;
    final offsetX = (size.width - boardSize) / 2;
    final offsetY = (size.height - boardSize) / 2;

    final boardPaint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Theme.of(context).colorScheme.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw board
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        boardPaint.color = (r + c) % 2 == 0 
            ? Theme.of(context).colorScheme.surface 
            : Theme.of(context).scaffoldBackgroundColor;
        canvas.drawRect(
          Rect.fromLTWH(offsetX + c * cellSize, offsetY + r * cellSize, cellSize, cellSize),
          boardPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(offsetX + c * cellSize, offsetY + r * cellSize, cellSize, cellSize),
          borderPaint,
        );
      }
    }

    // Draw queens (just mock positions: 0,1 then 1,3 etc.)
    final queenPositions = [const Offset(1, 0), const Offset(3, 1), const Offset(0, 2), const Offset(2, 3)];
    
    final queenPaint = Paint()
      ..color = Theme.of(context).colorScheme.secondary
      ..style = PaintingStyle.fill;
      
    final queenGlowPaint = Paint()
      ..color = Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5 * animationValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    for (int i = 0; i < queenPositions.length; i++) {
      final pos = queenPositions[i];
      final center = Offset(
        offsetX + pos.dx * cellSize + cellSize / 2,
        offsetY + pos.dy * cellSize + cellSize / 2,
      );
      
      canvas.drawCircle(center, cellSize * 0.3, queenGlowPaint);
      canvas.drawCircle(center, cellSize * 0.2, queenPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GraphPainter extends CustomPainter {
  final double animationValue;
  final BuildContext context;

  _GraphPainter({required this.animationValue, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    // 3 nodes in a triangle
    final n1 = Offset(size.width / 2, 40);
    final n2 = Offset(size.width * 0.3, size.height - 60);
    final n3 = Offset(size.width * 0.7, size.height - 60);
    
    final edgePaint = Paint()
      ..color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final activeEdgePaint = Paint()
      ..color = Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8 * animationValue)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(n1, n2, edgePaint);
    canvas.drawLine(n2, n3, edgePaint);
    canvas.drawLine(n3, n1, activeEdgePaint); // Animating constraint check

    void drawNode(Offset center, Color color, String label) {
      canvas.drawCircle(center, 24, Paint()..color = Theme.of(context).colorScheme.surface);
      canvas.drawCircle(center, 24, Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke);
      
      final textSpan = TextSpan(text: label, style: TextStyle(color: color, fontWeight: FontWeight.bold));
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
    }

    drawNode(n1, Theme.of(context).colorScheme.error, "Red");
    drawNode(n2, Theme.of(context).colorScheme.primary, "Blue");
    drawNode(n3, Theme.of(context).colorScheme.tertiary, "?");
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TreePainter extends CustomPainter {
  final double animationValue;
  final BuildContext context;

  _TreePainter({required this.animationValue, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.primary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = Theme.of(context).colorScheme.surface
      ..style = PaintingStyle.fill;
      
    final nodeBorderPaint = Paint()
      ..color = Theme.of(context).colorScheme.secondary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.3 * animationValue)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    void drawNode(Offset center, String text, bool isEnd) {
      canvas.drawCircle(center, 16, nodePaint);
      canvas.drawCircle(center, 16, isEnd ? (Paint()..color=Theme.of(context).colorScheme.error..strokeWidth=2..style=PaintingStyle.stroke) : nodeBorderPaint);
      
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2)),
      );
    }

    void drawBranch(Offset start, Offset end) {
      canvas.drawLine(start, end, glowPaint);
      canvas.drawLine(start, end, paint);
    }

    // Root
    final root = Offset(size.width / 2, 40);
    // Level 1
    final l1Left = Offset(size.width * 0.25, 120);
    final l1Right = Offset(size.width * 0.75, 120);
    // Level 2 (left)
    final l2Left1 = Offset(size.width * 0.15, 200);
    final l2Left2 = Offset(size.width * 0.35, 200);
    // Level 2 (right)
    final l2Right1 = Offset(size.width * 0.65, 200);
    final l2Right2 = Offset(size.width * 0.85, 200);

    drawBranch(root, l1Left);
    drawBranch(root, l1Right);
    
    drawBranch(l1Left, l2Left1);
    drawBranch(l1Left, l2Left2);
    
    drawBranch(l1Right, l2Right1);
    drawBranch(l1Right, l2Right2);

    drawNode(root, 'f(3)', false);
    drawNode(l1Left, 'f(2)', false);
    drawNode(l1Right, 'f(1)', false);
    
    drawNode(l2Left1, 'f(1)', true);
    drawNode(l2Left2, 'f(0)', true);
    drawNode(l2Right1, 'f(0)', true);
    drawNode(l2Right2, 'f(-1)', true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

