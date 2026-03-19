-- =========================================
-- TWORZENIE TABEL I PODSTAWOWYCH REGUŁ
-- =========================================

CREATE TABLE Specjalizacja (
    KodSpecjalizacji VARCHAR(3) NOT NULL, -- Reg/21: Max 3 znaki
    NazwaSpecjalizacji VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Specjalizacja PRIMARY KEY (KodSpecjalizacji)
);

CREATE TABLE Szpital (
    Regon VARCHAR(14) NOT NULL,
    Nazwa VARCHAR(255) NOT NULL,
    Adres VARCHAR(255) NOT NULL,
    KodPocztowy VARCHAR(6) NOT NULL,
    NumerTelefonu VARCHAR(15) NOT NULL,
    NIP CHAR(10) NOT NULL,
    KRS CHAR(10) NOT NULL,
    CONSTRAINT PK_Szpital PRIMARY KEY (Regon),
    CONSTRAINT UQ_Szpital_NIP UNIQUE (NIP), -- Reg/02
    CONSTRAINT UQ_Szpital_KRS UNIQUE (KRS), -- Reg/03
    CONSTRAINT CHK_Szpital_NIP CHECK (LEN(NIP) = 10), -- Reg/05
    CONSTRAINT CHK_Szpital_KRS CHECK (LEN(KRS) = 10), -- Reg/06
    CONSTRAINT CHK_Szpital_Regon CHECK (LEN(Regon) = 9 OR LEN(Regon) = 14) -- Reg/07
);

CREATE TABLE Oddzial (
    RegonSzpitala VARCHAR(14) NOT NULL,
    KodSpecjalizacji VARCHAR(3) NOT NULL,
    Nazwa VARCHAR(255) NOT NULL, -- Reg/09
    LiczbaLozek INT NOT NULL,
    CONSTRAINT PK_Oddzial PRIMARY KEY (RegonSzpitala, KodSpecjalizacji),
    CONSTRAINT FK_Oddzial_Szpital FOREIGN KEY (RegonSzpitala) REFERENCES Szpital(Regon), -- Reg/08
    CONSTRAINT FK_Oddzial_Specjalizacja FOREIGN KEY (KodSpecjalizacji) REFERENCES Specjalizacja(KodSpecjalizacji), -- Reg/10
    CONSTRAINT CHK_Oddzial_LiczbaLozek CHECK (LiczbaLozek > 0) -- Reg/11
);

CREATE TABLE Choroba (
    ICD10 VARCHAR(10) NOT NULL,
    Nazwa VARCHAR(255) NOT NULL,
    Opis VARCHAR(MAX) NULL,
    CONSTRAINT PK_Choroba PRIMARY KEY (ICD10) -- Reg/27
);

CREATE TABLE Pacjent (
    PESEL CHAR(11) NOT NULL,
    Imie VARCHAR(100) NOT NULL,
    Nazwisko VARCHAR(100) NOT NULL,
    DataUrodzenia DATE NOT NULL,
    Adres VARCHAR(255) NOT NULL,
    NumerTelefonu VARCHAR(15) NULL,
    Plec CHAR(1) NOT NULL,
    CONSTRAINT PK_Pacjent PRIMARY KEY (PESEL),
    CONSTRAINT CHK_Pacjent_PESEL CHECK (LEN(PESEL) = 11), -- Reg/14
    CONSTRAINT CHK_Pacjent_Plec CHECK (Plec IN ('M', 'K')), -- Reg/17
    CONSTRAINT CHK_Pacjent_DataUr CHECK (DataUrodzenia <= CAST(GETDATE() AS DATE)) -- Reg/23
);

