SELECT * 
FROM [dbo].[NashvilleHousing];

-- Standardize date format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM [dbo].[NashvilleHousing];

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date; 

UPDATE [dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(date, SaleDate);

-- Populate property address data

/* Join NashvilleHousing together to check double ParcelID*/
SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID;

-- Breaking out address into individual columns (Address, City, State)
/*Delimiter is sth separates different columns or different values. Ex: commas,..*/
SELECT PropertyAddress
FROM NashvilleHousing;

SELECT SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1) +2 ,LEN (PropertyAddress) - CHARINDEX(',',PropertyAddress,1)) AS PropertySplitCity
FROM  NashvilleHousing;
SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1) AS PropertySplitAddress
FROM  NashvilleHousing;

SELECT PropertySplitAddress
FROM [dbo].[NashvilleHousing];

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1) +2 ,LEN (PropertyAddress) - CHARINDEX(',',PropertyAddress,1))


SELECT * 
FROM NashvilleHousing;

--PARSENAME ('object_name' , object_piece ): returns the specified part of the specified object name backwards

SELECT OwnerAddress
FROM NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerSplitState
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



-- Change Y to Yes and N to No in 'SoldAsVacant'
SELECT 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing;

--Remove duplicates
WITH Row_number AS
(SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID,
										 PropertyAddress,
										 SaleDate,
										 SalePrice,
										 LegalReference
										 ORDER BY ParcelID) row_num
FROM NashvilleHousing)
SELECT *
FROM Row_number
WHERE row_num>1;

-- Delete Usued Columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict; 

ALTER TABLE NashvilleHousing
DROP COLUMN SalePrice; 

SELECT *
FROM NashvilleHousing