import tomllib
from google import genai

clave = tomllib.load(open(".streamlit/secrets.toml", "rb"))["GEMINI_API_KEY"]
cliente = genai.Client(vertexai=True, api_key=clave)

modelos = [
    "gemini-3.6-flash",
    "gemini-3.5-flash",
    "gemini-3-flash-preview",
    "gemini-flash-latest",
    "gemini-2.5-flash-lite",
    "gemini-2.0-flash",
]

for modelo in modelos:
    try:
        r = cliente.models.generate_content(
            model=modelo,
            contents="Saluda en una frase como Mumo, un cachorro golden retriever amable.",
        )
        print("✅ FUNCIONA:", modelo)
        print(r.text)
        break
    except Exception as e:
        print("❌", modelo, "->", str(e)[:90])