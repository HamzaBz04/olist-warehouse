import os
import pandas as pd
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text

racine = Path(__file__).resolve().parent.parent
load_dotenv(racine / ".env")

url = (
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
engine = create_engine(url)

dossier = racine / "data" / "raw"
inspecteur = inspect(engine)

for fichier in dossier.glob("*.csv"):
    nom_table = fichier.stem.replace("olist_", "").replace("_dataset", "")
    df = pd.read_csv(fichier, dtype=str)

    if inspecteur.has_table(nom_table, schema="bronze"):
        # La table existe : on vide son contenu sans la supprimer
        with engine.begin() as conn:
            conn.execute(text(f'TRUNCATE TABLE bronze."{nom_table}"'))
        mode = "append"
    else:
        # Première fois : on crée la table
        mode = "fail"

    df.to_sql(
        nom_table,
        engine,
        schema="bronze",
        if_exists=mode,
        index=False,
        chunksize=10_000,
    )
    print(f"{nom_table} : {len(df)} lignes chargées")

print("Chargement terminé.")