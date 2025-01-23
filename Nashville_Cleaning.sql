
-- Purpose is to clean the data and make it more usable and friendly so others can use
-- Change the formats of some columns
-- Populate some Null Columns
-- Delete and Drop a useless column
-- Alter and Add new data to columns
-- Remove Duplicates
--Display the data and table

Select*
From PorfolioP..NashvilleH

-- Changing the Date format
-- As It's displaying time, which isn't needed
-- updating the new changes
-- Update weren't showing, so added new table through Alter
-- Then update the data from the original to the new table

Select SaleDate, CONVERT(Date, SaleDate)
From PorfolioP..NashvilleH


Alter Table PorfolioP..NashvilleH
ADD SaleDateCov Date;

Update PorfolioP..NashvilleH 
SET SaleDateCov = CONVERT(Date, SaleDate)


Select SaleDateCov
From PorfolioP..NashvilleH


-- Populate Property Address
-- The property address will not change, so it can be populated with a refrence point
-- We can do this by looking through the data and finding same IDs and then checking property address

Select *
From PorfolioP..NashvilleH
Order by ParcelID


-- using a Self Join 
-- Then we need to distinguish between each ones
-- Hence we added Unique Id for both aren't equal
-- Leading us to joining both together but making them not the same row or repeat

Select *
From PorfolioP..NashvilleH Na
JOIN PorfolioP..NashvilleH Nb
	On Na.ParcelID = nb.ParcelID
	AND Na.[UniqueID ] <> Nb.[UniqueID ]


-- Write out the tables statements
-- Then populate all the Null property address through the use of ISNULL
-- ISNULL checks to if it's NULL, then it will populate it with a value

Select na.ParcelID, na.PropertyAddress, nb.ParcelID, nb.PropertyAddress, ISNULL(na.PropertyAddress,nb.PropertyAddress) 
From PorfolioP..NashvilleH Na
JOIN PorfolioP..NashvilleH Nb
	On Na.ParcelID = nb.ParcelID
	AND Na.[UniqueID ] <> Nb.[UniqueID ]
Where na.PropertyAddress is null 


-- Next we update the new table
-- Then check to make sure it did update properly

Update Na
SET PropertyAddress = ISNULL(na.PropertyAddress,nb.PropertyAddress)
From PorfolioP..NashvilleH Na
JOIN PorfolioP..NashvilleH Nb
	On Na.ParcelID = nb.ParcelID
	AND Na.[UniqueID ] <> Nb.[UniqueID ]
Where na.PropertyAddress is null 

Select *
From PorfolioP..NashvilleH
Order by ParcelID


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PorfolioP..NashvilleH

-- Using subtrings to find and go to comma before using -1 to take it out
--For the second one, instead of minus one, we will do +1 to go to the actual comma
-- Once were there, we want to add one
--Then specfify where it needs to go to and finish
-- Since every address is different, we can use lenght to manipulate it
-- Thereby removing the commas

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , Len(PropertyAddress)) as Address
From PorfolioP..NashvilleH

--Next updating the table

Alter Table PorfolioP..NashvilleH
ADD PropertySepAddress Nvarchar(255)

Update PorfolioP..NashvilleH
SET PropertySepAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

Alter Table PorfolioP..NashvilleH
ADD PropertySpliteCity Nvarchar(255)

Update PorfolioP..NashvilleH
SET PropertySpliteCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , Len(PropertyAddress)) 

--Checking the Data

Select *
From PorfolioP..NashvilleH


-- Using Parsename to extract the comma from the table
-- Since Parsename deals with periods, used replace to turn the commas into periods. 

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From PorfolioP..NashvilleH

-- Create a Table/Alter
-- Update the Table

Alter Table PorfolioP..NashvilleH
ADD OwnerSepAddress Nvarchar(255)

Update PorfolioP..NashvilleH
SET OwnerSepAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

Alter Table PorfolioP..NashvilleH
ADD OwnerSepCity Nvarchar(255)

Update PorfolioP..NashvilleH
SET OwnerSepCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

Alter Table PorfolioP..NashvilleH
ADD OwnerSepState Nvarchar(255)

Update PorfolioP..NashvilleH
SET OwnerSepState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count (SoldAsVacant)
From PorfolioP..NashvilleH

-- Going to use a Case statement
-- The case statement helps turns the N and Y, into Nos  and Yes in a simple way
-- Next we will need to alter and update the table to add these

Select SoldAsVacant,
CASE
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
END
From PorfolioP..NashvilleH


Update PorfolioP..NashvilleH
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From PorfolioP..NashvilleH


-- Remove Duplicates
-- When removing duplicates, need a way to identify the rows
-- Using Row numbers to identify the duplict
-- Using Partition to create it own seperate temporary table 
-- Then add the CTE over it


WITH rownum_cte AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From PorfolioP..NashvilleH 
)

-- Next first used Delete to get rid of any lingering duplicates
-- Should be atleast 104 rows
-- Then do select to check

--DELETE
SELECT *
From rownum_cte
Where row_num > 1


--Delete Unused Columns
-- Such as the uneeded columns and useless ones
-- using Alter and Drop, led to the new, clean and improve Data

Select *
From PorfolioP..NashvilleH 

ALTER TABLE PorfolioP..NashvilleH 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PorfolioP..NashvilleH 
DROP COLUMN SaleDate

