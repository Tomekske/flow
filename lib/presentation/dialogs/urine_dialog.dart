import 'package:flow/data/models/urine_log_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/enums/urine_color.dart';

class UrineDialog extends StatefulWidget {
  final UrineLogEntry? existingLog;
  const UrineDialog({super.key, this.existingLog});

  @override
  State<UrineDialog> createState() => _UrineDialogState();
}

class _UrineDialogState extends State<UrineDialog> {
  UrineColor _selectedColor = UrineColor.yellow;
  String _selectedAmount = 'Medium';
  int _selectedUrgency = 2; // Default to Normal (2)
  late DateTime _selectedTime;

  final List<String> _amounts = ['Small', 'Medium', 'Large'];

  final Map<int, String> _urgencyLabels = {
    1: 'Low',
    2: 'Normal',
    3: 'High',
    4: 'Urgent',
  };

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      _selectedColor = widget.existingLog!.color;
      _selectedAmount = widget.existingLog!.amount;
      _selectedUrgency = widget.existingLog!.urgency;
      _selectedTime = widget.existingLog!.createdAt;
    } else {
      _selectedTime = DateTime.now();
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time == null) return;

    setState(() {
      _selectedTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingLog != null
                    ? "Edit Toilet Log"
                    : "Log Toilet Visit",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 24),

              // Date Time Picker
              Text(
                "Time",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickDateTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.transparent
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat(
                          'yyyy-MM-dd - HH:mm',
                        ).format(_selectedTime),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Color",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: UrineColor.values.map((option) {
                  final bool isSelected = _selectedColor == option;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = option),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: option.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 20,
                                  color: Colors.black54,
                                )
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.blue
                                : (isDark
                                      ? Colors.grey[400]
                                      : const Color(0xFF94A3B8)),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                "Urgency",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: _urgencyLabels.entries.map((entry) {
                    final int value = entry.key;
                    final String label = entry.value;
                    final bool isSelected = _selectedUrgency == value;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedUrgency = value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.grey[700] : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? (isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B))
                                  : (isDark
                                        ? Colors.grey[400]
                                        : const Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Volume",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              _buildVolumeControl(isDark),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'color': _selectedColor,
                          'amount': _selectedAmount,
                          'urgency': _selectedUrgency, // Returns int (1-4)
                          'created_at': _selectedTime,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Volume (String based)
  Widget _buildVolumeControl(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _amounts.map((amount) {
          final bool isSelected = _selectedAmount == amount;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedAmount = amount),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? Colors.grey[700] : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF1E293B))
                        : (isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
