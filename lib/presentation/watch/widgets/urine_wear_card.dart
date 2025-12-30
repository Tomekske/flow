import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/urination_stats.dart';

class UrineWearCard extends StatelessWidget {
  final UrinationStats stats;
  final VoidCallback onTap;

  const UrineWearCard({
    super.key,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Forces the widget to be a perfect square/circle
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(4), // Tiny margin to not touch bezel
          decoration: const BoxDecoration(
            shape: BoxShape.circle, // <--- MAKES IT ROUND
            gradient: LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Header (Pushed down slightly to fit top curve)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: Color(0xFFFFFBEB),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Visits", // Shortened text to fit width
                      style: TextStyle(
                        color: Color(0xFFFFFBEB),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 2),

              // 2. Big Number (Center - widest part of circle)
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      stats.total.toString(),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Compact Stats Row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time
                    Text(
                      stats.lastVisit != null
                          ? DateFormat('HH:mm').format(stats.lastVisit!)
                          : "--:--",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Vertical Divider
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 1,
                      height: 10,
                      color: Colors.white54,
                    ),
                    // Frequency
                    Text(
                      stats.frequency,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Bottom padding spacer to clear bottom curve
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
