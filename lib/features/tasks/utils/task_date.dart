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

String formatTaskDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatTaskDateShort(DateTime d) => '${_months[d.month - 1]} ${d.day}';
