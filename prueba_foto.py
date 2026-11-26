import streamlit as st
from backend.gemini_service import validar_foto

st.title("Prueba ¿Voy bien?")
foto = st.file_uploader("Sube una foto de un letrero", type=["jpg", "jpeg", "png"])

if foto:
    st.image(foto, width=250)
    paso = {
        "numero": 2,
        "instruccion": "Avanza por la calle Génova",
        "referencia": "Letrero de la calle Génova",
        "accesibilidad": "Piso plano",
    }
    st.json(validar_foto(foto.getvalue(), foto.type, paso))