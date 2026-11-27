// pantalla_camara.dart — Cámara dentro de la app
// ==================================================
// Abre la cámara EN VIVO dentro de Mova (en Chrome y en el celular),
// en lugar de abrir una ventana para elegir archivos.
//
// Uso:  final bytes = await obtenerFoto(context, ImageSource.camera);
// Si la cámara no se puede abrir (sin permiso o sin cámara), se usa
// el selector normal de image_picker como respaldo.

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;

final ImagePicker _picker = ImagePicker();

/// Devuelve los bytes de la foto, o null si la persona canceló.
Future<Uint8List?> obtenerFoto(BuildContext context, ImageSource fuente) async {
  if (fuente == ImageSource.camera) {
    final navigator = Navigator.of(context);
    try {
      final camaras = await availableCameras();
      if (camaras.isNotEmpty) {
        // Preferimos la cámara trasera (para fotografiar letreros)
        final trasera = camaras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => camaras.first,
        );
        return await navigator.push<Uint8List>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => PantallaCamara(camara: trasera),
          ),
        );
      }
    } catch (_) {
      // Sin permiso o sin cámara → usamos el respaldo de abajo
    }
  }

  // Galería, o respaldo si la cámara en vivo no funcionó
  final foto = await _picker.pickImage(
    source: fuente,
    maxWidth: 1024,
    imageQuality: 80,
  );
  return foto?.readAsBytes();
}

/// Pantalla completa con la vista de la cámara y un botón grande para tomar la foto.
class PantallaCamara extends StatefulWidget {
  final CameraDescription camara;

  const PantallaCamara({super.key, required this.camara});

  @override
  State<PantallaCamara> createState() => _PantallaCamaraState();
}

class _PantallaCamaraState extends State<PantallaCamara> {
  late final CameraController _control;
  late final Future<void> _iniciando;
  bool _tomando = false;

  @override
  void initState() {
    super.initState();
    _control = CameraController(
      widget.camara,
      ResolutionPreset.high, // Suficiente para leer letreros
      enableAudio: false,
    );
    _iniciando = _control.initialize();
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  Future<void> _tomar() async {
    if (_tomando || !_control.value.isInitialized) return;
    setState(() => _tomando = true);
    try {
      final foto = await _control.takePicture();
      final bytes = await foto.readAsBytes();
      if (mounted) Navigator.of(context).pop(bytes);
    } catch (_) {
      if (mounted) {
        setState(() => _tomando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🐶 No pude tomar la foto. Intenta otra vez.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _iniciando,
          builder: (context, snap) {
            if (snap.hasError) {
              return _Mensaje(
                texto:
                    '🐶 No pude abrir la cámara.\n'
                    'Revisa que Mova tenga permiso para usarla.',
                onVolver: () => Navigator.of(context).pop(),
              );
            }
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFF3CCDE)),
              );
            }
            return Stack(
              children: [
                // Vista de la cámara en vivo
                Center(child: CameraPreview(_control)),

                // Botón cerrar
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    tooltip: 'Cerrar cámara',
                    iconSize: 32,
                    color: Colors.white,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Ayuda + botón grande para tomar la foto
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Column(
                    children: [
                      const Text(
                        'Apunta al letrero y toca el botón',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      const SizedBox(height: 14),
                      Semantics(
                        button: true,
                        label: 'Tomar foto',
                        child: GestureDetector(
                          onTap: _tomar,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _tomando
                                  ? Colors.grey
                                  : const Color(0xFF9E6899),
                              border: Border.all(color: Colors.white, width: 5),
                            ),
                            child: _tomando
                                ? const Padding(
                                    padding: EdgeInsets.all(22),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  final String texto;
  final VoidCallback onVolver;

  const _Mensaje({required this.texto, required this.onVolver});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onVolver, child: const Text('Volver')),
          ],
        ),
      ),
    );
  }
}
