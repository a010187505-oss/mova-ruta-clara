# Mova — Ruta Clara

**Mova** es una app web móvil que convierte cualquier ruta en la ciudad en **máximo 6 pasos sencillos, uno por pantalla**, pensada para personas con discapacidad (motriz, intelectual, autismo) y adultos mayores. Si la persona duda, puede tomarle foto a un letrero y **Mumo**, un cachorro golden retriever que habla con calma, le dice dónde está, si va bien y qué hacer.

Proyecto del equipo **Nexus** para el **Hackatón Nacional de Innovación con IA Aplicada UVM 2026 – Ingenio Incluyente** (Campus Reforma).

- **App funcionando:** [PEGAR LINK .streamlit.app]
- **Boceto (Google Stitch):** https://stitch.google.com/projects/2649360552157803594
- **Video del pitch:** [PEGAR LINK DE DRIVE]

> Mova es un apoyo: siempre verifica con la señalización oficial.

---

## 1. El problema

Las apps de mapas dicen "gire a la derecha", pero no dicen si hay elevador, si la salida tiene escaleras o qué hacer si te pierdes. Según el Censo de Población y Vivienda 2020 del INEGI, en México 7,168,178 personas (5.7 %) tienen discapacidad y/o algún problema o condición mental.

## 2. La solución

| Función | Qué hace |
|---|---|
| Ruta en 6 pasos | El usuario escribe de dónde a dónde va y elige su necesidad. Gemini genera una ruta accesible en máximo 6 pasos, uno por pantalla, con emoji, referencia visual y datos de accesibilidad (elevador, rampa, escaleras). |
| ¿Voy bien? | El usuario toma foto de un letrero. Gemini la analiza junto con el paso actual y Mumo responde si va bien, qué ve y qué hacer. |
| ¿Dónde estoy? | El usuario toma foto de un letrero, calle o estación. Gemini reconoce el lugar por las pistas visibles y Mumo le dice dónde está y qué hacer. Desde ahí puede empezar su ruta. |
| Escuchar | Un botón lee cada paso y cada respuesta en voz alta. |
| Llamar a mi familiar | Botón que abre la llamada a un contacto de confianza. |
| Mumo | Mascota que acompaña con mensajes de ánimo y calma (saludando, pensativo y feliz). |
| Accesibilidad | Letra grande, colores de alto contraste y un solo paso por pantalla. |

**Perfiles:** silla de ruedas, adulto mayor, discapacidad intelectual o autismo, sin necesidad especial.

## 3. Objetivos de Desarrollo Sostenible

- **ODS 10 – Reducción de las desigualdades:** facilita que personas con discapacidad y adultos mayores se muevan solas por la ciudad.
- **ODS 11 – Ciudades y comunidades sostenibles:** apoya el acceso a un transporte accesible para todas las personas.

## 4. Tecnologías

| Pieza | Herramienta | Para qué |
|---|---|---|
| Lenguaje | Python | Todo el código |
| Interfaz móvil | Streamlit | Pantallas, botones, cámara y tema de colores |
| Inteligencia artificial | Google Gemini (`google-genai`, modelo `gemini-3.5-flash` vía Vertex AI en modo Exprés) | Generar la ruta, analizar la foto del letrero y reconocer el lugar |
| Voz | gTTS | Leer los pasos en voz alta |
| Diseño | Google Stitch | Boceto de pantallas, Mumo y paleta de colores |
| Código y versiones | GitHub + VS Code | Repositorio y control de versiones |
| Documentación | Google Workspace (Docs, Drive) | Documentación, video y evidencias |
| Publicación | Streamlit Community Cloud | Link público de la app |

## 5. Arquitectura

```
Usuario (celular) → App web Streamlit (app.py)
                      → backend/gemini_service.py → API de Google Gemini
                          · generar_ruta()    → ruta en máximo 6 pasos
                          · validar_foto()    → ¿Voy bien?
                          · detectar_lugar()  → ¿Dónde estoy?
                      ← Respuesta en JSON
                    → Se muestra un paso por pantalla, con voz (gTTS)
```

