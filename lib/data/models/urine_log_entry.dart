import '../enums/urine_color.dart';
import 'log_entry.dart';

class UrineLogEntry extends LogEntry {
  final UrineColor color;
  final String amount;
  final int urgency;

  const UrineLogEntry({
    required super.id,
    required super.createdAt,
    required this.color,
    required this.amount,
    required this.urgency,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'color': color.index,
    'amount': amount,
    'urgency': urgency,
    'created_at': createdAt.toIso8601String(),
  };

  factory UrineLogEntry.fromJson(Map<String, dynamic> json) {
    try {
      if (json['id'] == null ||
          json['created_at'] == null ||
          json['color'] == null ||
          json['amount'] == null) {
        throw ArgumentError('Missing required fields in UrineLogEntry JSON');
      }

      return UrineLogEntry(
        id: json['id'],
        color: UrineColor.fromId(json['color']),
        amount: json['amount'],
        // Check if urgency exists and is an int, otherwise default to 2 (Normal)
        urgency: (json['urgency'] is int) ? json['urgency'] : 2,
        createdAt: DateTime.parse(json['created_at']),
      );
    } catch (e) {
      throw FormatException('Failed to parse UrineLogEntry from JSON: $e');
    }
  }

  UrineLogEntry copyWith({
    int? id,
    UrineColor? color,
    String? amount,
    int? urgency, //
    DateTime? createdAt,
  }) {
    return UrineLogEntry(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      amount: amount ?? this.amount,
      urgency: urgency ?? this.urgency, //
    );
  }
}
