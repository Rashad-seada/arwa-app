-- Create medication_reminders table
create table public.medication_reminders (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  medication_name text not null,
  description text,
  reminder_times jsonb not null,
  days_of_week integer[] not null,
  is_active boolean not null default true,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);

-- Enable Row Level Security (RLS)
alter table public.medication_reminders enable row level security;

-- Create policies
-- Allow users to view their own medication reminders
create policy "Users can view their own medication reminders"
  on medication_reminders for select
  using (auth.uid() = user_id);

-- Allow users to create their own medication reminders
create policy "Users can insert their own medication reminders"
  on medication_reminders for insert
  with check (auth.uid() = user_id);

-- Allow users to update their own medication reminders
create policy "Users can update their own medication reminders"
  on medication_reminders for update
  using (auth.uid() = user_id);

-- Allow users to delete their own medication reminders
create policy "Users can delete their own medication reminders"
  on medication_reminders for delete
  using (auth.uid() = user_id);

-- Create index for faster queries
create index medication_reminders_user_id_idx on medication_reminders (user_id);
create index medication_reminders_is_active_idx on medication_reminders (is_active); 