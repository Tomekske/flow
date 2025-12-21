enum UrgencyLevel {
  low(1, 'Low'),
  normal(2, 'Normal'),
  high(3, 'High'),
  urgent(4, 'Urgent')
  ;

  const UrgencyLevel(this.value, this.label);
  final int value;
  final String label;
}
