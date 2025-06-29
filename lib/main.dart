import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_starter_package/core/config/locale_constants.dart';
import 'package:flutter_starter_package/core/config/supabase_config.dart';
import 'package:flutter_starter_package/core/providers/theme_provider.dart';
import 'package:flutter_starter_package/core/theme/app_theme.dart';
import 'package:flutter_starter_package/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:flutter_starter_package/features/auth/domain/providers/auth_provider.dart';
import 'package:flutter_starter_package/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Create a ProviderContainer with overrides
  final container = ProviderContainer(
    overrides: [
      // Initialize the auth repository provider with Supabase implementation
      authRepositoryProvider.overrideWith((ref) => SupabaseAuthRepository()),
    ],
  );
  
  // Pre-initialize the theme to reduce flicker
  await container.read(themeModeProvider.notifier).loadThemeMode();
  
  runApp(
    EasyLocalization(
      supportedLocales: LocaleConstants.supportedLocales,
      path: LocaleConstants.PATH,
      fallbackLocale: LocaleConstants.enLocale,
      child: UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme mode provider to rebuild when theme changes
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'app.title'.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Add support for correct text direction based on locale
        return child!;
      },
    );
  }
}
