import 'package:flow/data/enums/urine_color.dart';
import 'package:flutter/material.dart';

class UrineLogEntryPage extends StatefulWidget {
  const UrineLogEntryPage({super.key});

  @override
  State<UrineLogEntryPage> createState() => _UrineLogEntryPageState();
}

class _UrineLogEntryPageState extends State<UrineLogEntryPage> {
  UrineColor _selectedColor = UrineColor.yellow;
  String _selectedAmount = 'Medium';
  int _selectedUrgency = 2;

  final List<String> _amounts = ['Small', 'Medium', 'Large'];

  final Map<int, String> _urgencyLabels = {
    1: 'Low',
    2: 'Normal',
    3: 'High',
    4: 'Urgent',
  };

  final PageController _mainPageController = PageController();

  void _onSave() {
    Navigator.pop(context, {
      'color': _selectedColor,
      'amount': _selectedAmount,
      'urgency': _selectedUrgency,
      'created_at': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _mainPageController,
        scrollDirection: Axis.vertical,
        children: [
          _buildColorStep(),
          _buildUrgencyStep(),
          _buildVolumeStep(),
          _buildSaveStep(),
        ],
      ),
    );
  }

  Widget _buildStepContainer({required List<Widget> children}) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildColorStep() {
    return _buildStepContainer(
      children: [
        const Text(
          "SELECT COLOR",
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: UrineColor.values.map((option) {
            final isSelected = _selectedColor == option;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedColor = option);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: option.color,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : Border.all(color: Colors.transparent, width: 2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: option.color.withOpacity(0.6),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black54, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
        Text(
          _selectedColor.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
      ],
    );
  }

  Widget _buildUrgencyStep() {
    final urgencies = _urgencyLabels.keys.toList();

    return _buildStepContainer(
      children: [
        const Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 16),
        const SizedBox(height: 8),
        const Text(
          "SELECT URGENCY",
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: urgencies.map((urgencyValue) {
            final label = _urgencyLabels[urgencyValue]!;
            final isSelected = _selectedUrgency == urgencyValue;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedUrgency = urgencyValue);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ), // Compact padding
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
      ],
    );
  }

  Widget _buildVolumeStep() {
    return _buildStepContainer(
      children: [
        const Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 16),
        const SizedBox(height: 8),
        const Text(
          "SELECT VOLUME",
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: _amounts.map((amount) {
            final isSelected = _selectedAmount == amount;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedAmount = amount);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                ),
                child: Text(
                  amount,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
      ],
    );
  }

  Widget _buildSaveStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 16),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _selectedColor.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "$_selectedAmount Amount",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 120,
          height: 48,
          child: ElevatedButton(
            onPressed: _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text("Save"),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
