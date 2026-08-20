import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../providers/expense_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final expensesAsync = ref.watch(expensesProvider(eventId));
    final expenseController = ref.watch(expenseControllerProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.brandInk),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Budget Tracker',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
        ),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: expenseController.isLoading,
        child: eventAsync.when(
          data: (event) {
            if (event == null) return const Center(child: Text('Event not found.'));
            return expensesAsync.when(
              data: (expenses) {
                final totalSpent = expenses.fold<int>(0, (sum, item) => sum + item.amount);
                return _buildBody(context, ref, event, expenses, totalSpent);
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
              error: (err, _) => Center(child: Text('Error: $err')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: GradientButton(
          label: 'Add Expense',
          icon: Icons.add_rounded,
          onPressed: () => _showAddExpenseModal(context, ref),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, EventModel event, List expenses, int totalSpent) {
    final formatCurrency = NumberFormat.simpleCurrency(decimalDigits: 0);
    
    return Column(
      children: [
        _buildSummaryCard(context, ref, event, totalSpent, formatCurrency),
        Expanded(
          child: expenses.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 80),
                  itemCount: expenses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = expenses[index];
                    return _buildExpenseTile(context, ref, item, formatCurrency);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, WidgetRef ref, EventModel event, int totalSpent, NumberFormat format) {
    final budget = event.totalBudget ?? 0;
    final remaining = budget - totalSpent;
    final progress = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = remaining < 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentBlueSoft.withAlpha(127),
            AppColors.surface,
            AppColors.accentPinkSoft.withAlpha(127),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.brandInk, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Budget',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.charcoal, letterSpacing: 1.2),
              ),
              GestureDetector(
                onTap: () => _showSetBudgetModal(context, ref, event),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withAlpha(200),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded, color: AppColors.brandInk, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.totalBudget == null ? 'Not Set' : format.format(budget),
            style: AppTextStyles.displayLarge.copyWith(color: AppColors.brandInk, fontSize: 36, height: 1.1),
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface.withAlpha(200),
              color: isOverBudget ? AppColors.statusDeclined : AppColors.brandInk,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format.format(totalSpent),
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format.format(remaining),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isOverBudget ? AppColors.statusDeclined : AppColors.brandInk,
                      fontWeight: isOverBudget ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.statusPending.withAlpha(50),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandInk, width: 1),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: AppColors.statusPending,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No expenses yet',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brandInk),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your event spending by adding your first expense.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTile(BuildContext context, WidgetRef ref, expense, NumberFormat format) {
    IconData icon;
    Color iconColor;
    
    switch (expense.category) {
      case 'Venue':
        icon = Icons.location_city_rounded;
        iconColor = AppColors.accentBlue;
        break;
      case 'Catering':
        icon = Icons.restaurant_rounded;
        iconColor = AppColors.statusPending;
        break;
      case 'Decor':
        icon = Icons.celebration_rounded;
        iconColor = AppColors.accentPink;
        break;
      case 'Photography':
        icon = Icons.camera_alt_rounded;
        iconColor = AppColors.brandInkLight;
        break;
      case 'Attire':
        icon = Icons.checkroom_rounded;
        iconColor = AppColors.stone;
        break;
      default:
        icon = Icons.receipt_long_rounded;
        iconColor = AppColors.charcoal;
    }

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(expenseControllerProvider(eventId).notifier).deleteExpense(expense.id);
      },
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.statusDeclined,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.surface),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brandInk, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              title: Text(expense.label, style: AppTextStyles.titleMedium),
              subtitle: Text(
                expense.category,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone),
              ),
              trailing: Text(
                format.format(expense.amount),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.brandInk,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSetBudgetModal(BuildContext context, WidgetRef ref, EventModel event) {
    final controller = TextEditingController(text: event.totalBudget?.toString() ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set Total Budget', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money_rounded),
                hintText: 'Enter total budget',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final val = int.tryParse(controller.text.trim());
                if (val != null) {
                  final updated = event.copyWith(totalBudget: val);
                  await ref.read(eventControllerProvider.notifier).updateEvent(updated);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandInk,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Save Budget', style: AppTextStyles.button.copyWith(color: AppColors.surface)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context, WidgetRef ref) {
    final labelController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Other';
    final categories = ['Venue', 'Catering', 'Decor', 'Photography', 'Attire', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add Expense', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 24),
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      hintText: 'What was this for?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      hintText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final label = labelController.text.trim();
                      final amount = int.tryParse(amountController.text.trim());
                      
                      if (label.isEmpty || amount == null || amount <= 0) {
                        return; // Add simple validation or error message
                      }
                      
                      ref.read(expenseControllerProvider(eventId).notifier).addExpense(
                        label: label,
                        category: selectedCategory,
                        amount: amount,
                      );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandInk,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Add Expense', style: AppTextStyles.button.copyWith(color: AppColors.surface)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
