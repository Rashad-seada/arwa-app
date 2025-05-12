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

📦 Packages Used
Purpose	Package
State Management	flutter_riverpod / bloc
UI Components	flutter_hooks, gap, heroicons
Routing	go_router
Dependency Injection	get_it, riverpod
Forms & Validation	reactive_forms, formz
HTTP / Data	dio, retrofit, json_serializable
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