import '../models/medication_reminder.dart';

abstract class MedicationRepository {
  Future<List<MedicationReminder>> getMedicationReminders(String userId);
  
  Future<MedicationReminder> getMedicationReminderById(String reminderId);
  
  Future<MedicationReminder> createMedicationReminder(MedicationReminder reminder);
  
  Future<MedicationReminder> updateMedicationReminder(MedicationReminder reminder);
  
  Future<void> deleteMedicationReminder(String reminderId);
  
  Future<void> toggleMedicationReminderActive(String reminderId, bool isActive);
} 