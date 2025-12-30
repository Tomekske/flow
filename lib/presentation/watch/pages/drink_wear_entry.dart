import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrinkWearEntry extends StatefulWidget {
  const DrinkWearEntry({super.key});

  @override
  State<DrinkWearEntry> createState() => _DrinkWearEntryState();
}

class _DrinkWearEntryState extends State<DrinkWearEntry> {
  // Defaults
  String _selectedType = 'Water';
  int _selectedVolume = 250;

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

  late PageController _typeController;
  late PageController _volumeController;

  @override
  void initState() {
    super.initState();
    _typeController = PageController(
      viewportFraction: 0.35,
      initialPage: _types.indexWhere((t) => t['id'] == _selectedType),
    );

    _volumeController = PageController(
      viewportFraction: 0.5,
      initialPage: _volumes.indexOf(_selectedVolume),
    );
  }

  @override
  void dispose() {
    _typeController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  void _onSave() {
    Navigator.pop(context, {
      'type': _selectedType,
      'volume': _selectedVolume,
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
          _buildTypeStep(),
          _buildVolumeStep(),
          _buildSaveStep(),
        ],
      ),
    );
  }

  // --- Step 1: Type Carousel ---
  Widget _buildTypeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "SELECT DRINK",
          style: TextStyle(
            color: Color(0xFF93C5FD),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _typeController,
            itemCount: _types.length,
            onPageChanged: (index) {
              setState(() => _selectedType = _types[index]['id']);
            },
            itemBuilder: (context, index) {
              final type = _types[index];
              final isSelected = _selectedType == type['id'];
              final iconData = type['icon'];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF1E293B),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : Border.all(color: Colors.transparent, width: 3),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.6),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: iconData is IconData
                      ? Icon(
                          iconData,
                          color: isSelected ? Colors.white : Colors.grey,
                          size: 24,
                        )
                      : FaIcon(
                          iconData,
                          color: isSelected ? Colors.white : Colors.grey,
                          size: 20,
                        ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _selectedType,
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

  Widget _buildVolumeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 16),
        const SizedBox(height: 4),
        const Text(
          "SELECT VOLUME",
          style: TextStyle(
            color: Color(0xFF93C5FD),
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
            itemCount: _volumes.length,
            onPageChanged: (index) {
              setState(() => _selectedVolume = _volumes[index]);
            },
            itemBuilder: (context, index) {
              final vol = _volumes[index];
              final isSelected = _selectedVolume == vol;

              return Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : Colors.grey[700],
                    fontSize: isSelected ? 24 : 18,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  child: Text("$vol ml"),
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
    // Find icon for summary
    final selectedIconData = _types.firstWhere(
      (t) => t['id'] == _selectedType,
      orElse: () => _types.first,
    )['icon'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 16),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selectedIconData is IconData
                ? Icon(selectedIconData, color: Colors.blue, size: 16)
                : FaIcon(selectedIconData, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            Text(
              "$_selectedVolume ml",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
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
              backgroundColor: const Color(0xFF2563EB),
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
