const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a date like "9 Oct 2026" for task screens.
String formatTaskDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}';
