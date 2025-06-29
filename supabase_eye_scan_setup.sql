-- Create eyeScans table
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

-- Create an updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER eyeScans_updated_at
  BEFORE UPDATE ON public.eyeScans
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_updated_at();

-- Create eyeScans storage bucket
-- Note: This part needs to be executed in the Supabase dashboard or using the Supabase CLI
-- You cannot create storage buckets using SQL directly

-- Instructions for storage bucket setup:
-- 1. Go to the Supabase dashboard
-- 2. Navigate to the Storage section
-- 3. Click "Create bucket"
-- 4. Name it "eyeScans"
-- 5. Set it to public or private based on your requirements
-- 6. Create the following RLS policies for the bucket:

/*
-- For public bucket:
CREATE POLICY "Anyone can view eye scans"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'eyeScans');

-- For authenticated uploads:
CREATE POLICY "Authenticated users can upload eye scans"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'eyeScans' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- For user-specific updates:
CREATE POLICY "Users can update their own eye scans"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'eyeScans' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- For user-specific deletes:
CREATE POLICY "Users can delete their own eye scans"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'eyeScans' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
*/ 