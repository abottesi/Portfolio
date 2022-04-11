SELECT *
FROM Portfolio.dbo.NashvilleHousing;


--Change Data Format (Sale Date)
Select SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio.dbo.NashvilleHousing

UPDATE Portfolio.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Portfolio.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Address Data
Select *
FROM Portfolio.dbo.NashvilleHousing
ORDER by ParcelID;


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing a 
JOIN Portfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.NashvilleHousing a 
JOIN Portfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null;


	--Breaking out Address into Individual Columns (Address, City, and State)
Select PropertyAddress
FROM Portfolio.dbo.NashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM Portfolio.dbo.NashvilleHousing;


ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Portfolio.dbo.NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE Portfolio.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM Portfolio.dbo.NashvilleHousing;


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio.dbo.NashvilleHousing;



ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Portfolio.dbo.NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Portfolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE Portfolio.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE Portfolio.dbo.NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



--Change Y and N to Yes and No in "Sold as Vacant" feild

SELECT DISTINCT(SoldAsVacant), COUNT(SoldasVacant)
FROM Portfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER by 2;

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio.dbo.NashvilleHousing;


UPDATE Portfolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;


--Remove Duplicates 

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
FROM Portfolio.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;



-- Delete Unused Columns

ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;


ALTER TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate;