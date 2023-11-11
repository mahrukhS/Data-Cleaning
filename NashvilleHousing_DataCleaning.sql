/* 
Cleaning Data using SQL Queries
*/

Select *
from housing

-------------------------------------------------------------------------

-----Standardize Date Format
Select saleDateConverted, CONVERT(Date, SaleDate)
from housing

Update housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE housing
Add SaleDateConverted Date;

Update housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------------

-----Populate Property Address data

select *
From housing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From housing a
Join housing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From housing a
Join housing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Double check to confirm that all rows in PropertyAddress are populated
Select PropertyAddress
from housing
where PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------

-----Breaking out Address into Individual Columns (Address, City, State)

-- METHOD 1: Using Substring on Property Address to split Address and city

Select PropertyAddress
from housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from housing

ALTER TABLE housing
Add PropertySplitAddress nvarchar(255);

Update housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE housing
Add PropertySplitCity nvarchar(255)

Update housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


---- METHOD 2: Using Parsename to split OwnerAddress by address, city, state

--parsename parses from backward)

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
from housing

ALTER TABLE housing
Add OwnerSplitAddress nvarchar(255);

Update housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)


ALTER TABLE housing
Add OwnerSplitCity nvarchar(255);

Update housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE housing
Add OwnerSplitState nvarchar(255);

Update housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


----------------------------------------------------------------------------------------------------------------

-----Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from housing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from housing


UPDATE housing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----Remove Duplicates

--METHOD 1: USING CTE

--delete duplicate rows using rownum
WITH ROWNUMCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
from housing
)
DELETE
from ROWNUMCTE
where row_num>1

--confirm if there are any duplicates left
WITH ROWNUMCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
from housing
)

Select *
from ROWNUMCTE
where row_num>1
Order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----Delete Unused Columns
Select *
from housing

ALTER TABLE housing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress
