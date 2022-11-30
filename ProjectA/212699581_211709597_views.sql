--  Views for question 3
CREATE VIEW indusCountry
AS
SELECT *
FROM (
        SELECT Location, COUNT(Symbol) numCompanies
        FROM Company
        WHERE Founded < 1990
        GROUP BY Location ) Before90
WHERE numCompanies > 5;

CREATE VIEW CompaniesInIndus
AS
SELECT *
FROM Company
WHERE Location IN (SELECT Location FROM indusCountry);

CREATE VIEW maxStocks
AS
SELECT Symbol, MAX(Price) maxPrice
FROM Stock
GROUP BY Symbol;




-- Views for question 4
CREATE VIEW improvingCompanySymbol
AS
SELECT Symbol, ROUND(100 * (MAX(Price) - MIN(Price)) / MIN(Price) , 3) Yield
FROM Stock
WHERE Symbol NOT IN (
SELECT DISTINCT S1.Symbol
FROM Stock S1
    INNER JOIN Stock S2
        ON S1.Symbol = S2.Symbol AND s1.tDate > s2.tDate AND s1.Price < s2.Price)
GROUP BY Symbol;

CREATE VIEW improvingCompany
AS
SELECT improvingCompanySymbol.Symbol, Sector, Yield
FROM improvingCompanySymbol
    INNER JOIN Company C on improvingCompanySymbol.Symbol = C.Symbol;




