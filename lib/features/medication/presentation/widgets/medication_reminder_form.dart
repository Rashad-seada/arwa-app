import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class MedicationReminderForm extends StatefulWidget {
  final ScrollController scrollController;
  final String? initialMedicationName;
  final String? initialDescription;
  final List<DateTime>? initialReminderTimes;
  final List<int>? initialDaysOfWeek;
  final bool isEditing;
  final Function(String, String?, List<DateTime>, List<int>) onSave;

  const MedicationReminderForm({
    Key? key,
    required this.scrollController,
    this.initialMedicationName,
    this.initialDescription,
    this.initialReminderTimes,
    this.initialDaysOfWeek,
    this.isEditing = false,
    required this.onSave,
  }) : super(key: key);

  @override
  State<MedicationReminderForm> createState() => _MedicationReminderFormState();
}

class _MedicationReminderFormState extends State<MedicationReminderForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _medicationNameController;
  late TextEditingController _descriptionController;
  late List<DateTime> _reminderTimes;
  late List<int> _selectedDays;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _medicationNameController = TextEditingController(text: widget.initialMedicationName ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _reminderTimes = widget.initialReminderTimes?.toList() ?? [DateTime(2022, 1, 1, 8, 0)];
    _selectedDays = widget.initialDaysOfWeek?.toList() ?? [1, 2, 3, 4, 5, 6, 7]; // Default to all days
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form title
            Center(
              child: Text(
                widget.isEditing 
                    ? 'medication.edit_reminder'.tr() 
                    : 'medication.add_reminder'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Medication name field
            TextFormField(
              controller: _medicationNameController,
              decoration: InputDecoration(
                labelText: 'medication.medication_name'.tr(),
                hintText: 'medication.medication_name_hint'.tr(),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'medication.medication_name_required'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'medication.description'.tr(),
                hintText: 'medication.description_hint'.tr(),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Reminder times section
            Text(
              'medication.reminder_times'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Reminder times list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reminderTimes.length,
              itemBuilder: (context, index) {
                return _buildTimeItem(index);
              },
            ),
            
            // Add time button
            TextButton.icon(
              onPressed: _addReminderTime,
              icon: const Icon(Icons.add),
              label: Text('medication.add_time'.tr()),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Days of week section
            Text(
              'medication.days_of_week'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Days of week selection
            _buildDaySelector(),
            const SizedBox(height: 32),
            
            // Submit button
            PrimaryButton(
              onPressed: _isSubmitting ? null : _submitForm,
              text: widget.isEditing 
                  ? 'medication.update'.tr() 
                  : 'medication.save'.tr(),
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeItem(int index) {
    final time = _reminderTimes[index];
    final timeFormat = DateFormat.jm();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    timeFormat.format(time),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _selectTime(index),
          ),
          if (_reminderTimes.length > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeReminderTime(index),
              color: AppColors.error,
            ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = [
      'medication.monday_short'.tr(),
      'medication.tuesday_short'.tr(),
      'medication.wednesday_short'.tr(),
      'medication.thursday_short'.tr(),
      'medication.friday_short'.tr(),
      'medication.saturday_short'.tr(),
      'medication.sunday_short'.tr(),
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = _selectedDays.contains(dayNumber);
        
        return InkWell(
          onTap: () => _toggleDay(dayNumber),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _selectTime(int index) async {
    final currentTime = _reminderTimes[index];
    final TimeOfDay initialTime = TimeOfDay(
      hour: currentTime.hour,
      minute: currentTime.minute,
    );
    
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      setState(() {
        _reminderTimes[index] = DateTime(
          2022, 1, 1, 
          pickedTime.hour, 
          pickedTime.minute,
        );
      });
    }
  }

  void _addReminderTime() {
    setState(() {
      // Default to next hour from the last time
      final lastTime = _reminderTimes.last;
      final newHour = (lastTime.hour + 1) % 24;
      _reminderTimes.add(DateTime(2022, 1, 1, newHour, 0));
    });
  }

  void _removeReminderTime(int index) {
    setState(() {
      _reminderTimes.removeAt(index);
    });
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_reminderTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('medication.time_required'.tr())),
        );
        return;
      }
      
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('medication.day_required'.tr())),
        );
        return;
      }
      
      setState(() {
        _isSubmitting = true;
      });
      
      // Sort days and times for consistency
      _selectedDays.sort();
      _reminderTimes.sort((a, b) => a.hour * 60 + a.minute - (b.hour * 60 + b.minute));
      
      widget.onSave(
        _medicationNameController.text,
        _descriptionController.text.isEmpty ? null : _descriptionController.text,
        _reminderTimes,
        _selectedDays,
      );
    }
  }
} 