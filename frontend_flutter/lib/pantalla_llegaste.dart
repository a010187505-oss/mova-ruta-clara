// pantalla_llegaste.dart — Pantalla 5: ¡Llegaste!
// ===================================================
// Mumo feliz celebra con el usuario. Muestra el mensaje
// final y da la opción de empezar una nueva ruta.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'estado_app.dart';
import 'widgets_comunes.dart';

class PantallaLlegaste extends StatelessWidget {
  const PantallaLlegaste({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final base = textoBase(context);
    final mensajeMumo =
        estado.ruta?['mensaje_mumo']?.toString() ?? '¡Lo lograste! 🐶';

    return PlantillaMova(
      children: [
        const SizedBox(height: 20),

        // ── Mumo feliz (grande y centrado) ──
        const Center(
          child: MumoImagen(tipo: 'feliz', alto: 200),
        ),
        const SizedBox(height: 20),

        // ── ¡Llegaste! ──
        Center(
          child: Text(
            '🎉 ¡Llegaste!',
            style: TextStyle(
              fontSize: textoTitulo(context) + 6,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF9E6899),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Mensaje de Mumo ──
        MumoDice(texto: mensajeMumo),
        const SizedBox(height: 20),

        // ── Escuchar ──
        BotonEscuchar(texto: '¡Llegaste! $mensajeMumo'),
        const SizedBox(height: 24),

        // ── Nueva ruta ──
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => estado.limpiarTodo(),
            icon: const Text('🏠', style: TextStyle(fontSize: 22)),
            label: Text(
              'Nueva ruta',
              style: TextStyle(fontSize: base + 2),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}
