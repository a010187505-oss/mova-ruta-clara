"""
api_server.py — Servidor API REST para Mova
=============================================
Envuelve las funciones de backend/gemini_service.py como endpoints HTTP
para que el frontend Flutter pueda usarlos.

NO modifica nada dentro de backend/ — solo importa las funciones y las expone.

Cómo correr (en PowerShell, desde la carpeta raíz del proyecto):
  .venv/Scripts/activate
  pip install -r requirements.txt
  uvicorn api_server:app --reload --port 8000
"""

import json
import tomllib

from google import genai
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

# ── Leer la API key de Gemini (misma que usa Streamlit) ──────────────
with open(".streamlit/secrets.toml", "rb") as f:
    _api_key = tomllib.load(f)["GEMINI_API_KEY"]

# ── Importar backend y parchear el cliente para funcionar sin Streamlit ──
import backend.gemini_service as _gs


def _cliente_sin_streamlit():
    """Crea el cliente de Gemini sin depender de st.secrets."""
    return genai.Client(vertexai=True, api_key=_api_key)


# Reemplaza la función interna para que no necesite Streamlit corriendo
_gs._obtener_cliente = _cliente_sin_streamlit

# Ahora sí importamos las funciones (ya parcheadas)
from backend.gemini_service import generar_ruta, validar_foto, detectar_lugar

# ── App FastAPI ──────────────────────────────────────────────────────
app = FastAPI(title="Mova — Ruta Clara API")

# Permitir que Flutter web se conecte (CORS abierto para demo local)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# Sitio web de Mova (carpeta website/): abre http://localhost:8000/sitio/
app.mount("/sitio", StaticFiles(directory="website", html=True), name="sitio")


@app.get("/")
async def raiz():
    """Endpoint de prueba — solo para verificar que el servidor está corriendo."""
    return {"estado": "ok", "mensaje": "🐶 Mova API lista"}


@app.post("/api/ruta")
async def endpoint_ruta(datos: dict):
    """Genera una ruta accesible paso a paso."""
    origen = datos.get("origen", "")
    destino = datos.get("destino", "")
    perfil = datos.get("perfil", "sin necesidad especial")
    return generar_ruta(origen, destino, perfil)


@app.post("/api/voy-bien")
async def endpoint_voy_bien(
    foto: UploadFile = File(...),
    paso_json: str = Form(...),
):
    """Revisa una foto y dice si la persona va bien en su paso actual."""
    imagen_bytes = await foto.read()
    tipo_mime = foto.content_type or "image/jpeg"
    paso = json.loads(paso_json)
    return validar_foto(imagen_bytes, tipo_mime, paso)


@app.post("/api/donde-estoy")
async def endpoint_donde_estoy(
    foto: UploadFile = File(...),
):
    """Detecta dónde está la persona a partir de una foto."""
    imagen_bytes = await foto.read()
    tipo_mime = foto.content_type or "image/jpeg"
    return detectar_lugar(imagen_bytes, tipo_mime)
