import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/models/medication_reminder.dart';
import '../../../../core/theme/app_colors.dart';

class MedicationReminderCard extends StatelessWidget {
  final MedicationReminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggleActive;

  const MedicationReminderCard({
    Key? key,
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: reminder.isActive 
              ? Colors.transparent 
              : AppColors.muted.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Opacity(
        opacity: reminder.isActive ? 1.0 : 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with medication name and actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      reminder.medicationName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Switch(
                    value: reminder.isActive,
                    onChanged: onToggleActive,
                    activeColor: AppColors.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    tooltip: 'medication.edit'.tr(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    tooltip: 'medication.delete'.tr(),
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Reminder details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                    Text(
                      reminder.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Reminder times
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatReminderTimes(reminder.reminderTimes),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Days of week
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDaysOfWeek(reminder.daysOfWeek, context),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatReminderTimes(List<DateTime> times) {
    final timeFormat = DateFormat.jm();
    if (times.isEmpty) return 'medication.no_times'.tr();
    
    if (times.length <= 3) {
      return times.map((time) => timeFormat.format(time)).join(', ');
    } else {
      return '${times.length} ${'medication.times_per_day'.tr()}';
    }
  }

  String _formatDaysOfWeek(List<int> days, BuildContext context) {
    if (days.isEmpty) return 'medication.no_days'.tr();
    
    if (days.length == 7) {
      return 'medication.every_day'.tr();
    }
    
    final dayNames = [
      'medication.monday'.tr(),
      'medication.tuesday'.tr(),
      'medication.wednesday'.tr(),
      'medication.thursday'.tr(),
      'medication.friday'.tr(),
      'medication.saturday'.tr(),
      'medication.sunday'.tr(),
    ];
    
    if (days.length <= 3) {
      return days.map((day) => dayNames[day - 1]).join(', ');
    } else {
      return '${days.length} ${'medication.days_per_week'.tr()}';
    }
  }
} 