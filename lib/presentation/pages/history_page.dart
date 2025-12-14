import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/bloc/log_bloc.dart';
import '../dialogs/confirm_dialog.dart';
import '../dialogs/toilet_dialog.dart';
import '../dialogs/intake_dialog.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _showEditDialog(BuildContext context, dynamic log) async {
    final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => log.type == 'toilet' ? ToiletDialog(existingLog: log) : IntakeDialog(existingLog: log)
    );

    if (result != null && context.mounted) {
      // Construct updated log based on type
      final updatedLog = log.type == 'toilet'
          ? log.copyWith(urineColor: result['color'], urineAmount: result['amount'])
          : log.copyWith(fluidType: result['type'], volume: result['volume']);

      context.read<LogBloc>().add(UpdateLog(updatedLog));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log updated!'), duration: Duration(seconds: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("History", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), if (state.logs.isNotEmpty) TextButton(onPressed: () async { final confirm = await showConfirmDialog(context, title: "Clear All?", content: "This cannot be undone.", confirmText: "Clear All", confirmColor: Colors.red); if (confirm == true) { if (context.mounted) context.read<LogBloc>().add(ClearAllLogs()); } }, style: TextButton.styleFrom(backgroundColor: const Color(0xFFFEF2F2), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)), child: const Text("Clear All", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)))]),
              const SizedBox(height: 16),
              Expanded(
                child: state.logs.isEmpty
                    ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history, size: 48, color: Colors.black12), SizedBox(height: 16), Text("No history yet.", style: TextStyle(color: Colors.black26))]))
                    : ListView.builder(
                  itemCount: state.logs.length,
                  itemBuilder: (ctx, index) {
                    final log = state.logs[index];
                    final isToilet = log.type == 'toilet';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
                      child: Row(
                        children: [
                          // Icon Box
                          Container(
                              width: 40, height: 40,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(color: isToilet ? Colors.amber.shade50 : Colors.blue.shade50, shape: BoxShape.circle),
                              child: Icon(isToilet ? Icons.water_drop : Icons.local_drink, color: isToilet ? Colors.amber.shade700 : Colors.blue.shade700, size: 20)
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Text(DateFormat('hh:mm a').format(log.timestamp), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155))), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: isToilet ? Colors.amber.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(4)), child: Text(isToilet ? (log.urineAmount ?? '?') : '+ ${log.volume}ml', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isToilet ? Colors.amber.shade700 : Colors.blue.shade700)))]),
                                const SizedBox(height: 4),
                                Text(DateFormat('MMM dd, yyyy').format(log.timestamp), style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                          IconButton(onPressed: () => _showEditDialog(context, log), icon: const Icon(Icons.edit, color: Color(0xFFCBD5E1), size: 20)),
                          IconButton(onPressed: () async { final confirm = await showConfirmDialog(context, title: "Delete?", content: "Remove this entry?", confirmText: "Delete", confirmColor: Colors.red); if (confirm == true) { if (context.mounted) context.read<LogBloc>().add(DeleteLog(log.id)); } }, icon: const Icon(Icons.delete_outline, color: Color(0xFFCBD5E1), size: 20)),
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
