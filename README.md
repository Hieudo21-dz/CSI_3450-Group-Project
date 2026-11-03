# Group Project– CSI 3450

Final project for **CSI 3450 – Database Design & Implementation** (Fall 2026).

<!-- Replace with a 2–3 sentence description once you choose your idea: the problem, who it's for, and what the app does. -->
A relational database built in **Microsoft SQL Server** and connected to a **web application / API** (TBD).

---

## Tech Stack

<!-- fill in once decided -->
- **Database:** Microsoft SQL Server
- **Application:** TBD (e.g. Python/Flask, Java/Spring Boot, ASP.NET, PHP, Node.js)
- **Driver / connector:** TBD (e.g. pyodbc, JDBC, ADO.NET)

---

## Project Structure

```
CSI3450_Final_Project/
├── database/
│   ├── schema/          # CREATE TABLE scripts, keys, constraints
│   ├── data/            # INSERT scripts and sample data
│   ├── queries/         # Retrieval, reporting, and management queries
│   └── all_queries.txt  # All SQL combined (required for submission)
├── app/                 # Web app or API source code and config
├── docs/
│   ├── diagrams/        # ER model and relational diagram
│   ├── data-dictionary/ # Tables, attributes, types, constraints
│   ├── screenshots/     # Proof of connectivity and functionality
│   ├── report/          # Project report (.docx / .pdf)
│   └── presentation/    # Slides (.ppt / .pptx / .pdf)
├── .gitignore
└── README.md
```

---

## Requirements Checklist

**Database**
- [ ] Tables, attributes, primary and foreign keys, relationships, constraints
- [ ] Proper data types and normalization
- [ ] Sufficient sample data
- [ ] SQL for creating, populating, and managing the database
- [ ] Meaningful retrieval and reporting queries
- [ ] All SQL combined into `database/all_queries.txt`

**Connectivity**
- [ ] Working connection between SQL Server and the app/API
- [ ] Data retrieval through the app
- [ ] Data insertion and/or updating through the app
- [ ] Error handling for database errors and invalid requests
- [ ] Screenshots of it working

**Report** (.docx or .pdf)
- [ ] Group information and project title
- [ ] Abstract
- [ ] Business rules and database requirements
- [ ] Data dictionary
- [ ] ER model
- [ ] Relational model
- [ ] Database implementation
- [ ] Connectivity and integration (with screenshots)
- [ ] Division of work
- [ ] Challenges and solutions
- [ ] Queries and reports

**Presentation**
- [ ] Overview, design, ER and relational models, implementation, queries, connectivity
- [ ] Live demo or recorded walkthrough
- [ ] Outcomes, division of work, challenges

**Submission**
- [ ] One ZIP named `Final_YourGroupName.zip` with the implementation, report, and slides

---

## Setup

<!-- fill in once the app is built: how to create the database, configure the connection, and run the app -->
1. Run the scripts in `database/schema/`, then `database/data/`, in SQL Server.
2. Set up the database connection for the app (keep credentials out of the repo).
3. Run the app.
