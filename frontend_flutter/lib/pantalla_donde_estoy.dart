// pantalla_donde_estoy.dart — Pantalla 4: ¿Dónde estoy? (cámara)
// ==================================================================
// El usuario toma una foto de un letrero, calle o estación y la IA
// intenta decirle dónde está. Luego puede usar ese lugar como origen.

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:provider/provider.dart';

import 'estado_app.dart';
import 'pantalla_camara.dart';
import 'servicio_api.dart';
import 'widgets_comunes.dart';

class PantallaDondeEstoy extends StatefulWidget {
  const PantallaDondeEstoy({super.key});

  @override
  State<PantallaDondeEstoy> createState() => _PantallaDondeEstoyState();
}

class _PantallaDondeEstoyState extends State<PantallaDondeEstoy> {
  /// Tomar foto con la cámara (en vivo) o elegir de la galería
  Future<void> _tomarFoto(BuildContext context, ImageSource fuente) async {
    try {
      final bytes = await obtenerFoto(context, fuente);
      if (bytes == null || !context.mounted) return;

      final estado = context.read<EstadoApp>();

      // Guardar foto y empezar carga
      estado.fotoDonde = bytes;
      estado.resultadoDonde = null;
      estado.setCargando(true);

      // Enviar al backend
      final resultado = await ServicioApi.detectarLugar(bytes);

      if (context.mounted) {
        estado.resultadoDonde = resultado;
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
    final resultado = estado.resultadoDonde;

    return PlantillaMova(
      children: [
        // ── Título ──
        Text(
          '¿Dónde estoy?',
          style: TextStyle(
            fontSize: textoTitulo(context),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D1630),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Toma una foto de un letrero, calle o estación.',
          style: TextStyle(fontSize: base, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),

        // ── Área de foto ──
        if (estado.fotoDonde != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF3CCDE), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  estado.fotoDonde!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ] else ...[
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

        // ── Botones cámara / galería ──
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

        // ── Mumo pensando ──
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
          _buildResultado(context, resultado, base, estado),
        ],

        const SizedBox(height: 20),

        // ── Volver al inicio ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => estado.irA('inicio'),
            icon: const Text('🏠', style: TextStyle(fontSize: 18)),
            label: Text('Volver al inicio', style: TextStyle(fontSize: base)),
          ),
        ),
      ],
    );
  }

  /// Muestra el resultado de la detección de lugar
  Widget _buildResultado(
    BuildContext context,
    Map<String, dynamic> r,
    double base,
    EstadoApp estado,
  ) {
    final seguridad = r['seguridad']?.toString() ?? 'baja';

    // Color de la etiqueta de seguridad
    Color colorSeguridad;
    switch (seguridad) {
      case 'alta':
        colorSeguridad = Colors.green;
        break;
      case 'media':
        colorSeguridad = Colors.orange;
        break;
      default:
        colorSeguridad = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lugar
        TarjetaRosa(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📍 Lugar',
                style: TextStyle(
                  fontSize: base,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D1630),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r['lugar']?.toString() ?? '',
                style: TextStyle(fontSize: base + 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Lo que vi
        TarjetaRosa(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lo que vi',
                style: TextStyle(
                  fontSize: base,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D1630),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r['pistas']?.toString() ?? '',
                style: TextStyle(fontSize: base),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Qué tan seguro estoy
        Row(
          children: [
            Text(
              'Qué tan seguro estoy  ',
              style: TextStyle(
                fontSize: base,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1630),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorSeguridad.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorSeguridad),
              ),
              child: Text(
                seguridad,
                style: TextStyle(
                  fontSize: base - 1,
                  fontWeight: FontWeight.bold,
                  color: colorSeguridad,
                ),
              ),
            ),
          ],
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
              'Estás en ${r['lugar']}. ${r['pistas']}. '
              '${r['que_hacer']}. ${r['mensaje_mumo']}',
        ),
        const SizedBox(height: 16),

        // Botón para usar este lugar como origen
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final lugar = r['lugar']?.toString() ?? '';
              estado.setOrigenDesdeDeteccion(lugar);
            },
            icon: const Text('🐾', style: TextStyle(fontSize: 20)),
            label: Text(
              'Empezar mi ruta desde aquí',
              style: TextStyle(fontSize: base),
            ),
          ),
        ),
      ],
    );
  }
}
