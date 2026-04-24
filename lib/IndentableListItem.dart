import 'package:flutter/material.dart';

class IndentableListItem extends StatefulWidget {
  final Widget child;
  final void Function(String direction)? onSwipe;
  final int maxLevels;
  final List<int> location;
  final int maxItemDepth;
  final ScaffoldMessengerState scaffoldMessenger;

  const IndentableListItem({
    Key? key,
    required this.child,
    required this.maxLevels,
    required this.location,
    required this.maxItemDepth,
    required this.scaffoldMessenger,
    this.onSwipe,
  }) : super(key: key);

  @override
  _IndentableListItemState createState() => _IndentableListItemState();
}

class _IndentableListItemState extends State<IndentableListItem> {
  int indent = 0;
  double dragDelta = 0.0;

  void _handleSwipe(String direction) {
    if (widget.location.last == 0 && direction == "right") {
      widget.scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Can't indent first item in (sub)-list.")),
      );
      return;
    }
    if (widget.maxItemDepth >= 3 && direction == "right") {
      widget.scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Can't indent, would cause nesting level above max.")),
      );
      return;
    }

    setState(() {
      if (direction == 'right') {
        indent = (indent + 20).clamp(0, 20 * widget.maxLevels);
      } else if (direction == 'left') {
        indent = (indent - 20).clamp(0, 20 * widget.maxLevels);
      }
    });

    widget.onSwipe?.call(direction);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        dragDelta += details.delta.dx;
      },
      onHorizontalDragEnd: (_) {
        if (dragDelta.abs() > 10) {
          if (dragDelta > 0) {
            _handleSwipe('right');
          } else {
            _handleSwipe('left');
          }
        }
        dragDelta = 0; // reset
      },
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(left: indent.toDouble()),
        child: widget.child,
      ),
    );
  }
}
