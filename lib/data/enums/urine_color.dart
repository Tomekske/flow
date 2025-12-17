import 'package:flutter/material.dart';

enum UrineColor {
  clear(0xFFF7F7F7, 'Clear'),
  pale(0xFFFFF9C4, 'Pale'),
  yellow(0xFFFFEB3B, 'Yellow'),
  dark(0xFFFBC02D, 'Dark'),
  amber(0xFFFFA000, 'Amber')
  ;

  // Fields
  final int hex;
  final String label;

  // Constructor
  const UrineColor(this.hex, this.label);

  // Helper getter for Flutter Color
  Color get color => Color(hex);

  // Safe way to get Enum from database ID (int)
  static UrineColor fromId(int id) {
    // Ensure the ID is within the valid range
    if (id < 0 || id >= UrineColor.values.length) {
      throw ArgumentError('Invalid UrineColor id: $id');
    }
    return UrineColor.values[id];
  }
}
