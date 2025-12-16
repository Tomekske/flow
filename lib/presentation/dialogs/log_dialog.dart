import 'package:flutter/material.dart';
import '../../data/models/log.dart';

class LogDialog extends StatefulWidget {
  final ToiletLog? existingLog;
  const LogDialog({super.key, this.existingLog});

  @override
  State<LogDialog> createState() => _LogDialogState();
}

class _LogDialogState extends State<LogDialog> {
  int? _selectedColor;
  String _selectedAmount = 'Medium';

  final List<Map<String, dynamic>> _colors = [
    {'color': 0xFFF7F7F7, 'label': 'Clear'},
    {'color': 0xFFFFF9C4, 'label': 'Pale'},
    {'color': 0xFFFFEB3B, 'label': 'Yellow'},
    {'color': 0xFFFBC02D, 'label': 'Dark'},
    {'color': 0xFFFFA000, 'label': 'Amber'},
  ];

  // Updated Volume Options
  final List<String> _amounts = ['Small', 'Medium', 'Large'];

  @override
  void initState() {
    super.initState();
    // Pre-fill data if editing
    if (widget.existingLog != null) {
      _selectedColor = widget.existingLog!.urineColor;
      _selectedAmount = widget.existingLog!.urineAmount ?? 'Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingLog != null ? "Edit Log" : "Log Visit",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Color",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _colors.map((c) {
                final int colorVal = c['color'];
                final bool isSelected = _selectedColor == colorVal;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorVal),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(colorVal),
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
                                    color: Colors.blue.withOpacity(0.3),
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
                        c['label'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.blue
                              : const Color(0xFF94A3B8),
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

            const Text(
              "Amount",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
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
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
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
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Color(0xFF64748B)),
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
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
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
