import os
from io import BytesIO

import streamlit as st
from gtts import gTTS

from backend.gemini_service import generar_ruta, validar_foto, detectar_lugar

st.set_page_config(page_title="Mova · Ruta Clara", page_icon="🐶", layout="centered")

# Imagenes de Mumo y logo (hechas por Maren)
ASSETS = "mobile/assets"
IMG = {
    "logo": f"{ASSETS}/logo.png",
    "saludando": f"{ASSETS}/mumo saludando.jpg",
    "pensativo": f"{ASSETS}/mumo pensativo.jpg",
    "feliz": f"{ASSETS}/mumo feliz.jpg",
}

# Memoria de la app (en que pantalla estamos, la ruta, el paso, etc.)
for clave, valor in {
    "pantalla": "inicio",
    "ruta": None,
    "paso": 0,
    "telefono": "",
    "origen": "",
    "destino": "",
    "letra_grande": False,
}.items():
    if clave not in st.session_state:
        st.session_state[clave] = valor


# ---------- Funciones de apoyo ----------

@st.cache_data(show_spinner=False)
def revisar_foto(imagen, tipo, paso):
    """Guarda la respuesta para no gastar creditos de Gemini en cada clic."""
    return validar_foto(imagen, tipo, paso)


@st.cache_data(show_spinner=False)
def buscar_lugar(imagen, tipo):
    return detectar_lugar(imagen, tipo)


def mostrar_imagen(nombre, ancho=160):
    ruta = IMG[nombre]
    if os.path.exists(ruta):
        st.image(ruta, width=ancho)
    else:
        st.markdown("# 🐶")


def mumo_dice(texto):
    st.success(f"🐶 **Mumo:** {texto}")


def boton_escuchar(texto, clave):
    """Lee el texto en voz alta con gTTS."""
    if st.button("🔊 Escuchar", key=clave, use_container_width=True):
        try:
            audio = BytesIO()
            gTTS(text=texto, lang="es", tld="com.mx").write_to_fp(audio)
            st.audio(audio.getvalue(), format="audio/mp3", autoplay=True)
        except Exception as error:
            print("Error gTTS:", error)
            st.warning("No pude leer en voz alta. Revisa tu conexión a internet.")


def aplicar_estilo():
    """Letra grande y botones grandes para accesibilidad."""
    tamano = "1.35rem" if st.session_state.letra_grande else "1.1rem"
    st.markdown(
        f"""
        <style>
        html, body, p, label, li, .stMarkdown {{ font-size: {tamano} !important; }}
        .stButton button, .stLinkButton a {{ font-size: {tamano} !important; padding: 0.8rem !important; }}
        </style>
        """,
        unsafe_allow_html=True,
    )


def barra_superior():
    col1, col2 = st.columns([3, 2])
    with col1:
        if os.path.exists(IMG["logo"]):
            st.image(IMG["logo"], width=130)
        else:
            st.title("Mova")
    with col2:
        st.toggle("🔠 Letra grande", key="letra_grande")
    if st.session_state.telefono:
        st.link_button(
            "📞 Llamar a mi familiar",
            f"tel:{st.session_state.telefono}",
            use_container_width=True,
        )


def ir_a(pantalla):
    st.session_state.pantalla = pantalla
    st.rerun()


# ---------- Pantallas ----------

def pantalla_inicio():
    mostrar_imagen("saludando")
    mumo_dice("¡Hola! Soy Mumo. Dime a dónde vas y te llevo paso a paso.")

    origen = st.text_input("📍 ¿Dónde estás?", key="origen", placeholder="Ej. Metro Insurgentes")
    destino = st.text_input("🏁 ¿A dónde vas?", key="destino", placeholder="Ej. UVM Campus Reforma")
    perfil = st.selectbox(
        "🧑‍🦽 ¿Qué necesitas?",
        ["silla de ruedas", "adulto mayor", "discapacidad intelectual o autismo", "sin necesidad especial"],
    )
    st.text_input("📞 Teléfono de mi familiar (opcional)", key="telefono")

    if st.button("🐾 Crear mi ruta", type="primary", use_container_width=True):
        if not origen or not destino:
            st.warning("Escribe de dónde sales y a dónde vas.")
        else:
            with st.spinner("Mumo está pensando tu ruta... 🐶"):
                st.session_state.ruta = generar_ruta(origen, destino, perfil)
            st.session_state.paso = 0
            ir_a("pasos")

    st.divider()
    if st.button("📷 ¿Dónde estoy?", use_container_width=True):
        ir_a("donde")


