import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_snackbar.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';

// =============================================================================
// 1. CREATE EVENT SCREEN
// =============================================================================

/// Screen for creating a new wedding event.
class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _venueLatLng;

  @override
  void dispose() {
    _titleController.dispose();
    _venueNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandInk,
              onPrimary: AppColors.surface,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 18, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.brandInk,
                onPrimary: AppColors.surface,
                onSurface: AppColors.ink,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  Future<void> _pickLocation() async {
    final result =
        await context.push<LatLng?>('/location-picker', extra: _venueLatLng);
    if (result != null && mounted) {
      setState(() {
        _venueLatLng = result;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      showErrorSnackbar(context, 'Please select a date and time.');
      return;
    }

    final finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    await ref.read(eventControllerProvider.notifier).createEvent(
          title: _titleController.text.trim(),
          date: finalDateTime,
          venueName: _venueNameController.text.trim(),
          description: _descriptionController.text.trim(),
          venueLatLng: _venueLatLng != null
              ? {'lat': _venueLatLng!.latitude, 'lng': _venueLatLng!.longitude}
              : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(eventControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) => showErrorSnackbar(context, error.toString()),
        data: (_) {
          showSuccessSnackbar(context, 'Event created successfully!');
          context.pop();
        },
      );
    });

    final isLoading = ref.watch(eventControllerProvider).isLoading;
    final displayDate = _selectedDate != null && _selectedTime != null
        ? '${DateFormat('MMM d, yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}'
        : 'Select Date & Time';

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.brandInk,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Create Event',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Let\'s set up your special day.',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.brandInk,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _titleController,
                  label: 'Event Title',
                  hint: 'e.g. Sarah & John\'s Wedding',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.brandInk, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.brandInk,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          displayDate,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _selectedDate == null
                                ? AppColors.stone
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _venueNameController,
                  label: 'Venue Name',
                  hint: 'e.g. The Grand Hotel',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Venue is required' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.brandInk, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.brandInk, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          _venueLatLng != null
                              ? 'Location Selected'
                              : 'Pick Location on Map (Optional)',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _venueLatLng == null
                                ? AppColors.stone
                                : AppColors.statusAccepted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  hint: 'Add some details about your event...',
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                PrimaryButton(label: 'Create Event', onPressed: _submit),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 2. EDIT EVENT SCREEN
// =============================================================================

/// Screen for updating an existing wedding event.
class EditEventScreen extends ConsumerStatefulWidget {
  const EditEventScreen({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _venueLatLng;
  bool _isInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _venueNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeData(EventModel event) {
    if (_isInitialized) return;
    _titleController.text = event.title;
    _venueNameController.text = event.venueName;
    _descriptionController.text = event.description ?? '';
    _selectedDate = event.date;
    _selectedTime = TimeOfDay.fromDateTime(event.date);
    if (event.venueLatLng != null) {
      _venueLatLng =
          LatLng(event.venueLatLng!['lat']!, event.venueLatLng!['lng']!);
    }
    _isInitialized = true;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandInk,
              onPrimary: AppColors.surface,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.brandInk,
                onPrimary: AppColors.surface,
                onSurface: AppColors.ink,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  Future<void> _pickLocation() async {
    final result =
        await context.push<LatLng?>('/location-picker', extra: _venueLatLng);
    if (result != null && mounted) {
      setState(() {
        _venueLatLng = result;
      });
    }
  }

  void _submit(EventModel existingEvent) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      showErrorSnackbar(context, 'Please select a date and time.');
      return;
    }

    final finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final updatedEvent = EventModel(
      id: existingEvent.id,
      hostId: existingEvent.hostId,
      title: _titleController.text.trim(),
      date: finalDateTime,
      venueName: _venueNameController.text.trim(),
      description: _descriptionController.text.trim(),
      venueLatLng: _venueLatLng != null
          ? {'lat': _venueLatLng!.latitude, 'lng': _venueLatLng!.longitude}
          : null,
      coverImageUrl: existingEvent.coverImageUrl,
      totalBudget: existingEvent.totalBudget,
      createdAt: existingEvent.createdAt,
      privacy: existingEvent.privacy,
    );

    await ref.read(eventControllerProvider.notifier).updateEvent(updatedEvent);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(eventControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (error, _) => showErrorSnackbar(context, error.toString()),
        data: (_) {
          showSuccessSnackbar(context, 'Event updated successfully!');
          context.pop();
        },
      );
    });

    final isLoading = ref.watch(eventControllerProvider).isLoading;
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));

    return eventAsync.when(
      data: (event) {
        if (event == null) {
          return const Scaffold(body: Center(child: Text('Event not found.')));
        }

        // Initialize controllers with existing data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeData(event);
        });

        final displayDate = _selectedDate != null && _selectedTime != null
            ? '${DateFormat('MMM d, yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}'
            : 'Select Date & Time';

        return LoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            backgroundColor: AppColors.cream,
            appBar: AppBar(
              backgroundColor: AppColors.cream,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.brandInk),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Edit Event',
                style:
                    AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Update event details',
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: AppColors.brandInk),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _titleController,
                      label: 'Event Title',
                      hint: 'e.g. Sarah & John\'s Wedding',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.brandInk, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined,
                                color: AppColors.brandInk, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              displayDate,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: _selectedDate == null
                                    ? AppColors.stone
                                    : AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _venueNameController,
                      label: 'Venue Name',
                      hint: 'e.g. The Grand Hotel',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Venue is required' : null,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickLocation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.brandInk, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: AppColors.brandInk, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _venueLatLng != null
                                    ? 'Location Selected'
                                    : 'Pick Location on Map (Optional)',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: _venueLatLng == null
                                      ? AppColors.stone
                                      : AppColors.statusAccepted,
                                ),
                              ),
                            ),
                            if (_venueLatLng != null)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.close_rounded,
                                    color: AppColors.stone, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _venueLatLng = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      hint: 'Add some details about your event...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                        label: 'Update Event',
                        onPressed: () => _submit(event)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

