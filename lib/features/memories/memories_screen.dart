import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../repositories/memory_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../repositories/premium_repository.dart';

class MemoriesScreen extends ConsumerWidget {
  final String eventId;

  const MemoriesScreen({super.key, required this.eventId});

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      final user = ref.read(currentUserModelProvider).valueOrNull;
      if (user == null) return;

      // Read file bytes and convert to Base64
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Show uploading indicator
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading photo...'), duration: Duration(seconds: 2)),
      );

      try {
        final repo = ref.read(memoryRepositoryProvider);
        await repo.uploadMemory(base64String, eventId, user);
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(eventMemoriesProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brandInk),
        title: Text('Event Gallery', style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Consumer(builder: (context, ref, _) {
            final memories = ref.watch(eventMemoriesProvider(eventId)).valueOrNull ?? [];
            final premiumStatus = ref.watch(eventPremiumProvider(eventId)).valueOrNull;
            final imageLimit = premiumStatus?.imageLimit ?? 5;
            final count = memories.length;
            final progress = (count / imageLimit).clamp(0.0, 1.0);
            final isAtLimit = count >= imageLimit;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$count / $imageLimit photos',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isAtLimit ? AppColors.statusDeclined : AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isAtLimit)
                        Text('Full', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.statusDeclined, fontWeight: FontWeight.bold))
                      else
                        Text('${imageLimit - count} left', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isAtLimit ? AppColors.statusDeclined : AppColors.brandInk,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      floatingActionButton: Consumer(builder: (context, ref, _) {
        final memories = ref.watch(eventMemoriesProvider(eventId)).valueOrNull ?? [];
        final premiumStatus = ref.watch(eventPremiumProvider(eventId)).valueOrNull;
        final imageLimit = premiumStatus?.imageLimit ?? 5;
        final isLimitReached = memories.length >= imageLimit;

        if (isLimitReached) {
          return FloatingActionButton.extended(
            onPressed: () => context.push('/event/$eventId/premium'),
            backgroundColor: AppColors.stone,
            icon: const Icon(Icons.lock_rounded, color: Colors.white),
            label: Text('Upgrade to Upload', style: AppTextStyles.button.copyWith(color: Colors.white)),
          );
        }

        return FloatingActionButton.extended(
          onPressed: () => _pickAndUploadImage(context, ref),
          backgroundColor: AppColors.brandInk,
          icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
          label: Text('Upload', style: AppTextStyles.button.copyWith(color: Colors.white)),
        );
      }),
      body: memoriesAsync.when(
        data: (memories) {
          final premiumStatus = ref.watch(eventPremiumProvider(eventId)).valueOrNull;
          final imageLimit = premiumStatus?.imageLimit ?? 5;
          final isLimitReached = memories.length >= imageLimit;

          // Determine if the current user is the event host
          final currentUser = ref.watch(currentUserModelProvider).valueOrNull;
          final event = ref.watch(eventDetailProvider(eventId)).valueOrNull;
          final isHost = currentUser != null && event != null && event.hostId == currentUser.id;

          if (memories.isEmpty) {
            return const Center(
              child: Text(
                'No photos yet.\nBe the first to upload a memory!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.stone, fontSize: 16),
              ),
            );
          }

          final grid = GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return GestureDetector(
                onTap: () {
                  context.push('/event/$eventId/memories/viewer', extra: {
                    'memories': memories,
                    'initialIndex': index,
                  });
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(memory.base64Data),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.stone.withAlpha(50),
                          child: const Icon(Icons.broken_image, color: AppColors.stone),
                        ),
                      ),
                    ),
                    // Delete button — only shown to the host
                    if (isHost)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Photo'),
                                content: const Text('Remove this photo from the gallery?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => ctx.pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => ctx.pop(true),
                                    child: const Text('Delete', style: TextStyle(color: AppColors.statusDeclined)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await ref.read(memoryRepositoryProvider).deleteMemory(eventId, memory.id);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(160),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
          
          return Column(
            children: [
              if (isLimitReached)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColors.statusDeclined.withAlpha(20),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.statusDeclined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Gallery limit reached ($imageLimit/$imageLimit). Upgrade to Premium to upload more.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.statusDeclined),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/event/$eventId/premium'),
                        child: const Text('UPGRADE', style: TextStyle(color: AppColors.statusDeclined, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              Expanded(child: grid),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
