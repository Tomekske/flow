import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/drink_log.dart';
import '../../helpers/stats_helper.dart';
import '../../logic/bloc/log_bloc.dart';
import '../dialogs/urine_dialog.dart';
import '../dialogs/drink_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _showUrineDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UrineDialog(),
    );
    if (result != null && context.mounted) {
      context.read<LogBloc>().add(
        AddUrineLogEvent(color: result['color'], amount: result['amount']),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toilet visit logged!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _showIntakeDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const DrinkDialog(),
    );
    if (result != null && context.mounted) {
      context.read<LogBloc>().add(
        AddDrinkLogEvent(fluidType: result['type'], volume: result['volume']),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fluid intake logged!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        final urineLogs = state.urineLogs;
        final drinkLogs = state.drinkLogs;
        final now = state.now;
        final todayStr = DateFormat('yyyy-MM-dd').format(now);

        final todayUrineLogs = urineLogs
            .where(
              (l) => DateFormat('yyyy-MM-dd').format(l.createdAt) == todayStr,
            )
            .toList();

        final todayDrinkLogs = drinkLogs
            .where(
              (l) => DateFormat('yyyy-MM-dd').format(l.createdAt) == todayStr,
            )
            .toList();

        // --- Toilet Metrics ---
        final todayToiletCount = todayUrineLogs.length;
        final lastToilet = urineLogs.isNotEmpty ? urineLogs.first : null;
        final lastToiletTime = lastToilet != null
            ? DateFormat('HH:mm').format(lastToilet.createdAt)
            : '--:--';

        final dailyStats = StatsHelper.calculateStats(todayUrineLogs, now: now);
        final globalStats = StatsHelper.calculateStats(urineLogs, now: null);

        final hasTodayData = todayUrineLogs.isNotEmpty;
        final displayRate = hasTodayData
            ? dailyStats['rate']!
            : globalStats['rate']!;

        // --- Intake Metrics ---
        final todayDrinkVol = todayDrinkLogs.whereType<DrinkLog>().fold(
          0,
          (sum, l) => sum + (l.volume ?? 0),
        );

        final lastDrink = drinkLogs.isNotEmpty ? drinkLogs.first : null;
        final lastDrinkTime = lastDrink != null
            ? DateFormat('HH:mm').format(lastDrink.createdAt)
            : '--:--';

        final goalLiters = state.dailyGoal;
        final currentLiters = todayDrinkVol / 1000.0;
        // Clamp progress to prevent bar overflow if goal is exceeded
        final progress = (goalLiters > 0)
            ? (currentLiters / goalLiters).clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toilet Card (Amber)
              GestureDetector(
                onTap: () => _showUrineDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Toilet Visits",
                            style: TextStyle(
                              color: Color(0xFFFFFBEB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$todayToiletCount",
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "LAST VISIT",
                                style: TextStyle(
                                  color: Color(0xFFFFFBEB),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    lastToiletTime,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "VISIT RATE",
                                style: const TextStyle(
                                  color: Color(0xFFFFFBEB),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    displayRate,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "/ hr",
                                    style: TextStyle(
                                      color: Color(0xFFFFFBEB),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Intake Card (Blue)
              GestureDetector(
                onTap: () => _showIntakeDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF22D3EE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Fluid Intake",
                            style: TextStyle(
                              color: Color(0xFFDBEAFE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            currentLiters.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "/ ${goalLiters.toStringAsFixed(1)} L",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFFDBEAFE),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black26,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "LAST CONSUMPTION",
                            style: TextStyle(
                              color: Color(0xFFFFFBEB),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lastDrinkTime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
