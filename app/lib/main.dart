import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'screens/mission_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
  runApp(const EnglishBrainApp());
}

class EnglishBrainApp extends StatelessWidget {
  const EnglishBrainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Brain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A1A1A)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MissionScreen(),
    );
  }
}
