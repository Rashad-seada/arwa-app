# Model Updates for Supabase Integration

This document outlines the necessary updates to your model classes to align with the Supabase database schema.

## User Model Updates

Update your `User` model in `lib/features/auth/domain/models/user.dart` to match the database schema:

```dart
class User {
  final String id;
  final String? email;
  final String? full_name; // Changed from 'name' to 'full_name'
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? settings;
  
  const User({
    required this.id,
    this.email,
    this.full_name, // Changed from 'name' to 'full_name'
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.settings,
  });
  
  // Factory constructor to create a User from Supabase data
  factory User.fromSupabase(
    supabase.User supabaseUser, 
    Map<String, dynamic>? profileData,
    Map<String, dynamic>? settingsData,
  ) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email,
      full_name: profileData?['full_name'] as String?, // Changed from 'name' to 'full_name'
      avatarUrl: profileData?['avatar_url'] as String?,
      createdAt: supabaseUser.createdAt,
      updatedAt: profileData?['updated_at'] != null 
        ? DateTime.parse(profileData!['updated_at']) 
        : null,
      settings: settingsData,
    );
  }
  
  // Create an empty user
  factory User.empty() {
    return const User(id: '');
  }
  
  // Convert to Map for database operations
  Map<String, dynamic> toProfileMap() {
    return {
      'id': id,
      'full_name': full_name, // Changed from 'name' to 'full_name'
      'avatar_url': avatarUrl,
    };
  }
  
  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? full_name, // Changed from 'name' to 'full_name'
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      full_name: full_name ?? this.full_name, // Changed from 'name' to 'full_name'
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }
}
```

## UserProfileRepository Updates

Update your `UserProfileRepository` implementation to use the correct field names:

```dart
@override
Future<void> updateProfile(Map<String, dynamic> data) async {
  try {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Make sure we're using the correct field names
    final profileData = {
      if (data.containsKey('full_name')) 'full_name': data['full_name'], // Changed from 'name' to 'full_name'
      if (data.containsKey('avatar_url')) 'avatar_url': data['avatar_url'],
    };
    
    await _supabaseClient
      .from('profiles')
      .update(profileData)
      .eq('id', userId);
  } catch (e) {
    throw Exception('Failed to update profile: $e');
  }
}
```

## Storage Path Updates

The storage path format has been updated to comply with the new policy. When uploading profile pictures, use the following format:

```dart
// Old format
final String path = 'profile_pictures/$userId.$fileExtension';

// New format
final String path = '$userId/profile.$fileExtension';
```

This change ensures the storage policy can correctly identify the user's folder:

```sql
bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
```

This policy allows users to upload files only to folders named with their user ID. In Supabase storage, the file path is stored in the `name` column, and `storage.foldername()` extracts the first folder name from the path.

## UI Updates

Update any UI components that reference the user's name to use `full_name` instead of `name`:

```dart
// Example in a profile screen
Text(
  user.full_name ?? 'No name provided', // Changed from user.name
  style: Theme.of(context).textTheme.headline6,
),
```

## Form Updates

Update any form fields that collect the user's name:

```dart
TextFormField(
  decoration: InputDecoration(labelText: 'Full Name'), // Changed from 'Name'
  initialValue: user.full_name, // Changed from user.name
  onSaved: (value) => userData['full_name'] = value, // Changed from userData['name']
),
```

These changes ensure your application correctly interacts with the Supabase database schema. 