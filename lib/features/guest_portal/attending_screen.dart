import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/event_provider.dart';
import '../../providers/guest_provider.dart';

class AttendingScreen extends ConsumerWidget {
  const AttendingScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final guestStatusAsync = ref.watch(currentGuestStatusProvider(eventId));
    final allGuestsAsync = ref.watch(guestsProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return Center(
              child: Text('Event not found.', style: AppTextStyles.titleMedium),
            );
          }

          final displayDate = DateFormat('EEEE, MMMM d, yyyy \n h:mm a').format(event.date).toUpperCase();

          return guestStatusAsync.when(
            data: (currentGuest) {
              final isPending = currentGuest?.status == 'requested';

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 0,
                    pinned: true,
                    backgroundColor: AppColors.cream,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: AppColors.brandInk),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.brandInk),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (isPending)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.statusPending.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.statusPending, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_empty_rounded, color: AppColors.statusPending),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your request is pending host approval. You will see more options once approved.',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brandInk),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          event.title,
                          style: AppTextStyles.displayLarge.copyWith(color: AppColors.brandInk),
                        ),
                        const SizedBox(height: 24),
                        _InfoRow(
                          icon: Icons.calendar_month_rounded,
                          text: displayDate,
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          text: event.venueName,
                        ),
                        if (event.venueLatLng != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.brandInk, width: 1),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(event.venueLatLng!['lat']!, event.venueLatLng!['lng']!),
                                initialZoom: 14,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.munasabat',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(event.venueLatLng!['lat']!, event.venueLatLng!['lng']!),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: AppColors.statusDeclined,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: InkWell(
                              onTap: () async {
                                final lat = event.venueLatLng!['lat'];
                                final lng = event.venueLatLng!['lng'];
                                final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.map_rounded, size: 16, color: AppColors.accentBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Open in Maps',
                                    style: AppTextStyles.link.copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (event.description != null && event.description!.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Text('About this event', style: AppTextStyles.titleLarge),
                          const SizedBox(height: 12),
                          Text(
                            event.description!,
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.charcoal),
                          ),
                        ],
                        const SizedBox(height: 40),
                        Text('Guests Attending', style: AppTextStyles.titleLarge),
                        const SizedBox(height: 12),
                        allGuestsAsync.when(
                          data: (guests) {
                            final attendingGuests = guests.where((g) => g.status == 'accepted').toList();

                            if (attendingGuests.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.brandInk, width: 1),
                                ),
                                child: Text(
                                  'No guests have joined yet.',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: attendingGuests.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final guest = attendingGuests[index];
                                final isMe = currentGuest?.id == guest.id;

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.brandInk, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isMe ? AppColors.accentBlue.withAlpha(20) : AppColors.brandInk.withAlpha(10),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          guest.name.substring(0, 1).toUpperCase(),
                                          style: AppTextStyles.titleMedium.copyWith(
                                            color: isMe ? AppColors.accentBlue : AppColors.brandInk,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          isMe ? '${guest.name} (You)' : guest.name,
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
                          error: (err, _) => Text('Failed to load guests: $err'),
                        ),
                        const SizedBox(height: 32),
                        if (currentGuest?.status == 'accepted' || currentGuest?.status == 'checked_in') ...[
                          GradientButton(
                            label: 'Send a Wedding Gift',
                            icon: Icons.card_giftcard_rounded,
                            onPressed: () {
                              context.push('/event/${event.id}/gifts/send');
                            },
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            label: 'View Event Gallery',
                            icon: Icons.photo_library_rounded,
                            onPressed: () {
                              context.push('/event/${event.id}/memories');
                            },
                          ),
                        ],
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
            error: (err, _) => Center(
              child: Text('Error loading guest status: $err', style: AppTextStyles.bodyMedium),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandInk)),
        error: (err, _) => Center(
          child: Text('Error loading event: $err', style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accentBlue, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}
