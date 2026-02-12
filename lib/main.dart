import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_tcg/viewmodels/app_settings_viewmodel.dart';
import 'package:pokedex_tcg/views/explore_page.dart';
import 'package:pokedex_tcg/views/home_page.dart';
import 'package:pokedex_tcg/views/search_page.dart';

Future<void> main() async {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettingsViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1C3B6A),
      onPrimary: Colors.white,
      secondary: Color(0xFFFFB454),
      onSecondary: Color(0xFF1E1E1E),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Color(0xFFF6F4F0),
      onSurface: Color(0xFF1E1E1E),
    );

    return MaterialApp(
      title: 'Pokedex TCG',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.surface,
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F4F0),
          foregroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/search': (context) => const SearchPage(),
        '/explore': (context) => const ExplorePage(),
      },
      initialRoute: '/',
    );
  }
}