// =============================================================================
// 3. EVENT DETAIL SCREEN
// =============================================================================

/// Screen displaying the full details of an event with mini-map and edit/delete actions.
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

          final displayDate =
              DateFormat('EEEE, MMMM d, yyyy \n h:mm a').format(event.date);

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
                    icon: const Icon(Icons.edit_rounded,
                        color: AppColors.brandInk),
                    onPressed: () {
                      context.push('/event/${event.id}/edit');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.statusDeclined),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Event'),
                          content: const Text(
                              'Are you sure you want to delete this event? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => ctx.pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => ctx.pop(true),
                              child: const Text('Delete',
                                  style: TextStyle(
                                      color: AppColors.statusDeclined)),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        await ref
                            .read(eventControllerProvider.notifier)
                            .deleteEvent(event.id);
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
                      style: AppTextStyles.displayLarge
                          .copyWith(color: AppColors.brandInk),
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
                    if (event.eventCode != null) ...[
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.qr_code_rounded,
                        text: 'Event Code: ${event.eventCode}',
                      ),
                    ],
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
                            initialCenter: LatLng(event.venueLatLng!['lat']!,
                                event.venueLatLng!['lng']!),
                            initialZoom: 14,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.munasabat',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(event.venueLatLng!['lat']!,
                                      event.venueLatLng!['lng']!),
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
                            final url = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.map_rounded,
                                  size: 16, color: AppColors.accentBlue),
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
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text('About this event',
                          style: AppTextStyles.titleLarge),
                      const SizedBox(height: 12),
                      Text(
                        event.description!,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.charcoal),
                      ),
                    ],
                    const SizedBox(height: 40),
                    PrimaryButton(
                      label: 'Manage Checklist',
                      onPressed: () {
                        context.push('/event/${event.id}/checklist');
                      },
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Manage Budget',
                      onPressed: () {
                        context.push('/event/${event.id}/budget');
                      },
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Manage Guests',
                      onPressed: () {
                        context.push('/event/${event.id}/guests');
                      },
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Share Invitation',
                      onPressed: () {
                        context.push('/event/${event.id}/invitation');
                      },
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.brandInk)),
        error: (err, _) => Center(
          child: Text('Error loading event: $err',
              style: AppTextStyles.bodyMedium),
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

// =============================================================================
// 4. EVENT LIST SCREEN
// =============================================================================

/// Screen listing all events hosted by the current user.
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
          style:
              AppTextStyles.headlineMedium.copyWith(color: AppColors.brandInk),
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
                    const Icon(Icons.event_busy_rounded,
                        size: 64, color: AppColors.stone),
                    const SizedBox(height: 16),
                    Text(
                      'No events found',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.brandInk),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to create your first event.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.charcoal),
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
                    border: Border.all(color: AppColors.brandInk, width: 1),
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
                          style: AppTextStyles.titleLarge
                              .copyWith(color: AppColors.brandInk),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 16, color: AppColors.accentBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                DateFormat('MMMM d, yyyy • h:mm a')
                                    .format(event.date),
                                style: AppTextStyles.bodyLarge
                                    .copyWith(color: AppColors.charcoal),
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
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.brandInk)),
        error: (err, _) => Center(child: Text('Error loading events: $err')),
      ),
    );
  }
}

// =============================================================================
// 5. LOCATION PICKER SCREEN
// =============================================================================

/// Interactive OpenStreetMap picker with Nominatim venue search.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  final LatLng? initialLocation;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  static const LatLng _defaultLocation = LatLng(25.2048, 55.2708);

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');
      final response = await http
          .get(url, headers: {'User-Agent': 'com.example.munasabat'});
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _onResultTapped(dynamic result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final newLocation = LatLng(lat, lon);

    setState(() {
      _selectedLocation = newLocation;
      _searchResults = [];
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });

    _mapController.move(newLocation, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.brandInk),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pick Venue Location',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.brandInk),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? _defaultLocation,
              initialZoom: 13,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.munasabat',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
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
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for a place...',
                      hintStyle: AppTextStyles.hint,
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.stone),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.brandInk),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      color: AppColors.stone),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          title: Text(
                            result['display_name'],
                            style: AppTextStyles.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: const Icon(Icons.location_on_outlined,
                              color: AppColors.stone),
                          onTap: () => _onResultTapped(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (_selectedLocation != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () => context.pop(_selectedLocation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandInk,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Confirm Location',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
