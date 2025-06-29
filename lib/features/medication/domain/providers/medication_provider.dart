import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/medication_reminder.dart';
import '../repositories/medication_repository.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/repositories/supabase_medication_repository.dart';

// Repository provider
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return SupabaseMedicationRepository();
});

// State class for medication reminders
class MedicationState {
  final List<MedicationReminder> reminders;
  final bool isLoading;
  final String? error;

  MedicationState({
    this.reminders = const [],
    this.isLoading = false,
    this.error,
  });

  MedicationState copyWith({
    List<MedicationReminder>? reminders,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier class for medication reminders
class MedicationNotifier extends StateNotifier<MedicationState> {
  final MedicationRepository _repository;
  final String _userId;

  MedicationNotifier(this._repository, this._userId) : super(MedicationState()) {
    loadMedicationReminders();
  }

  Future<void> loadMedicationReminders() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final reminders = await _repository.getMedicationReminders(_userId);
      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<MedicationReminder?> createMedicationReminder({
    required String medicationName,
    String? description,
    required List<DateTime> reminderTimes,
    required List<int> daysOfWeek,
  }) async {
    try {
      final now = DateTime.now();
      final reminder = MedicationReminder(
        id: const Uuid().v4(),
        userId: _userId,
        medicationName: medicationName,
        description: description,
        reminderTimes: reminderTimes,
        daysOfWeek: daysOfWeek,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final createdReminder = await _repository.createMedicationReminder(reminder);
      
      state = state.copyWith(
        reminders: [createdReminder, ...state.reminders],
      );
      
      return createdReminder;
    } catch (e) {
      debugPrint('Error creating medication reminder: $e');
      return null;
    }
  }

  Future<MedicationReminder?> updateMedicationReminder({
    required String id,
    String? medicationName,
    String? description,
    List<DateTime>? reminderTimes,
    List<int>? daysOfWeek,
    bool? isActive,
  }) async {
    try {
      final reminderIndex = state.reminders.indexWhere((r) => r.id == id);
      if (reminderIndex == -1) return null;
      
      final existingReminder = state.reminders[reminderIndex];
      final updatedReminder = existingReminder.copyWith(
        medicationName: medicationName,
        description: description != null ? () => description : null,
        reminderTimes: reminderTimes,
        daysOfWeek: daysOfWeek,
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
      
      final savedReminder = await _repository.updateMedicationReminder(updatedReminder);
      
      final updatedReminders = [...state.reminders];
      updatedReminders[reminderIndex] = savedReminder;
      
      state = state.copyWith(reminders: updatedReminders);
      
      return savedReminder;
    } catch (e) {
      debugPrint('Error updating medication reminder: $e');
      return null;
    }
  }

  Future<void> deleteMedicationReminder(String id) async {
    try {
      await _repository.deleteMedicationReminder(id);
      
      state = state.copyWith(
        reminders: state.reminders.where((r) => r.id != id).toList(),
      );
    } catch (e) {
      debugPrint('Error deleting medication reminder: $e');
    }
  }

  Future<void> toggleMedicationReminderActive(String id, bool isActive) async {
    try {
      await _repository.toggleMedicationReminderActive(id, isActive);
      
      final updatedReminders = state.reminders.map((reminder) {
        if (reminder.id == id) {
          return reminder.copyWith(isActive: isActive);
        }
        return reminder;
      }).toList();
      
      state = state.copyWith(reminders: updatedReminders);
    } catch (e) {
      debugPrint('Error toggling medication reminder active state: $e');
    }
  }
}

// Provider for medication state
final medicationProvider = StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  final repository = ref.watch(medicationRepositoryProvider);
  final authState = ref.watch(authProvider);
  
  if (authState.user == null) {
    throw Exception('User must be authenticated to access medication reminders');
  }
  
  return MedicationNotifier(repository, authState.user!.id);
}); 