class Log {
  final int id;
  final DateTime timestamp;
  final String type; // 'toilet' or 'intake'

  // Toilet specific
  final int? urineColor;
  final String? urineAmount;

  // Intake specific
  final String? fluidType; // Water, Soda, Tea, Soup
  final int? volume; // ml

  Log({
    required this.id,
    required this.timestamp,
    required this.type,
    this.urineColor,
    this.urineAmount,
    this.fluidType,
    this.volume,
  });

  Log copyWith({
    int? id,
    DateTime? timestamp,
    String? type,
    int? urineColor,
    String? urineAmount,
    String? fluidType,
    int? volume,
  }) {
    return Log(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      urineColor: urineColor ?? this.urineColor,
      urineAmount: urineAmount ?? this.urineAmount,
      fluidType: fluidType ?? this.fluidType,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'urineColor': urineColor,
    'urineAmount': urineAmount,
    'fluidType': fluidType,
    'volume': volume,
  };

  factory Log.fromJson(Map<String, dynamic> json) => Log(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    type: json['type'] ?? 'toilet', // Backwards compatibility
    urineColor: json['urineColor'],
    urineAmount: json['urineAmount'],
    fluidType: json['fluidType'],
    volume: json['volume'],
  );
}
