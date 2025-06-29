Modular Flutter App – Clean Architecture & Modern UI (shadcn-inspired)
🧱 Project Structure
bash
Copy
Edit
lib/
│
├── core/                    # Global app utilities
│   ├── theme/               # Colors, typography, spacing
│   ├── utils/               # Global helpers
│   ├── services/            # App-wide services (e.g., NavigationService, AuthService)
│   ├── widgets/             # Reusable UI components
│   └── config/              # Constants, environment configs
│
├── features/                # Feature-based modules
│   ├── auth/                # Authentication feature
│   │   ├── data/            # API, repositories, models
│   │   ├── domain/          # Entities & use cases
│   │   ├── presentation/    # UI, screens, state management
│   │   └── auth_module.dart # Entry point
│   ├── glaucoma/            # Glaucoma detection feature
│   │   ├── data/            # API, repositories
│   │   ├── domain/          # Models & providers
│   │   ├── presentation/    # UI, screens
│   │   └── glaucoma_module.dart # Entry point
│   ├── medication/          # Medication reminder feature
│   │   ├── data/            # API, repositories
│   │   ├── domain/          # Models & providers
│   │   ├── presentation/    # UI, screens, widgets
│   │   └── medication_module.dart # Entry point
│   ├── profile/             # Profile feature
│   └── .../
│
├── routes/                  # App routes and navigation setup
├── main.dart                # App entry point
└── di.dart                  # Dependency injection setup
🧼 Clean Architecture Layers
1. Presentation
screens/, widgets/, controllers/

State management: Riverpod / Bloc

Dumb widgets + ViewModels/Controllers (MVVM-style)

2. Domain
Pure Dart (no Flutter imports)

Entities and use cases

Easily testable, business-logic only

3. Data
Handles APIs, local storage

Maps raw data (DTOs) to domain models

🧠 Rule: UI depends on domain, domain does not depend on data or presentation.

✨ UI Guidelines (Inspired by shadcn/ui)
🎨 Design Language
Minimalist, bold typography, flat design

Primary color + subtle backgrounds

Use elevation, shadow, blur sparingly

dart
Copy
Edit
// Example color scheme
final colorScheme = ColorScheme.light(
  primary: Color(0xFF6366F1),
  background: Color(0xFFF9FAFB),
  surface: Colors.white,
  onPrimary: Colors.white,
  onBackground: Color(0xFF111827),
);
📐 Layout
Use Padding / Gap / SizedBox consistently

Max width containers for large screens

Avoid deeply nested Column/Row

🔘 Components (Widgets)
Use a consistent style for components, similar to shadcn's:

<PrimaryButton />

<InputField />

<Card />

<Badge variant="success" />

All live in core/widgets/ or are grouped per feature in presentation/widgets/.

dart
Copy
Edit
PrimaryButton(
  onPressed: () {},
  text: 'Continue',
  icon: Icons.arrow_forward,
)
🕶️ Typography
Define consistent text styles:

dart
Copy
Edit
Text('Title', style: Theme.of(context).textTheme.headlineMedium);
In theme/text_theme.dart, include:

displayLarge

headlineMedium

titleSmall

bodyLarge

labelMedium

🧩 UI Components Inspired by shadcn
Modal: showModalBottomSheet

Tooltip: Tooltip

Card: Elevated Container with border and shadow

Tabs: TabBarView

Toast: Use fluttertoast or a custom Overlay

✅ Clean Code Guidelines
Use final and const wherever possible

Keep widget trees shallow with helpers or reusable widgets

One class = one file

Organize features and files by purpose, not widget type

Follow Dart naming conventions (camelCase, PascalCase)

🔌 Supabase Integration
This project includes full integration with Supabase for:

- Authentication (email/password, OAuth providers)
- Database operations (CRUD)
- Storage (file uploads)
- Realtime subscriptions

### Setup Supabase

