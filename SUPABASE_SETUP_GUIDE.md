# Supabase Setup Guide for Flutter Starter Package

This guide will walk you through setting up your Supabase project for the Flutter Starter Package.

## 1. Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com) and sign in or create an account
2. Click "New Project" to create a new project
3. Choose an organization, enter a project name, and set a database password
4. Choose a region closest to your users
5. Click "Create new project" and wait for it to be created (this may take a few minutes)

## 2. Get Your API Keys

1. Once your project is created, go to the project dashboard
2. In the left sidebar, click on "Project Settings"
3. Click on "API" in the settings menu
4. Copy the "URL" under "Project URL"
5. Copy the "anon" key under "Project API Keys"
6. Update `lib/core/config/supabase_config.dart` with these values:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

## 3. Set Up Database Tables

1. In the Supabase dashboard, go to the "SQL Editor" in the left sidebar
2. Click "New Query"
3. Copy and paste the SQL commands from the `supabase_setup.sql` file
4. Click "Run" to execute the SQL commands

The SQL script will create the following tables:
- `profiles`: Stores user profile information
- `user_settings`: Stores user preferences like theme and language
- `notifications`: Stores user notifications

It also sets up Row Level Security (RLS) policies to secure your data and creates a trigger to automatically create profile and settings entries when a new user signs up.

## 4. Set Up Storage Buckets

1. In the Supabase dashboard, go to "Storage" in the left sidebar
2. Click "Create a new bucket"
3. Enter "avatars" as the bucket name
4. Choose "Public" bucket type (we'll secure it with policies)
5. Click "Create bucket"

## 5. Set Up Storage Policies

1. Click on the "avatars" bucket you just created
2. Go to the "Policies" tab
3. Add the following policies:

### For uploads (INSERT):
- Policy name: "Allow authenticated users to upload their own avatar"
- Policy definition: 
```
bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
```

### For downloads (SELECT):
- Policy name: "Allow public access to read avatars"
- Policy definition: `bucket_id = 'avatars'`
- Select "Apply policy to: SELECT"
- Check "Enable policy"

## 6. Set Up Authentication Providers

1. In the Supabase dashboard, go to "Authentication" in the left sidebar
2. Go to the "Providers" tab
3. Enable "Email" provider and configure as needed
4. For Google authentication:
   - Enable "Google" provider
   - Create a Google OAuth application in the Google Cloud Console
   - Add your Supabase authentication callback URL to the Google OAuth app
   - Copy the Client ID and Client Secret to Supabase

## 7. Test Your Setup

1. Run your Flutter app
2. Try to register a new user
3. Check the Supabase dashboard to verify that:
   - The user was created in the Auth section
   - A profile was automatically created in the `profiles` table
   - Settings were automatically created in the `user_settings` table

## Troubleshooting

- If the automatic profile creation isn't working, check the Supabase logs for any errors in the trigger function
- Ensure your RLS policies are correctly set up to allow the operations your app needs
- For storage issues, check that your bucket policies are correctly configured

## Next Steps

- Consider adding more tables as your app grows
- Set up additional authentication providers if needed
- Configure email templates for authentication emails
- Set up webhooks for important events 