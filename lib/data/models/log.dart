class Log {
  final int id;
  final DateTime timestamp;
  final int? urineColor;
  final String? urineAmount;

  Log({required this.id, required this.timestamp, this.urineColor, this.urineAmount});

  Log copyWith({int? id, DateTime? timestamp, int? urineColor, String? urineAmount}) {
    return Log(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      urineColor: urineColor ?? this.urineColor,
      urineAmount: urineAmount ?? this.urineAmount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'urineColor': urineColor,
    'urineAmount': urineAmount,
  };

  factory Log.fromJson(Map<String, dynamic> json) => Log(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    urineColor: json['urineColor'],
    urineAmount: json['urineAmount'],
  );
}
