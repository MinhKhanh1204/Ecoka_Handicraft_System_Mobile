import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/shared_prefs.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/theme_provider.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/auth/forgot_password_screen.dart';
import 'presentation/auth/reset_password_screen.dart';
import 'presentation/profile/change_password_screen.dart';
import 'presentation/profile/edit_profile_screen.dart';
import 'presentation/main_navigator.dart';
import 'presentation/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  runApp(const ProviderScope(child: EcokaCustomerApp()));
}

class EcokaCustomerApp extends ConsumerWidget {
  const EcokaCustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Ecoka Customer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.themeMode,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const MainEntry());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/forgot-password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
          case '/reset-password':
            final email = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(email: email ?? ''),
            );
          case '/change-password':
            return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
          case '/edit-profile':
            return MaterialPageRoute(builder: (_) => const EditProfileScreen());
          default:
            return MaterialPageRoute(builder: (_) => const MainEntry());
        }
      },
      home: const MainEntry(),
    );
  }
}

class MainEntry extends ConsumerStatefulWidget {
  const MainEntry({super.key});

  @override
  ConsumerState<MainEntry> createState() => _MainEntryState();
}

class _MainEntryState extends ConsumerState<MainEntry> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    final authState = ref.watch(authProvider);
    if (!authState.isLoggedIn) return const LoginScreen();

    return const MainNavigator();
  }
}
