import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../data/models/drink_log_entry.dart';

class DrinkDialog extends StatefulWidget {
  final DrinkLogEntry? existingLog;
  const DrinkDialog({super.key, this.existingLog});

  @override
  State<DrinkDialog> createState() => _DrinkDialogState();
}

class _DrinkDialogState extends State<DrinkDialog> {
  String _selectedType = 'Water';
  int _selectedVolume = 250;
  late DateTime _selectedTime;

  final List<Map<String, dynamic>> _types = [
    {'id': 'Water', 'icon': Icons.water_drop_rounded, 'label': 'Water'},
    {'id': 'Soda', 'icon': FontAwesomeIcons.burger, 'label': 'Soda'},
    {'id': 'Milk', 'icon': FontAwesomeIcons.cow, 'label': 'Milk'},
    {'id': 'Juice', 'icon': FontAwesomeIcons.appleWhole, 'label': 'Juice'},
    {'id': 'Soup', 'icon': Icons.soup_kitchen_rounded, 'label': 'Soup'},
    {'id': 'Tea', 'icon': Icons.emoji_food_beverage_rounded, 'label': 'Tea'},
    {'id': 'Alcohol', 'icon': Icons.liquor_rounded, 'label': 'Alcohol'},
  ];
  final List<int> _volumes = [200, 250, 330, 500];

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      _selectedType = widget.existingLog!.fluidType;
      _selectedVolume = widget.existingLog!.volume;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingLog != null ? "Edit Drink" : "Log Drink",
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
                        color: isDark ? Colors.white : const Color(0xFF334155),
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
              "Type",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: _types.map((t) {
                final bool isSelected = _selectedType == t['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = t['id']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? Colors.blue.withValues(alpha: 0.2)
                                : Colors.blue.shade50)
                          : (isDark ? Colors.grey[800] : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        t['icon'] is IconData
                            ? Icon(
                                t['icon'],
                                color: isSelected
                                    ? (isDark ? Colors.blueAccent : Colors.blue)
                                    : (isDark
                                          ? Colors.grey
                                          : Colors.grey.shade400),
                              )
                            : FaIcon(
                                t['icon'],
                                size:
                                    20, // FaIcons can sometimes be slightly larger/smaller
                                color: isSelected
                                    ? (isDark ? Colors.blueAccent : Colors.blue)
                                    : (isDark
                                          ? Colors.grey
                                          : Colors.grey.shade400),
                              ),
                        const SizedBox(height: 4),
                        Text(
                          t['label'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? (isDark ? Colors.blueAccent : Colors.blue)
                                : (isDark ? Colors.grey : Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            Text(
              "Volume (ml)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _volumes.map((vol) {
                final bool isSelected = _selectedVolume == vol;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVolume = vol),
                  child: Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : (isDark
                                ? Colors.grey[800]
                                : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+$vol',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

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
                        'type': _selectedType,
                        'volume': _selectedVolume,
                        'created_at': _selectedTime,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
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
    );
  }
}
