import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_package/core/providers/database_provider.dart';
import 'package:flutter_starter_package/features/auth/data/repositories/user_profile_repository.dart';
import 'package:flutter_starter_package/features/auth/domain/models/user.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';

// Provider for the UserProfileRepository
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return UserProfileRepository(database);
});

// State for user profile
class UserProfileState {
  final bool isLoading;
  final Map<String, dynamic>? profileData;
  final String? error;

  UserProfileState({
    this.isLoading = false,
    this.profileData,
    this.error,
  });

  UserProfileState copyWith({
    bool? isLoading,
    Map<String, dynamic>? profileData,
    String? error,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      profileData: profileData ?? this.profileData,
      error: error,
    );
  }
}

// Notifier for user profile state management
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserProfileRepository _repository;
  final AuthState _authState;

  UserProfileNotifier(this._repository, this._authState)
      : super(UserProfileState()) {
    if (_authState.status == AuthStatus.authenticated && _authState.user != null) {
      loadUserProfile();
    }
  }

  Future<void> loadUserProfile() async {
    if (_authState.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = _authState.user!.id;
      final profileData = await _repository.getUserProfile(userId);
      state = state.copyWith(
        isLoading: false,
        profileData: profileData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_authState.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = _authState.user!.id;
      final updatedProfile = await _repository.updateUserProfile(userId, updates);
      state = state.copyWith(
        isLoading: false,
        profileData: updatedProfile,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadProfilePicture(List<int> fileBytes, String fileExtension) async {
    if (_authState.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = _authState.user!.id;
      final fileUrl = await _repository.uploadProfilePicture(
        userId,
        fileBytes,
        fileExtension,
      );
      
      // Update the state with the new profile picture URL
      final updatedProfileData = Map<String, dynamic>.from(state.profileData ?? {});
      updatedProfileData['avatar_url'] = fileUrl;
      
      state = state.copyWith(
        isLoading: false,
        profileData: updatedProfileData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider for user profile state
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  final authState = ref.watch(authProvider);
  return UserProfileNotifier(repository, authState);
}); 