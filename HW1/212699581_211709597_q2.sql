-- A


SELECT tID, name, num_friends
FROM Traveler
    INNER JOIN (SELECT tID1, COUNT(tID2) num_friends FROM Friends GROUP BY tID1) AS firend_count
    ON Traveler.tID = firend_count.tID1
WHERE num_friends > 4
ORDER BY num_friends DESC, tID DESC


-- B


SELECT A.favTripsType, A.tID, A.maxDate
FROM
(SELECT Traveler.tID, name, favTripsType, trips, maxDate
FROM (Traveler
    INNER JOIN

--     make a list with id and every trip the traveler with that id took
--     and the latest trip end date
    (SELECT tID, COUNT(tID) trips, MAX(endDate) maxDate
        FROM TravelerInTrip
        GROUP BY tID) AS TRIPS_PER_TRAVELER

    ON TRIPS_PER_TRAVELER.tID = Traveler.tID)) AS A

INNER JOIN

-- grouped the joined two lists by the favTripsType and the max number of trips
(SELECT favTripsType, MAX(trips) trips
FROM
     (Traveler
    INNER JOIN
--     make a list with id and every trip the traveler with that id took
    (SELECT tID, COUNT(tID) trips
        FROM TravelerInTrip
        GROUP BY tID) AS TRIPS_PER_TRAVELER

    ON TRIPS_PER_TRAVELER.tID = Traveler.tID)

GROUP BY favTripsType) AS B
ON A.favTripsType = B.favTripsType AND A.trips = B.trips


-- C



SELECT A.tripName, A.startDate, A.endDate, COUNT(tID) pNum
FROM TravelerInTrip A INNER JOIN

-- took all the trips excepts those ones that have at least one non-returning travelers
(SELECT DISTINCT tripName, startDate, endDate FROM TravelerInTrip
WHERE YEAR(startDate) = 2020 AND YEAR(endDate) = 2020
EXCEPT

-- took all the trips that have at least one non-returning traveler
SELECT DISTINCT tripName, startDate, endDate FROM TravelerInTrip
WHERE tID NOT IN

-- list of all returning travelers
(SELECT DISTINCT T1.tID AS tID
FROM TravelerInTrip T1
INNER JOIN  TravelerInTrip T2
ON T1.tripName = T2.tripName AND T1.tID = T2.tID
       AND T1.startDate > T2.startDate
       AND DATEDIFF(MONTH, T2.endDate, T1.startDate) < 3)) T

ON A.tripName = T.tripName AND A.startDate = T.startDate AND A.endDate = T.endDate
GROUP BY A.tripName, A.startDate, A.endDate
ORDER BY pNum DESC, A.tripName, A.startDate






