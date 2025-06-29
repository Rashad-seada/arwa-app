import '../models/eye_scan.dart';

abstract class EyeScanRepository {
  Future<List<EyeScan>> getEyeScans(String userId);
  Future<EyeScan> getEyeScanById(String scanId);
  Future<EyeScan> createEyeScan(EyeScan scan);
  Future<EyeScan> updateEyeScan(EyeScan scan);
  Future<void> deleteEyeScan(String scanId);
} 