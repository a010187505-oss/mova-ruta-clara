# Mova · App Flutter

App principal de **Mova — Ruta Clara**. Ver el [README principal](../README.md) para la explicación completa.

## Cómo correrla
1. Arranca el servidor desde la carpeta raíz: `uvicorn api_server:app --port 8000`
2. Aquí: `flutter pub get` y luego `flutter run -d chrome`

Si el servidor no está prendido, la app sigue funcionando con una **ruta de ejemplo** (Metro Insurgentes → UVM Campus Reforma).

## Archivos
| Archivo | Qué hace |
|---|---|
| `lib/main.dart` | Punto de entrada, colores de Mova y cambio de pantallas |
| `lib/estado_app.dart` | Estado global (pantalla actual, ruta, paso, letra grande) |
| `lib/servicio_api.dart` | Llamadas al servidor (`localhost:8000`) y respuestas de respaldo |
| `lib/pantalla_inicio.dart` | Formulario: origen, destino, necesidad y teléfono |
| `lib/pantalla_ruta.dart` | Un paso de la ruta por pantalla |
| `lib/pantalla_voy_bien.dart` | Foto del letrero → "¿Voy bien?" |
| `lib/pantalla_donde_estoy.dart` | Foto del lugar → "¿Dónde estoy?" |
| `lib/pantalla_llegaste.dart` | Pantalla final de "¡Llegaste!" |
| `lib/widgets_comunes.dart` | Barra superior, Mumo, botón de escuchar, avisos |
| `test/widget_test.dart` | Pruebas básicas (`flutter test`) |
