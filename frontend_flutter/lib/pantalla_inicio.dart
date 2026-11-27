// pantalla_inicio.dart — Pantalla 1: Inicio
// =============================================
// Mumo saluda, el usuario escribe origen/destino, elige perfil
// de accesibilidad y opcionalmente un teléfono de contacto.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'estado_app.dart';
import 'servicio_api.dart';
import 'widgets_comunes.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  // Controladores de texto (para poder leer lo que escribe el usuario)
  late TextEditingController _origenCtrl;
  late TextEditingController _destinoCtrl;
  late TextEditingController _telefonoCtrl;

  // Opciones del selector de perfil
  final List<String> _perfiles = [
    'Silla de ruedas',
    'Adulto mayor',
    'Discapacidad intelectual o autismo',
    'Sin necesidad especial',
  ];

  @override
  void initState() {
    super.initState();
    final estado = context.read<EstadoApp>();
    _origenCtrl = TextEditingController(text: estado.origen);
    _destinoCtrl = TextEditingController(text: estado.destino);
    _telefonoCtrl = TextEditingController(text: estado.telefono);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Si el origen cambió desde fuera (ej: "¿Dónde estoy?"), actualizar
    final estado = context.read<EstadoApp>();
    if (_origenCtrl.text != estado.origen) {
      _origenCtrl.text = estado.origen;
    }
  }

  @override
  void dispose() {
    _origenCtrl.dispose();
    _destinoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final base = textoBase(context);

    return PlantillaMova(
      children: [
        // ── Mumo saludando con burbuja ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const MumoImagen(tipo: 'saludando', alto: 120),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3CCDE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '¡Hola! Soy Mumo. Dime a dónde vas y te llevo paso a paso.',
                  style: TextStyle(
                    fontSize: base,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D1630),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Campo: ¿Dónde estás? ──
        Text('📍 ¿Dónde estás?',
            style: TextStyle(
                fontSize: base + 1,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1630))),
        const SizedBox(height: 6),
        TextField(
          controller: _origenCtrl,
          style: TextStyle(fontSize: base),
          decoration: InputDecoration(
            hintText: 'Ej. Metro Insurgentes',
            prefixIcon: const Icon(Icons.my_location, color: Color(0xFF9E6899)),
            hintStyle: TextStyle(fontSize: base - 1),
          ),
          onChanged: (v) => estado.origen = v,
        ),
        const SizedBox(height: 16),

        // ── Campo: ¿A dónde vas? ──
        Text('🏁 ¿A dónde vas?',
            style: TextStyle(
                fontSize: base + 1,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1630))),
        const SizedBox(height: 6),
        TextField(
          controller: _destinoCtrl,
          style: TextStyle(fontSize: base),
          decoration: InputDecoration(
            hintText: 'Ej. UVM Campus Reforma',
            prefixIcon:
                const Icon(Icons.flag_rounded, color: Color(0xFF9E6899)),
            hintStyle: TextStyle(fontSize: base - 1),
          ),
          onChanged: (v) => estado.destino = v,
        ),
        const SizedBox(height: 16),

        // ── Selector: ¿Qué necesitas? ──
        Text('🧑‍🦽 ¿Qué necesitas?',
            style: TextStyle(
                fontSize: base + 1,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1630))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF3CCDE)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: estado.perfil,
              style: TextStyle(fontSize: base, color: const Color(0xFF2D1630)),
              items: _perfiles
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => estado.perfil = v);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Campo: Teléfono de mi familiar ──
        Text('📞 Teléfono de mi familiar (opcional)',
            style: TextStyle(
                fontSize: base + 1,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1630))),
        const SizedBox(height: 6),
        TextField(
          controller: _telefonoCtrl,
          style: TextStyle(fontSize: base),
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Escribe el teléfono',
            prefixIcon: const Icon(Icons.phone, color: Color(0xFF9E6899)),
            hintStyle: TextStyle(fontSize: base - 1),
          ),
          onChanged: (v) => estado.telefono = v,
        ),
        const SizedBox(height: 24),

        // ── Botón principal: Crear mi ruta ──
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: estado.cargando ? null : () => _crearRuta(context),
            icon: const Text('🐾', style: TextStyle(fontSize: 22)),
            label: Text(
              estado.cargando ? 'Mumo está pensando...' : 'Crear mi ruta',
              style: TextStyle(fontSize: base + 1),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Mumo pensando (mientras carga) ──
        if (estado.cargando) ...[
          const SizedBox(height: 8),
          Center(child: MumoImagen(tipo: 'pensando', alto: 100)),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Mumo está pensando tu ruta... 🐶',
              style: TextStyle(
                  fontSize: base, color: const Color(0xFF9E6899)),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
        ],

        const SizedBox(height: 8),

        // ── Botón: ¿Dónde estoy? ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: estado.cargando
                ? null
                : () => estado.irA('donde_estoy'),
            icon: const Text('📷', style: TextStyle(fontSize: 20)),
            label: Text('¿Dónde estoy?',
                style: TextStyle(fontSize: base)),
          ),
        ),
      ],
    );
  }

  /// Llama al backend para generar la ruta
  Future<void> _crearRuta(BuildContext context) async {
    final estado = context.read<EstadoApp>();
    final origen = _origenCtrl.text.trim();
    final destino = _destinoCtrl.text.trim();

    // Validar que haya origen y destino
    if (origen.isEmpty || destino.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🐶 Escribe de dónde sales y a dónde vas.',
            style: TextStyle(fontSize: textoBase(context)),
          ),
          backgroundColor: const Color(0xFF9E6899),
        ),
      );
      return;
    }

    // Guardar datos y mostrar carga
    estado.origen = origen;
    estado.destino = destino;
    estado.telefono = _telefonoCtrl.text.trim();
    estado.setCargando(true);

    // Llamar al backend
    final ruta = await ServicioApi.generarRuta(origen, destino, estado.perfil);

    // Guardar la ruta y cambiar a la pantalla de pasos
    if (context.mounted) {
      estado.setRuta(ruta);
    }
  }
}
