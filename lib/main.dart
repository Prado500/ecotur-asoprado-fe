import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/catalog_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const EcoturApp());
}

class EcoturApp extends StatelessWidget {
  const EcoturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecotur Asoprado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FB), // Surface
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF006875), // Primary
          secondary: Color(0xFF006C49), // Secondary
          surface: Color(0xFFF7F9FB),
          error: Color(0xFFBA1A1A),
        ),
        fontFamily: 'Inter', // Fuente por defecto para cuerpos de texto
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Space Grotesk', fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF191C1E)),
          headlineMedium: TextStyle(fontFamily: 'Space Grotesk', fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF191C1E)),
          bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF191C1E)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFBAC9CC))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF006875), width: 2)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006875),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 2,
          ),
        ),
      ),
      // Arrancamos siempre en el Login
      home: const LoginScreen(),
    );
  }
}