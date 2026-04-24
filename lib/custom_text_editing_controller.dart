import 'package:flutter/material.dart';

class MarkdownEditingController extends TextEditingController {
  final Map<String, TextStyle> map;
  final Pattern pattern;

  MarkdownEditingController()
      : map = const {
          r"@.\w+": TextStyle(
            color: Colors.blue, // For mentions
          ),
          r"#.\w+": TextStyle(
            color: Colors.blue, // for hashtags
          ),
          r'_(.*?)\_': TextStyle(
            fontStyle: FontStyle.italic, // italic text
          ),
          '~(.*?)~': TextStyle(
            decoration: TextDecoration.lineThrough, // strikethrough text
          ),
          r'\*(.*?)\*': TextStyle(
            fontWeight: FontWeight.bold, // bold text
          ),
        },
        pattern = RegExp(
            {r"@.\w+", r"#.\w+", r'_(.*?)\_', r'~(.*?)~', r'\*(.*?)\*'}
                .join('|'),
            multiLine: true);

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context, TextStyle? style, bool? withComposing}) {
    final List<InlineSpan> children = [];
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        String? patternMatched;
        String? formatText;
        TextStyle? myStyle = map[map.keys.firstWhere(
          (e) {
            bool ret = false;
            RegExp(e).allMatches(text).forEach((element) {
              if (element.group(0) == match[0]) {
                patternMatched = e;
                ret = true;
              }
            });
            return ret;
          },
        )];

        if (patternMatched == r"_(.*?)\_") {
          formatText = match[0]!.replaceAll("_", " ");
        } else if (patternMatched == r'\*(.*?)\*') {
          formatText = match[0]!.replaceAll("*", " ");
        } else if (patternMatched == "~(.*?)~") {
          formatText = match[0]!.replaceAll("~", " ");
        } else if (patternMatched == r'```(.*?)```') {
          formatText = match[0]!.replaceAll("```", "   ");
        } else {
          formatText = match[0];
        }

        children.add(TextSpan(
          text: formatText,
          style: style!.merge(myStyle),
        ));
        return "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return "";
      },
    );

    return TextSpan(style: style, children: children);
  }
}
