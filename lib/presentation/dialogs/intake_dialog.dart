import 'package:flutter/material.dart';
import '../../data/models/log.dart';

class IntakeDialog extends StatefulWidget {
  final Log? existingLog;
  const IntakeDialog({super.key, this.existingLog});

  @override
  State<IntakeDialog> createState() => _IntakeDialogState();
}

class _IntakeDialogState extends State<IntakeDialog> {
  String _selectedType = 'Water';
  int _selectedVolume = 250;

  final List<Map<String, dynamic>> _types = [
    {'id': 'Water', 'icon': Icons.water_drop, 'label': 'Water'},
    {'id': 'Soda', 'icon': Icons.local_drink, 'label': 'Soda'},
    {'id': 'Tea', 'icon': Icons.coffee, 'label': 'Tea'},
    {'id': 'Soup', 'icon': Icons.soup_kitchen, 'label': 'Soup'},
  ];

  final List<int> _volumes = [200, 250, 330, 500];

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      _selectedType = widget.existingLog!.fluidType ?? 'Water';
      _selectedVolume = widget.existingLog!.volume ?? 250;
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
            Text(widget.existingLog != null ? "Edit Intake" : "Log Fluids", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 24),

            const Text("Type", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
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
                      color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t['icon'], color: isSelected ? Colors.blue : Colors.grey.shade400),
                        const SizedBox(height: 4),
                        Text(t['label'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.grey.shade400)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            const Text("Volume (ml)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _volumes.map((vol) {
                final bool isSelected = _selectedVolume == vol;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVolume = vol),
                  child: Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : [],
                    ),
                    alignment: Alignment.center,
                    child: Text('$vol', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF64748B))),
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
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {'type': _selectedType, 'volume': _selectedVolume});
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
