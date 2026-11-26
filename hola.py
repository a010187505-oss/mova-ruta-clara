import tomllib
from google import genai

clave = tomllib.load(open(".streamlit/secrets.toml", "rb"))["GEMINI_API_KEY"]
cliente = genai.Client(api_key=clave)
respuesta = cliente.models.generate_content(
    model="gemini-flash-latest",
    contents="Saluda en una frase como Mumo, un cachorro golden retriever amable.",
)
print(respuesta.text)