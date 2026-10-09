import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

/// Single-choice segmented control for an enum, e.g. priority or status.
class ChoiceSegments<T> extends StatelessWidget {
  const ChoiceSegments({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  /// Each value with the label shown for it.
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SegmentedButton<T>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        backgroundColor: palette.surface,
        foregroundColor: palette.ink2,
        selectedBackgroundColor: palette.tint,
        selectedForegroundColor: palette.accent,
        side: BorderSide(color: palette.border),
      ),
      segments: [
        for (final (value, label) in options)
          ButtonSegment(value: value, label: Text(label)),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
