import 'package:flutter/material.dart';

class MarkdownTextEditingController extends TextEditingController {
  MarkdownTextEditingController({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    assert(!value.composing.isValid || !withComposing || value.isComposingRangeValid);
    
    // If the composing range is out of range for the current text, ignore it to
    // preserve the tree integrity, otherwise in release mode a RangeError will
    // be thrown and this EditableText will be built with a broken subtree.
    final bool composingRegionOutOfRange = !value.isComposingRangeValid || !withComposing;

    if (composingRegionOutOfRange) {
      return _buildStyledTextSpan(context, style);
    }

    // Handle composing text with markdown styling
    final TextStyle composingStyle =
        style?.merge(const TextStyle(decoration: TextDecoration.underline)) ??
        const TextStyle(decoration: TextDecoration.underline);

    final String beforeComposing = value.composing.textBefore(value.text);
    final String composingText = value.composing.textInside(value.text);
    final String afterComposing = value.composing.textAfter(value.text);

    return TextSpan(
      style: style,
      children: [
        ..._buildStyledTextSpans(context, beforeComposing, style),
        ..._buildStyledTextSpans(context, composingText, composingStyle),
        ..._buildStyledTextSpans(context, afterComposing, style),
      ],
    );
  }

  TextSpan _buildStyledTextSpan(BuildContext context, TextStyle? style) {
    final List<TextSpan> spans = _buildStyledTextSpans(context, text, style);
    return TextSpan(style: style, children: spans);
  }

  List<TextSpan> _buildStyledTextSpans(BuildContext context, String text, TextStyle? baseStyle) {
    if (text.isEmpty) return [];

    final List<TextSpan> spans = [];
    final List<String> lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      TextStyle? lineStyle = baseStyle;
      
      // Check for markdown headers - merge baseStyle into theme style (not the other way around)
      if (line.startsWith('### ')) {
        // Title Small
        lineStyle = baseStyle != null 
            ? Theme.of(context).textTheme.titleSmall?.copyWith(
                color: baseStyle.color,
                decoration: baseStyle.decoration,
                decorationColor: baseStyle.decorationColor,
              ) 
            : Theme.of(context).textTheme.labelMedium;
      } else if (line.startsWith('## ')) {
        // Title Medium
        lineStyle = baseStyle != null 
            ? Theme.of(context).textTheme.titleMedium?.copyWith(
                color: baseStyle.color,
                decoration: baseStyle.decoration,
                decorationColor: baseStyle.decorationColor,
              ) 
            : Theme.of(context).textTheme.titleMedium;
      } else if (line.startsWith('# ')) {
        // Title Large
        lineStyle = baseStyle != null 
            ? Theme.of(context).textTheme.titleLarge?.copyWith(
                color: baseStyle.color,
                decoration: baseStyle.decoration,
                decorationColor: baseStyle.decorationColor,
              ) 
            : Theme.of(context).textTheme.titleLarge;
      }
      
      spans.add(TextSpan(
        text: line,
        style: lineStyle,
      ));
      
      // Add newline character except for the last line
      if (i < lines.length - 1) {
        spans.add(TextSpan(
          text: '\n',
          style: baseStyle,
        ));
      }
    }
    
    return spans;
  }
}

// Example usage widget
class MarkdownTextFieldExample extends StatefulWidget {
  @override
  _MarkdownTextFieldExampleState createState() => _MarkdownTextFieldExampleState();
}

class _MarkdownTextFieldExampleState extends State<MarkdownTextFieldExample> {
  late MarkdownTextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MarkdownTextEditingController(
      text: '# Large Title\nThis is normal text.\n## Medium Title\nMore normal text.\n### Small Title\nEven more text.',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Markdown Text Field'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type with # for headers...',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Use # for large title, ## for medium title, ### for small title',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
