import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_snackbar.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/event_model.dart';
import '../../../providers/event_provider.dart';

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
      _venueLatLng = LatLng(event.venueLatLng!['lat']!, event.venueLatLng!['lng']!);
    }
    _isInitialized = true;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
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
    final result = await context.push<LatLng?>('/location-picker', extra: _venueLatLng);
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

    final updatedEvent = existingEvent.copyWith(
      title: _titleController.text.trim(),
      date: finalDateTime,
      venueName: _venueNameController.text.trim(),
      description: _descriptionController.text.trim(),
      venueLatLng: _venueLatLng != null 
          ? {'lat': _venueLatLng!.latitude, 'lng': _venueLatLng!.longitude} 
          : null,
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
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.brandInk),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Edit Event',
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
                      'Update event details',
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brandInk),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _titleController,
                      label: 'Event Title',
                      hint: 'e.g. Sarah & John\'s Wedding',
                      validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, color: AppColors.brandInk, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              displayDate,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: _selectedDate == null ? AppColors.stone : AppColors.ink,
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
                      validator: (v) => v == null || v.isEmpty ? 'Venue is required' : null,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickLocation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppColors.brandInk, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              _venueLatLng != null ? 'Location Selected' : 'Pick Location on Map (Optional)',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: _venueLatLng == null ? AppColors.stone : AppColors.statusAccepted,
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
                    PrimaryButton(label: 'Update Event', onPressed: () => _submit(event)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
