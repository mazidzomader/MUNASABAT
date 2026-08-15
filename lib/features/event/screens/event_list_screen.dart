import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/event_provider.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(hostEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brandInk),
        title: Text(
          'Your Events',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brandInk),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/event/create'),
        backgroundColor: AppColors.brandInk,
        child: const Icon(Icons.add, color: AppColors.surface),
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy_rounded, size: 64, color: AppColors.stone),
                    const SizedBox(height: 16),
                    Text(
                      'No events found',
                      style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to create your first event.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () => context.push('/event/${event.id}'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.accentBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                DateFormat('MMMM d, yyyy • h:mm a').format(event.date),
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.charcoal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
        error: (err, _) => Center(child: Text('Error loading events: $err')),
      ),
    );
  }
}
