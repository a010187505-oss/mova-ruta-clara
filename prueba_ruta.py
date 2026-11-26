import streamlit as st
from backend.gemini_service import generar_ruta

st.title("Prueba de ruta")
st.json(generar_ruta("Metro Insurgentes", "UVM Campus Reforma", "silla de ruedas"))