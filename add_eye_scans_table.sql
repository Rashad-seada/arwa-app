-- Create eye_scans table for glaucoma feature
CREATE TABLE IF NOT EXISTS public.eye_scans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  image_path TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.eye_scans ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for eye_scans table
-- Users can view their own scans
CREATE POLICY "Users can view their own eye scans" 
  ON public.eye_scans 
  FOR SELECT 
  USING (auth.uid() = user_id);

-- Users can insert their own scans
CREATE POLICY "Users can insert their own eye scans" 
  ON public.eye_scans 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own scans
CREATE POLICY "Users can update their own eye scans" 
  ON public.eye_scans 
  FOR UPDATE 
  USING (auth.uid() = user_id);

-- Users can delete their own scans
CREATE POLICY "Users can delete their own eye scans" 
  ON public.eye_scans 
  FOR DELETE 
  USING (auth.uid() = user_id);

-- Create an updated_at trigger if it doesn't already exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'handle_updated_at') THEN
    CREATE FUNCTION public.handle_updated_at()
    RETURNS TRIGGER AS $$
    BEGIN
      NEW.updated_at = now();
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
  END IF;
END $$;

-- Create trigger for eye_scans updated_at
CREATE TRIGGER eye_scans_updated_at
  BEFORE UPDATE ON public.eye_scans
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_updated_at(); 