1. Create a Supabase project at [https://supabase.com](https://supabase.com)
2. Get your Supabase URL and anon key from the project settings
3. Update the `lib/core/config/supabase_config.dart` file with your credentials:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### Database Schema

Create the following tables in your Supabase project:

1. **profiles** table (linked to auth.users):
```sql
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  name text,
  avatar_url text,
  updated_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.profiles enable row level security;

-- Create policies
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update their own profile."
  on profiles for update
  using ( auth.uid() = id );
```

2. **eye_scans** table (for glaucoma feature):
```sql
create table public.eye_scans (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text,
  image_path text not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.eye_scans enable row level security;

-- Create policies
create policy "Users can view their own eye scans"
  on eye_scans for select
  using (auth.uid() = user_id);

create policy "Users can insert their own eye scans"
  on eye_scans for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own eye scans"
  on eye_scans for update
  using (auth.uid() = user_id);

create policy "Users can delete their own eye scans"
  on eye_scans for delete
  using (auth.uid() = user_id);
```

3. **medication_reminders** table (for medication reminder feature):
```sql
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

-- Enable RLS
alter table public.medication_reminders enable row level security;

-- Create policies
create policy "Users can view their own medication reminders"
  on medication_reminders for select
  using (auth.uid() = user_id);

create policy "Users can insert their own medication reminders"
  on medication_reminders for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own medication reminders"
  on medication_reminders for update
  using (auth.uid() = user_id);

create policy "Users can delete their own medication reminders"
  on medication_reminders for delete
  using (auth.uid() = user_id);
```

4. Set up storage buckets:
   - Create an "avatars" bucket for profile pictures
   - Create an "eye-scans" bucket for glaucoma scan images (note: use hyphen, not underscore)
   - Set up appropriate bucket policies

For detailed setup instructions, refer to the [SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md) file.

### Using Supabase in the App

The app uses repository pattern to abstract Supabase operations:

- `SupabaseAuthRepository` - Handles authentication
- `SupabaseDatabase` - Generic database operations
- `UserProfileRepository` - Profile-specific operations
- `SupabaseEyeScanRepository` - Eye scan operations for glaucoma feature
- `SupabaseMedicationRepository` - Medication reminder operations

Example usage:

```dart
// Authentication
final authNotifier = ref.read(authProvider.notifier);
await authNotifier.login(email, password);

// Database operations
final database = ref.read(databaseProvider);
final users = await database.getAll('users', limit: 10);

// User profile
final profileNotifier = ref.read(userProfileProvider.notifier);
await profileNotifier.updateProfile({'name': 'New Name'});

// Eye scans
final eyeScanNotifier = ref.read(eyeScanProvider.notifier);
await eyeScanNotifier.createEyeScan(scan);

// Medication reminders
final medicationNotifier = ref.read(medicationProvider.notifier);
await medicationNotifier.createMedicationReminder(
  medicationName: 'Aspirin',
  description: 'For headache',
  reminderTimes: [DateTime(2022, 1, 1, 8, 0), DateTime(2022, 1, 1, 20, 0)],
  daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
);
```

## Glaucoma Feature

This app includes a feature for glaucoma patients to:

- Capture eye images using the device camera
- Save and organize eye scans with titles and descriptions
- View a history of all saved scans
- Track changes over time

The feature uses:
- Camera and image picker integration
- Secure storage of images in Supabase
- Clean architecture pattern with proper separation of concerns

To use this feature:
1. Ensure you've set up the eye_scans table and eye-scans storage bucket in Supabase
2. Navigate to the Eye Scan screen from the home screen
3. Follow the on-screen instructions to capture or select an image
4. Add a title and optional description
5. Save the scan to view it later

## Medication Reminder Feature

This app includes a medication reminder feature for patients to:

- Create medication reminders with custom schedules
- Set multiple reminder times per day
- Select specific days of the week for each medication
- Add descriptions and notes for each medication
- Enable/disable reminders as needed
- View all medication reminders in one place

The feature uses:
- Riverpod for state management
- Supabase for data persistence
- Clean architecture pattern
- Intuitive UI for managing complex schedules

To use this feature:
1. Ensure you've set up the medication_reminders table in Supabase
2. Navigate to the Medication Reminders screen from the home screen
3. Tap the "+" button to add a new reminder
4. Enter medication details, set times and days
5. Save the reminder
6. Edit or delete reminders as needed from the main list

📦 Packages Used
Purpose	Package
State Management	flutter_riverpod / bloc
UI Components	flutter_hooks, gap, heroicons
Routing	go_router
Dependency Injection	get_it, riverpod
Forms & Validation	reactive_forms, formz
HTTP / Data	dio, retrofit, json_serializable, supabase_flutter
Persistence	hive, shared_preferences
Animations	flutter_animate, motion

🧪 Testing Strategy
Use mockito or mocktail for mocking dependencies

test/ folder should mirror the lib/ structure

Write unit tests for:

Use cases (domain layer)

State notifiers/blocs (presentation)

Repositories with mocked APIs

🛠️ Dev Tools
Use very_good_analysis or lint for static analysis

Use melos for monorepo if multiple packages

Use flutter_gen for assets, fonts, and localization

🚀 CI/CD Suggestions
Use GitHub Actions for linting, testing, and building

Use Codemagic, Bitrise, or FlutterFlow CI for deployment

Export production builds with version control

💡 UI/UX Best Practices
Use clear CTAs (Call-To-Actions)

Always show loading states and feedback

Keep spacing and padding consistent (8pt grid recommended)

Use micro-interactions (AnimatedSwitcher, Fade, Hero)

Support dark mode if possible

Make forms accessible and clear

📘 Starter Ideas
Want to bootstrap faster?

Create your own widget library inspired by shadcn components (shad_ui/)

Use AppScaffold, AppButton, AppCard, AppInput to unify layout and interaction

Create a global ThemeExtension for custom tokens

🌐🌓 Flutter Guidelines – Localization (Arabic & English) + Dark/Light Mode in the entire application
🌍 Localization (Arabic 🇸🇦 & English 🇺🇸)
✅ Packages
Use the built-in Flutter localization and flutter_localizations package.

Optionally, you can use easy_localization 