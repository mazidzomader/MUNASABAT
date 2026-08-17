import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'event_provider.dart';
import 'checklist_provider.dart';
import 'expense_provider.dart';

class DashboardStats {
  final double tasksDonePercent;
  final int budgetUsed;

  const DashboardStats({
    this.tasksDonePercent = 0.0,
    this.budgetUsed = 0,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final eventsList = ref.watch(hostEventsProvider).valueOrNull ?? [];
  
  if (eventsList.isEmpty) return const DashboardStats();

  int totalTasks = 0;
  int completedTasks = 0;
  int totalSpent = 0;

  for (final event in eventsList) {
    final checklist = ref.watch(checklistProvider(event.id)).valueOrNull ?? [];
    totalTasks += checklist.length;
    completedTasks += checklist.where((c) => c.isCompleted).length;

    final expenses = ref.watch(expensesProvider(event.id)).valueOrNull ?? [];
    totalSpent += expenses.fold<int>(0, (sum, exp) => sum + exp.amount);
  }

  final double percent = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks);
  
  return DashboardStats(
    tasksDonePercent: percent,
    budgetUsed: totalSpent,
  );
});
