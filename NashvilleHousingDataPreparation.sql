-- Select all rows from the "nashv" table in the "master.dbo" schema
SELECT * FROM master.dbo.nashv;

-- -- WHERE PRopertyaddress is null
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM master.dbo.nashv a
JOIN master.dbo.nashv b ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM master.dbo.nashv a
JOIN master.dbo.nashv b ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress FROM master.dbo.nashv;
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) AS City
FROM master.dbo.nashv;

ALTER TABLE master.dbo.nashv
ADD PropertySpAddress NVARCHAR(255);

ALTER TABLE master.dbo.nashv
ADD PropertySpCity NVARCHAR(255);

UPDATE master.dbo.nashv
SET PropertySpAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

UPDATE master.dbo.nashv
SET PropertySpCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))
FROM master.dbo.nashv;

SELECT OwnerAddress
FROM master.dbo.nashv;

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM master.dbo.nashv;

SELECT OwnerAddress FROM master.dbo.nashv;
ALTER TABLE master.dbo.nashv
ADD OwnerSpAddress NVARCHAR(255);

ALTER TABLE master.dbo.nashv
ADD OwnerSpCity NVARCHAR(255);

ALTER TABLE master.dbo.nashv
ADD OwnerSpState NVARCHAR(255);

UPDATE master.dbo.nashv
SET OwnerSpAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE master.dbo.nashv
SET OwnerSpCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE master.dbo.nashv
SET OwnerSpState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT * FROM master.dbo.nashv;

-- Change Y and N to YES and NO in SoldAsVacant

SELECT SoldAsVacant, COUNT(SoldAsVacant) FROM master.dbo.nashv
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
    END
FROM master.dbo.nashv;

UPDATE master.dbo.nashv
SET SoldAsVacant =
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
    END;

SELECT SoldAsVacant FROM master.dbo.nashv
WHERE SoldAsVacant = 'N';

-- Remove Duplicate Rows

WITH ROWCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference
            ORDER BY UniqueID
        ) AS row_number
    FROM master.dbo.nashv
)
DELETE FROM ROWCTE
WHERE row_number > 1;

WITH ROWCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference
            ORDER BY UniqueID
        ) AS row_number
    FROM master.dbo.nashv
)
SELECT * FROM ROWCTE
WHERE row_number > 1;

-- Delete Unused Columns

ALTER TABLE master.dbo.nashv
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

-- Select all rows from the "nashv" table in the "master.dbo" schema
SELECT * FROM master.dbo.nashv;
