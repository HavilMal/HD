-- =========================================================================
-- KOMPLETNY SKRYPT TESTOWY OGRANICZEŃ DZIEDZINOWYCH (REGUŁY 01-28)
-- =========================================================================

BEGIN TRANSACTION;
GO

-- DODATEK DLA REG/28: Dodanie fizycznego sprawdzenia kodu pocztowego (XX-XXX)
ALTER TABLE Szpital
    ADD CONSTRAINT CHK_Szpital_KodPocztowy
        CHECK (KodPocztowy LIKE '[0-9][0-9]-[0-9][0-9][0-9]');
GO

PRINT '==================================================';
PRINT ' ETAP 1: WPROWADZENIE POPRAWNYCH DANYCH BAZOWYCH';
PRINT '==================================================';

-- Wprowadzamy poprawne dane, które posłużą jako fundament do testów (brak błędów)
INSERT INTO Specjalizacja (KodSpecjalizacji, NazwaSpecjalizacji)
VALUES ('53', 'Kardiologia');

INSERT INTO Szpital (Regon, Nazwa, Adres, KodPocztowy, NumerTelefonu, NIP, KRS)
VALUES ('111111111', 'Szpital Bazowy', 'ul. Baza 1', '00-111', '123456789', '1111111111', '1111111111');

INSERT INTO Oddzial (RegonSzpitala, KodSpecjalizacji, Nazwa, LiczbaLozek)
VALUES ('111111111', '53', 'Oddział Kardiologiczny', 50);

INSERT INTO Choroba (ICD10, Nazwa, Opis)
VALUES ('I50', 'Niewydolność serca', 'Opis');

INSERT INTO Pacjent (PESEL, Imie, Nazwisko, DataUrodzenia, Adres, NumerTelefonu, Plec)
VALUES ('90010100000', 'Jan', 'Kowalski', '1990-01-01', 'ul. Leśna 1', '500600700', 'M');

INSERT INTO Lekarz (NPWZ, PESEL, Imie, Nazwisko, KodSpecjalizacji, DataUrodzenia, DataZatrudnienia, Adres,
                    NumerTelefonu)
VALUES ('1111111', '80010100000', 'Adam', 'Lekarski', '53', '1980-01-01', '2010-01-01', 'ul. Szpitalna 2', '600700800');

PRINT 'OK: Dane bazowe zostały załadowane pomyślnie.';
GO

PRINT '==================================================';
PRINT ' ETAP 2: TESTOWANIE NARUSZEŃ REGUŁ (BŁĘDY)';
PRINT '==================================================';

PRINT CHAR(10) + '--- TABELA: Specjalizacja ---';
-- [NIEPOPRAWNE] Reg/20: Kod specjalizacji max 3 znaki
-- Oczekiwany błąd: String or binary data would be truncated.
INSERT INTO Specjalizacja (KodSpecjalizacji, NazwaSpecjalizacji)
VALUES ('1290', 'Kardiologia dziecięca');
GO


PRINT CHAR(10) + '--- TABELA: Szpital ---';
-- [NIEPOPRAWNE] Reg/01: NIP musi być unikalny
-- Oczekiwany błąd: Violation of UNIQUE KEY constraint 'UQ_Szpital_NIP'.
INSERT INTO Szpital (Regon, Nazwa, Adres, KodPocztowy, NumerTelefonu, NIP, KRS)
VALUES ('222222222', 'Szpital Drugi', 'ul. B', '00-222', '123', '1111111111', '2222222222');
GO

-- [NIEPOPRAWNE] Reg/02: KRS musi być unikalny
-- Oczekiwany błąd: Violation of UNIQUE KEY constraint 'UQ_Szpital_KRS'.
INSERT INTO Szpital (Regon, Nazwa, Adres, KodPocztowy, NumerTelefonu, NIP, KRS)
VALUES ('333333333', 'Szpital Trzeci', 'ul. C', '00-333', '123', '3333333333', '1111111111');
GO

-- [NIEPOPRAWNE] Reg/03: Regon musi być unikalny (Klucz główny)
-- Oczekiwany błąd: Violation of PRIMARY KEY constraint 'PK_Szpital'.
INSERT INTO Szpital (Regon, Nazwa, Adres, KodPocztowy, NumerTelefonu, NIP, KRS)
VALUES ('111111111', 'Szpital Duplikat', 'ul. D', '00-444', '123', '4444444444', '4444444444');
GO

