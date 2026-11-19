# Application

The web app or API that connects to SQL Server. Put the source code and configuration files here once the team picks a language/framework. Never commit real passwords or connection strings.

## Current Baseline (Python)

This folder now includes a safe Python starter for SQL Server connectivity using `pyodbc`.

### Files

- `requirements.txt` — Python dependencies
- `.env.example` — environment variable template for database connection
- `db/config.py` — reads connection settings from environment
- `db/connection.py` — builds SQL Server connection and tests it
- `db/health.py` — app-friendly health-check function
- `run_health_check.py` — command-line connection test script

### Setup

1. Create and activate a virtual environment (minimal install path on Windows):

	```powershell
	py -3.9 -m venv .venv
	.\.venv\Scripts\Activate.ps1
	```

2. Install dependencies:

	```powershell
	.\.venv\Scripts\python.exe -m pip install -r requirements.txt
	```

3. Copy `.env.example` to `.env` and fill in your SQL Server details.

### Verify Connectivity

Run:

```powershell
.\.venv\Scripts\python.exe run_health_check.py
```

Expected output includes:

- `status: "ok"`
- connected SQL Server name
- connected database name

If credentials or connection values are wrong, output will include `status: "error"` and a message.

### Windows Troubleshooting

If `python` is not recognized, use the Python launcher commands shown above (`py -3.9 ...`) instead of `python ...`.
