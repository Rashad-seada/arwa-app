import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/medication_reminder.dart';
import '../../domain/providers/medication_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/medication_reminder_card.dart';
import '../widgets/medication_reminder_form.dart';

class MedicationRemindersScreen extends ConsumerStatefulWidget {
  const MedicationRemindersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicationRemindersScreen> createState() => _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends ConsumerState<MedicationRemindersScreen> {
  @override
  void initState() {
    super.initState();
    // Load reminders when the screen is first opened
    Future.microtask(() => ref.read(medicationProvider.notifier).loadMedicationReminders());
  }

  @override
  Widget build(BuildContext context) {
    final medicationState = ref.watch(medicationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('medication.title'.tr()),
        elevation: 0,
      ),
      body: _buildBody(medicationState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(MedicationState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('medication.error_loading'.tr()),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () => ref.read(medicationProvider.notifier).loadMedicationReminders(),
              text: 'medication.try_again'.tr(),
            ),
          ],
        ),
      );
    }
    
    if (state.reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 64,
              color: AppColors.muted,
            ),
            const SizedBox(height: 16),
            Text(
              'medication.no_reminders'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'medication.create_first_reminder'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () => _showAddReminderDialog(context),
              text: 'medication.add_reminder'.tr(),
              icon: Icons.add,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.reminders.length,
      itemBuilder: (context, index) {
        final reminder = state.reminders[index];
        return MedicationReminderCard(
          reminder: reminder,
          onEdit: () => _showEditReminderDialog(context, reminder),
          onDelete: () => _confirmDeleteReminder(context, reminder),
          onToggleActive: (isActive) {
            ref.read(medicationProvider.notifier).toggleMedicationReminderActive(
              reminder.id, 
              isActive,
            );
          },
        );
      },
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: MedicationReminderForm(
                scrollController: scrollController,
                onSave: (medicationName, description, reminderTimes, daysOfWeek) async {
                  Navigator.pop(context);
                  await ref.read(medicationProvider.notifier).createMedicationReminder(
                    medicationName: medicationName,
                    description: description,
                    reminderTimes: reminderTimes,
                    daysOfWeek: daysOfWeek,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showEditReminderDialog(BuildContext context, MedicationReminder reminder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: MedicationReminderForm(
                scrollController: scrollController,
                initialMedicationName: reminder.medicationName,
                initialDescription: reminder.description,
                initialReminderTimes: reminder.reminderTimes,
                initialDaysOfWeek: reminder.daysOfWeek,
                isEditing: true,
                onSave: (medicationName, description, reminderTimes, daysOfWeek) async {
                  Navigator.pop(context);
                  await ref.read(medicationProvider.notifier).updateMedicationReminder(
                    id: reminder.id,
                    medicationName: medicationName,
                    description: description,
                    reminderTimes: reminderTimes,
                    daysOfWeek: daysOfWeek,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteReminder(BuildContext context, MedicationReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('medication.confirm_delete'.tr()),
        content: Text('medication.delete_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('medication.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(medicationProvider.notifier).deleteMedicationReminder(reminder.id);
            },
            child: Text(
              'medication.delete'.tr(),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
} 