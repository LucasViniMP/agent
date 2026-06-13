import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/customer_order_page.dart';
import 'providers/customer_provider.dart';
import 'theme/app_theme.dart';

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
    statusBarIconBrightness: Brightness.light,
  ));

  final provider = CustomerProvider();

  runApp(
    ChangeNotifierProvider<CustomerProvider>.value(
      value: provider,
      child: const MesaMestreCustomerApp(),
    ),
  );

  provider.init();
}

class MesaMestreCustomerApp extends StatelessWidget {
  const MesaMestreCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesaMestre Online',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const CustomerOrderPage(),
    );
  }
}
