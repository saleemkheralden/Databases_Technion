-- A

CREATE View IDS
as
(
SELECT DISTINCT ID
FROM (SELECT Buying.ID As ID, tDate, COUNT(DISTINCT Sector) As counter
      FROM Buying
               INNER JOIN Company
                          ON Company.Symbol = Buying.Symbol
      GROUP BY ID, tDate) A
Where A.counter >= 8)

-- end A


-- B

CREATE VIEW NumberOfDays
As
(
SELECT COUNT(tDate) AS Days
FROM (SELECT DISTINCT tDate
      FROM Buying) A)


CREATE VIEW Symbols1
AS
(
SELECT Symbol
FROM (
         SELECT Symbol, COUNT(DISTINCT tDate) as Days
         FROM Buying
         GRoup BY Symbol) B,
     NumberOfDays
Where (B.Days > 0.5 * NumberOfDays.Days))


CREATE VIEW Symbols2
AS
(
SELECT Symbol, A.ID AS ID, Quantity
FROM (SELECT Symbol, ID, Sum(BQuantity) As Quantity
      FROM Buying
      GROUP BY Symbol, ID) A
Where Quantity >= 10
    )


CREATE VIEW NOT_MAX
AS
(
SELECT ID, Quantity, Symbols2.Symbol As Symbol
FROM Symbols1
         INNER JOIN Symbols2
                    ON Symbols1.Symbol = Symbols2.Symbol
    )

-- end B


-- C

CREATE View Times as
(
SELECT S1.Symbol                         as Symbol,
       S1.tDate                          as Day1,
       S1.Price                          as price1,
       S2.tDate                          as Day2,
       S2.Price                          as price2,
       DATEDIFF(day, S1.tDate, S2.tDate) AS DateDiff
FROM Stock as S1
         INNER JOIN Stock as S2
                    ON S1.Symbol = S2.Symbol and S1.tDate < S2.tDate)

CREATE VIEW Companys As
(
(SELECT DISTINCT Stock.Symbol As Symbol, Stock.tDate As tDAte
 FROM (SELECT Buying.Symbol As Symbol, ID, tDate
       FROM (SELECT A.Symbol As symbol
             FROM (SELECT Symbol, count(*) as time
                   FROM Buying
                   GROUP BY symbol) A
             WHERE A.time = 1) B
                INNER JOIN Buying
                           ON B.symbol = Buying.Symbol) C
          INNER JOIN Stock
                     ON C.Symbol = Stock.Symbol and Stock.tDate = C.tDate)
INTERSECT
(SELECT Symbol, Day1 As tDate
 FROM (SELECT Symbol, Day1, Price1, Day2, Price2
       FROM TIMES
       EXCEPT
       (SELECT T2.Symbol AS Symbol, T2.Day1 AS Day1, T2.Price1 AS Price1, T2.Day2 AS Day2, T2.Price2 AS Price2
        FROM Times T1
                 INNER JOIN Times T2
                            ON T1.DateDiff < T2.DateDiff and T1.symbol = T2.symbol and T1.Day1 = T2.Day1)) E
 WHERE (E.price2 - E.price1) / E.price1 > 0.03)
)