// pantalla_voy_bien.dart — Pantalla 3: ¿Voy bien? (cámara)
// ============================================================
// El usuario toma una foto de un letrero y la IA dice si va bien
// en su paso actual de la ruta.

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:provider/provider.dart';

import 'estado_app.dart';
import 'pantalla_camara.dart';
import 'servicio_api.dart';
import 'widgets_comunes.dart';

class PantallaVoyBien extends StatefulWidget {
  const PantallaVoyBien({super.key});

  @override
  State<PantallaVoyBien> createState() => _PantallaVoyBienState();
}

class _PantallaVoyBienState extends State<PantallaVoyBien> {
  /// Tomar foto con la cámara (en vivo) o elegir de la galería
  Future<void> _tomarFoto(BuildContext context, ImageSource fuente) async {
    try {
      final bytes = await obtenerFoto(context, fuente);
      if (bytes == null || !context.mounted) return;

      final estado = context.read<EstadoApp>();

      // Guardar la foto para mostrarla
      estado.fotoVoyBien = bytes;
      estado.resultadoVoyBien = null;
      estado.setCargando(true);

      // Enviar la foto al backend con el paso actual
      final resultado = await ServicioApi.validarFoto(
        bytes,
        estado.pasoInfo ?? {},
      );

      if (context.mounted) {
        estado.resultadoVoyBien = resultado;
        estado.setCargando(false);
      }
    } catch (e) {
      if (context.mounted) {
        context.read<EstadoApp>().setCargando(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🐶 No pude abrir la cámara.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final base = textoBase(context);
    final resultado = estado.resultadoVoyBien;

    return PlantillaMova(
      children: [
        // ── Título ──
        Text(
          '📷 ¿Voy bien?',
          style: TextStyle(
            fontSize: textoTitulo(context),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D1630),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Toma una foto del letrero o señal que ves.',
          style: TextStyle(fontSize: base, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),

        // ── Área de foto ──
        if (estado.fotoVoyBien != null) ...[
          // Mostrar la foto tomada
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              estado.fotoVoyBien!,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
        ] else ...[
          // Placeholder de cámara
          GestureDetector(
            onTap: () => _tomarFoto(context, ImageSource.camera),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF3CCDE).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3CCDE)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 48, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  Text(
                    'Toca para tomar foto',
                    style: TextStyle(
                      fontSize: base,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),

        // ── Botones de cámara / galería ──
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: estado.cargando
                    ? null
                    : () => _tomarFoto(context, ImageSource.camera),
                icon: const Text('📷', style: TextStyle(fontSize: 18)),
                label: Text('Tomar foto', style: TextStyle(fontSize: base)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: estado.cargando
                    ? null
                    : () => _tomarFoto(context, ImageSource.gallery),
                icon: const Text('🖼️', style: TextStyle(fontSize: 18)),
                label: Text('Galería', style: TextStyle(fontSize: base)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Mumo pensando (mientras carga) ──
        if (estado.cargando) ...[
          const Center(child: MumoImagen(tipo: 'pensando', alto: 100)),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Mumo está revisando la foto... 🐶',
              style: TextStyle(fontSize: base, color: const Color(0xFF9E6899)),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
        ],

        // ── Resultado del backend ──
        if (resultado != null) ...[
          const SizedBox(height: 16),
          _buildResultado(context, resultado, base),
        ],

        const SizedBox(height: 20),

        // ── Volver a mi paso ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => estado.irA('ruta'),
            icon: const Icon(Icons.arrow_back),
            label: Text('Volver a mi paso', style: TextStyle(fontSize: base)),
          ),
        ),
      ],
    );
  }

  /// Construye el resultado visual según va_bien
  Widget _buildResultado(
    BuildContext context,
    Map<String, dynamic> r,
    double base,
  ) {
    final vaBien = r['va_bien']?.toString() ?? 'no_seguro';

    // Título según resultado
    String titulo;
    Color colorTitulo;
    switch (vaBien) {
      case 'si':
        titulo = '✅ ¡Vas bien!';
        colorTitulo = Colors.green.shade700;
        break;
      case 'no':
        titulo = '⚠️ Parece que no es por aquí';
        colorTitulo = Colors.orange.shade800;
        break;
      default:
        titulo = '🤔 No estoy seguro';
        colorTitulo = Colors.amber.shade800;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con color
        Text(
          titulo,
          style: TextStyle(
            fontSize: textoTitulo(context),
            fontWeight: FontWeight.bold,
            color: colorTitulo,
          ),
        ),
        const SizedBox(height: 12),

        // Lo que veo
        TarjetaRosa(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lo que veo',
                style: TextStyle(
                  fontSize: base,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D1630),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r['que_veo']?.toString() ?? '',
                style: TextStyle(fontSize: base),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Qué hacer
        TarjetaRosa(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '👉 Qué hacer',
                style: TextStyle(
                  fontSize: base,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D1630),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r['que_hacer']?.toString() ?? '',
                style: TextStyle(fontSize: base),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Mensaje de Mumo
        MumoDice(texto: r['mensaje_mumo']?.toString() ?? ''),
        const SizedBox(height: 12),

        // Escuchar
        BotonEscuchar(
          texto:
              '$titulo. ${r['que_veo']}. ${r['que_hacer']}. '
              '${r['mensaje_mumo']}',
        ),
      ],
    );
  }
}
