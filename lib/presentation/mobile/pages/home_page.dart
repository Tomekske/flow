import 'package:flow/data/models/urination_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../helpers/stats_helper.dart';
import '../../../logic/bloc/log_bloc.dart';
import '../dialogs/drink_dialog.dart';
import '../dialogs/urine_dialog.dart';
import '../widgets/drink_card.dart';
import '../widgets/urine_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _showUrineDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UrineDialog(),
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
        AddDrinkLogEvent(
          fluidType: result['type'],
          volume: result['volume'],
          createdAt: result['created_at'],
        ),
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

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UrineCard(
                stats: dailyUrinationStats,
                onTap: () => _showUrineDialog(context),
              ),
              const SizedBox(
                height: 24,
              ),
              DrinkCard(
                stats: dailyDrinkStats,
                goalLiters: goalLiters,
                progress: progress,
                onTap: () => _showIntakeDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
