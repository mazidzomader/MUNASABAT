import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/event_provider.dart';

class InvitationScreen extends ConsumerWidget {
  const InvitationScreen({super.key, required this.eventId});
  
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

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
          'Share Invitation',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
        ),
        centerTitle: true,
      ),
      body: eventAsync.when(
        data: (event) {
          if (event == null) return const Center(child: Text('Event not found.'));
          
          final eventCode = event.eventCode ?? 'NO-CODE';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.brandInk, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandInk.withAlpha(20),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty)
                              Container(
                                height: 160,
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: NetworkImage(event.coverImageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Text(
                              event.title,
                              style: AppTextStyles.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(event.date),
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.venueName,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.brandInk, width: 1),
                              ),
                              child: QrImageView(
                                data: eventCode,
                                version: QrVersions.auto,
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: AppColors.brandInk,
                                ),
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: AppColors.brandInk,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    final shareText = "You're invited to ${event.title}!\n\n"
                        "Date: ${DateFormat('EEEE, MMMM d, yyyy').format(event.date)}\n"
                        "Venue: ${event.venueName}\n\n"
                        "Download the Munasabat app and enter code to join:\n"
                        "$eventCode";
                    Share.share(shareText);
                  },
                  icon: const Icon(Icons.share_rounded, color: AppColors.surface),
                  label: Text('Share Invitation', style: AppTextStyles.button.copyWith(color: AppColors.surface)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandInk,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