-- [NIEPOPRAWNE] Reg/04: NIP ma 10 cyfr (wpisujemy 9)
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Szpital_NIP".
INSERT INTO Szpital (Regon, Nazwa, Adres, KodPocztowy, NumerTelefonu, NIP, KRS)
VALUES ('555555555', 'Szpital Zły NIP', 'ul. E', '00-555', '123', '555555555', '5555555555');
GO

-- [NIEPOPRAWNE] Reg/05: KRS ma 10 cyfr (wpisujemy 8)
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Szpital_KRS".
INSERT INTO Szpital (Regon, Nazwa, Adres, KodPocztowy, NumerTelefonu, NIP, KRS)
VALUES ('666666666', 'Szpital Zły KRS', 'ul. F', '00-666', '123', '6666666666', '66666666');
GO

-- [NIEPOPRAWNE] Reg/06: Regon ma 9 lub 14 cyfr (wpisujemy 10)
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Szpital_Regon".
INSERT INTO Szpital (Regon, Nazwa, Adres, KodPocztowy, NumerTelefonu, NIP, KRS)
VALUES ('7777777770', 'Szpital Zły Regon', 'ul. G', '00-777', '123', '7777777777', '7777777777');
GO

-- [NIEPOPRAWNE] Reg/28: Kod pocztowy bez myślnika
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Szpital_KodPocztowy".
INSERT INTO Szpital (Regon, Nazwa, Adres, KodPocztowy, NumerTelefonu, NIP, KRS)
VALUES ('888888888', 'Szpital Zły Kod', 'ul. H', '000888', '123', '8888888888', '8888888888');
GO


PRINT CHAR(10) + '--- TABELA: Oddział ---';
-- [NIEPOPRAWNE] Reg/07: Każdy oddział musi należeć do jednego szpitala (brakujący szpital)
-- Oczekiwany błąd: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Oddzial_Szpital".
INSERT INTO Oddzial (RegonSzpitala, KodSpecjalizacji, Nazwa, LiczbaLozek)
VALUES ('999999999', '53', 'Oddział w Kosmosie', 20);
GO

-- [NIEPOPRAWNE] Reg/08: Brak nazwy oddziału (próba wstawienia NULL)
-- Oczekiwany błąd: Cannot insert the value NULL into column 'Nazwa'.
INSERT INTO Oddzial (RegonSzpitala, KodSpecjalizacji, Nazwa, LiczbaLozek)
VALUES ('111111111', '53', NULL, 10);
GO

-- [NIEPOPRAWNE] Reg/09: Oddział musi mieć przypisaną specjalizację z bazy
-- Oczekiwany błąd: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Oddzial_Specjalizacja".
INSERT INTO Oddzial (RegonSzpitala, KodSpecjalizacji, Nazwa, LiczbaLozek)
VALUES ('111111111', 'XYZ', 'Oddział XYZ', 10);
GO

-- [NIEPOPRAWNE] Reg/10: Liczba łóżek > 0 (wpisujemy 0)
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Oddzial_LiczbaLozek".
INSERT INTO Oddzial (RegonSzpitala, KodSpecjalizacji, Nazwa, LiczbaLozek)
VALUES ('111111111', '53', 'Oddział Zamknięty', 0);
GO


PRINT CHAR(10) + '--- TABELA: Choroba ---';
-- [NIEPOPRAWNE] Reg/26: Choroba musi mieć unikalny kod ICD-10 (Próba duplikacji 'I50')
-- Oczekiwany błąd: Violation of PRIMARY KEY constraint 'PK_Choroba'.
INSERT INTO Choroba (ICD10, Nazwa, Opis)
VALUES ('I50', 'Inna nazwa', 'Inny opis');
GO


PRINT CHAR(10) + '--- TABELA: Pacjent ---';
-- [NIEPOPRAWNE] Reg/13: PESEL pacjenta musi mieć 11 cyfr (wpisujemy 10)
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Pacjent_PESEL".
INSERT INTO Pacjent (PESEL, Imie, Nazwisko, DataUrodzenia, Adres, NumerTelefonu, Plec)
VALUES ('9001010000', 'Anna', 'Krótka', '1990-01-01', 'ul. A', '123', 'K');
GO

