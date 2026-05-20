import 'package:flutter/material.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/root_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage helper
  await LocalStorage.init();

  final bool isLoggedIn = LocalStorage.getBool(
    'isLoggedIn',
    defaultValue: false,
  );

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  static final ValueNotifier<AppThemeMode> themeNotifier = ValueNotifier(
    AppThemeMode.system,
  );

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Load theme from storage
    final storedTheme = LocalStorage.getString(
      'theme_mode',
      defaultValue: 'light',
    );
    _applyTheme(storedTheme);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // If the active theme mode is set to 'system', rebuild to apply the new system theme colors!
    if (AppColors.themeMode == AppThemeMode.system) {
      setState(() {});
    }
  }

  void _applyTheme(String storedTheme) {
    if (storedTheme == 'dark') {
      MyApp.themeNotifier.value = AppThemeMode.dark;
      AppColors.themeMode = AppThemeMode.dark;
    } else if (storedTheme == 'sunset') {
      MyApp.themeNotifier.value = AppThemeMode.sunset;
      AppColors.themeMode = AppThemeMode.sunset;
    } else if (storedTheme == 'light') {
      MyApp.themeNotifier.value = AppThemeMode.light;
      AppColors.themeMode = AppThemeMode.light;
    } else {
      MyApp.themeNotifier.value = AppThemeMode.system;
      AppColors.themeMode = AppThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: MyApp.themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'fameo - X',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: widget.isLoggedIn
              ? const RootNavigationShell()
              : const LoginScreen(),
        );
      },
    );
  }
}
