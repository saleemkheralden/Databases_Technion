
SELECT Location, Symbol, maxPrice
FROM (
        SELECT Location, MAX(maxPrice) max_price
        FROM maxStocks
        INNER JOIN CompaniesInIndus C ON C.Symbol = maxStocks.Symbol
        GROUP BY Location ) LocationMaxPrice
INNER JOIN maxStocks ON maxStocks.maxPrice = LocationMaxPrice.max_price
ORDER BY Location



