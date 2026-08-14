# Getting Started

This dbt project runs fully local with Python + DuckDB.

## 1. Prerequisites

1. Install Python (3.10 to 3.14 is fine for this repo).
2. Open PowerShell in the project folder.
3. If script activation is blocked, allow it for this session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## 2. Setup (one time)

1. Create and activate a virtual environment:

```powershell
python -m venv .venv
```

```powershell
.\.venv\Scripts\Activate.ps1
```

2. Install dependencies:

```powershell
pip install -r requirements.txt
```
OR
```powershell
uv pip install -r requirements.txt
```
## 3. Run dbt locally

1. Optional: choose DuckDB file path/name for this shell session:

```powershell
$env:DBT_DUCKDB_PATH = "ai_course.duckdb"
```

2. Validate profile/config:

```powershell
dbt debug --profiles-dir .
```

3. Load seed CSVs:

```powershell
dbt seed --profiles-dir .
```

4. Build models:

```powershell
dbt run --profiles-dir .
```

5. Run tests:

```powershell
dbt test --profiles-dir .
```

6. Generate docs:

```powershell
dbt docs generate --profiles-dir .
```

7. Optional: open docs site:

```powershell
dbt docs serve --profiles-dir .
```

## 4. Expected output

1. dbt commands complete without errors.
2. A local DuckDB file appears (default: `ai_course.duckdb` in repo root unless you changed `DBT_DUCKDB_PATH`).
3. Build artifacts appear under `target/`.
