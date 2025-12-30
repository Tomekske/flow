import 'package:flow/data/models/urination_stats.dart';
import 'package:flow/presentation/watch/widgets/urine_wear_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../helpers/stats_helper.dart';
import '../../../logic/bloc/log_bloc.dart';
import '../mobile/widgets/urine_card.dart';

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

          // Calculate Stats
          final dailyUrinationStats = StatsHelper.getUrinationStats(
            todayUrineLogs,
            now: now,
          );

          return Center(
            child: UrineWearCard(
              stats: dailyUrinationStats,
              onTap: () => print("Add Urine log"),
            ),
          );
        },
      ),
    );
  }
}
