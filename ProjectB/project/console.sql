





SELECT Symbol, COUNT(ID) as ID
FROM Buying
GROUP BY Symbol
ORDER BY ID DESC



CREATE TABLE doctor (
    ID      VARCHAR(9) PRIMARY KEY,
);

CREATE TABLE Clinic (
    name    VARCHAR(100) PRIMARY KEY,
    head    VARCHAR(9),
    FOREIGN KEY (head) REFERENCES doctor(ID)
);

CREATE TABLE visit (
    ID      INT,

    CHECK (ID BETWEEN 10000 AND 99999)
);

INSERT INTO visit (ID) VALUES (12345)
INSERT INTO visit (ID) VALUES (99999)

SELECT * FROM visit

INSERT INTO doctor (ID) VALUES ('123456789')

SELECT * FROM doctor

INSERT INTO Clinic (name, head) VALUES ('saleem', '123456789')
INSERT INTO Clinic (name, head) VALUES ('plpl1', NULL)

SELECT * FROM Clinic

















-- #B:


CREATE VIEW NumberOfDays
As (SELECT COUNT(tDate) AS Days
FROM (SELECT DISTINCT tDate
             FROM Buying) A)


CREATE VIEW Symbols1
    AS(
SELECT Symbol
FROM(
SELECT Symbol,COUNT(DISTINCT tDate) as Days
FROM Buying
GRoup BY Symbol)B, NumberOfDays
Where (B.Days>0.5*NumberOfDays.Days))


CREATE VIEW Symbols2
    AS(
SELECT Symbol,A.ID AS ID,Quantity
FROM(SELECT Symbol ,ID,Sum(BQuantity) As Quantity
FROM Buying
GROUP BY Symbol,ID) A
Where Quantity>=10
)


CREATE VIEW NOT_MAX
    AS
    (SELECT ID,Quantity,Symbols2.Symbol As Symbol
FROM Symbols1 INNER JOIN Symbols2
ON Symbols1.Symbol=Symbols2.Symbol
)

SELECT Symbol,Name,Quantity
FROM (SELECT *
    FROM NOT_MAX
        EXCEPT (SELECT O1.ID AS ID,O1.Quantity AS Quntity ,O1.symbol AS Symbol
                      FROM NOT_MAX O1,NOT_MAX O2
                      Where O1.Quantity<O2.Quantity and O1.ID!=O2.ID and O1.symbol=O2.symbol))B
INNER JOIN Investor
ON Investor.ID=B.ID
ORDER BY Symbol






SELECT * FROM Symbols2 WHERE Symbol='HSIC'
SELECT * FROM Symbols1
SELECT * FROM Investor WHERE ID=898574707

-- ########################################################################################################################
-- #C:
CREATE View Times as
(SELECT S1.Symbol as Symbol,S1.tDate as Day1,S1.Price as price1,S2.tDate as Day2,S2.Price as price2 ,DATEDIFF(day, S1.tDate, S2.tDate) AS DateDiff
FROM Stock as S1 INNER JOIN  Stock as S2
ON S1.Symbol=S2.Symbol and S1.tDate<S2.tDate)


CREATE VIEW Companys As
((SELECT DISTINCT Stock.Symbol As Symbol ,Stock.tDate As tDAte
FROM(SELECT Buying.Symbol As Symbol,ID,tDate
FROM(SELECT A.Symbol As symbol
FROM(SELECT Symbol,count(*) as time
FROM Buying
GROUP BY symbol)A
WHERE A.time=1)B INNER JOIN Buying
ON B.symbol=Buying.Symbol )C INNER JOIN  Stock
ON C.Symbol=Stock.Symbol and Stock.tDate=C.tDate)
INTERSECT
(SELECT Symbol,Day1 As tDate
       FROM(SELECT Symbol,Day1,Price1,Day2,Price2
FROM TIMES
 EXCEPT (SELECT T2.Symbol AS Symbol ,T2.Day1 AS Day1,T2.Price1 AS Price1,T2.Day2 AS Day2,T2.Price2 AS Price2
      FROM  Times T1 INNER JOIN  Times T2
      ON T1.DateDiff<T2.DateDiff and T1.symbol=T2.symbol and T1.Day1=T2.Day1))E
WHERE (E.price2-E.price1)/E.price1>0.03))

SELECT G.tDate as Date ,G.Symbol As Symbol ,Name
    FROM Investor INNER JOIN(SELECT ID,Buying.Symbol As Symbol,Companys.tDAte As tDate
FROM Companys INNER JOIN Buying
ON (Companys.Symbol=Buying.Symbol and Buying.tDate=Companys.tDAte))G
ON Investor.ID=G.ID
ORDER BY Date,Symbol

-- ######################################################################################################################
SELECT * FROM Investor
















