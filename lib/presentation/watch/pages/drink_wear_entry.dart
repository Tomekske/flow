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

  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _types = [
    {'id': 'Water', 'icon': Icons.water_drop_rounded, 'label': 'Water'},
    {'id': 'Soda', 'icon': FontAwesomeIcons.burger, 'label': 'Soda'},
    {'id': 'Milk', 'icon': FontAwesomeIcons.cow, 'label': 'Milk'},
    {'id': 'Juice', 'icon': FontAwesomeIcons.appleWhole, 'label': 'Juice'},
    {'id': 'Soup', 'icon': Icons.soup_kitchen_rounded, 'label': 'Soup'},
    {'id': 'Tea', 'icon': Icons.emoji_food_beverage_rounded, 'label': 'Tea'},
    {'id': 'Alcohol', 'icon': Icons.liquor_rounded, 'label': 'Alcohol'},
  ];

  final List<int> _volumes = [100, 150, 200, 250, 300, 350];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSave() {
    Navigator.pop(context, {
      'type': _selectedType,
      'volume': _selectedVolume,
      'created_at': DateTime.now(),
    });
  }

  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        children: [
          _buildTypeStep(),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeStep() {
    return _buildStepContainer(
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
        const SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _types.map((type) {
            final isSelected = _selectedType == type['id'];
            final iconData = type['icon'];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedType = type['id']);
                    Future.delayed(const Duration(milliseconds: 150), () {
                      _goToNextPage();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF1E293B),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : Border.all(color: Colors.transparent, width: 2),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.6),
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
                              size: 22,
                            )
                          : FaIcon(
                              iconData,
                              color: isSelected ? Colors.white : Colors.grey,
                              size: 18,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type['label'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _goToNextPage,
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeStep() {
    return _buildStepContainer(
      children: [
        GestureDetector(
          onTap: _goToPreviousPage,
          child: const Icon(
            Icons.keyboard_arrow_up,
            color: Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "SELECT VOLUME",
          style: TextStyle(
            color: Color(0xFF93C5FD),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: _volumes.map((vol) {
            final isSelected = _selectedVolume == vol;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedVolume = vol);
                Future.delayed(const Duration(milliseconds: 150), () {
                  _goToNextPage();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                width: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(
                          0xFF1E293B,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 1.5)
                      : Border.all(color: Colors.transparent),
                ),
                child: Text(
                  "$vol ml",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontSize: 12,
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
        GestureDetector(
          onTap: _goToNextPage,
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveStep() {
    final selectedIconData = _types.firstWhere(
      (t) => t['id'] == _selectedType,
      orElse: () => _types.first,
    )['icon'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _goToPreviousPage,
          child: const Icon(
            Icons.keyboard_arrow_up,
            color: Colors.grey,
            size: 24,
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selectedIconData is IconData
                ? Icon(selectedIconData, color: Colors.blue, size: 20)
                : FaIcon(selectedIconData, color: Colors.blue, size: 20),
            const SizedBox(width: 10),
            Text(
              "$_selectedVolume ml",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 140,
          height: 48,
          child: ElevatedButton(
            onPressed: _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
            child: const Text(
              "Save",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
