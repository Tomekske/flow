import 'package:flow/data/models/log_entry.dart';

class DrinkLogEntry extends LogEntry {
  final String fluidType; // Water, Soda, Tea, Soup
  final int volume;

  const DrinkLogEntry({
    required super.id,
    required super.createdAt,
    required this.fluidType,
    required this.volume,
  }) ;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fluid_type': fluidType,
    'volume': volume,
    'created_at': createdAt.toIso8601String(),
  };

  factory DrinkLogEntry.fromJson(Map<String, dynamic> json) {
    try {
      if (json['id'] == null ||
          json['created_at'] == null ||
          json['fluid_type'] == null ||
          json['volume'] == null) {
        throw ArgumentError('Missing required fields in DrinkLog JSON');
      }

      return DrinkLogEntry(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        fluidType: json['fluid_type'],
        volume: json['volume'],
      );
    } catch (e) {
      throw FormatException('Failed to parse DrinkLog from JSON: $e');
    }
  }

  DrinkLogEntry copyWith({
    int? id,
    DateTime? createdAt,
    String? fluidType,
    int? volume,
  }) {
    return DrinkLogEntry(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      fluidType: fluidType ?? this.fluidType,
      volume: volume ?? this.volume,
    );
  }
}
