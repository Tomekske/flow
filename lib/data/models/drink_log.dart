class DrinkLog {
  final int id;
  final String? fluidType; // Water, Soda, Tea, Soup
  final int? volume; // ml
  final DateTime createdAt;

  const DrinkLog({
    required this.id,
    this.fluidType,
    this.volume,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fluid_type': fluidType,
    'volume': volume,
    'created_at': createdAt.toIso8601String(),
  };

  factory DrinkLog.fromJson(Map<String, dynamic> json) {
    try {
      if (json['id'] == null || json['created_at'] == null) {
        throw ArgumentError('Missing required fields: id or created_at');
      }

      return DrinkLog(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        fluidType: json['fluid_type'],
        volume: json['volume'],
      );
    } catch (e) {
      throw FormatException('Failed to parse DrinkLog from JSON: $e');
    }
  }

  DrinkLog copyWith({
    int? id,
    DateTime? createdAt,
    String? fluidType,
    int? volume,
  }) {
    return DrinkLog(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      fluidType: fluidType ?? this.fluidType,
      volume: volume ?? this.volume,
    );
  }
}
