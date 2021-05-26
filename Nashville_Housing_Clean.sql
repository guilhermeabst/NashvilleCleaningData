Select *
from Housing


-- 1. Standardize Date

ALTER TABLE Housing 
add SaleDateFormat date

UPDATE Housing
SET SaleDateFormat = CONVERT(date, SaleDate)


-- 2. Populate Property Address

SELECT
ISNULL(a.PropertyAddress, b.PropertyAddress),
a.ParcelID,
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress
FROM Housing a 
INNER JOIN housing b 
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a 
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a 
INNER JOIN housing b 
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- 3. Breaking address into columns

SELECT
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) as City,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
FROM Housing

ALTER TABLE Housing
add PropertyCity nvarchar(255)

UPDATE Housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))

ALTER TABLE Housing
add PropertyAdress2 nvarchar(255)

UPDATE Housing
SET PropertyAdress2 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Select 
OwnerAddress,
RIGHT(OwnerAddress, 2 ) as OwnerState,
LEFT(OwnerAddress, charindex(',',OwnerAddress)-1) as OwnerAddress,
SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+2, LEN(OwnerAddress) - CHARINDEX(',', OwnerAddress)-5) as OwnerCity
From Housing

ALTER TABLE Housing
add OwnerState nvarchar(255)

UPDATE Housing
SET OwnerState = RIGHT(OwnerAddress, 2 )

ALTER TABLE Housing
add OwnerAddress2 nvarchar(255)

UPDATE Housing
SET OwnerAddress2 = LEFT(OwnerAddress, charindex(',',OwnerAddress)-1)

ALTER TABLE Housing
add OwnerCity nvarchar(255)

UPDATE Housing
SET OwnerCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+2, LEN(OwnerAddress) - CHARINDEX(',', OwnerAddress)-5)

Select * From Housing


-- 3. Replace Yes and No at SoldAsVacant

SELECT
SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No' 
ELSE SoldAsVacant
END
from Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No' 
ELSE SoldAsVacant
END

Select 
SoldAsVacant, 
COUNT(*)
FROM Housing
GROUP BY SoldAsVacant


-- 4. Remove Duplicates 


WITH t1 as(
SELECT * , 
ROW_NUMBER() OVER( PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) as Row_num
FROM Housing)

DELETE 
FROM T1
WHERE Row_num > 1 


-- 5. Delete Columns 

ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Housing
DROP COLUMN SaleDate

SELECT *
FROM Housing