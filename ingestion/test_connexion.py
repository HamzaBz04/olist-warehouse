import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

racine = Path(__file__).resolve().parent.parent
load_dotenv(racine / ".env")

url = (
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
engine = create_engine(url)

with engine.connect() as conn:
    print("Connecté à la base :", conn.execute(text("SELECT current_database()")).scalar())