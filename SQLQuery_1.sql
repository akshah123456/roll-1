SELECT TOP (5) *
  FROM [dbo].[Nashville Housing Data for Data Cleaning]

-- Standardizing the date data

SELECT CONVERT(Date, SaleDate) AS saleDateConverted
FROM [dbo].[Nashville Housing Data for Data Cleaning]


UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date, SaleDate)

-- Populating the Propery Address Info to Parcel ID's that have Null Address Value assigned

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [dbo].[Nashville Housing Data for Data Cleaning] b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [dbo].[Nashville Housing Data for Data Cleaning] b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

-- Returning separate columns from propery address
SELECT  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress) - CHARINDEX(',', PropertyAddress)) AS Address
FROM [dbo].[Nashville Housing Data for Data Cleaning];

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress NVARCHAR(MAX);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET PropertyAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress) - CHARINDEX(',', PropertyAddress));

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);



ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
Add OwnerAddressState NVARCHAR(MAX), OwnerAddressCity NVARCHAR(MAX);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET OwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);

EXEC sp_rename '[dbo].[Nashville Housing Data for Data Cleaning].OwnerAddress', 'OwnersAddressState', 'COLUMN';
EXEC sp_rename '[dbo].[Nashville Housing Data for Data Cleaning].OwnerAddressState', 'OwnersAddressStreet', 'COLUMN';
EXEC sp_rename '[dbo].[Nashville Housing Data for Data Cleaning].PropertySplitAddress', 'PropertyAddressStreet', 'COLUMN';
-- Changing Y to Yes and N No under the SoldAsVacant column as there is a mix of Y, N, Yes, and No's.

Select SoldAsVacant, Count(SoldAsVacant)
From [dbo].[Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant
order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM [dbo].[Nashville Housing Data for Data Cleaning]

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END; 

-- It's important to remove the duplicates

WITH RowNumCTE AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num FROM [dbo].[Nashville Housing Data for Data Cleaning])
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

SELECT TaxDistrict, COUNT(DISTINCT TaxDistrict)
  FROM [dbo].[Nashville Housing Data for Data Cleaning]
  GROUP BY TaxDistrict;


-- Dropping unused columns
