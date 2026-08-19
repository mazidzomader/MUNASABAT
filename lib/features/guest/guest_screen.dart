import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../models/event_model.dart';
import '../../models/guest_model.dart';
import '../../providers/event_provider.dart';
import '../../providers/guest_provider.dart';
import '../../repositories/premium_repository.dart';

class GuestScreen extends ConsumerStatefulWidget {
  const GuestScreen({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends ConsumerState<GuestScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final guestsAsync = ref.watch(guestsProvider(widget.eventId));
    final guestController = ref.watch(guestControllerProvider(widget.eventId));

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
          'Guest List',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
        ),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: guestController.isLoading,
        child: eventAsync.when(
          data: (event) {
            if (event == null) return const Center(child: Text('Event not found.'));
            return guestsAsync.when(
              data: (guests) {
                final filteredGuests = guests.where((g) {
                  final query = _searchQuery.toLowerCase();
                  return g.name.toLowerCase().contains(query) ||
                      (g.phone?.toLowerCase().contains(query) ?? false) ||
                      (g.email?.toLowerCase().contains(query) ?? false);
                }).toList();

                final pendingRequests = filteredGuests.where((g) => g.status == 'requested').toList();
                final otherGuests = filteredGuests.where((g) => g.status != 'requested').toList();

                return _buildBody(context, event, pendingRequests, otherGuests, guests.length);
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
              error: (err, _) => Center(child: Text('Error: $err')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: Consumer(builder: (context, ref, _) {
        final guests = ref.watch(guestsProvider(widget.eventId)).valueOrNull ?? [];
        final premiumStatus = ref.watch(eventPremiumProvider(widget.eventId)).valueOrNull;
        final hasUnlimited = premiumStatus?.unlockedFeatures.contains('unlimited_guests') ?? false;
        
        final isLimitReached = !hasUnlimited && guests.length >= 20;

        return FloatingActionButton.extended(
          onPressed: isLimitReached ? () {
            context.push('/event/${widget.eventId}/premium');
          } : () => _showGuestModal(context, ref, isEdit: false),
          backgroundColor: isLimitReached ? AppColors.stone : AppColors.brandInk,
          icon: Icon(isLimitReached ? Icons.lock_rounded : Icons.person_add_alt_1_rounded, color: AppColors.surface),
          label: Text(isLimitReached ? 'Upgrade to Add' : 'Add Guest', style: AppTextStyles.button.copyWith(color: AppColors.surface)),
        );
      }),
    );
  }

  Widget _buildBody(BuildContext context, EventModel event, List<GuestModel> requests, List<GuestModel> others, int totalGuests) {
    final premiumStatus = ref.watch(eventPremiumProvider(widget.eventId)).valueOrNull;
    final hasUnlimited = premiumStatus?.unlockedFeatures.contains('unlimited_guests') ?? false;
    final isLimitReached = !hasUnlimited && totalGuests >= 20;

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
                    'Guest limit reached (20/20). Upgrade to Premium to invite unlimited guests.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.statusDeclined),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/event/${widget.eventId}/premium'),
                  child: const Text('UPGRADE', style: TextStyle(color: AppColors.statusDeclined, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        _buildSummaryAndSearch(totalGuests),
        Expanded(
          child: (requests.isEmpty && others.isEmpty)
              ? _buildEmptyState(totalGuests == 0)
              : ListView(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 80),
                  children: [
                    if (requests.isNotEmpty) ...[
                      Text('Join Requests', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                      ...requests.map((guest) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildRequestTile(context, ref, guest),
                          )),
                      const SizedBox(height: 24),
                    ],
                    if (others.isNotEmpty) ...[
                      if (requests.isNotEmpty)
                        Text('Guest List', style: AppTextStyles.titleMedium),
                      if (requests.isNotEmpty)
                        const SizedBox(height: 12),
                      ...others.map((guest) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildGuestTile(context, ref, guest),
                          )),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryAndSearch(int totalGuests) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                'Total Guests',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.ink),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandInk,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalGuests',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.surface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search guests by name, phone, or email...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandInk),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.brandInk),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.cream,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isCompletelyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandInk, width: 1),
              ),
              child: Icon(
                isCompletelyEmpty ? Icons.people_outline_rounded : Icons.search_off_rounded,
                size: 64,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isCompletelyEmpty ? 'No guests yet' : 'No guests found',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brandInk),
            ),
            const SizedBox(height: 8),
            Text(
              isCompletelyEmpty
                  ? 'Start building your guest list to send out invitations and track RSVPs.'
                  : 'Try adjusting your search query.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestTile(BuildContext context, WidgetRef ref, GuestModel guest) {
    Color statusColor;
    String statusLabel;
    
    switch (guest.status) {
      case 'accepted':
        statusColor = AppColors.statusAccepted;
        statusLabel = 'Attending';
        break;
      case 'declined':
        statusColor = AppColors.statusDeclined;
        statusLabel = 'Declined';
        break;
      case 'checked_in':
        statusColor = AppColors.brandInk;
        statusLabel = 'Checked In';
        break;
      default:
        statusColor = AppColors.statusPending;
        statusLabel = 'Pending';
    }

    return Dismissible(
      key: Key(guest.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(guestControllerProvider(widget.eventId).notifier).deleteGuest(guest.id);
      },
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
          onTap: () => _showGuestModal(context, ref, isEdit: true, existingGuest: guest),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brandInk, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.brandInk),
            ),
          ),
          title: Text(guest.name, style: AppTextStyles.titleMedium),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (guest.phone != null && guest.phone!.isNotEmpty)
                Text(guest.phone!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone)),
              if (guest.email != null && guest.email!.isNotEmpty)
                Text(guest.email!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone)),
            ],
          ),
          trailing: guest.status == 'accepted'
              ? ElevatedButton(
                  onPressed: () {
                    final updated = GuestModel(
                      id: guest.id,
                      name: guest.name,
                      phone: guest.phone,
                      email: guest.email,
                      status: 'checked_in',
                      invitationId: guest.invitationId,
                      checkedInAt: DateTime.now(),
                    );
                    ref.read(guestControllerProvider(widget.eventId).notifier).updateGuest(updated);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandInk,
                    foregroundColor: AppColors.surface,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Check In', style: AppTextStyles.labelSmall.copyWith(color: AppColors.surface)),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRequestTile(BuildContext context, WidgetRef ref, GuestModel guest) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.accentBlue, width: 2), // Highlight requests
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentBlue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guest.name, style: AppTextStyles.titleMedium),
                      if (guest.phone != null && guest.phone!.isNotEmpty)
                        Text(guest.phone!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                       ref.read(guestControllerProvider(widget.eventId).notifier).deleteGuest(guest.id);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusDeclined,
                      side: const BorderSide(color: AppColors.statusDeclined),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Reject', style: AppTextStyles.button.copyWith(color: AppColors.statusDeclined)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                       final updated = GuestModel(
                          id: guest.id,
                          name: guest.name,
                          phone: guest.phone,
                          email: guest.email,
                          status: 'accepted',
                       );
                       ref.read(guestControllerProvider(widget.eventId).notifier).updateGuest(updated);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusAccepted,
                      foregroundColor: AppColors.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Approve', style: AppTextStyles.button.copyWith(color: AppColors.surface)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestModal(BuildContext context, WidgetRef ref, {required bool isEdit, GuestModel? existingGuest}) {
    final nameController = TextEditingController(text: existingGuest?.name ?? '');
    final phoneController = TextEditingController(text: existingGuest?.phone ?? '');
    final emailController = TextEditingController(text: existingGuest?.email ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
              Text(isEdit ? 'Edit Guest' : 'Add Guest', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
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
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number (Optional)',
                  prefixIcon: const Icon(Icons.phone_outlined),
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
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email Address (Optional)',
                  prefixIcon: const Icon(Icons.email_outlined),
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
                onPressed: () {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final email = emailController.text.trim();
                  
                  if (name.isEmpty) return; // Add simple validation or error message
                  
                  if (isEdit && existingGuest != null) {
                    final updated = GuestModel(
                      id: existingGuest.id,
                      name: name,
                      phone: phone.isEmpty ? null : phone,
                      email: email.isEmpty ? null : email,
                      status: existingGuest.status,
                      invitationId: existingGuest.invitationId,
                      checkedInAt: existingGuest.checkedInAt,
                    );
                    ref.read(guestControllerProvider(widget.eventId).notifier).updateGuest(updated);
                  } else {
                    ref.read(guestControllerProvider(widget.eventId).notifier).addGuest(
                      name: name,
                      phone: phone.isEmpty ? null : phone,
                      email: email.isEmpty ? null : email,
                    );
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandInk,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEdit ? 'Save Changes' : 'Add Guest', style: AppTextStyles.button.copyWith(color: AppColors.surface)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
