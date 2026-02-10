-- #######################################################
-- # 0. DATABASE ANLEGEN
-- #######################################################
CREATE DATABASE IF NOT EXISTS buchtausch_app;
USE buchtausch_app;

-- Optional: FK-Checks deaktivieren zum sauberen Droppen
SET FOREIGN_KEY_CHECKS = 0;

-- #######################################################
-- # 1. VORBEREITUNG (Tabellen löschen, falls existieren)
-- #######################################################
-- Alte Data-Mart-Tabellen müssen zuerst gelöscht werden, da sie die logischen Abhängigkeiten bilden
DROP TABLE IF EXISTS Fakt_Ausleihvorgang;
DROP TABLE IF EXISTS Dim_Buch;
DROP TABLE IF EXISTS Dim_Benutzer;

-- Dann die Normalisierungstabellen
DROP TABLE IF EXISTS BUCH_AUTOR_VERLAG;
DROP TABLE IF EXISTS AUSLEIHVORGAENGE;
DROP TABLE IF EXISTS BEWERTUNGEN;
DROP TABLE IF EXISTS STANDORTE;
DROP TABLE IF EXISTS BUECHER;
DROP TABLE IF EXISTS AUTOR;
DROP TABLE IF EXISTS VERLAG;
DROP TABLE IF EXISTS KATEGORIE;
DROP TABLE IF EXISTS SPRACHE;
DROP TABLE IF EXISTS ZUSTAND;
DROP TABLE IF EXISTS BENUTZER;
DROP TABLE IF EXISTS ROLLE;

SET FOREIGN_KEY_CHECKS = 1;

-- #######################################################
-- # 2. TABELLEN-DEFINITION (Normalisiertes Schema - 3NF)
-- #######################################################

CREATE TABLE ROLLE (
    rolle_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);

CREATE TABLE BENUTZER (
    benutzer_id INT AUTO_INCREMENT PRIMARY KEY,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    adresse VARCHAR(200),
    plz VARCHAR(10),
    stadt VARCHAR(50),
    telefon VARCHAR(20),
    registrierungsdatum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    rolle_id INT,
    FOREIGN KEY (rolle_id) REFERENCES ROLLE(rolle_id)
);

