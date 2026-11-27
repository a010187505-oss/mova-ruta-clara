// widgets_comunes.dart — Widgets reutilizables en todas las pantallas
// ====================================================================
// Incluye: barra superior (logo + letra grande), botón de llamar,
// aviso de IA, tarjetas rosas, botón de escuchar, imágenes de Mumo.

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'estado_app.dart';

// ── Instancia global de TTS (text-to-speech) ────────────
final FlutterTts _tts = FlutterTts();
bool _ttsIniciado = false;

Future<void> _iniciarTts() async {
  if (!_ttsIniciado) {
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.45); // Lento para accesibilidad
    await _tts.setVolume(1.0);
    _ttsIniciado = true;
  }
}

// ── Tamaños de texto según "Letra grande" ───────────────
double textoBase(BuildContext context) {
  final grande = context.watch<EstadoApp>().letraGrande;
  return grande ? 20.0 : 16.0;
}

double textoTitulo(BuildContext context) {
  final grande = context.watch<EstadoApp>().letraGrande;
  return grande ? 26.0 : 22.0;
}

double textoGrande(BuildContext context) {
  final grande = context.watch<EstadoApp>().letraGrande;
  return grande ? 24.0 : 19.0;
}

// ══════════════════════════════════════════════════════════
//  PlantillaMova — Envuelve cada pantalla con los elementos comunes
// ══════════════════════════════════════════════════════════

class PlantillaMova extends StatelessWidget {
  final List<Widget> children;

  const PlantillaMova({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Logo de Mova ──
        const BarraSuperior(),
        const SizedBox(height: 4),

        // ── Botón rojo "Llamar a mi familiar" (solo si hay teléfono) ──
        if (estado.telefono.isNotEmpty) ...[
          const SizedBox(height: 8),
          const BotonLlamarFamiliar(),
        ],
        const SizedBox(height: 12),

        // ── Contenido específico de cada pantalla ──
        ...children,

        // ── Aviso de IA al final ──
        const SizedBox(height: 20),
        const AvisoIA(),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  BarraSuperior — Logo + interruptor de letra grande
// ══════════════════════════════════════════════════════════

class BarraSuperior extends StatelessWidget {
  const BarraSuperior({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();

    return Row(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3CCDE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            'assets/logo.png',
            width: 32,
            height: 32,
            errorBuilder: (_, _, _) =>
                const Text('🐶', style: TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Mova',
          style: TextStyle(
            fontSize: textoTitulo(context),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9E6899),
          ),
        ),
        const SizedBox(width: 8),
        // Interruptor "Letra grande" (se ajusta en pantallas angostas)
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('🔠', style: TextStyle(fontSize: textoBase(context))),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Letra grande',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: textoBase(context) - 2),
                ),
              ),
              Switch(
                value: estado.letraGrande,
                activeThumbColor: const Color(0xFF9E6899),
                onChanged: (_) => estado.toggleLetraGrande(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  BotonLlamarFamiliar — Botón rojo para llamar por teléfono
// ══════════════════════════════════════════════════════════

class BotonLlamarFamiliar extends StatelessWidget {
  const BotonLlamarFamiliar({super.key});

  @override
  Widget build(BuildContext context) {
    final telefono = context.watch<EstadoApp>().telefono;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final uri = Uri.parse('tel:$telefono');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        icon: const Text('📞', style: TextStyle(fontSize: 20)),
        label: Text(
          'Llamar a mi familiar',
          style: TextStyle(fontSize: textoBase(context)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  AvisoIA — Texto de advertencia sobre la IA
// ══════════════════════════════════════════════════════════

class AvisoIA extends StatelessWidget {
  const AvisoIA({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '⚠️ Mova usa inteligencia artificial y puede equivocarse. '
        'Verifica siempre con la señalización oficial.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: textoBase(context) - 3,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  BotonEscuchar — Lee texto en voz alta con flutter_tts
// ══════════════════════════════════════════════════════════

class BotonEscuchar extends StatelessWidget {
  final String texto;

  const BotonEscuchar({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await _iniciarTts();
          await _tts.speak(texto);
        },
        icon: const Text('🔊', style: TextStyle(fontSize: 20)),
        label: Text('Escuchar', style: TextStyle(fontSize: textoBase(context))),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  MumoImagen — Muestra una imagen de Mumo (el cachorro)
// ══════════════════════════════════════════════════════════

class MumoImagen extends StatelessWidget {
  /// Nombre del asset: 'saludando', 'pensando' o 'feliz'
  final String tipo;
  final double alto;

  const MumoImagen({super.key, required this.tipo, this.alto = 160});

  @override
  Widget build(BuildContext context) {
    // Mapear tipo a nombre de archivo
    String archivo;
    switch (tipo) {
      case 'pensando':
        archivo = 'assets/mumo_pensando.jpg';
        break;
      case 'feliz':
        archivo = 'assets/mumo_feliz.jpg';
        break;
      default:
        archivo = 'assets/mumo_saludando.jpg';
    }

    return Image.asset(
      archivo,
      height: alto,
      fit: BoxFit.contain,
      // Si la imagen no existe, usar mumo_saludando como respaldo
      errorBuilder: (_, _, _) => Image.asset(
        'assets/mumo_saludando.jpg',
        height: alto,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            Text('🐶', style: TextStyle(fontSize: alto * 0.5)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  MumoDice — Burbuja de diálogo de Mumo
// ══════════════════════════════════════════════════════════

class MumoDice extends StatelessWidget {
  final String texto;

  const MumoDice({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3CCDE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🐶', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: textoBase(context),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D1630),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  TarjetaRosa — Tarjeta con fondo rosa para información
// ══════════════════════════════════════════════════════════

class TarjetaRosa extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const TarjetaRosa({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3CCDE).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3CCDE)),
      ),
      child: child,
    );
  }
}

// ══════════════════════════════════════════════════════════
//  AvisoAmarillo — Caja amarilla de advertencia
// ══════════════════════════════════════════════════════════

class AvisoAmarillo extends StatelessWidget {
  final String texto;

  const AvisoAmarillo({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: textoBase(context) - 1,
          color: Colors.brown.shade800,
        ),
      ),
    );
  }
}
