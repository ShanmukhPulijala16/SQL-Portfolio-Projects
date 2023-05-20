/*
  Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject_2.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------

-- Standardize the Date Format

SELECT SaleDate
FROM PortfolioProject_2..NashvilleHousing


-- Currently SaleDate also has time besides the date which is unnecessary and annoying

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject_2..NashvilleHousing


-- Lets create a new column 'SaleDateConverted' and update the SaleDateConverted Column

ALTER TABLE PortfolioProject_2..NashvilleHousing
ADD SaleDateConverted DATE

UPDATE PortfolioProject_2..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


-- Checking whether SaleDateConverted Column is created and does it have only dates

SELECT SaleDateConverted
FROM PortfolioProject_2..NashvilleHousing


----------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM PortfolioProject_2..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- I noticed that those who have same 'ParcelID' have same 'PropertyAddress' pretty much
-- We can use this to fill in the 'NULL values' in 'PropertyAddress'. Let's do it

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject_2..NashvilleHousing a
JOIN PortfolioProject_2..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject_2..NashvilleHousing a
JOIN PortfolioProject_2..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


----------------------------------------------------------------------------------------------

-- See the Property Address

SELECT PropertyAddress
FROM PortfolioProject_2..NashvilleHousing


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
AS Address
FROM PortfolioProject_2..NashvilleHousing


-- Let's create two new columns and update the table with 

ALTER TABLE PortfolioProject_2..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE PortfolioProject_2..NashvilleHousing
SET PropertySplitAddress = 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject_2..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject_2..NashvilleHousing
SET PropertySplitCity = 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- Checking the NashvilleHousing Table for those two columns we just created

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject_2..NashvilleHousing


-----------------------------------------------------------------------------------------------

-- Let's take a look at OwnerAddress

SELECT OwnerAddress
FROM PortfolioProject_2..NashvilleHousing


-- What we have in this OwnerAddress is Address, City and State
-- So Let's split them into seperate columns
-- Observe there are commas seperating Address, City and State

SELECT *
FROM PortfolioProject_2..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject_2..NashvilleHousing


-- Using PARSENAME to seperate OwnerAddress into three columns

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject_2..NashvilleHousing


-- Updating the new three columns into NashvilleHousing Table

ALTER TABLE PortfolioProject_2..NashvilleHousing
ADD
OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255)

UPDATE PortfolioProject_2..NashvilleHousing
SET 
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Checking to see whether the three columns were updated

SELECT *
FROM PortfolioProject_2..NashvilleHousing


------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'SoldAsVacant' field/column

-- First let's check out 'SoldAsVacant' column

SELECT SoldAsVacant
FROM PortfolioProject_2..NashvilleHousing


-- Let's check out what distinct values are there in 'SoldAsVacant' column and also their count

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject_2..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-- 'Y' is 'Yes' and 'N' is 'No'
-- As 'Yes' and 'No' are very large compared to 'Y' and 'N'. Let's change 'Y' to 'Yes' and 'N' to 'No
-- Let's do it using CASE statement

SELECT SoldAsVacant,
CASE
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM PortfolioProject_2..NashvilleHousing


-- Now let's update it

UPDATE PortfolioProject_2..NashvilleHousing
SET SoldAsVacant = 
CASE
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END


-- Checking SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject_2..NashvilleHousing
GROUP BY SoldAsVacant
-- It worked!


-----------------------------------------------------------------------------------------------------

-- Finding and Removing Duplicates

-- Let's find duplicates first

SELECT *
FROM PortfolioProject_2..NashvilleHousing

WITH RowNumCTE AS(
SELECT *, 
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
	             PropertyAddress, 
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num
FROM PortfolioProject_2..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- Now let's delete duplicates

WITH RowNumCTE AS(
SELECT *, 
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
	             PropertyAddress, 
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num
FROM PortfolioProject_2..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
/*ORDER BY PropertyAddress*/


-- Checking whether those rows are deleted

WITH RowNumCTE AS(
SELECT *, 
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
	             PropertyAddress, 
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num
FROM PortfolioProject_2..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-----------------------------------------------------------------------------------------------------

-- Delete unused columns

SELECT *
FROM PortfolioProject_2..NashvilleHousing

ALTER TABLE PortfolioProject_2..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict


-- We deleted the unused columns
-- Check the table just to confirm it

SELECT *
FROM PortfolioProject_2..NashvilleHousing
ORDER BY [UniqueID ]
