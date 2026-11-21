# Database Connectivity and Integration

## External Platform and Technologies

The FreeBee database is implemented in Microsoft SQL Server Express and integrated with a Python command-line application. SQL Server and the application run on the local development machine. The Python application uses `pyodbc` and Microsoft ODBC Driver 18 for SQL Server to execute parameterized SQL statements.

The local database environment uses:

- SQL Server instance: `localhost\SQLEXPRESS`
- Database: `FreeBee`
- Authentication: Windows Authentication
- Python: 3.9 virtual environment
- Database driver: ODBC Driver 18 for SQL Server
- Integration layer: Python `pyodbc` connector

The application stores connection settings in an environment file. [app/.env.example](../../app/.env.example) documents the required settings, while [app/.env](../../app/.env) contains the local configuration and is excluded from source control.

## Connection Method

[app/db/connection.py](../../app/db/connection.py) reads the database settings and constructs the SQL Server connection string. It supports either a complete `DB_CONNECTION_STRING` or individual server, database, driver, authentication, encryption, and timeout settings.

Windows Authentication is used for the local installation. The connection string therefore uses a trusted connection instead of a SQL Server username and password. The local SQL Server certificate is trusted for the development connection.

[app/run_health_check.py](../../app/run_health_check.py) executes [app/db/health.py](../../app/db/health.py), which tests connectivity using `SELECT @@SERVERNAME` and `DB_NAME()`. A successful result identifies the SQL Server instance and selected database. A connection failure is converted into a JSON error response rather than being exposed as an unformatted application crash.

## Application Architecture

The integration is organized into three layers:

1. [app/demo_integration.py](../../app/demo_integration.py) provides a command-line interface and formats operation results.
2. [app/db/queries.py](../../app/db/queries.py) contains parameterized database operations.
3. [app/db/connection.py](../../app/db/connection.py) manages the `pyodbc` connection.

This separation keeps SQL operations independent of command-line argument handling and makes the database functions reusable if the project later adds a web interface or API.

## Data Retrieval

The application provides two retrieval operations.

### Customer Allergy Retrieval

`get_customer_allergies()` accepts a customer ID and executes a parameterized join across `CUSTOMER`, `CUSTOMER_ALLERGY`, and `ALLERGEN`. It returns the customer's name, allergen names, allergy severity, and safety notes.

The following command retrieves customer 1's allergy profile:

```bash
python demo_integration.py --customer-id 1
```

Customer 1 was verified to return the Peanuts and Dairy allergies in the local `FreeBee` database.

### Safe Menu Retrieval

`get_safe_menu()` accepts a customer ID and returns menu items that do not contain allergens associated with that customer. The SQL statement uses `NOT EXISTS` to compare every menu item with the customer's allergy mappings.

The same demo command for customer 1 retrieves the safe menu and excludes dishes associated with Peanuts or Dairy. Menu item ID and category fields are also included to identify the returned dishes clearly.

## Data Insertion

`add_customer()` provides an insertion operation for the `CUSTOMER` table. The SQL statement uses question-mark placeholders rather than concatenated values. It inserts the first name, last name, phone number, and email address, then uses SQL Server's `OUTPUT` clause to return the generated `CustomerID` and inserted values.

The optional demo command is:

```bash
python demo_integration.py --customer-id 1 --add-customer --first-name Alex --last-name Demo --email alex.demo@example.com
```

The normal demo command performs read operations only. `--add-customer` explicitly enables the write operation, preventing accidental sample-data changes during normal demonstrations.

The insert operation calls `commit()` after success and `rollback()` if an exception occurs. The `CUSTOMER.Email` column is unique, so duplicate email addresses are rejected by SQL Server and can be used to demonstrate database constraint handling.

## Database Error and Invalid Request Handling

The health check and integration demo catch database exceptions and print a JSON object containing `status: "error"` and a readable error message. The insert operation also rolls back an unsuccessful transaction.

Database-side constraints remain authoritative. Relevant examples include:

- unique customer emails;
- valid allergy severity values;
- valid menu categories;
- positive menu prices;
- order quantities from 1 through 50; and
- allergen safety triggers on `ORDER_ITEM`.

If SQL Server is unavailable, an invalid server name is configured, or the application cannot open `FreeBee`, the health and integration commands return an error instead of continuing with no database state.

## Connectivity Verification

The implementation was verified locally after initializing `FreeBee` from:

- [database/data/01_create_tables.sql](../../database/data/01_create_tables.sql)
- [database/data/02_sample_data.sql](../../database/data/02_sample_data.sql)
- [database/data/03_triggers.sql](../../database/data/03_triggers.sql)
- [database/queries/05_views_queries.sql](../../database/queries/05_views_queries.sql)

The Python health check successfully reported:

- server: `DESKTOP-4BQINDN\SQLEXPRESS`
- database: `FreeBee`
- connected: `true`

The customer 1 integration run successfully returned allergy records and a filtered safe-menu list. This demonstrates both database connectivity and schema-specific data retrieval.

## Supporting Screenshots

The following screenshots should be added to [docs/screenshots](../screenshots):

1. SQL Server Express running and the `FreeBee` database created.
2. A successful run of `python run_health_check.py`.
3. A successful customer 1 allergy retrieval.
4. A successful customer 1 safe-menu retrieval.
5. A successful optional customer insert.
6. A SQL Server query confirming that the inserted customer exists.
7. A duplicate-email or database-connection error demonstrating error handling.
