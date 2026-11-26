import json
import streamlit as st
from google import genai
from google.genai import types

# Modelo configuracion
MODELO = "gemini-3.5-flash"

# Ruta de respaldo por si hay algun error de red o de formato
RUTA_RESPALDO = {
    "pasos": [
        {
            "numero": 1,
            "emoji": "🚶",
            "instruccion": "Camina hacia la entrada principal con cuidado",
            "referencia": "Puerta con rampa y techo visible",
            "accesibilidad": "Rampa suave sin escalones",
        },
        {
            "numero": 2,
            "emoji": "🚇",
            "instruccion": "Entra a la estacion y busca el elevador",
            "referencia": "Letrero azul con icono de persona",
            "accesibilidad": "Elevador disponible y amplio",
        },
        {
            "numero": 3,
            "emoji": "📍",
            "instruccion": "Baja en tu destino y sal con calma",
            "referencia": "Salida senalada con flecha verde",
            "accesibilidad": "Paso libre y banca cerca",
        },
    ],
    "mensaje_mumo": "Guau, vamos paso a paso. Aqui estoy contigo.",
}


def _obtener_cliente() -> genai.Client:
    """Crea y devuelve el cliente de Gemini usando la clave de Streamlit."""
    return genai.Client(vertexai=True, api_key=st.secrets["GEMINI_API_KEY"])


def _normalizar_ruta(data: dict) -> dict:
    """Asegura que el diccionario tenga la estructura exacta y maximo 6 pasos."""
    pasos_raw = data.get("pasos", [])
    if not isinstance(pasos_raw, list) or len(pasos_raw) == 0:
        return RUTA_RESPALDO

    pasos_limpios = []
    for idx, paso in enumerate(pasos_raw[:6], start=1):
        if not isinstance(paso, dict):
            continue
        pasos_limpios.append(
            {
                "numero": idx,
                "emoji": str(paso.get("emoji", "🧭")).strip() or "🧭",
                "instruccion": str(paso.get("instruccion", "Avanza con calma")).strip(),
                "referencia": str(paso.get("referencia", "Busca un letrero claro")).strip(),
                "accesibilidad": str(paso.get("accesibilidad", "Ruta directa")).strip(),
            }
        )

    if not pasos_limpios:
        return RUTA_RESPALDO

    mensaje = str(data.get("mensaje_mumo", "")).strip()
    if not mensaje:
        mensaje = "Guau, vas muy bien. Seguimos juntos."

    return {
        "pasos": pasos_limpios,
        "mensaje_mumo": mensaje,
    }


def generar_ruta(origen: str, destino: str, perfil: str) -> dict:
    """Genera una ruta accesible de maximo 6 pasos usando Gemini."""
    origen_limpio = (origen or "").strip() or "Punto de inicio"
    destino_limpio = (destino or "").strip() or "Destino"
    perfil_limpio = (perfil or "sin necesidad especial").strip()

    prompt = f"""
Crea una ruta de viaje desde "{origen_limpio}" hasta "{destino_limpio}".
Perfil de la persona: "{perfil_limpio}".

Reglas estrictas:
1. Escribe en espanol muy sencillo, claro y amable.
2. Prioriza caminos accesibles (rampas, elevadores, pasos amplios, evitar escaleras si aplica).
3. Maximo 6 pasos.
4. Cada "instruccion" debe tener maximo 15 palabras.
5. "referencia" debe describir algo facil de ver en el camino (letrero, color, tienda, parada).
6. "accesibilidad" debe indicar rampa, elevador, piso parejo o apoyo disponible (o "Ruta sencilla" si no aplica algo especial).
7. "mensaje_mumo" es una frase corta de animo de Mumo, un cachorro golden retriever tranquilo.
8. Si no estás seguro de un nombre de estación o línea, no lo inventes: da una indicación general y pide revisar los letreros.

Responde unicamente con un objeto JSON...

Responde unicamente con un objeto JSON con esta estructura exacta:
{{
  "pasos": [
    {{
      "numero": 1,
      "emoji": "🚇",
      "instruccion": "maximo 15 palabras",
      "referencia": "algo que se ve en el camino",
      "accesibilidad": "rampa o elevador si aplica"
    }}
  ],
  "mensaje_mumo": "frase corta de animo"
}}
"""

    try:
        cliente = _obtener_cliente()
        respuesta = cliente.models.generate_content(
            model=MODELO,
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.3,
            ),
        )

        texto = (respuesta.text or "").strip()
        if not texto:
            return RUTA_RESPALDO

        datos = json.loads(texto)
        if not isinstance(datos, dict):
            return RUTA_RESPALDO

        return _normalizar_ruta(datos)

    except Exception as error:
        # Muestra el error en la terminal y avisa en la app que es una ruta de ejemplo
        print("Error con Gemini:", error)
        respaldo = dict(RUTA_RESPALDO)
        respaldo["aviso"] = "No pude conectarme con Gemini. Esta es una ruta de ejemplo."
        return respaldo