CREATE TABLE Lekarz (
    NPWZ CHAR(7) NOT NULL,
    PESEL CHAR(11) NOT NULL,
    Imie VARCHAR(100) NOT NULL,
    Nazwisko VARCHAR(100) NOT NULL,
    KodSpecjalizacji VARCHAR(3) NULL,
    DataUrodzenia DATE NOT NULL,
    DataZatrudnienia DATE NOT NULL,
    Adres VARCHAR(255) NOT NULL,
    NumerTelefonu VARCHAR(15) NULL,
    CONSTRAINT PK_Lekarz PRIMARY KEY (NPWZ), -- Reg/12
    CONSTRAINT UQ_Lekarz_PESEL UNIQUE (PESEL), -- Reg/15
    CONSTRAINT CHK_Lekarz_NPWZ CHECK (LEN(NPWZ) = 7), -- Reg/13
    CONSTRAINT CHK_Lekarz_PESEL CHECK (LEN(PESEL) = 11), -- Reg/14
    CONSTRAINT FK_Lekarz_Specjalizacja FOREIGN KEY (KodSpecjalizacji) REFERENCES Specjalizacja(KodSpecjalizacji),
    CONSTRAINT CHK_Lekarz_Daty CHECK (DataZatrudnienia > DataUrodzenia), -- Reg/16
    CONSTRAINT CHK_Lekarz_DataUr CHECK (DataUrodzenia <= CAST(GETDATE() AS DATE)), -- Reg/23
    CONSTRAINT CHK_Lekarz_DataZatrudnienia CHECK (DataZatrudnienia <= CAST(GETDATE() AS DATE)) -- Reg/24
);

CREATE TABLE Diagnoza (
    IdDiagnozy INT IDENTITY(1,1) NOT NULL, -- Klucz sztuczny
    DataGodzinaDiagnozy DATETIME NOT NULL,
    ICD10 VARCHAR(10) NOT NULL,
    NPWZ CHAR(7) NOT NULL,
    PESEL_Pacjenta CHAR(11) NOT NULL,
    WynikBadania VARCHAR(MAX) NULL,
    Zalecenia VARCHAR(MAX) NULL,
    CONSTRAINT PK_Diagnoza PRIMARY KEY (IdDiagnozy),

    CONSTRAINT FK_Diagnoza_Choroba FOREIGN KEY (ICD10) REFERENCES Choroba(ICD10), -- Reg/20
    CONSTRAINT FK_Diagnoza_Lekarz FOREIGN KEY (NPWZ) REFERENCES Lekarz(NPWZ), -- Reg/18
    CONSTRAINT FK_Diagnoza_Pacjent FOREIGN KEY (PESEL_Pacjenta) REFERENCES Pacjent(PESEL), -- Reg/19
    CONSTRAINT CHK_Diagnoza_DataGodzina CHECK (DataGodzinaDiagnozy <= GETDATE()) -- Reg/25
);

CREATE TABLE Przyjecie (
    IdPrzyjecia INT IDENTITY(1,1) NOT NULL, -- Klucz sztuczny
    RegonSzpitala VARCHAR(14) NOT NULL,
    KodSpecjalizacji VARCHAR(3) NOT NULL,
    PESEL_Pacjenta CHAR(11) NOT NULL,
    DataPrzyjecia DATE NOT NULL,
    CONSTRAINT PK_Przyjecie PRIMARY KEY (IdPrzyjecia),

    CONSTRAINT FK_Przyjecie_Oddzial FOREIGN KEY (RegonSzpitala, KodSpecjalizacji) REFERENCES Oddzial(RegonSzpitala, KodSpecjalizacji),
    CONSTRAINT FK_Przyjecie_Pacjent FOREIGN KEY (PESEL_Pacjenta) REFERENCES Pacjent(PESEL),
    CONSTRAINT CHK_Przyjecie_Data CHECK (DataPrzyjecia <= CAST(GETDATE() AS DATE)) -- Reg/28
);

GO

-- =========================================
-- WYZWALACZE (TRIGGERS) DLA ZŁOŻONYCH REGUŁ
-- =========================================

-- Reg/26: Data wystawienia diagnozy musi być większa niż data zatrudnienia lekarza.
-- Ograniczenie to wymaga sprawdzenia danych w innej tabeli (Lekarz), więc używamy wyzwalacza.

CEATE TRIGGER trg_SprawdzDateDiagnozy_Zatrudnienie
ON Diagnoza
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Lekarz l ON i.NPWZ = l.NPWZ
        WHERE i.DataGodzinaDiagnozy <= CAST(l.DataZatrudnienia AS DATETIME)
    )
    BEGIN
        RAISERROR ('Reg/26: Data i godzina diagnozy musi być chronologicznie późniejsza niż data zatrudnienia lekarza wystawiającego diagnozę.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO