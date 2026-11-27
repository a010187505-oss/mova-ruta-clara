// pantalla_ruta.dart — Pantalla 2: Ruta (un paso por pantalla)
// ==============================================================
// Muestra cada paso de la ruta con emoji grande, instrucción,
// referencia visual y accesibilidad. Botones para navegar,
// escuchar y verificar con foto.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'estado_app.dart';
import 'widgets_comunes.dart';

class PantallaRuta extends StatelessWidget {
  const PantallaRuta({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final paso = estado.pasoInfo;
    final base = textoBase(context);
    final total = estado.totalPasos;
    final actual = estado.pasoActual;

    // Seguridad: si no hay ruta, volver al inicio
    if (estado.ruta == null || paso == null) {
      return PlantillaMova(
        children: [
          const MumoDice(texto: 'Ups, no tengo una ruta. Volvamos al inicio.'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => estado.limpiarTodo(),
              icon: const Text('🏠', style: TextStyle(fontSize: 20)),
              label: Text('Volver al inicio',
                  style: TextStyle(fontSize: base)),
            ),
          ),
        ],
      );
    }

    final tieneAviso = estado.ruta!.containsKey('aviso') &&
        estado.ruta!['aviso'] != null;

    return PlantillaMova(
      children: [
        // ── Paso X de N ──
        Text(
          'Paso ${actual + 1} de $total',
          style: TextStyle(
            fontSize: textoTitulo(context),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D1630),
          ),
        ),
        const SizedBox(height: 8),

        // ── Barra de progreso segmentada ──
        _barraProgreso(actual, total),
        const SizedBox(height: 10),

        // ── Badge "Modo demo" + nombre de ruta ──
        if (tieneAviso)
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0C060),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Modo demo',
                    style: TextStyle(
                        fontSize: base - 3, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${estado.origen} → ${estado.destino}',
                  style: TextStyle(
                      fontSize: base - 2, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        if (tieneAviso) const SizedBox(height: 8),

        // ── Aviso amarillo (si es ruta demo o hay advertencia) ──
        if (tieneAviso)
          AvisoAmarillo(texto: estado.ruta!['aviso'].toString()),
        if (tieneAviso) const SizedBox(height: 12),

        // ── Tarjeta principal del paso ──
        TarjetaRosa(
          child: Column(
            children: [
              // Emoji grande del paso
              Text(
                paso['emoji']?.toString() ?? '🧭',
                style: const TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 12),
              // Instrucción en letra grande y negrita
              Text(
                paso['instruccion']?.toString() ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textoGrande(context),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D1630),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Busca: referencia visual ──
        TarjetaRosa(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text('👀', style: TextStyle(fontSize: base + 2)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Busca: ${paso['referencia'] ?? ''}',
                  style: TextStyle(fontSize: base, color: const Color(0xFF2D1630)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Accesibilidad ──
        TarjetaRosa(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text('♿', style: TextStyle(fontSize: base + 2)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Accesibilidad: ${paso['accesibilidad'] ?? ''}',
                  style: TextStyle(fontSize: base, color: const Color(0xFF2D1630)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Botón "Escuchar" ──
        BotonEscuchar(
          texto:
              'Paso ${actual + 1}. ${paso['instruccion']}. '
              'Busca: ${paso['referencia']}. '
              'Accesibilidad: ${paso['accesibilidad']}.',
        ),
        const SizedBox(height: 16),

        // ── Botones Anterior / Siguiente ──
        Row(
          children: [
            // Anterior
            Expanded(
              child: OutlinedButton.icon(
                onPressed: actual == 0 ? null : () => estado.anteriorPaso(),
                icon: const Icon(Icons.arrow_back),
                label: Text('Anterior',
                    style: TextStyle(fontSize: base)),
              ),
            ),
            const SizedBox(width: 12),
            // Siguiente
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => estado.siguientePaso(),
                icon: Text(
                  actual < total - 1 ? '' : '🎉',
                  style: const TextStyle(fontSize: 18),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actual < total - 1 ? 'Siguiente' : '¡Llegué!',
                      style: TextStyle(fontSize: base),
                    ),
                    if (actual < total - 1) const SizedBox(width: 4),
                    if (actual < total - 1) const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Botón "¿Voy bien?" (cámara) ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              estado.resultadoVoyBien = null;
              estado.fotoVoyBien = null;
              estado.irA('voy_bien');
            },
            icon: const Text('📷', style: TextStyle(fontSize: 20)),
            label: Text('¿Voy bien?',
                style: TextStyle(fontSize: base)),
          ),
        ),
        const SizedBox(height: 8),

        // ── Botón "Volver al inicio" ──
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => estado.irA('inicio'),
            icon: const Text('🏠', style: TextStyle(fontSize: 18)),
            label: Text('Volver al inicio',
                style: TextStyle(fontSize: base - 1, color: Colors.grey.shade600)),
          ),
        ),
      ],
    );
  }

  /// Barra de progreso segmentada (como en las capturas del prototipo)
  Widget _barraProgreso(int actual, int total) {
    return Row(
      children: List.generate(total, (i) {
        final esActual = i <= actual;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: esActual
                  ? const Color(0xFF9E6899)
                  : const Color(0xFFF3CCDE),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
