
-- A
SELECT Name, A.Generation
    FROM
(select Generation,Max(Hp+Attack+Defense) AS Total1
From Pokemons
GROUP BY Generation ) A
INNER JOIN
 (Select Name,Generation,(Hp+Attack+Defense)As Total
                          From (SELECT Name,Hp,Attack,Defense,Legendary,Generation
                                    From Pokemons
                                     Where Legendary='1') temp) B
ON A.Generation=B.Generation and A.Total1=B.Total
ORDER BY Generation


-- B
SELECT Name, Type
FROM Pokemons
EXCEPT
(SELECT A.Name, A.Type
FROM Pokemons A
INNER JOIN Pokemons B
ON A.Type = B.Type AND A.Name != B.Name
    AND (A.Attack <= B.Attack OR A.Defense <= B.Defense OR A.HP <= B.HP))


-- C
SELECT E.Type
FROM (Select Type ,count(A.Name)As number
        From (SELECT DISTINCT Name, Type
                FROM Pokemons
                Where Attack>=100) A
    GROUP BY Type)E
Where Number>50
ORDER BY Type


SELECT *
FROM Pokemons
WHERE Type='water' AND Attack>=100

-- D

SELECT Type, CAST(ROUND(SUM(Balance) / (1.0 * COUNT(Name)), 2) AS decimal(16, 2)) AVG
FROM (SELECT Name, Type, ABS(Attack - Defense) Balance
    FROM Pokemons) innerA
GROUP BY Type
EXCEPT
SELECT DISTINCT A.Type, A.AVG
FROM
(SELECT Type, CAST(ROUND(SUM(Balance) / (1.0 * COUNT(Name)), 2) AS decimal(16, 2)) AVG
FROM (SELECT Name, Type, ABS(Attack - Defense) Balance
    FROM Pokemons) innerA
GROUP BY Type) A
INNER JOIN
(SELECT Type, CAST(ROUND(SUM(Balance) / (1.0 * COUNT(Name)), 2) AS decimal(16, 2)) AVG
FROM (SELECT Name, Type, ABS(Attack - Defense) Balance
    FROM Pokemons) innerB
GROUP BY Type) B
ON A.AVG < B.AVG

SELECT * FROM Pokemons WHERE Name='aa'
DELETE FROM Pokemons WHERE Name='aa'



