import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'pages/role_selection_page.dart';
import 'pages/login_page.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final provider = AppProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider<AppProvider>.value(
      value: provider,
      child: const MesaMestreApp(),
    ),
  );
}

class MesaMestreApp extends StatelessWidget {
  const MesaMestreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesaMestre',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.activeRole == null) {
      return const RoleSelectionPage();
    }

    if (!provider.isAuthenticated) {
      return const LoginPage();
    }

    return const AppShell();
  }
}
