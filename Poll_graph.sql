Select *
From PorfolioP..Pres_Elect
Order by 3,4

-- Select the data we are going to be using

-- Select state, Geoid, votes_dem, votes_rep, votes_total, pct_dem_lead, official_boundary
-- From PorfolioP..Pres_Elect
-- Order by 3,4

--Check the total amount of votes for demograts

Select state, votes_dem, votes_total
From PorfolioP..Pres_Elect
Group by state, votes_dem, votes_total, votes_rep

-- Checking the highest vote for FL 
Select state, Geoid, votes_dem
From PorfolioP..Pres_Elect
WHERE GEOID like '%Garland%'
Group by state, Geoid, votes_dem
Order by votes_dem desc

--The highest number of votes in FLorida

Select state, SUM(votes_dem)
From PorfolioP..Pres_Elect
WHERE state = 'FL'
Group by state, votes_dem
Order by votes_dem desc


-- Votes in Baltimore City
Select state, Geoid, votes_dem
From PorfolioP..Pres_Elect
WHERE GEOID like '%Baltimore City%'
Group by state, Geoid, votes_dem
Order by votes_dem desc

--Adding another Table, which is the polls for election

Select *
From PorfolioP..pres_polls


-- Which day past 200 had the most Dem Vote
-- Which state had it

Select Day, State, Dem 
From PorfolioP..pres_polls
WHERE Day > 200 
Group by Day, State, Dem 
Order by Dem desc



