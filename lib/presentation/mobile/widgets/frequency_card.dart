import 'package:flutter/material.dart';

class FrequencyCard extends StatelessWidget {
  final String dailyRate;
  final String globalRate;
  final String dailyInterval;
  final String globalInterval;

  const FrequencyCard({
    super.key,
    required this.dailyRate,
    required this.globalRate,
    required this.dailyInterval,
    required this.globalInterval,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Frequency Analysis",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF312E81),
                    ),
                  ),
                  Text(
                    "Compare Daily vs All-Time",
                    style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5)),
                  ),
                ],
              ),
              Icon(Icons.access_time_filled, color: Color(0xFF6366F1)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "METRIC",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA5B4FC),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "TODAY",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "ALL TIME",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA5B4FC),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatRow("Visits / Hr", dailyRate, globalRate),
          const SizedBox(height: 8),
          _buildStatRow("Avg Gap", dailyInterval, globalInterval),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String val1, String val2) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF312E81),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E7FF)),
            ),
            child: Center(
              child: Text(
                val1,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              val2,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF818CF8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
