import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_snackbar.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../models/checklist_item_model.dart';
import '../../providers/checklist_provider.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;
    
    ref.read(checklistControllerProvider(widget.eventId).notifier).addItem(title);
    _taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors when modifying checklist
    ref.listen<AsyncValue<void>>(
      checklistControllerProvider(widget.eventId),
      (prev, next) {
        next.whenOrNull(
          error: (error, _) => showErrorSnackbar(context, error.toString()),
        );
      },
    );

    final checklistAsync = ref.watch(checklistProvider(widget.eventId));
    final controllerState = ref.watch(checklistControllerProvider(widget.eventId));
    
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
          'Checklist',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
        ),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: controllerState.isLoading,
        child: checklistAsync.when(
          data: (items) {
            final completedCount = items.where((i) => i.isCompleted).length;
            final totalCount = items.length;
            final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

            return Column(
              children: [
                _buildProgressBar(completedCount, totalCount, progress),
                Expanded(
                  child: items.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _ChecklistItemTile(
                              item: item,
                              onToggle: () => ref
                                  .read(checklistControllerProvider(widget.eventId).notifier)
                                  .toggleItemCompletion(item),
                              onDelete: () => ref
                                  .read(checklistControllerProvider(widget.eventId).notifier)
                                  .deleteItem(item.id),
                            );
                          },
                        ),
                ),
                _buildAddBar(),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.brandInk),
          ),
          error: (err, _) => Center(
            child: Text('Error: $err', style: AppTextStyles.bodyMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int completed, int total, double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.brandInk, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks Completed',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.brandInk),
              ),
              Text(
                '$completed / $total',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              color: AppColors.statusAccepted,
              minHeight: 12,
            ),
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
                color: AppColors.accentBlueSoft.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checklist_rounded,
                size: 64,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks yet',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brandInk),
            ),
            const SizedBox(height: 8),
            Text(
              'Add tasks below to start planning your event.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Add a new task...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone),
                filled: true,
                fillColor: AppColors.cream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.brandInk, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.brandInk),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _addTask(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _addTask,
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: AppColors.brandInk,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.surface),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItemTile extends StatelessWidget {
  const _ChecklistItemTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final ChecklistItemModel item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.statusDeclined,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.surface),
      ),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.brandInk, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onToggle,
        leading: GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isCompleted ? AppColors.statusAccepted : Colors.transparent,
                border: Border.all(
                  color: item.isCompleted ? AppColors.statusAccepted : AppColors.stone,
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check_rounded, size: 16, color: AppColors.surface)
                  : null,
            ),
          ),
          title: Text(
            item.title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: item.isCompleted ? AppColors.stone : AppColors.ink,
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }
}
