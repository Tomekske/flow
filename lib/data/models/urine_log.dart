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

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'color': color.index,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
  };

  factory UrineLog.fromJson(Map<String, dynamic> json) => UrineLog(
    id: json['id'],
    // Convert DB integer back to Enum
    color: UrineColor.fromId(json['color']),
    amount: json['amount'],
    createdAt: DateTime.parse(json['created_at']),
  );

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
