# 🐶 Mova — Ruta Clara

Prototipo funcional del equipo **NEXUS** para el **Hackatón Nacional de Innovación con IA UVM 2026** (Campus Reforma).

Mova es una app de navegación **accesible** para personas con discapacidad, adultos mayores y personas con autismo o discapacidad intelectual. La guía **Mumo**, un cachorro golden retriever tranquilo, y usa la IA de **Google Gemini** para:

| Función | Qué hace |
|---|---|
| 🗺️ **Crear mi ruta** | Escribes de dónde sales, a dónde vas y qué necesitas (por ejemplo, silla de ruedas). Mova arma una ruta de máximo 6 pasos, con instrucciones cortas, algo fácil de ver en el camino y datos de accesibilidad (rampas, elevadores). |
| 📷 **¿Voy bien?** | Tomas una foto de un letrero y Mumo te dice si vas por el camino correcto del paso actual. |
| 📍 **¿Dónde estoy?** | Tomas una foto de tu alrededor y Mumo te dice dónde pareces estar. Puedes usar ese lugar como punto de inicio. |
| 🔊 **Escuchar** | Lee las instrucciones en voz alta. |
| 🔠 **Letra grande** | Hace más grande todo el texto. |
| 📞 **Llamar a mi familiar** | Un botón para llamar rápido a una persona de confianza. |

> ⚠️ Mova usa inteligencia artificial y puede equivocarse. Verifica siempre con la señalización oficial.

---

## 🧱 Cómo está organizado

```
mova-ruta-clara/
├── backend/
│   └── gemini_service.py   ← La lógica de IA (ruta, ¿voy bien?, ¿dónde estoy?)
├── api_server.py           ← Servidor FastAPI: conecta la app Flutter con el backend
├── app.py                  ← Versión web en Streamlit (también completa)
├── frontend_flutter/       ← App principal en Flutter (web / celular)
│   ├── lib/                ← Pantallas, estado y conexión con el servidor
│   └── assets/             ← Logo e imágenes de Mumo
├── .streamlit/             ← Colores de Streamlit y la clave de Gemini (secrets.toml, NO se sube)
├── docs/                   ← Capturas y documentación
├── mobile/                 ← Carpeta original de imágenes
├── hola.py, prueba_*.py    ← Pruebas rápidas de cada función
└── requirements.txt        ← Paquetes de Python
```

```
 App Flutter ──HTTP──▶ api_server.py (FastAPI) ──▶ backend/gemini_service.py ──▶ Gemini
 app.py (Streamlit) ─────────────────────────────▶ backend/gemini_service.py ──▶ Gemini
```

Si Gemini o el internet fallan, Mova **no se rompe**: muestra una ruta de ejemplo y mensajes amables de Mumo.

---

## ▶️ Cómo correrlo

### Lo que necesitas
- Python 3.11 o más nuevo
- Flutter 3.x (solo para la app Flutter)
- Una clave de Gemini en `.streamlit/secrets.toml`:
  ```toml
  GEMINI_API_KEY = "tu-clave-aquí"
  ```

### 1. Preparar Python (una sola vez)
En PowerShell, desde la carpeta del proyecto:
```powershell
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

### 2A. App Flutter (la principal)
**Terminal 1: el servidor**
```powershell
.venv\Scripts\activate
uvicorn api_server:app --port 8000
```
Abre http://localhost:8000. Debe decir `"Mova API lista"`.

**Terminal 2: la app**
```powershell
cd frontend_flutter
flutter pub get
flutter run -d chrome
```

### 2B. Sitio web (sin instalar Flutter)
Con el servidor encendido (`uvicorn api_server:app --port 8000`), abre http://localhost:8000/sitio/.
Tiene las mismas pantallas que la app: crear ruta, ¿Voy bien?, ¿Dónde estoy?, escuchar, letra grande y llamar a tu familiar.
Si el servidor no responde, el sitio usa la ruta de ejemplo, igual que la app.
Los archivos están en `website/`.

### 2C. Versión Streamlit (respaldo)
```powershell
.venv\Scripts\activate
streamlit run app.py
```

### Pruebas
```powershell
cd frontend_flutter
flutter test
```

---

## 🛠️ Tecnologías
- **IA:** Google Gemini (`google-genai`), con respuestas en JSON
- **Backend:** Python, FastAPI, Uvicorn
- **Frontend:** Flutter (Provider, image_picker, flutter_tts, url_launcher)
- **Versión alterna:** Streamlit + gTTS (voz)

## 👥 Equipo NEXUS
Hackatón Nacional de Innovación con IA UVM 2026. Ilustraciones de Mumo y logo hechas por Maren.

## 📄 Licencia
Ver [LICENSE](LICENSE).
