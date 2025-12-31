import 'package:flow/data/enums/urine_color.dart';
import 'package:flutter/material.dart';

class UrineLogEntryPage extends StatefulWidget {
  const UrineLogEntryPage({super.key});

  @override
  State<UrineLogEntryPage> createState() => _UrineLogEntryPageState();
}

class _UrineLogEntryPageState extends State<UrineLogEntryPage> {
  // Defaults
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

  // Controllers for the horizontal carousels
  late PageController _colorController;
  late PageController _urgencyController;
  late PageController _volumeController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers to the default selected indices
    _colorController = PageController(
      viewportFraction: 0.35,
      initialPage: UrineColor.values.indexOf(_selectedColor),
    );

    _urgencyController = PageController(
      viewportFraction: 0.5,
      initialPage: _selectedUrgency - 1,
    );

    _volumeController = PageController(
      viewportFraction: 0.5,
      initialPage: _amounts.indexOf(_selectedAmount),
    );
  }

  @override
  void dispose() {
    _colorController.dispose();
    _urgencyController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

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

  Widget _buildColorStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _colorController,
            itemCount: UrineColor.values.length,
            onPageChanged: (index) {
              setState(() => _selectedColor = UrineColor.values[index]);
            },
            itemBuilder: (context, index) {
              final option = UrineColor.values[index];
              final isSelected = _selectedColor == option;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: option.color,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : Border.all(color: Colors.transparent, width: 3),
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
                    ? const Icon(Icons.check, color: Colors.black54)
                    : null,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _selectedColor.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
      ],
    );
  }

  Widget _buildUrgencyStep() {
    final urgencies = _urgencyLabels.keys.toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 16),
        const SizedBox(height: 4),
        const Text(
          "SELECT URGENCY",
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: PageView.builder(
            controller: _urgencyController,
            itemCount: urgencies.length,
            onPageChanged: (index) {
              setState(() => _selectedUrgency = urgencies[index]);
            },
            itemBuilder: (context, index) {
              final urgencyValue = urgencies[index];
              final label = _urgencyLabels[urgencyValue]!;
              final isSelected = _selectedUrgency == urgencyValue;

              return Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontSize: isSelected ? 20 : 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  child: Text(label),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
      ],
    );
  }

  Widget _buildVolumeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 16),
        const SizedBox(height: 4),
        const Text(
          "SELECT VOLUME",
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: PageView.builder(
            controller: _volumeController,
            itemCount: _amounts.length,
            onPageChanged: (index) {
              setState(() => _selectedAmount = _amounts[index]);
            },
            itemBuilder: (context, index) {
              final amount = _amounts[index];
              final isSelected = _selectedAmount == amount;

              return Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontSize: isSelected ? 20 : 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  child: Text(amount),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
      ],
    );
  }

  Widget _buildSaveStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
