/*
Cleaning Data in SQL Queries
*/


Select *
From PROJECT.dbo.[NASHVILLE HOUSING]


-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PROJECT.dbo.[NASHVILLE HOUSING]

Update [NASHVILLE HOUSING]
SET SaleDate = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select *
From PROJECT.dbo.[NASHVILLE HOUSING]
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PROJECT.dbo.[NASHVILLE HOUSING] a
JOIN PROJECT.dbo.[NASHVILLE HOUSING] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PROJECT.dbo.[NASHVILLE HOUSING] a
JOIN PROJECT.dbo.[NASHVILLE HOUSING] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PROJECT.dbo.[NASHVILLE HOUSING]
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PROJECT.dbo.[NASHVILLE HOUSING]



ALTER TABLE [NASHVILLE HOUSING]
Add PropertySplitAddress Nvarchar(255);

Update [NASHVILLE HOUSING]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )



ALTER TABLE [NASHVILLE HOUSING]
Add PropertySplitCity Nvarchar(255);

Update [NASHVILLE HOUSING]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PROJECT.dbo.[NASHVILLE HOUSING]

Select OwnerAddress
From PROJECT.dbo.[NASHVILLE HOUSING]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PROJECT.dbo.[NASHVILLE HOUSING]


ALTER TABLE [NASHVILLE HOUSING]
Add OwnerSplitAddress Nvarchar(255);


Update [NASHVILLE HOUSING]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [NASHVILLE HOUSING]
Add OwnerSplitCity Nvarchar(255);

Update [NASHVILLE HOUSING]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [NASHVILLE HOUSING]
Add OwnerSplitState Nvarchar(255);

Update [NASHVILLE HOUSING]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PROJECT.dbo.[NASHVILLE HOUSING]


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PROJECT.dbo.[NASHVILLE HOUSING]
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PROJECT.dbo.[NASHVILLE HOUSING]



Update [NASHVILLE HOUSING]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



	   -- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PROJECT.dbo.[NASHVILLE HOUSING]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PROJECT.dbo.[NASHVILLE HOUSING]



-- Delete Unused Columns



Select *
From PROJECT.dbo.[NASHVILLE HOUSING]


ALTER TABLE PROJECT.dbo.[NASHVILLE HOUSING]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO








