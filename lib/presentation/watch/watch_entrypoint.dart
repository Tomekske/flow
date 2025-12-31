import 'package:flow/presentation/watch/pages/drink_wear_entry.dart';
import 'package:flow/presentation/watch/pages/urine_log_entry_page.dart';
import 'package:flow/presentation/watch/widgets/drink_wear_card.dart';
import 'package:flow/presentation/watch/widgets/urine_wear_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../helpers/stats_helper.dart';
import '../../../logic/bloc/log_bloc.dart';

class WatchEntrypoint extends StatelessWidget {
  const WatchEntrypoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<LogBloc, LogState>(
        builder: (context, state) {
          final urineLogs = state.urineLogs;
          final drinkLogs = state.drinkLogs;
          final now = state.now;
          final todayStr = DateFormat('yyyy-MM-dd').format(now);

          // Filter logs
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

          // Calculate Stats
          final dailyUrinationStats = StatsHelper.getUrinationStats(
            todayUrineLogs,
            now: now,
          );

          final dailyDrinkStats = StatsHelper.getDrinkingStats(
            todayDrinkLogs,
            now: now,
          );

          // Calculate Progress
          final goalLiters = state.dailyGoal;
          final progress = (goalLiters > 0)
              ? (dailyDrinkStats.total / goalLiters).clamp(0.0, 1.0)
              : 0.0;

          return PageView(
            scrollDirection: Axis.vertical,
            children: [
              Center(
                child: UrineWearCard(
                  stats: dailyUrinationStats,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UrineLogEntryPage(),
                      ),
                    );

                    if (result != null && context.mounted) {
                      context.read<LogBloc>().add(
                        AddUrineLogEvent(
                          color: result['color'],
                          amount: result['amount'],
                          urgency: result['urgency'],
                          createdAt: result['created_at'],
                        ),
                      );
                    }
                  },
                ),
              ),
              Center(
                child: DrinkWearCard(
                  stats: dailyDrinkStats,
                  goalLiters: goalLiters,
                  progress: progress,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DrinkWearEntry()),
                    );

                    if (result != null && context.mounted) {
                      context.read<LogBloc>().add(
                        AddDrinkLogEvent(
                          fluidType: result['type'],
                          volume: result['volume'],
                          createdAt: result['created_at'],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
