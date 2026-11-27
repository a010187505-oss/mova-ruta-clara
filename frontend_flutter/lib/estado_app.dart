// estado_app.dart — Estado global de la aplicación
// ==================================================
// Usa ChangeNotifier para que cuando algo cambie, las pantallas se
// actualicen automáticamente. Es como el session_state de Streamlit.

import 'dart:typed_data';
import 'package:flutter/material.dart';

class EstadoApp extends ChangeNotifier {
  // ── Pantalla actual ──────────────────────────────────
  // Puede ser: inicio, ruta, voy_bien, donde_estoy, llegaste
  String _pantalla = 'inicio';
  String get pantalla => _pantalla;

  // ── Datos del formulario de inicio ───────────────────
  String origen = '';
  String destino = '';
  String perfil = 'Sin necesidad especial';
  String telefono = '';

  // ── Letra grande (accesibilidad) ─────────────────────
  bool _letraGrande = false;
  bool get letraGrande => _letraGrande;

  // ── Ruta generada por el backend ─────────────────────
  Map<String, dynamic>? ruta;
  int pasoActual = 0;

  // ── Resultado de "¿Voy bien?" ────────────────────────
  Map<String, dynamic>? resultadoVoyBien;
  Uint8List? fotoVoyBien; // Bytes de la foto para mostrarla

  // ── Resultado de "¿Dónde estoy?" ─────────────────────
  Map<String, dynamic>? resultadoDonde;
  Uint8List? fotoDonde;

  // ── Cargando (para mostrar "Mumo está pensando...") ──
  bool cargando = false;

  // ── Cambiar de pantalla ──────────────────────────────
  void irA(String pantalla) {
    _pantalla = pantalla;
    notifyListeners();
  }

  // ── Alternar letra grande ────────────────────────────
  void toggleLetraGrande() {
    _letraGrande = !_letraGrande;
    notifyListeners();
  }

  // ── Guardar la ruta recibida del backend ─────────────
  void setRuta(Map<String, dynamic> nuevaRuta) {
    ruta = nuevaRuta;
    pasoActual = 0;
    cargando = false;
    _pantalla = 'ruta';
    notifyListeners();
  }

  // ── Navegar entre pasos ──────────────────────────────
  void siguientePaso() {
    final pasos = ruta?['pasos'] as List? ?? [];
    if (pasoActual < pasos.length - 1) {
      pasoActual++;
      notifyListeners();
    } else {
      // Era el último paso → pantalla de ¡Llegaste!
      _pantalla = 'llegaste';
      notifyListeners();
    }
  }

  void anteriorPaso() {
    if (pasoActual > 0) {
      pasoActual--;
      notifyListeners();
    }
  }

  // ── Información del paso actual ──────────────────────
  Map<String, dynamic>? get pasoInfo {
    final pasos = ruta?['pasos'] as List? ?? [];
    if (pasoActual >= 0 && pasoActual < pasos.length) {
      return Map<String, dynamic>.from(pasos[pasoActual]);
    }
    return null;
  }

  int get totalPasos => (ruta?['pasos'] as List?)?.length ?? 0;

  // ── Limpiar todo y volver al inicio ──────────────────
  void limpiarTodo() {
    _pantalla = 'inicio';
    origen = '';
    destino = '';
    ruta = null;
    pasoActual = 0;
    resultadoVoyBien = null;
    resultadoDonde = null;
    fotoVoyBien = null;
    fotoDonde = null;
    cargando = false;
    notifyListeners();
  }

  // ── Poner un lugar detectado como origen ─────────────
  void setOrigenDesdeDeteccion(String lugar) {
    origen = lugar;
    _pantalla = 'inicio';
    resultadoDonde = null;
    fotoDonde = null;
    notifyListeners();
  }

  // ── Iniciar / terminar carga ─────────────────────────
  void setCargando(bool valor) {
    cargando = valor;
    notifyListeners();
  }
}
