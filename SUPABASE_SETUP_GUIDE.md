# Supabase Setup Guide

This guide will help you set up your Supabase project for this Flutter starter package.

## 1. Create a Supabase Project

1. Go to [Supabase](https://supabase.com/) and sign in or create an account
2. Create a new project and give it a name
3. Wait for the database to be ready

## 2. Set Up Authentication

Supabase provides authentication out of the box. For this starter package, we'll enable:

1. Email authentication
2. Google OAuth
3. Apple OAuth (if needed)

### Email Authentication

This is enabled by default. You can customize settings in the Authentication section of your Supabase dashboard.

### Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Navigate to "APIs & Services" > "Credentials"
4. Click "Create Credentials" > "OAuth client ID"
5. Configure the OAuth consent screen
6. Create a Web client ID
7. Add your Supabase authentication callback URL: `https://<your-project>.supabase.co/auth/v1/callback`
8. Copy the Client ID and Client Secret
9. In your Supabase dashboard, go to Authentication > Providers > Google
10. Enable Google and paste your Client ID and Client Secret

### Apple OAuth (Optional)

1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Create a new App ID if you don't have one
3. Enable "Sign In with Apple" capability
4. Create a Services ID
5. Configure the domain and return URL
6. Generate a key
7. In your Supabase dashboard, go to Authentication > Providers > Apple
8. Enable Apple and fill in the required information

## 3. Set Up Database Tables

Run the following SQL in the SQL Editor in your Supabase dashboard:

```sql
-- Create profiles table
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
  full_name TEXT,
  avatar_url TEXT,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public profiles are viewable by everyone." 
  ON public.profiles 
  FOR SELECT 
  USING (true);

CREATE POLICY "Users can insert their own profile." 
  ON public.profiles 
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile." 
  ON public.profiles 
  FOR UPDATE 
  USING (auth.uid() = id);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_updated_at();

-- Create eyeScans table for glaucoma feature
CREATE TABLE IF NOT EXISTS public.eyeScans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  image_path TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.eyeScans ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for eyeScans table
-- Users can view their own scans
CREATE POLICY "Users can view their own eye scans" 
  ON public.eyeScans 
  FOR SELECT 
  USING (auth.uid() = user_id);

-- Users can insert their own scans
CREATE POLICY "Users can insert their own eye scans" 
  ON public.eyeScans 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own scans
CREATE POLICY "Users can update their own eye scans" 
  ON public.eyeScans 
  FOR UPDATE 
  USING (auth.uid() = user_id);

-- Users can delete their own scans
CREATE POLICY "Users can delete their own eye scans" 
  ON public.eyeScans 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Create trigger for eyeScans updated_at
CREATE TRIGGER eyeScans_updated_at
  BEFORE UPDATE ON public.eyeScans
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_updated_at();
```

## 4. Set Up Storage Buckets

### Create Avatars Bucket

1. Go to Storage in your Supabase dashboard
2. Click "Create Bucket"
3. Name it "avatars"
4. Choose whether to make it public or private (public is recommended for avatars)
5. Create the following policies:

```sql
-- For public bucket:
CREATE POLICY "Avatar images are publicly accessible."
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'avatars');

-- For authenticated uploads:
CREATE POLICY "Users can upload their own avatar."
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- For user-specific updates:
CREATE POLICY "Users can update their own avatar."
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- For user-specific deletes:
CREATE POLICY "Users can delete their own avatar."
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

### Create Eye Scans Bucket

1. Go to Storage in your Supabase dashboard
2. Click "Create Bucket"
3. Name it "eyeScans"
4. Choose whether to make it public or private (public is recommended for easy access)
5. Create the following policies:

```sql
-- For public bucket:
CREATE POLICY "Eye scan images are publicly accessible."
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'eyeScans');

-- For authenticated uploads:
CREATE POLICY "Users can upload their own eye scans."
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'eyeScans' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- For user-specific updates:
CREATE POLICY "Users can update their own eye scans."
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'eyeScans' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- For user-specific deletes:
CREATE POLICY "Users can delete their own eye scans."
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'eyeScans' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

## 5. Configure Your Flutter App

1. In your Supabase project, go to Project Settings > API
2. Copy the URL and anon key
3. Update the `lib/core/config/supabase_config.dart` file with these values:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

## 6. Testing Your Setup

1. Run the app and try to register a new user
2. Verify that the user is created in the Auth section of your Supabase dashboard
3. Check that a corresponding entry is created in the profiles table
4. Test the eye scan feature by adding a new scan and verifying it appears in both the database and storage 