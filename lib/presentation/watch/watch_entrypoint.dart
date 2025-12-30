import 'package:flow/presentation/watch/widgets/urine_wear_card.dart';
import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';

import '../../data/models/urination_stats.dart';

class WatchEntrypoint extends StatelessWidget {
  const WatchEntrypoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      // We pass the data into the screen here
      home: UrineStatsScreen(
        stats: UrinationStats(
          total: 5,
          frequency: "10h",
          lastVisit: DateTime.now(),
        ),
        onLogTap: () {
          print("Log button tapped");
        },
      ),
    );
  }
}

/// A reusable widget that handles the Wear OS layout logic
class UrineStatsScreen extends StatelessWidget {
  final UrinationStats stats;
  final VoidCallback onLogTap;

  const UrineStatsScreen({
    super.key,
    required this.stats,
    required this.onLogTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: WatchShape(
          builder: (BuildContext context, WearShape shape, Widget? child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UrineWearCard(
                  stats: stats,
                  onTap: onLogTap,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
