# Olist Data Warehouse

Entrepôt de données construit à partir du dataset e-commerce **Olist** (≈100 000 commandes brésiliennes, 2016-2018), avec une architecture **bronze / silver / gold**, un **modèle dimensionnel en étoile**, des **tests de qualité** et une documentation avec **lineage**.

**Stack** : Python · PostgreSQL · dbt · SQL · Git

---

## Objectif

Transformer 9 fichiers CSV bruts en tables fiables et faciles à interroger, pour répondre à des questions métier comme :

- Quel est le chiffre d'affaires par mois et par catégorie ?
- Quels vendeurs et quels états génèrent le plus de ventes ?
- Quel est le délai moyen de livraison et la part de commandes en retard ?

---

## Architecture

```
CSV Olist ──► [bronze] ──► [silver] ──► [gold : étoile] ──► tests & docs
              données      données      fact_sales +
              brutes       nettoyées    4 dimensions
```

| Couche | Contenu | Outil |
|---|---|---|
| **Bronze** | Copie brute des 9 CSV (tout en texte) | Python (pandas, SQLAlchemy) |
| **Silver** | 7 modèles `stg_*` : types corrects, noms clairs, avis dédoublonnés | dbt (vues) |
| **Gold** | Modèle en étoile prêt pour l'analyse | dbt (tables) |

### Modèle en étoile

```
 dim_customer ─┐
 dim_product  ─┼──► fact_sales ◄── dim_date
 dim_seller   ─┘
```

- **Grain** de `fact_sales` : une ligne par article d'une commande.
- **Mesures** : `price`, `freight_value`, `total_item_value`, `delivery_delay_days`.
- **Dimension dégénérée** : `order_id` et `order_status` restent dans la table de faits.
- **Clés de substitution** : `customer_key`, `product_key`, `seller_key`, `date_key`.

![Lineage dbt](docs/lineage.png)

---

## Décisions techniques

- **Bronze en texte (`dtype=str`)** : fidèle à la source, le typage se fait en silver.
- **`customer_unique_id`** (et non `customer_id`) pour `dim_customer` : `customer_id` change à chaque commande.
- **Avis dédoublonnés** en silver : certaines commandes ont plusieurs avis, on garde le plus récent.
- **Catégories manquantes** remplacées par `unknown`.
- **Paiements exclus** de `fact_sales` : une commande peut avoir plusieurs paiements, les joindre dupliquerait les montants.
- **Chargement idempotent** : le script vide les tables (`TRUNCATE`) au lieu de les supprimer, donc il peut être relancé sans doublons ni conflit avec les vues dbt.

---

## Qualité des données

Tests dbt déclarés dans `models/marts/_marts.yml` :

- `unique` et `not_null` sur toutes les clés ;
- `relationships` : chaque vente pointe vers une dimension existante ;
- `accepted_values` sur `order_status` ;
- tests personnalisés : prix strictement positif, `total_item_value = price + freight_value`.

---

## Structure du projet

```
olist-warehouse/
├── ingestion/
│   ├── load_bronze.py         # chargement des CSV dans le bronze
│   └── test_connexion.py      # test de connexion à la base
├── olist_dbt/
│   ├── models/
│   │   ├── staging/           # couche silver (stg_*) + _sources.yml
│   │   └── marts/             # couche gold (dim_*, fact_sales) + _marts.yml
│   ├── macros/                # generate_schema_name
│   └── tests/                 # tests SQL personnalisés
├── docs/                      # captures (lineage, etc.)
├── .env.example               # modèle de configuration
├── requirements.txt
└── README.md
```

---

## Installation

### Prérequis

Python 3.10+, PostgreSQL 16+, Git. Les données sont à télécharger sur Kaggle : *Brazilian E-Commerce Public Dataset by Olist*.

### 1. Cloner et installer

```bash
git clone https://github.com/<TON_PSEUDO>/olist-warehouse.git
cd olist-warehouse
python -m venv venv
venv\Scripts\activate          # Windows
source venv/bin/activate       # Mac / Linux
pip install -r requirements.txt
```

### 2. Configurer la base

Dans PostgreSQL :

```sql
CREATE DATABASE olist;
-- puis, connecté à la base olist :
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
```

Copie `.env.example` en `.env` et renseigne ton mot de passe :

```
DB_USER=postgres
DB_PASSWORD=<ton_mot_de_passe>
DB_HOST=localhost
DB_PORT=5432
DB_NAME=olist
```

### 3. Charger le bronze

Place les CSV dans `data/raw/`, puis :

```bash
python ingestion/load_bronze.py
```

### 4. Construire silver et gold avec dbt

Configure `~/.dbt/profiles.yml` (profil `olist_dbt`, base `olist`, schéma `silver`), puis :

```bash
cd olist_dbt
dbt debug      # vérifier la connexion
dbt run        # construire silver et gold
dbt test       # lancer les tests de qualité
```

### 5. Générer la documentation

```bash
dbt docs generate
dbt docs serve     # ouvre http://localhost:8080
```

---

## Exemple de requête

```sql
select d.year, d.month, round(sum(f.price), 2) as chiffre_affaires
from gold.fact_sales f
join gold.dim_date d on f.date_key = d.date_key
group by d.year, d.month
order by d.year, d.month;
```

---



