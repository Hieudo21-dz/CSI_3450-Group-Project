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
- `demo_integration.py` — retrieves a customer's allergies and demonstrates an insert
- `db/queries.py` — parameterized read and insert operations for the FreeBee schema

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

### Test FreeBee Data Integration

Retrieve customer 1's allergies and safe menu:

```powershell
.\.venv\Scripts\python.exe demo_integration.py --customer-id 1
```

Exercise the parameterized insert explicitly:

```powershell
.\.venv\Scripts\python.exe demo_integration.py --customer-id 1 --add-customer --first-name Alex --last-name Demo --email alex.demo@example.com
```

The insert uses a parameterized SQL statement and rolls back on failure. The default demo performs reads only and does not change data.

Update a customer phone number explicitly:

```powershell
python demo_integration.py --customer-id 1 --update-phone 248-555-0199
```

The update uses a parameterized SQL statement and is returned in the JSON output only when the customer exists.

### Windows Troubleshooting

If `python` is not recognized, use the Python launcher commands shown above (`py -3.9 ...`) instead of `python ...`.
