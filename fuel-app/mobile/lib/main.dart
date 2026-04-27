import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'features/auth/login_page.dart';
import 'features/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- ATENÇÃO: COLOQUE A SUA URL E SUA CHAVE AQUI ---
  await Supabase.initialize(
    url: 'https://veteaytdhbvapultbvup.supabase.co', // Sua URL do Supabase
    anonKey: 'sb_publishable_D-6G9BSAPwAP5k0oDx47iw_GrtulP5p', // Sua Publishable Key do Supabase
  );
  // --------------------------------------------------

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return MaterialApp(
      title: 'FuelSave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: auth.isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