CREATE TABLE KATEGORIE (
    kategorie_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE SPRACHE (
    sprache_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE ZUSTAND (
    zustand_id INT AUTO_INCREMENT PRIMARY KEY,
    beschreibung VARCHAR(50) NOT NULL
);

CREATE TABLE AUTOR (
    autor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE VERLAG (
    verlag_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE BUECHER (
    buch_id INT AUTO_INCREMENT PRIMARY KEY,
    titel VARCHAR(100) NOT NULL,
    erscheinungsjahr INT,
    besitzer_id INT NOT NULL,
    kategorie_id INT,
    sprache_id INT,
    zustand_id INT,
    FOREIGN KEY (besitzer_id) REFERENCES BENUTZER(benutzer_id),
    FOREIGN KEY (kategorie_id) REFERENCES KATEGORIE(kategorie_id),
    FOREIGN KEY (sprache_id) REFERENCES SPRACHE(sprache_id),
    FOREIGN KEY (zustand_id) REFERENCES ZUSTAND(zustand_id)
);

CREATE TABLE BUCH_AUTOR_VERLAG (
    buch_id INT NOT NULL,
    autor_id INT NOT NULL,
    verlag_id INT NOT NULL,
    PRIMARY KEY (buch_id, autor_id, verlag_id),
    FOREIGN KEY (buch_id) REFERENCES BUECHER(buch_id),
    FOREIGN KEY (autor_id) REFERENCES AUTOR(autor_id),
    FOREIGN KEY (verlag_id) REFERENCES VERLAG(verlag_id)
);

CREATE TABLE AUSLEIHVORGAENGE (
    ausleih_id INT AUTO_INCREMENT PRIMARY KEY,
    buch_id INT NOT NULL,
    ausleiher_id INT NOT NULL,
    ausleihdatum DATE NOT NULL,
    rueckgabedatum DATE,
    status VARCHAR(20) DEFAULT 'ausgeliehen',
    FOREIGN KEY (buch_id) REFERENCES BUECHER(buch_id),
    FOREIGN KEY (ausleiher_id) REFERENCES BENUTZER(benutzer_id)
);

CREATE TABLE BEWERTUNGEN (
    bewertung_id INT AUTO_INCREMENT PRIMARY KEY,
    buch_id INT NOT NULL,
    benutzer_id INT NOT NULL,
    bewertung INT NOT NULL CHECK (bewertung BETWEEN 1 AND 5),
    kommentar TEXT,
    datum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (buch_id) REFERENCES BUECHER(buch_id),
    FOREIGN KEY (benutzer_id) REFERENCES BENUTZER(benutzer_id),
    UNIQUE (buch_id, benutzer_id)
);

CREATE TABLE STANDORTE (
    standort_id INT AUTO_INCREMENT PRIMARY KEY,
    benutzer_id INT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    buch_id INT,
    FOREIGN KEY (benutzer_id) REFERENCES BENUTZER(benutzer_id),
    FOREIGN KEY (buch_id) REFERENCES BUECHER(buch_id)
);

-- #######################################################
-- # 3. DATA MART (Star-Schema)
-- #######################################################

CREATE TABLE Dim_Benutzer (
    dim_benutzer_id INT PRIMARY KEY AUTO_INCREMENT,
    benutzer_id_fk INT UNIQUE NOT NULL,
    vollstaendiger_name VARCHAR(100) NOT NULL,
    stadt_plz VARCHAR(60),
    rolle_name VARCHAR(20),
    registrierungsdatum DATE
);

CREATE TABLE Dim_Buch (
    dim_buch_id INT PRIMARY KEY AUTO_INCREMENT,
    buch_id_fk INT NOT NULL,
    titel VARCHAR(100) NOT NULL,
    kategorie_name VARCHAR(50),
    sprache_name VARCHAR(30),
    zustand_beschreibung VARCHAR(50),
    autor_name VARCHAR(100),
    verlag_name VARCHAR(100),
    UNIQUE (buch_id_fk, autor_name, verlag_name)
);

CREATE TABLE Fakt_Ausleihvorgang (
    fact_id INT PRIMARY KEY AUTO_INCREMENT,
    dim_buch_id INT NOT NULL,
    dim_ausleiher_id INT NOT NULL,
    dim_besitzer_id INT NOT NULL,
    ausleihdatum DATE NOT NULL,
    rueckgabedatum DATE,
    anzahl_tage_ausgeliehen INT,
    durchschnitt_bewertung DECIMAL(2, 1),
    FOREIGN KEY (dim_buch_id) REFERENCES Dim_Buch(dim_buch_id),
    FOREIGN KEY (dim_ausleiher_id) REFERENCES Dim_Benutzer(dim_benutzer_id),
    FOREIGN KEY (dim_besitzer_id) REFERENCES Dim_Benutzer(dim_benutzer_id)
);

-- #######################################################
-- # 4. STAMMDATEN EINPFLEGEN (10+ Einträge)
-- #######################################################

-- ROLLE (3 Einträge, >10 nicht sinnvoll)
INSERT INTO ROLLE (name) VALUES
('Administrator'),
('Benutzer'),
('Gast');

-- ZUSTAND (5 Einträge, >10 nicht sinnvoll)
INSERT INTO ZUSTAND (beschreibung) VALUES
('Neu'),
('Gebraucht, sehr gut'),
('Gebraucht, gut'),
('Gebraucht, akzeptabel'),
('Starke Gebrauchsspuren');

-- SPRACHE (3 Einträge, >10 nicht sinnvoll)
INSERT INTO SPRACHE (name) VALUES
('Deutsch'),
('Englisch'),
('Französisch');

-- KATEGORIE (12 Einträge)
INSERT INTO KATEGORIE (name) VALUES
('Romantik'), -- 1
('Thriller'), -- 2
('Sachbuch'), -- 3
('Science Fiction'), -- 4
('Fantasy'), -- 5
('Krimi'), -- 6
('Kinderbuch'), -- 7
('Historischer Roman'), -- 8
('Biografie'), -- 9
('Hörspiel'), -- 10
('Klassiker'), -- 11
('Dystopie'); -- 12

-- BENUTZER (11 Einträge)
INSERT INTO BENUTZER (vorname, nachname, email, adresse, plz, stadt, telefon, rolle_id)
VALUES
('Max', 'Mustermann', 'max@example.com', 'Musterstr. 1', '12345', 'Berlin', '030123456', 2), -- 1
('Anna', 'Schmidt', 'anna@example.com', 'Beispielweg 42', '54321', 'Hamburg', '040765432', 2), -- 2
('Lisa', 'Müller', 'lisa@example.com', 'Testallee 10', '67890', 'München', '0891234567', 1), -- 3 (Admin)
('Tom', 'Braun', 'tom@example.com', 'Birkenweg 5', '20095', 'Hamburg', '040987654', 2), -- 4
('Clara', 'Weber', 'clara@example.com', 'Hauptstr. 12', '10115', 'Berlin', '030456789', 2), -- 5
('Felix', 'Koch', 'felix@example.com', 'Rheinstr. 3', '60329', 'Frankfurt', '069112233', 2), -- 6
('Jana', 'Lehmann', 'jana@example.com', 'Seeweg 7', '80331', 'München', '0899876543', 2), -- 7
('Marc', 'Fischer', 'marc@example.com', 'Dorfplatz 1', '28195', 'Bremen', '042154321', 2), -- 8
('Emilia', 'Meier', 'emilia@example.com', 'Ahornweg 15', '40210', 'Düsseldorf', '021167890', 2), -- 9
('Paul', 'König', 'paul@example.com', 'Am Markt 8', '70173', 'Stuttgart', '071134567', 2), -- 10
('Gast', 'Leser', 'gast@example.com', NULL, NULL, NULL, NULL, 3); -- 11 (Gast)

-- AUTOR (11 Einträge)
INSERT INTO AUTOR (name) VALUES
('Joanne K. Rowling'), -- 1
('Stephen King'), -- 2
('Ernest Hemingway'), -- 3
('Jane Austen'), -- 4
('George Orwell'), -- 5
('Ken Follett'), -- 6
('Astrid Lindgren'), -- 7
('Juli Zeh'), -- 8
('Sebastian Fitzek'), -- 9
('Mark Twain'), -- 10
('Mary Shelley'); -- 11

-- VERLAG (11 Einträge)
INSERT INTO VERLAG (name) VALUES
('Carlsen Verlag'), -- 1
('Random House'), -- 2
('Diogenes Verlag'), -- 3
('Penguin Books'), -- 4
('HarperCollins'), -- 5
('Fischer Verlag'), -- 6
('dtv'), -- 7
('Klett-Cotta'), -- 8
('Suhrkamp Verlag'), -- 9
('Luchterhand Literaturverlag'), -- 10
('Aufbau Verlag'); -- 11

-- BUECHER (11 Einträge)
INSERT INTO BUECHER (titel, erscheinungsjahr, besitzer_id, kategorie_id, sprache_id, zustand_id)
VALUES
('Harry Potter und der Stein der Weisen', 1997, 1, 5, 1, 2), -- 1 (Max)
('Der Herr der Ringe', 1954, 2, 5, 1, 1), -- 2 (Anna)
('Shining', 1977, 1, 2, 1, 3), -- 3 (Max)
('Stolz und Vorurteil', 1813, 4, 1, 2, 2), -- 4 (Tom)
('1984', 1949, 5, 4, 2, 4), -- 5 (Clara)
('Die Säulen der Erde', 1989, 6, 8, 1, 1), -- 6 (Felix)
('Pippi Langstrumpf', 1945, 7, 7, 1, 5), -- 7 (Jana)
('Unterleuten', 2016, 8, 2, 1, 2), -- 8 (Marc)
('Das Paket', 2016, 9, 6, 1, 3), -- 9 (Emilia)
('Tom Sawyer', 1876, 10, 11, 2, 2), -- 10 (Paul)
('Frankenstein', 1818, 1, 4, 2, 1); -- 11 (Max)

-- BUCH_AUTOR_VERLAG (n:m-Beziehung, 11 Einträge)
INSERT INTO BUCH_AUTOR_VERLAG (buch_id, autor_id, verlag_id) VALUES
(1, 1, 1),
(2, 3, 8),
(3, 2, 2),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6),
(7, 7, 1),
(8, 8, 9),
(9, 9, 6),
(10, 10, 5),
(11, 11, 4);

-- AUSLEIHVORGAENGE (10 Einträge)
INSERT INTO AUSLEIHVORGAENGE (buch_id, ausleiher_id, ausleihdatum, rueckgabedatum, status)
VALUES
(1, 2, '2023-10-01', '2023-11-01', 'zurückgegeben'),
(3, 3, '2023-11-15', '2023-12-15', 'ausgeliehen'),
(4, 1, '2023-12-01', '2024-01-01', 'zurückgegeben'),
(5, 6, '2024-01-05', '2024-02-05', 'zurückgegeben'),
(6, 4, '2024-02-10', '2024-03-10', 'zurückgegeben'),
(8, 5, '2024-03-15', NULL, 'ausgeliehen'),
(9, 7, '2024-04-01', '2024-04-20', 'zurückgegeben'),
(10, 9, '2024-04-10', '2024-05-10', 'zurückgegeben'),
(11, 2, '2024-05-15', NULL, 'ausgeliehen'),
(1, 4, '2024-06-01', '2024-07-01', 'zurückgegeben');

-- BEWERTUNGEN (12 Einträge)
INSERT INTO BEWERTUNGEN (buch_id, benutzer_id, bewertung, kommentar)
VALUES
(1, 2, 5, 'Tolles Buch!'),
(3, 3, 4, 'Spannend, aber etwas gruselig.'),
(4, 1, 5, 'Ein zeitloser Klassiker der Romantik.'),
(5, 6, 3, 'Schwierige Lektüre, aber wichtig.'),
(6, 4, 5, 'Episch und fesselnd!'),
(8, 5, 4, 'Tolle Dorfgeschichte.'),
(9, 7, 5, 'Sebastian Fitzek enttäuscht nie.'),
(10, 9, 4, 'Für Kinder und Erwachsene ein Spaß.'),
(11, 2, 5, 'Absoluter Klassiker der Science Fiction.'),
(1, 4, 4, 'Guter Wiedereinstieg in die Serie.'),
(6, 6, 5, 'Noch eine tolle Bewertung für die Säulen.'),
(10, 8, 3, 'Etwas langatmig.');

-- STANDORTE (12 Einträge)
INSERT INTO STANDORTE (benutzer_id, latitude, longitude, buch_id)
VALUES
(1, 52.520008, 13.404954, NULL), -- 1. Max (Berlin)
(2, 53.551086, 9.993682, NULL), -- 2. Anna (Hamburg)
(3, 48.135125, 11.581981, NULL), -- 3. Lisa (München)
(4, 53.551086, 9.993682, NULL), -- 4. Tom (Hamburg)
(5, 52.520008, 13.404954, NULL), -- 5. Clara (Berlin)
(6, 50.110924, 8.682127, NULL), -- 6. Felix (Frankfurt)
(7, 48.135125, 11.581981, NULL), -- 7. Jana (München)
(8, 53.079296, 8.801694, NULL), -- 8. Marc (Bremen)
(9, 51.227741, 6.773456, NULL), -- 9. Emilia (Düsseldorf)
(10, 48.775840, 9.182932, NULL), -- 10. Paul (Stuttgart)
(1, 52.520000, 13.404900, 1), -- 11. Buch 1 bei Max
(6, 50.110900, 8.682100, 6); -- 12. Buch 6 bei Felix

-- #######################################################
-- # 5. BEFÜLLEN DER DIMENSIONSTABELLEN
-- # KORREKTUR: Temporäre Deaktivierung der FK-Checks für TRUNCATE
-- #######################################################

-- Deaktivierung der Fremdschlüssel-Prüfungen
SET FOREIGN_KEY_CHECKS = 0;

-- Leeren der Tabellen in beliebiger Reihenfolge (da FK-Checks deaktiviert sind)
TRUNCATE TABLE Fakt_Ausleihvorgang;
TRUNCATE TABLE Dim_Buch;
TRUNCATE TABLE Dim_Benutzer;

-- Reaktivierung der Fremdschlüssel-Prüfungen
SET FOREIGN_KEY_CHECKS = 1;


INSERT INTO Dim_Benutzer (
    benutzer_id_fk, vollstaendiger_name, stadt_plz, rolle_name, registrierungsdatum
)
SELECT
    B.benutzer_id,
    CONCAT(B.vorname, ' ', B.nachname),
    CONCAT(B.plz, ' ', B.stadt),
    R.name,
    DATE(B.registrierungsdatum)
FROM BENUTZER B
JOIN ROLLE R ON B.rolle_id = R.rolle_id;

INSERT INTO Dim_Buch (
    buch_id_fk, titel, kategorie_name, sprache_name, zustand_beschreibung,
    autor_name, verlag_name
)
SELECT
    B.buch_id,
    B.titel,
    K.name,
    S.name,
    Z.beschreibung,
    A.name,
    V.name
FROM BUECHER B
JOIN KATEGORIE K ON B.kategorie_id = K.kategorie_id
JOIN SPRACHE S ON B.sprache_id = S.sprache_id
JOIN ZUSTAND Z ON B.zustand_id = Z.zustand_id
JOIN BUCH_AUTOR_VERLAG BAV ON B.buch_id = BAV.buch_id
JOIN AUTOR A ON BAV.autor_id = A.autor_id
JOIN VERLAG V ON BAV.verlag_id = V.verlag_id;

-- #######################################################
-- # 6. FACT-TABELLE BEFÜLLEN
-- #######################################################
INSERT INTO Fakt_Ausleihvorgang (
    dim_buch_id, dim_ausleiher_id, dim_besitzer_id,
    ausleihdatum, rueckgabedatum, anzahl_tage_ausgeliehen, durchschnitt_bewertung
)
SELECT
    DB.dim_buch_id,
    D_Aus.dim_benutzer_id,
    D_Bes.dim_benutzer_id,
    A.ausleihdatum,
    A.rueckgabedatum,
    DATEDIFF(COALESCE(A.rueckgabedatum, CURRENT_DATE()), A.ausleihdatum),
    (SELECT AVG(bewertung) FROM BEWERTUNGEN WHERE buch_id = A.buch_id)
FROM AUSLEIHVORGAENGE A
JOIN Dim_Buch DB ON DB.buch_id_fk = A.buch_id
JOIN BUECHER B ON B.buch_id = A.buch_id
JOIN Dim_Benutzer D_Aus ON D_Aus.benutzer_id_fk = A.ausleiher_id
JOIN Dim_Benutzer D_Bes ON D_Bes.benutzer_id_fk = B.besitzer_id;
-- #######################################################
-- # 7. OPTIMIERUNG (Umsetzung Feedback Phase 2)
-- #######################################################

-- Indizes auf häufig genutzte Fremdschlüssel zur Performance-Steigerung
CREATE INDEX idx_buch_besitzer ON BUECHER(besitzer_id);
CREATE INDEX idx_ausleihe_buch ON AUSLEIHVORGAENGE(buch_id);
CREATE INDEX idx_ausleihe_nutzer ON AUSLEIHVORGAENGE(ausleiher_id);
CREATE INDEX idx_bewertung_buch ON BEWERTUNGEN(buch_id);

-- Index für geografische Suchen (Standorte)
CREATE INDEX idx_standort_koordinaten ON STANDORTE(latitude, longitude);
