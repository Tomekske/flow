import '../enums/urine_color.dart';

class UrineLog {
  final int id;
  final UrineColor color;
  final String amount;
  final DateTime createdAt;

  const UrineLog({
    required this.id,
    required this.createdAt,
    required this.color,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'color': color.index,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
  };

  factory UrineLog.fromJson(Map<String, dynamic> json) {
    try {
      if (json['id'] == null || json['created_at'] == null) {
        throw ArgumentError('Missing required fields: id or created_at');
      }

      return UrineLog(
        id: json['id'],
        color: UrineColor.fromId(json['color']),
        amount: json['amount'],
        createdAt: DateTime.parse(json['created_at']),
      );
    } catch (e) {
      throw FormatException('Failed to parse UrineLog from JSON: $e');
    }
  }
  UrineLog copyWith({
    int? id,
    UrineColor? color,
    String? amount,
    DateTime? createdAt,
  }) {
    return UrineLog(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      amount: amount ?? this.amount,
    );
  }
}
