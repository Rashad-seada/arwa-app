import 'package:flutter_starter_package/core/services/supabase_database.dart';
import 'package:flutter_starter_package/features/auth/domain/models/user.dart';

class UserProfileRepository {
  final SupabaseDatabase _database;
  static const String _tableName = 'profiles';
  
  UserProfileRepository(this._database);
  
  // Get user profile by ID
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      return await _database.getById(_tableName, userId);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }
  
  // Create or update user profile
  Future<Map<String, dynamic>> saveUserProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      // Ensure the ID field is set correctly
      profileData['id'] = userId;
      
      // Use upsert to create or update the profile
      return await _database.upsert(_tableName, profileData);
    } catch (e) {
      throw Exception('Failed to save user profile: ${e.toString()}');
    }
  }
  
  // Update user profile fields
  Future<Map<String, dynamic>> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      return await _database.update(_tableName, userId, updates);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }
  
  // Upload profile picture and update profile
  Future<String> uploadProfilePicture(String userId, List<int> fileBytes, String fileExtension) async {
    try {
      // Upload the file to Supabase storage using the userId as the folder name
      final String path = '$userId/profile.$fileExtension';
      final String contentType = 'image/$fileExtension';
      
      final String fileUrl = await _database.uploadFile(
        'avatars',
        path,
        fileBytes,
        contentType,
      );
      
      // Update the user profile with the new picture URL
      await updateUserProfile(userId, {'avatar_url': fileUrl});
      
      return fileUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }
  
  // Delete profile picture
  Future<void> deleteProfilePicture(String userId, String path) async {
    try {
      await _database.deleteFile('avatars', path);
      // Update the profile to remove the picture URL
      await updateUserProfile(userId, {'avatar_url': null});
    } catch (e) {
      throw Exception('Failed to delete profile picture: ${e.toString()}');
    }
  }
  
  // Convert database profile to User model
  User mapProfileToUser(Map<String, dynamic> profile) {
    return User(
      id: profile['id'],
      full_name: profile['full_name'] ?? 'User',
      email: profile['email'] ?? '',
      photoUrl: profile['avatar_url'],
    );
  }
} 