import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/medication_reminder.dart';
import '../../domain/repositories/medication_repository.dart';

class SupabaseMedicationRepository implements MedicationRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'medication_reminders';
  
  @override
  Future<List<MedicationReminder>> getMedicationReminders(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => MedicationReminder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching medication reminders: $e');
      throw Exception('Failed to fetch medication reminders');
    }
  }

  @override
  Future<MedicationReminder> getMedicationReminderById(String reminderId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', reminderId)
          .single();
      
      return MedicationReminder.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching medication reminder: $e');
      throw Exception('Failed to fetch medication reminder');
    }
  }

  @override
  Future<MedicationReminder> createMedicationReminder(MedicationReminder reminder) async {
    try {
      final data = reminder.toJson();
      
      final response = await _client
          .from(_tableName)
          .insert(data)
          .select()
          .single();
      
      return MedicationReminder.fromJson(response);
    } catch (e) {
      debugPrint('Error creating medication reminder: $e');
      throw Exception('Failed to create medication reminder: $e');
    }
  }

  @override
  Future<MedicationReminder> updateMedicationReminder(MedicationReminder reminder) async {
    try {
      final data = reminder.toJson();
      
      final response = await _client
          .from(_tableName)
          .update(data)
          .eq('id', reminder.id)
          .select()
          .single();
      
      return MedicationReminder.fromJson(response);
    } catch (e) {
      debugPrint('Error updating medication reminder: $e');
      throw Exception('Failed to update medication reminder');
    }
  }

  @override
  Future<void> deleteMedicationReminder(String reminderId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', reminderId);
    } catch (e) {
      debugPrint('Error deleting medication reminder: $e');
      throw Exception('Failed to delete medication reminder');
    }
  }
  
  @override
  Future<void> toggleMedicationReminderActive(String reminderId, bool isActive) async {
    try {
      await _client
          .from(_tableName)
          .update({'is_active': isActive})
          .eq('id', reminderId);
    } catch (e) {
      debugPrint('Error toggling medication reminder active state: $e');
      throw Exception('Failed to toggle medication reminder active state');
    }
  }
} 