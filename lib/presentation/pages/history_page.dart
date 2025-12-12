import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/bloc/log_bloc.dart';
import '../../helpers/stats_helper.dart';
import '../dialogs/confirm_dialog.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("History Log", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  if (state.logs.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                         final confirm = await showConfirmDialog(context, title: "Clear All?", content: "This cannot be undone.", confirmText: "Clear All", confirmColor: Colors.red);
                         if (confirm == true) {
                           context.read<LogBloc>().add(ClearAllLogs());
                         }
                      },
                      style: TextButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                      child: const Text("Clear All", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: state.logs.isEmpty
                    ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.assignment_outlined, size: 48, color: Colors.black12), SizedBox(height: 16), Text("No logs found yet.", style: TextStyle(color: Colors.black26))]))
                    : ListView.builder(
                        itemCount: state.logs.length,
                        itemBuilder: (ctx, index) {
                          final log = state.logs[index];
                          // Interval from NEXT log (which is older)
                          String? intervalBadge;
                          if (index < state.logs.length - 1) {
                             final olderLog = state.logs[index + 1];
                             final diff = log.timestamp.difference(olderLog.timestamp);
                             if (diff.inMinutes > 0) intervalBadge = StatsHelper.formatInterval(diff);
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
                            child: Row(
                              children: [
                                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.check, color: Color(0xFF2563EB), size: 20)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(DateFormat('hh:mm a').format(log.timestamp), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155))),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(DateFormat('MMM dd, yyyy').format(log.timestamp), style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                          if (intervalBadge != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                              child: Row(children: [const Icon(Icons.timer_outlined, size: 10, color: Color(0xFF94A3B8)), const SizedBox(width: 2), Text(intervalBadge, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold))]),
                                            )
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final confirm = await showConfirmDialog(context, title: "Delete Log?", content: "Remove this entry?", confirmText: "Delete", confirmColor: Colors.red);
                                    if (confirm == true) {
                                      context.read<LogBloc>().add(DeleteLog(log.id));
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFCBD5E1)),
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
