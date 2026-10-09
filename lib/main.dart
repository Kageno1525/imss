import 'package:flutter/material.dart';
import 'app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ImssApp());
}

class ImssApp extends StatelessWidget {
  const ImssApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'imss',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const AppShell(),
      builder: (context, child) {
        return DefaultTextStyle(
          style: const TextStyle(
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          ),
          child: child!,
        );
      },
    );
  }
}

ThemeData _theme(Brightness b) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6C5CE7),
    brightness: b,
  );
  final base =
      ThemeData(useMaterial3: true, colorScheme: scheme, brightness: b);
  final clean = base.textTheme.apply(
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
  );

  return base.copyWith(
    scaffoldBackgroundColor:
        b == Brightness.dark ? const Color(0xFF0B0B14) : const Color(0xFFF5F6FB),
    textTheme: clean,
    primaryTextTheme: clean,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: b == Brightness.dark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      labelStyle: TextStyle(
        color: scheme.onSurface.withOpacity(0.6),
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
      ),
      hintStyle: TextStyle(
        color: scheme.onSurface.withOpacity(0.4),
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
      ),
    ),
  );
}