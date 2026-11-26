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
8. Si no estas seguro de un nombre de estacion o linea, no lo inventes: da una indicacion general y pide revisar los letreros.

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


def validar_foto(imagen_bytes: bytes, tipo_mime: str, paso_actual: dict) -> dict:
    """Revisa una foto de letrero o entorno y dice si la persona va bien en su paso actual."""
    # Respuesta segura por si hay un error tecnico o no se puede leer bien la imagen
    respaldo = {
        "va_bien": "no_seguro",
        "que_veo": "No pude revisar bien la foto en este momento.",
        "que_hacer": "Toma otra foto clara del letrero o pide ayuda cerca.",
        "mensaje_mumo": "Guau, sin prisas. Tomemos otra foto con calma.",
        "aviso": "No se pudo completar la revision automatica de la foto.",
    }

    if not imagen_bytes:
        return respaldo

    mime = (tipo_mime or "image/jpeg").strip()
    paso_info = paso_actual if isinstance(paso_actual, dict) else {}
    numero = paso_info.get("numero", 1)
    instruccion = paso_info.get("instruccion", "Avanzar por la ruta")
    referencia = paso_info.get("referencia", "Letrero o senal del camino")
    accesibilidad = paso_info.get("accesibilidad", "")

    prompt = f"""
Eres Mumo, un cachorro golden retriever tranquilo que ayuda a personas a moverse con calma.
Revisa esta foto tomada durante el paso {numero} de la ruta.

Datos del paso actual:
- Instruccion: "{instruccion}"
- Referencia esperada: "{referencia}"
- Accesibilidad: "{accesibilidad}"

Reglas:
1. Usa espanol muy sencillo, amable y calmado.
2. "va_bien" solo puede ser "si", "no" o "no_seguro".
3. Si la foto esta borrosa, oscura, cortada o no muestra algo util, usa "va_bien": "no_seguro" y pide tomar otra foto.
4. "que_veo": describe que hay en la foto en una sola frase corta.
5. "que_hacer": indica que hacer ahora en maximo 20 palabras.
6. "mensaje_mumo": frase corta y calmada de Mumo.

Responde unicamente con un objeto JSON con esta estructura exacta:
{{
  "va_bien": "si|no|no_seguro",
  "que_veo": "que hay en la foto en una frase",
  "que_hacer": "que debe hacer la persona en maximo 20 palabras",
  "mensaje_mumo": "frase corta y calmada de Mumo"
}}
"""

    try:
        cliente = _obtener_cliente()
        parte_imagen = types.Part.from_bytes(data=imagen_bytes, mime_type=mime)

        respuesta = cliente.models.generate_content(
            model=MODELO,
            contents=[parte_imagen, prompt],
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.2,
            ),
        )

        texto = (respuesta.text or "").strip()
        if not texto:
            return respaldo

        datos = json.loads(texto)
        if not isinstance(datos, dict):
            return respaldo

        va_bien_raw = str(datos.get("va_bien", "no_seguro")).strip().lower()
        if va_bien_raw not in ("si", "no", "no_seguro"):
            va_bien_raw = "no_seguro"

        que_veo = str(datos.get("que_veo", "")).strip() or respaldo["que_veo"]
        que_hacer = str(datos.get("que_hacer", "")).strip() or respaldo["que_hacer"]
        mensaje_mumo = str(datos.get("mensaje_mumo", "")).strip() or respaldo["mensaje_mumo"]

        return {
            "va_bien": va_bien_raw,
            "que_veo": que_veo,
            "que_hacer": que_hacer,
            "mensaje_mumo": mensaje_mumo,
        }

    except Exception as exc:
        # Imprime el error en la terminal para depurar sin romper la app
        print(f"[ERROR validar_foto]: {exc}")
        return respaldo


def detectar_lugar(imagen_bytes: bytes, tipo_mime: str) -> dict:
    """Mira una foto de la camara y dice donde parece estar la persona."""
    respaldo = {
        "lugar": "No pude reconocer el lugar.",
        "pistas": "La foto no tiene letreros o se ve poco clara.",
        "seguridad": "baja",
        "que_hacer": "Toma una foto de un letrero, nombre de calle o estacion.",
        "mensaje_mumo": "Guau, intentemos con otra foto, sin prisa.",
    }

    if not imagen_bytes:
        return respaldo

    prompt = """
Eres Mumo, un cachorro golden retriever tranquilo que ayuda a personas con discapacidad
y adultos mayores a ubicarse en la Ciudad de Mexico.
Mira la foto y di en que lugar parece estar la persona, usando SOLO pistas visibles
(letreros, nombres de calles, estaciones de metro o metrobus, monumentos, tiendas).

Reglas:
1. Espanol muy sencillo y calmado.
2. No inventes: si no hay pistas claras, dilo y pide otra foto.
3. "seguridad" solo puede ser "alta", "media" o "baja".
4. "que_hacer": un consejo en maximo 20 palabras (por ejemplo, buscar elevador o rampa cercana).

Responde unicamente con JSON con esta estructura exacta:
{"lugar": "nombre o descripcion del lugar", "pistas": "que viste en la foto que te ayudo",
 "seguridad": "alta|media|baja", "que_hacer": "consejo corto", "mensaje_mumo": "frase corta y calmada"}
"""

    try:
        cliente = _obtener_cliente()
        imagen = types.Part.from_bytes(data=imagen_bytes, mime_type=tipo_mime or "image/jpeg")
        respuesta = cliente.models.generate_content(
            model=MODELO,
            contents=[imagen, prompt],
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.2,
            ),
        )
        datos = json.loads((respuesta.text or "").strip())
        if not isinstance(datos, dict):
            return respaldo
        for clave in respaldo:
            datos[clave] = str(datos.get(clave, "")).strip() or respaldo[clave]
        if datos["seguridad"] not in ("alta", "media", "baja"):
            datos["seguridad"] = "baja"
        return datos

    except Exception as exc:
        print(f"[ERROR detectar_lugar]: {exc}")
        return respaldo