-- [NIEPOPRAWNE] Reg/16: Płeć to tylko M lub K
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Pacjent_Plec".
INSERT INTO Pacjent (PESEL, Imie, Nazwisko, DataUrodzenia, Adres, NumerTelefonu, Plec)
VALUES ('91020211111', 'X', 'Y', '1991-02-02', 'ul. B', '123', 'X');
GO

-- [NIEPOPRAWNE] Reg/22: Data urodzenia nie może być z przyszłości
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Pacjent_DataUr".
INSERT INTO Pacjent (PESEL, Imie, Nazwisko, DataUrodzenia, Adres, NumerTelefonu, Plec)
VALUES ('99010122222', 'Jan', 'Przyszły', '2050-01-01', 'ul. C', '123', 'M');
GO


PRINT CHAR(10) + '--- TABELA: Lekarz ---';
-- [NIEPOPRAWNE] Reg/11: Unikalny NPWZ (Próba duplikacji '1111111')
-- Oczekiwany błąd: Violation of PRIMARY KEY constraint 'PK_Lekarz'.
INSERT INTO Lekarz (NPWZ, PESEL, Imie, Nazwisko, KodSpecjalizacji, DataUrodzenia, DataZatrudnienia, Adres,
                    NumerTelefonu)
VALUES ('1111111', '81010100000', 'Piotr', 'Drugi', '53', '1981-01-01', '2015-01-01', 'ul. A', '123');
GO

-- [NIEPOPRAWNE] Reg/12: NPWZ ma 7 cyfr (wpisujemy 5)
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Lekarz_NPWZ".
INSERT INTO Lekarz (NPWZ, PESEL, Imie, Nazwisko, KodSpecjalizacji, DataUrodzenia, DataZatrudnienia, Adres,
                    NumerTelefonu)
VALUES ('12345', '82010100000', 'Tomasz', 'Krótki', '53', '1982-01-01', '2015-01-01', 'ul. B', '123');
GO

-- [NIEPOPRAWNE] Reg/14: PESEL lekarza musi być unikalny (Próba duplikacji '80010100000')
-- Oczekiwany błąd: Violation of UNIQUE KEY constraint 'UQ_Lekarz_PESEL'.
INSERT INTO Lekarz (NPWZ, PESEL, Imie, Nazwisko, KodSpecjalizacji, DataUrodzenia, DataZatrudnienia, Adres,
                    NumerTelefonu)
VALUES ('2222222', '80010100000', 'Ewa', 'Klon', '53', '1980-01-01', '2015-01-01', 'ul. C', '123');
GO

-- [NIEPOPRAWNE] Reg/15: Data zatrudnienia wcześniejsza niż data urodzenia
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Lekarz_Daty".
INSERT INTO Lekarz (NPWZ, PESEL, Imie, Nazwisko, KodSpecjalizacji, DataUrodzenia, DataZatrudnienia, Adres,
                    NumerTelefonu)
VALUES ('3333333', '85010100000', 'Anna', 'Szybka', '53', '1985-01-01', '1982-01-01', 'ul. D', '123');
GO

-- [NIEPOPRAWNE] Reg/23: Data zatrudnienia z przyszłości
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Lekarz_DataZatrudnienia".
INSERT INTO Lekarz (NPWZ, PESEL, Imie, Nazwisko, KodSpecjalizacji, DataUrodzenia, DataZatrudnienia, Adres,
                    NumerTelefonu)
VALUES ('4444444', '86010100000', 'Michał', 'Przyszły', '53', '1986-01-01', '2050-01-01', 'ul. E', '123');
GO


PRINT CHAR(10) + '--- TABELA: Diagnoza ---';
-- [NIEPOPRAWNE] Reg/17: Diagnoza wystawiona przez nieistniejącego lekarza
-- Oczekiwany błąd: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Diagnoza_Lekarz".
INSERT INTO Diagnoza (DataGodzinaDiagnozy, ICD10, NPWZ, PESEL_Pacjenta, WynikBadania, Zalecenia)
VALUES ('2023-10-01', 'I50', '9999999', '90010100000', 'Wynik', 'Brak');
GO

-- [NIEPOPRAWNE] Reg/18: Diagnoza dla nieistniejącego pacjenta
-- Oczekiwany błąd: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Diagnoza_Pacjent".
INSERT INTO Diagnoza (DataGodzinaDiagnozy, ICD10, NPWZ, PESEL_Pacjenta, WynikBadania, Zalecenia)
VALUES ('2023-10-01', 'I50', '1111111', '00000000000', 'Wynik', 'Brak');
GO

