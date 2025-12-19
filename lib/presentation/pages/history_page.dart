import 'package:flow/data/models/urine_log_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/drink_log_entry.dart';
import '../../logic/bloc/log_bloc.dart';
import '../dialogs/confirm_dialog.dart';
import '../dialogs/drink_dialog.dart';
import '../dialogs/urine_dialog.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  /// Handles opening the edit dialog for either log type.
  /// Using dynamic here allows flexibility, but type checks ensure safety.
  Future<void> _showEditDialog(BuildContext context, dynamic log) async {
    Widget dialog;

    if (log is UrineLogEntry) {
      dialog = UrineDialog(existingLog: log);
    } else if (log is DrinkLogEntry) {
      dialog = DrinkDialog(existingLog: log);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown log type')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => dialog,
    );

    if (result != null && context.mounted) {
      if (log is UrineLogEntry) {
        final updatedUrineLog = log.copyWith(
          color: result['color'],
          amount: result['amount'],
          createdAt: result['created_at'],
        );
        context.read<LogBloc>().add(UpdateUrineLogEvent(updatedUrineLog));
      } else if (log is DrinkLogEntry) {
        final updatedDrinkLog = log.copyWith(
          fluidType: result['type'],
          volume: result['volume'],
          createdAt: result['created_at'],
        );
        context.read<LogBloc>().add(UpdateDrinkLogEvent(updatedDrinkLog));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log updated!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Ensure these lists in your State are typed correctly or cast appropriately
        final urineLogs = state.urineLogs;
        final drinkLogs = state.drinkLogs;

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "History",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: isDark
                        ? Colors.blueAccent.withValues(alpha: 0.4)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                            ),
                          ],
                  ),
                  labelColor: isDark ? Colors.white : Colors.black,
                  unselectedLabelColor: Colors.grey,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Toilet"),
                    Tab(text: "Drinks"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLogList(context, urineLogs, isDark),
                    _buildLogList(context, drinkLogs, isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogList(BuildContext context, List<dynamic> logs, bool isDark) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              "No logs yet.",
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      itemCount: logs.length,
      itemBuilder: (ctx, index) {
        final log = logs[index];
        final isToilet = log is UrineLogEntry;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.transparent : const Color(0xFFF1F5F9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Box
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isToilet
                      ? (isDark
                            ? Colors.amber.withValues(alpha: 0.2)
                            : Colors.amber.shade50)
                      : (isDark
                            ? Colors.blue.withValues(alpha: 0.2)
                            : Colors.blue.shade50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isToilet ? Icons.water_drop : Icons.local_drink,
                  color: isToilet
                      ? (isDark ? Colors.amberAccent : Colors.amber.shade700)
                      : (isDark ? Colors.blueAccent : Colors.blue.shade700),
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isToilet
                              ? "Toilet Visit"
                              : (log is DrinkLogEntry)
                              ? (log.fluidType)
                              : "Unknown",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isToilet
                                ? (isDark
                                      ? Colors.amber.withValues(alpha: 0.2)
                                      : Colors.amber.shade50)
                                : (isDark
                                      ? Colors.blue.withValues(alpha: 0.2)
                                      : Colors.blue.shade50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isToilet
                                ? ((log).amount)
                                : '+${(log as DrinkLogEntry).volume}ml',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isToilet
                                  ? (isDark
                                        ? Colors.amberAccent
                                        : Colors.amber.shade700)
                                  : (isDark
                                        ? Colors.blueAccent
                                        : Colors.blue.shade700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${DateFormat('yyyy-MM-dd').format(log.createdAt)} • ${DateFormat('HH:mm').format(log.createdAt)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey[400]
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showEditDialog(context, log),
                icon: Icon(
                  Icons.edit,
                  color: isDark ? Colors.grey[500] : const Color(0xFFCBD5E1),
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final confirm = await showConfirmDialog(
                    context,
                    title: "Delete?",
                    content: "Remove this entry?",
                    confirmText: "Delete",
                    confirmColor: Colors.red,
                  );
                  if (confirm == true) {
                    if (context.mounted) {
                      if (log is UrineLogEntry) {
                        context.read<LogBloc>().add(DeleteUrineLog(log.id));
                      } else {
                        context.read<LogBloc>().add(DeleteDrinkLog(log.id));
                      }
                    }
                  }
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: isDark ? Colors.grey[500] : const Color(0xFFCBD5E1),
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
