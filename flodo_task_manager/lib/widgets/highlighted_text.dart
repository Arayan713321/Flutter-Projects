import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Renders [text] with case-insensitive [query] highlights.
/// Matched substrings appear with a primary color highlight background.
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.baseStyle,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String query;
  final TextStyle? baseStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = baseStyle ?? AppTextStyles.bodyMedium;

    if (query.isEmpty) {
      return Text(
        text,
        style: effectiveStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final lowerText  = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans      = <TextSpan>[];
    int start        = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: effectiveStyle));
        break;
      }

      // Unmatched portion before this match
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: effectiveStyle),
        );
      }

      // Matched portion
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: effectiveStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            backgroundColor: AppColors.primaryLight,
          ),
        ),
      );

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