-- [NIEPOPRAWNE] Reg/19: Diagnoza z nieistniejącą chorobą
-- Oczekiwany błąd: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Diagnoza_Choroba".
INSERT INTO Diagnoza (DataGodzinaDiagnozy, ICD10, NPWZ, PESEL_Pacjenta, WynikBadania, Zalecenia)
VALUES ('2023-10-01', 'XYZ', '1111111', '90010100000', 'Wynik', 'Brak');
GO

-- [NIEPOPRAWNE] Reg/24: Diagnoza z przyszłości
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Diagnoza_DataGodzina".
INSERT INTO Diagnoza (DataGodzinaDiagnozy, ICD10, NPWZ, PESEL_Pacjenta, WynikBadania, Zalecenia)
VALUES ('2050-10-01 12:00:00', 'I50', '1111111', '90010100000', 'Wynik', 'Brak');
GO



PRINT CHAR(10) + '--- TABELA: Przyjęcie ---';
-- [POPRAWNE] Rozpoczęcie pierwszej hospitalizacji
INSERT INTO Hospitalizacja (RegonSzpitala, KodSpecjalizacji, PESEL_Pacjenta, DataPrzyjecia, DataWypisu)
VALUES ('111111111', '53', '90010100000', '2023-10-01 10:00:00', NULL);
GO

-- [NIEPOPRAWNE] Reg/27: Próba przyjęcia pacjenta z datą z przyszłości
-- Oczekiwany błąd: The INSERT statement conflicted with the CHECK constraint "CHK_Hospitalizacja_DataPrzyjecia".
INSERT INTO Hospitalizacja (RegonSzpitala, KodSpecjalizacji, PESEL_Pacjenta, DataPrzyjecia, DataWypisu)
VALUES ('111111111', '53', '90010100000', '2050-10-01 10:00:00', NULL);
GO

-- [NIEPOPRAWNE] Reg/29: Próba wypisania pacjenta z datą wcześniejszą niż data przyjęcia
-- Oczekiwany błąd: The UPDATE statement conflicted with the CHECK constraint "CHK_Hospitalizacja_DataWypisu".
UPDATE Hospitalizacja
SET DataWypisu = '2023-09-30 10:00:00'
WHERE PESEL_Pacjenta = '90010100000' AND DataWypisu IS NULL;
GO

-- [NIEPOPRAWNE] Reg/30: Próba wypisania z datą z przyszłości (np. rok 2050)
-- Oczekiwany błąd: The UPDATE statement conflicted with the CHECK constraint "CHK_Hospitalizacja_DataWypisuCzas".
UPDATE Hospitalizacja
SET DataWypisu = '2050-01-01 10:00:00'
WHERE PESEL_Pacjenta = '90010100000' AND DataWypisu IS NULL;
GO

-- [POPRAWNE] Poprawne zakończenie hospitalizacji (wypis w dacie późniejszej niż przyjęcie)
UPDATE Hospitalizacja
SET DataWypisu = '2023-10-15 10:00:00'
WHERE PESEL_Pacjenta = '90010100000' AND DataWypisu IS NULL;
GO

-- [POPRAWNE] Ponowna hospitalizacja tego samego pacjenta w późniejszym terminie
INSERT INTO Hospitalizacja (RegonSzpitala, KodSpecjalizacji, PESEL_Pacjenta, DataPrzyjecia, DataWypisu)
VALUES ('111111111', '53', '90010100000', '2023-12-01 08:00:00', NULL);
GO


PRINT '==================================================';
PRINT ' Test Wyzwalacza (i ROLLBACK)';
PRINT '==================================================';

-- [NIEPOPRAWNE] Reg/25: Diagnoza przed zatrudnieniem lekarza (Lekarz zatrudniony w 2010)
-- Oczekiwany błąd: Błąd zdefiniowany w TRIGGERZE TRG_SprawdzDateDiagnozy_Zatrudnienie.
INSERT INTO Diagnoza (DataGodzinaDiagnozy, ICD10, NPWZ, PESEL_Pacjenta, WynikBadania, Zalecenia)
VALUES ('2005-01-01 10:00:00', 'I50', '1111111', '90010100000', 'Wynik', 'Brak');
GO
