// main.dart — Punto de entrada de Mova
// ==========================================
// Configura el tema (colores, tipografía) y el estado global.
// La app se muestra centrada con ancho de celular, perfecta para web.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'estado_app.dart';
import 'pantalla_inicio.dart';
import 'pantalla_ruta.dart';
import 'pantalla_voy_bien.dart';
import 'pantalla_donde_estoy.dart';
import 'pantalla_llegaste.dart';

void main() {
  runApp(
    // Provider: comparte el estado (EstadoApp) con todas las pantallas
    ChangeNotifierProvider(
      create: (_) => EstadoApp(),
      child: const MovaApp(),
    ),
  );
}

/// Widget raíz de la app
class MovaApp extends StatelessWidget {
  const MovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mova · Ruta Clara',
      debugShowCheckedModeBanner: false, // Quita la etiqueta "DEBUG"
      theme: ThemeData(
        // Colores del diseño de Mova
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF9E6899),   // Morado Mova
          secondary: const Color(0xFFF3CCDE), // Rosa claro
          surface: const Color(0xFFFDF6FB),   // Fondo rosita
          onSurface: const Color(0xFF2D1630), // Texto oscuro
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF6FB),
        useMaterial3: true,
        // Botones grandes y redondeados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9E6899),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF9E6899),
            side: const BorderSide(color: Color(0xFF9E6899), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF3CCDE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF3CCDE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF9E6899), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const ContenedorMovil(),
    );
  }
}

/// Contenedor principal: centra la app con ancho tipo celular (420px)
/// y muestra la pantalla según el estado actual.
class ContenedorMovil extends StatelessWidget {
  const ContenedorMovil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            // Sombra suave para que se vea como un celular en el navegador
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            color: const Color(0xFFFDF6FB),
          ),
          child: Consumer<EstadoApp>(
            builder: (context, estado, _) {
              // Muestra la pantalla según el estado actual
              switch (estado.pantalla) {
                case 'ruta':
                  return const PantallaRuta();
                case 'voy_bien':
                  return const PantallaVoyBien();
                case 'donde_estoy':
                  return const PantallaDondeEstoy();
                case 'llegaste':
                  return const PantallaLlegaste();
                default:
                  return const PantallaInicio();
              }
            },
          ),
        ),
      ),
    );
  }
}
