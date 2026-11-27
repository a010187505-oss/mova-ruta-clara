// servicio_api.dart — Llamadas HTTP al backend
// ================================================
// Cada función llama a un endpoint de api_server.py (FastAPI).
// Si la llamada falla, devuelve una respuesta de respaldo amable.

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ServicioApi {
  // ── URL del backend (FastAPI, puerto 8000) ────────────
  // En Chrome basta con localhost. En el celular (APK) "localhost" es el
  // propio teléfono, así que al compilar se pasa la IP de la computadora:
  //   flutter build apk --dart-define=API_URL=http://192.168.1.50:8000
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  // ── Ruta demo de 5 pasos (Metro Insurgentes → UVM) ───
  // Se usa si el backend no responde o Gemini falla.
  static const Map<String, dynamic> rutaDemo = {
    'pasos': [
      {
        'numero': 1,
        'emoji': '🚪',
        'instruccion': 'Busca la salida con rampa.',
        'referencia': 'Busca el letrero verde que dice "Salida".',
        'accesibilidad': 'Con rampa',
      },
      {
        'numero': 2,
        'emoji': '🛗',
        'instruccion': 'Usa el elevador para bajar al andén.',
        'referencia': 'Busca el símbolo azul de silla de ruedas.',
        'accesibilidad': 'Con elevador',
      },
      {
        'numero': 3,
        'emoji': '🚇',
        'instruccion': 'Sube al primer vagón y viaja dos estaciones.',
        'referencia': 'Espera detrás de la línea amarilla.',
        'accesibilidad': 'Asientos reservados',
      },
      {
        'numero': 4,
        'emoji': '🛗',
        'instruccion': 'Baja en Chapultepec y busca el elevador.',
        'referencia': 'Sigue los letreros de salida.',
        'accesibilidad': 'Con elevador',
      },
      {
        'numero': 5,
        'emoji': '🏫',
        'instruccion': 'Sigue por Reforma hasta UVM Campus Reforma.',
        'referencia': 'La entrada tiene una rampa gris.',
        'accesibilidad': 'Banqueta amplia',
      },
    ],
    'mensaje_mumo': '¡Guau! Lo logramos juntos. Estoy muy orgulloso de ti.',
    'aviso': 'No pude conectarme con Gemini. Esta es una ruta de ejemplo.',
  };

  // ── Generar ruta accesible ───────────────────────────
  static Future<Map<String, dynamic>> generarRuta(
    String origen,
    String destino,
    String perfil,
  ) async {
    try {
      final respuesta = await http
          .post(
            Uri.parse('$_baseUrl/api/ruta'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'origen': origen,
              'destino': destino,
              'perfil': perfil,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (respuesta.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(respuesta.body));
      }
    } catch (e) {
      // ignore - devolvemos la ruta demo
    }
    // Si algo falló, devolver ruta demo
    return Map<String, dynamic>.from(rutaDemo);
  }

  // ── Validar foto (¿Voy bien?) ────────────────────────
  static Future<Map<String, dynamic>> validarFoto(
    Uint8List fotoBytes,
    Map<String, dynamic> pasoActual,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/voy-bien'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('foto', fotoBytes, filename: 'foto.jpg'),
      );
      request.fields['paso_json'] = jsonEncode(pasoActual);

      final response = await request.send().timeout(
        const Duration(seconds: 45),
      );
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(body));
      }
    } catch (e) {
      // ignore - devolvemos respaldo
    }
    return {
      'va_bien': 'no_seguro',
      'que_veo': 'No pude revisar la foto en este momento.',
      'que_hacer': 'Toma otra foto clara del letrero o pide ayuda cerca.',
      'mensaje_mumo': 'Guau, sin prisas. Intentemos de nuevo.',
    };
  }

  // ── Detectar lugar (¿Dónde estoy?) ───────────────────
  static Future<Map<String, dynamic>> detectarLugar(Uint8List fotoBytes) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/donde-estoy'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('foto', fotoBytes, filename: 'foto.jpg'),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 45),
      );
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(body));
      }
    } catch (e) {
      // ignore - devolvemos respaldo
    }
    return {
      'lugar': 'No pude reconocer el lugar.',
      'pistas': 'La foto no tiene letreros claros.',
      'seguridad': 'baja',
      'que_hacer': 'Toma una foto de un letrero o nombre de calle.',
      'mensaje_mumo': 'Guau, intentemos con otra foto.',
    };
  }
}