La API key de Gemini se guarda en `st.secrets` y **nunca** se sube al repositorio.

## 6. Estructura del repositorio

```
mova-ruta-clara/
├── app.py                  ← la app Streamlit (pantallas)
├── requirements.txt        ← streamlit, google-genai, gTTS
├── .streamlit/
│   └── config.toml         ← colores de Mova
├── backend/
│   ├── __init__.py
│   └── gemini_service.py   ← conexión con Gemini
├── mobile/assets/          ← logo.png, mumo saludando.jpg, mumo pensativo.jpg, mumo feliz.jpg
├── docs/                   ← documentación y capturas
├── README.md
├── LICENSE
└── .gitignore
```

## 7. Cómo correrlo

```bash
git clone https://github.com/a010187505-oss/mova-ruta-clara.git
cd mova-ruta-clara
python -m venv .venv
# Windows: .venv\Scripts\activate    Mac: source .venv/bin/activate
pip install -r requirements.txt
```

Crea el archivo `.streamlit/secrets.toml` con tu clave de Gemini:

```toml
GEMINI_API_KEY = "TU_CLAVE"
```

Y ejecuta:

```bash
streamlit run app.py
```

## 8. Metodología: Scrum exprés

Trabajamos con **Scrum** comprimido a 3 sprints de 40–50 minutos. Cada sprint termina con algo que funciona y se sube a GitHub. Prioridades con **MoSCoW**. Las historias de usuario están como Issues en **GitHub**.

| ID | Historia de usuario | Prioridad |
|---|---|---|
| HU1 | Escribir de dónde a dónde voy y elegir mi necesidad | Must |
| HU2 | Ver mi ruta en máximo 6 pasos, uno por pantalla | Must |
| HU3 | Tomar foto de un letrero con "¿Voy bien?" o "¿Dónde estoy?" y que Mumo me diga qué hacer | Must |
| HU4 | Escuchar cada paso en voz alta | Must |
| HU5 | Dictar origen y destino con mi voz | Could |
| HU6 | Botón para llamar a mi familiar | Should |
| HU7 | Mumo me acompaña con su imagen y mensajes de ánimo | Should |
| HU8 | Letra grande y colores de alto contraste | Should |
| HU9 | Rutas más reales con la búsqueda de Google dentro de Gemini | Could |

**Roles:** Raymundo (Product Owner y Scrum Master); Ana, Maren y Raymundo (equipo de desarrollo).

**Ruta de prueba de la demo:** Metro Observatorio → UVM Campus Reforma, perfil silla de ruedas (Línea 1 hasta Balderas, Línea 3 hasta Juárez y Paseo de la Reforma).

## 9. Declaración de uso de inteligencia artificial

| Herramienta | Para qué | Qué revisó el equipo |
|---|---|---|
| Google Gemini (API) | Dentro de la app: generar rutas, analizar fotos de letreros y reconocer el lugar | Probamos la ruta de la demo y la comparamos con Google Maps; probamos fotos reales |
| Google Gemini (chat) | Apoyo para escribir código (`generar_ruta()`, `validar_foto()`), la ruta de prueba y la documentación | Revisamos, probamos y corregimos el código y los textos |
| Gemini (imágenes) | Crear las variantes de Mumo (saludando, pensativo, feliz) | Elegimos y revisamos que fueran consistentes con el diseño |
| Google Stitch | Boceto de pantallas, Mumo y paleta de colores | Ajustamos el diseño a nuestras necesidades de accesibilidad |
| Claude (Anthropic) | Plan de trabajo, guion y documentación; revisión y corrección de `gemini_service.py`; función `detectar_lugar()` y armado de `app.py` | Probamos todas las pantallas y funciones, y ajustamos el código |

El equipo definió la idea, el problema, las funciones y probó todo el contenido generado.

## 10. Equipo Nexus

- **Raymundo Carmona Romero** — Líder, Product Owner y Scrum Master
- **Ana Isabel Pacheco Rivera** — Desarrollo
- **Maren Yaretzi Jiménez Pérez** — Diseño, pruebas y accesibilidad

## Licencia

MIT. Ver [LICENSE](LICENSE).