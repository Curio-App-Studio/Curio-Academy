import 'package:flutter/material.dart';

class ScratchpadDrawer extends StatefulWidget {
  const ScratchpadDrawer({super.key});

  @override
  State<ScratchpadDrawer> createState() => _ScratchpadDrawerState();
}

class _ScratchpadDrawerState extends State<ScratchpadDrawer> {
  final List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];
  final Color _currentColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar & controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  'Scratchpad / Rough Work',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Clear canvas',
                  onPressed: () {
                    setState(() {
                      _lines.clear();
                      _currentLine.clear();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Canvas
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _currentLine = [details.localPosition];
                  _lines.add(_currentLine);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _currentLine.add(details.localPosition);
                });
              },
              child: CustomPaint(
                painter: _ScratchpadPainter(lines: _lines, color: _currentColor),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScratchpadPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final Color color;

  _ScratchpadPainter({required this.lines, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw strokes
    final strokePaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (final line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScratchpadPainter oldDelegate) => true;
}
