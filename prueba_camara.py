import streamlit as st
from backend.gemini_service import detectar_lugar

st.title("📍 ¿Dónde estoy?")
st.write("Toma una foto de un letrero, calle o estación y Mumo te dirá dónde estás.")

foto = st.camera_input("Abrir cámara")

if foto:
    with st.spinner("Mumo está mirando la foto... 🐶"):
        r = detectar_lugar(foto.getvalue(), foto.type)
    st.subheader(f"📍 {r['lugar']}")
    st.write(f"**Lo que vi:** {r['pistas']}")
    st.write(f"**Qué tan seguro estoy:** {r['seguridad']}")
    st.info(f"👉 {r['que_hacer']}")
    st.success(f"🐶 Mumo: {r['mensaje_mumo']}")