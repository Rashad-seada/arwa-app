import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/eye_scan.dart';
import '../repositories/eye_scan_repository.dart';
import '../../data/repositories/supabase_eye_scan_repository.dart';
import '../../../auth/domain/providers/auth_provider.dart';

// Repository provider
final eyeScanRepositoryProvider = Provider<EyeScanRepository>((ref) {
  return SupabaseEyeScanRepository();
});

// State for eye scans
class EyeScanState {
  final List<EyeScan> scans;
  final bool isLoading;
  final String? error;

  EyeScanState({
    this.scans = const [],
    this.isLoading = false,
    this.error,
  });

  EyeScanState copyWith({
    List<EyeScan>? scans,
    bool? isLoading,
    String? error,
  }) {
    return EyeScanState(
      scans: scans ?? this.scans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider for eye scan state
final eyeScanProvider = StateNotifierProvider<EyeScanNotifier, EyeScanState>((ref) {
  final repository = ref.watch(eyeScanRepositoryProvider);
  final authState = ref.watch(authProvider);
  
  return EyeScanNotifier(repository, authState.user?.id ?? '');
});

// Notifier for eye scan state
class EyeScanNotifier extends StateNotifier<EyeScanState> {
  final EyeScanRepository _repository;
  final String _userId;

  EyeScanNotifier(this._repository, this._userId) : super(EyeScanState()) {
    if (_userId.isNotEmpty) {
      loadEyeScans();
    }
  }

  Future<void> loadEyeScans() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final scans = await _repository.getEyeScans(_userId);
      state = state.copyWith(scans: scans, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load eye scans: $e',
      );
    }
  }

  Future<EyeScan?> createEyeScan({
    required String title,
    String? description,
    required String imagePath,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final newScan = EyeScan(
        id: const Uuid().v4(),
        userId: _userId,
        title: title,
        description: description,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );
      
      final createdScan = await _repository.createEyeScan(newScan);
      
      state = state.copyWith(
        scans: [createdScan, ...state.scans],
        isLoading: false,
      );
      
      return createdScan;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create eye scan: $e',
      );
      return null;
    }
  }

  Future<bool> updateEyeScan(EyeScan scan) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final updatedScan = await _repository.updateEyeScan(scan);
      
      state = state.copyWith(
        scans: state.scans.map((s) => s.id == updatedScan.id ? updatedScan : s).toList(),
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update eye scan: $e',
      );
      return false;
    }
  }

  Future<bool> deleteEyeScan(String scanId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _repository.deleteEyeScan(scanId);
      
      state = state.copyWith(
        scans: state.scans.where((scan) => scan.id != scanId).toList(),
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete eye scan: $e',
      );
      return false;
    }
  }
} 