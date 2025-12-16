enum LogType { toilet, drink }

abstract class Log {
  final int id;
  final DateTime timestamp;

  const Log({
    required this.id,
    required this.timestamp,
  });

  Map<String, dynamic> toJson();

  // Factory constructor to create the correct subclass from JSON
  factory Log.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type == 'toilet') {
      return ToiletLog.fromJson(json);
    } else if (type == 'drink') {
      return DrinkLog.fromJson(json);
    } else {
      throw Exception('Unknown log type: $type');
    }
  }
}

class ToiletLog extends Log {
  final int? urineColor;
  final String? urineAmount;

  const ToiletLog({
    required super.id,
    required super.timestamp,
    this.urineColor,
    this.urineAmount,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'urineColor': urineColor,
    'urineAmount': urineAmount,
  };

  factory ToiletLog.fromJson(Map<String, dynamic> json) => ToiletLog(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    urineColor: json['urineColor'],
    urineAmount: json['urineAmount'],
  );

  ToiletLog copyWith({
    int? id,
    DateTime? timestamp,
    int? urineColor,
    String? urineAmount,
  }) {
    return ToiletLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      urineColor: urineColor ?? this.urineColor,
      urineAmount: urineAmount ?? this.urineAmount,
    );
  }
}

class DrinkLog extends Log {
  final String? fluidType; // Water, Soda, Tea, Soup
  final int? volume; // ml

  const DrinkLog({
    required super.id,
    required super.timestamp,
    this.fluidType,
    this.volume,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'fluidType': fluidType,
    'volume': volume,
  };

  factory DrinkLog.fromJson(Map<String, dynamic> json) => DrinkLog(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    fluidType: json['fluidType'],
    volume: json['volume'],
  );

  DrinkLog copyWith({
    int? id,
    DateTime? timestamp,
    String? fluidType,
    int? volume,
  }) {
    return DrinkLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      fluidType: fluidType ?? this.fluidType,
      volume: volume ?? this.volume,
    );
  }
}
