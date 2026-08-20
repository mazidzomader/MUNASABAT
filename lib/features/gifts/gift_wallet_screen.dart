import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../repositories/gift_repository.dart';

class GiftWalletScreen extends ConsumerWidget {
  final String eventId;

  const GiftWalletScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final giftsAsync = ref.watch(eventGiftsProvider(eventId));
    final withdrawalsAsync = ref.watch(eventWithdrawalsProvider(eventId));

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
          'Gift Wallet',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
        ),
        centerTitle: true,
      ),
      body: giftsAsync.when(
        data: (gifts) {
          return withdrawalsAsync.when(
            data: (withdrawals) {
              final totalAmount = gifts.fold<int>(0, (sum, item) => sum + item.amount).toDouble();
              final platformFee = totalAmount * 0.10;
              final netHostAmount = totalAmount * 0.90;
              final totalWithdrawn = withdrawals.fold<int>(0, (sum, item) => sum + item.amount).toDouble();
              final availableBalance = netHostAmount - totalWithdrawn;

              return Column(
                children: [
                  // Dashboard Header
                  Container(
                    width: double.infinity,
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
                      children: [
                        Text(
                          'Available Balance',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${availableBalance.toStringAsFixed(2)}',
                          style: AppTextStyles.displayLarge.copyWith(
                            color: AppColors.brandInk,
                            fontSize: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Total Received',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.charcoal),
                                ),
                                Text(
                                  '\$${totalAmount.toStringAsFixed(2)}',
                                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.brandInk),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: AppColors.brandInk.withAlpha(50),
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Platform Fee (10%)',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.charcoal),
                                ),
                                Text(
                                  '\$${platformFee.toStringAsFixed(2)}',
                                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.brandInk),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: availableBalance > 0
                              ? () => _showWithdrawDialog(context, ref, availableBalance)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandInk,
                            foregroundColor: AppColors.surface,
                            disabledBackgroundColor: AppColors.surface.withAlpha(128),
                            disabledForegroundColor: AppColors.brandInk.withAlpha(128),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  
                  // Gifts List
                  Expanded(
                    child: gifts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.card_giftcard_rounded, size: 64, color: AppColors.stone),
                                const SizedBox(height: 16),
                                Text(
                                  'No gifts received yet',
                                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brandInk),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(24),
                            itemCount: gifts.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final gift = gifts[index];
                              final displayName = gift.isAnonymous || gift.displayName == null ? 'Anonymous' : gift.displayName!;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.brandInk, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: AppColors.accentBlue.withAlpha(20),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.person_rounded, color: AppColors.accentBlue, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              displayName,
                                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.brandInk),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '\$${gift.amount.toStringAsFixed(2)}',
                                          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.statusAccepted),
                                        ),
                                      ],
                                    ),
                                    if (gift.message != null && gift.message!.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.cream,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '"${gift.message}"',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.charcoal,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Text(
                                      DateFormat('MMM d, yyyy • h:mm a').format(gift.createdAt ?? DateTime.now()),
                                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.stone),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
            error: (err, _) => Center(child: Text('Error loading withdrawals: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
        error: (err, _) => Center(child: Text('Error loading gifts: $err')),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref, double availableBalance) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Withdraw Funds', style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk)),
        content: Text(
          'Are you sure you want to withdraw \$${availableBalance.toStringAsFixed(2)}? \n\n(Note: This is a simulated transaction for sandbox mode.)',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.stone)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                // Call repository to record the withdrawal
                await ref.read(giftRepositoryProvider).withdrawFunds(eventId, availableBalance.toInt());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Withdrawal successful! (Simulated)')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error during withdrawal: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandInk,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm Withdrawal'),
          ),
        ],
      ),
    );
  }
}
