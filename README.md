# Buchtausch-App DBMS

Willkommen im Repository der **Buchtausch-App** – einem relationalen Datenbankmanagementsystem für den Austausch von Büchern innerhalb einer Community.

---
## Über das Projekt

Die **Buchtausch-App** ist eine soziale Plattform für Literaturliebhaber:innen, die es ermöglicht, private Buchbestände zu katalogisieren, geografisch zu verorten und innerhalb einer Community auszutauschen. Das Projekt wurde im Rahmen eines **Portfolio-Kurses für Datenbankmanagement-Systeme** entwickelt und deckt den **vollständigen Lebenszyklus einer Datenbank** ab:

- **Konzeptionelles Design**: Erstellung des ER-Modells und der Geschäftslogik.
- **Relationale Implementierung (OLTP)**: Umsetzung in die 3. Normalform für maximale Datenintegrität.
- **Analytische Auswertung (OLAP)**: Implementierung eines Star-Schemas für Business Intelligence.

---
## 🔍 Technische Highlights

- **Hybrides Architektur-Design**:
  - **Operatives Schema (3NF)**: Gewährleistet Transaktionssicherheit und verhindert Redundanzen.
  - **Analytischer Data Mart (Star-Schema)**: Ermöglicht performante Abfragen über Ausleihgewohnheiten und Trends.

- **Komplexe Beziehungsmodellierung**:
  - Auflösung von **n:m:m-Beziehungen** zwischen Büchern, Autoren und Verlagen.
  - **Geodaten-Integration** für standortbasierte Funktionen.

- **Optimierte Performance**:
  - Gezielte Indizierung von Fremdschlüsseln und Koordinaten.
  - **ACID-Konformität** durch MariaDB 11.x + InnoDB.

---
## 🛠 Technologie-Stack

| **Komponente**       | **Tool / Version**          |
|----------------------|----------------------------|
| Datenbank            | MariaDB 11.x (InnoDB)      |
| Betriebssystem       | Arch Linux                 |
| SQL-Client           | DBeaver 25.x               |
| Modellierung         | Crow's Foot Notation (ER-Diagramm) |

---
## 📊 Architektur & Datenbankstruktur

Das System umfasst **15 Tabellen**, die wie folgt gegliedert sind:

### Operatives Schema
- Benutzerverwaltung: Profile, Rollen und Berechtigungen.
- Katalogisierung: Buchmetadaten (Kategorien, Sprachen, Zustand).
- Transaktionen: Leihprozesse und Bewertungssystem.
- Geolokalisierung: Standorte via Latitude/Longitude.

### Analytischer Data Mart
- **Fakten-Tabelle**: `Fakt_Ausleihvorgang` (zentrale Metrik für Analysen).
- **Dimensionstabellen**: `Dim_Buch` und `Dim_Benutzer` für schnelle Aggregationen.

---
## 📥 Installation & Setup

1. **Repository klonen**
   ```bash
   git clone https://github.com/dannybutczynsky/Buchtausch_App_DBMS.git
