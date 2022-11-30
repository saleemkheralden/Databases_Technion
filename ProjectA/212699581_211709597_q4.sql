
SELECT *
FROM improvingCompany
WHERE Symbol NOT IN (
                SELECT iC.Symbol
                FROM improvingCompany
                INNER JOIN improvingCompany iC
                ON improvingCompany.Sector = iC.Sector AND improvingCompany.Symbol != iC.Symbol)