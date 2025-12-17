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

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'fluid_type': fluidType,
    'volume': volume,
    'created_at': createdAt.toIso8601String(),
  };

  factory DrinkLog.fromJson(Map<String, dynamic> json) => DrinkLog(
    id: json['id'],
    createdAt: DateTime.parse(json['created_at']),
    fluidType: json['fluid_type'],
    volume: json['volume'],
  );

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