def pantalla_pasos():
    ruta = st.session_state.ruta
    pasos = ruta["pasos"]
    i = st.session_state.paso

    if ruta.get("aviso"):
        st.warning(ruta["aviso"])

    # Pantalla final
    if i >= len(pasos):
        mostrar_imagen("feliz")
        st.header("🎉 ¡Llegaste!")
        mumo_dice(ruta["mensaje_mumo"])
        boton_escuchar(f"¡Llegaste! {ruta['mensaje_mumo']}", "escuchar_fin")
        if st.button("🏠 Nueva ruta", use_container_width=True):
            st.session_state.ruta = None
            ir_a("inicio")
        return

    # Un solo paso por pantalla
    paso = pasos[i]
    st.caption(f"Paso {i + 1} de {len(pasos)}")
    st.progress((i + 1) / len(pasos))
    st.markdown(
        f"<div style='font-size:4rem;text-align:center'>{paso['emoji']}</div>",
        unsafe_allow_html=True,
    )
    st.subheader(paso["instruccion"])
    st.write(f"👀 **Busca:** {paso['referencia']}")
    st.write(f"♿ **Accesibilidad:** {paso['accesibilidad']}")
    boton_escuchar(
        f"Paso {i + 1}. {paso['instruccion']}. Busca: {paso['referencia']}.",
        f"escuchar_{i}",
    )

    col1, col2 = st.columns(2)
    with col1:
        if st.button("⬅️ Anterior", disabled=(i == 0), use_container_width=True):
            st.session_state.paso -= 1
            st.rerun()
    with col2:
        if st.button("Siguiente ➡️", type="primary", use_container_width=True):
            st.session_state.paso += 1
            st.rerun()

    # ¿Voy bien? con la camara
    with st.expander("📷 ¿Voy bien?"):
        foto = st.camera_input("Toma una foto del letrero", key=f"camara_{i}")
        if foto:
            with st.spinner("Mumo está revisando la foto... 🐶"):
                r = revisar_foto(foto.getvalue(), foto.type, paso)
            titulo = {
                "si": "✅ ¡Vas bien!",
                "no": "⚠️ Parece que no es por aquí",
                "no_seguro": "🤔 No estoy seguro",
            }[r["va_bien"]]
            mostrar_imagen("pensativo", 110)
            st.subheader(titulo)
            st.write(f"**Lo que veo:** {r['que_veo']}")
            st.info(f"👉 {r['que_hacer']}")
            mumo_dice(r["mensaje_mumo"])
            boton_escuchar(f"{titulo}. {r['que_hacer']}", f"escuchar_foto_{i}")

    if st.button("🏠 Volver al inicio", use_container_width=True):
        ir_a("inicio")


def pantalla_donde():
    st.header("📍 ¿Dónde estoy?")
    mostrar_imagen("pensativo", 140)
    st.write("Toma una foto de un letrero, calle o estación y Mumo te dirá dónde estás.")

    foto = st.camera_input("Abrir cámara", key="camara_donde")
    if foto:
        with st.spinner("Mumo está mirando la foto... 🐶"):
            r = buscar_lugar(foto.getvalue(), foto.type)
        st.subheader(f"📍 {r['lugar']}")
        st.write(f"**Lo que vi:** {r['pistas']}")
        st.write(f"**Qué tan seguro estoy:** {r['seguridad']}")
        st.info(f"👉 {r['que_hacer']}")
        mumo_dice(r["mensaje_mumo"])
        boton_escuchar(f"Estás en {r['lugar']}. {r['que_hacer']}", "escuchar_donde")
        if st.button("🐾 Empezar mi ruta desde aquí", type="primary", use_container_width=True):
            st.session_state.origen = r["lugar"]
            ir_a("inicio")

    if st.button("🏠 Volver al inicio", use_container_width=True):
        ir_a("inicio")


# ---------- App ----------

aplicar_estilo()
barra_superior()

if st.session_state.pantalla == "pasos" and st.session_state.ruta:
    pantalla_pasos()
elif st.session_state.pantalla == "donde":
    pantalla_donde()
else:
    pantalla_inicio()

st.caption("⚠️ Mova usa inteligencia artificial y puede equivocarse. Verifica siempre con la señalización oficial.")