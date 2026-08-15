import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/event_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return Center(
              child: Text('Event not found.', style: AppTextStyles.titleMedium),
            );
          }

          final displayDate = DateFormat('EEEE, MMMM d, yyyy \n h:mm a').format(event.date);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                backgroundColor: AppColors.cream,
                elevation: 0,
                iconTheme: const IconThemeData(color: AppColors.brandInk),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.brandInk),
                    onPressed: () {
                      context.push('/event/${event.id}/edit');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusDeclined),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Event'),
                          content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
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

                      if (confirmed == true && context.mounted) {
                        await ref.read(eventControllerProvider.notifier).deleteEvent(event.id);
                        if (context.mounted) {
                          context.go('/dashboard');
                        }
                      }
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
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
                          border: Border.all(color: AppColors.divider),
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
                              await launchUrl(url);
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
                  ]),
                ),
              ),
            ],
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
