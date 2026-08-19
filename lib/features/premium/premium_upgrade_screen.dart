import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/error_snackbar.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/services/stripe_service.dart';
import '../../repositories/premium_repository.dart';

class PremiumUpgradeScreen extends ConsumerStatefulWidget {
  final String eventId;

  const PremiumUpgradeScreen({super.key, required this.eventId});

  @override
  ConsumerState<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends ConsumerState<PremiumUpgradeScreen> {
  bool _isLoading = false;

  Future<void> _handleCheckout(String productType, int amountCents) async {
    setState(() => _isLoading = true);

    try {
      // 1. Create Payment Intent
      final clientSecret = await StripeService.instance.createPaymentIntent(amountCents, 'usd');
      if (clientSecret == null) {
        if (mounted) showErrorSnackbar(context, 'Failed to create payment intent');
        return;
      }

      final paymentIntentId = clientSecret.split('_secret_')[0];

      // 2. Initialize Payment Sheet
      final initSuccess = await StripeService.instance.initPaymentSheet(clientSecret, 'Munasabat Premium');
      if (!initSuccess) {
        if (mounted) showErrorSnackbar(context, 'Failed to initialize payment sheet.');
        return;
      }

      bool paymentSucceeded = false;
      try {
        // 3. Present Payment Sheet
        paymentSucceeded = await StripeService.instance.presentPaymentSheet();
      } catch (_) {
        // On some Android configurations, flutter_stripe throws even when payment
        // actually succeeded. Verify directly via the Stripe API as a fallback.
        final status = await StripeService.instance.checkPaymentIntentStatus(paymentIntentId);
        paymentSucceeded = (status == 'succeeded');
      }

      if (paymentSucceeded) {
        // 4. Update Firestore
        if (productType == 'guests') {
          await ref.read(premiumRepositoryProvider).purchaseUnlimitedGuests(widget.eventId, paymentIntentId);
          if (mounted) showSuccessSnackbar(context, 'Unlimited Guests unlocked! 🎉');
        } else if (productType == 'images') {
          await ref.read(premiumRepositoryProvider).purchaseImagePack(widget.eventId, paymentIntentId);
          if (mounted) showSuccessSnackbar(context, '+100 Image Pack added! 🎉');
        }
      } else {
        if (mounted) showErrorSnackbar(context, 'Payment was canceled.');
      }
    } catch (e) {
      if (mounted) showErrorSnackbar(context, 'Payment error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final premiumStatus = ref.watch(eventPremiumProvider(widget.eventId)).valueOrNull;
    final hasUnlimitedGuests = premiumStatus?.unlockedFeatures.contains('unlimited_guests') ?? false;
    final imageLimit = premiumStatus?.imageLimit ?? 5;

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.brandInk),
          title: Text('Premium Upgrade', style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.workspace_premium_rounded, size: 80, color: AppColors.accentPink),
              const SizedBox(height: 16),
              Text(
                'Upgrade Your Event',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayLarge.copyWith(color: AppColors.brandInk),
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock advanced features to make your wedding truly unforgettable.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.charcoal),
              ),
              const SizedBox(height: 48),

              // Guests Package
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brandInk, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Unlimited Guests', style: AppTextStyles.headlineMedium),
                        Text('\$9.99', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.statusAccepted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Remove the 20 guest limit and invite everyone.', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 16),
                    hasUnlimitedGuests
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.statusAccepted.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Unlocked', textAlign: TextAlign.center, style: TextStyle(color: AppColors.statusAccepted, fontWeight: FontWeight.bold)),
                          )
                        : PrimaryButton(
                            label: 'Buy Now',
                            onPressed: () => _handleCheckout('guests', 999),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Images Package
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brandInk, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('+100 Image Pack', style: AppTextStyles.headlineMedium),
                        Text('\$9.99', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.statusAccepted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Increase your gallery limit by 100 photos. (Current limit: $imageLimit)', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Buy Now',
                      onPressed: () => _handleCheckout('images', 999),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
