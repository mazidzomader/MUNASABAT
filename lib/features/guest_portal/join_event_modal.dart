import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/guest_provider.dart';

void showJoinEventModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return const JoinEventModal();
    },
  );
}

class JoinEventModal extends ConsumerStatefulWidget {
  const JoinEventModal({super.key});

  @override
  ConsumerState<JoinEventModal> createState() => _JoinEventModalState();
}

class _JoinEventModalState extends ConsumerState<JoinEventModal> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    ref.read(joinEventControllerProvider.notifier).joinEvent(code);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(joinEventControllerProvider);

    ref.listen<AsyncValue<void>>(
      joinEventControllerProvider,
      (previous, next) {
        next.when(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Join request sent successfully!')),
            );
            Navigator.pop(context);
          },
          loading: () {},
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          },
        );
      },
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Join Event', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-character event code provided by the host.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g., MNSB-A1B2C3',
              prefixIcon: const Icon(Icons.vpn_key_rounded),
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
            onPressed: state.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandInk,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2),
                  )
                : Text('Send Join Request', style: AppTextStyles.button.copyWith(color: AppColors.surface)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
