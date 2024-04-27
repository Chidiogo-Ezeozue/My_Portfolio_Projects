

-- Data Cleaning in SQL Queries

Select *
From PortfolioProject1..NashvilleHousing

---------------------------------------------------------------------------------------------------

-- Standardize Data Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject1..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject1..NashvilleHousing



---------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select *
from PortfolioProject1..NashvilleHousing
--where PropertyAddress is  null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject1..NashvilleHousing a
join PortfolioProject1..NashvilleHousing b
     on a.ParcelID = b.ParcelID
     and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject1..NashvilleHousing a
join PortfolioProject1..NashvilleHousing b
     on a.ParcelID = b.ParcelID
     and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



----------------------------------------------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject1..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))  as Address
From PortfolioProject1..NashvilleHousing

-- OR

Select
PARSENAME(REPLACE(PropertyAddress, ',','.'), 2)
,PARSENAME(REPLACE(PropertyAddress, ',','.'), 1)
From PortfolioProject1..NashvilleHousing

Alter Table NashvilleHousing
Add PropertyAddressSplit Nvarchar(255);

Update NashvilleHousing
Set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertyCitySplit NVarchar(255);

Update NashvilleHousing
set PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from PortfolioProject1..NashvilleHousing


Select OwnerAddress
from PortfolioProject1..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
From PortfolioProject1..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerAddressSplit Nvarchar(255);

Update NashvilleHousing
Set OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerCitySplit NVarchar(255);

Update NashvilleHousing
set OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerStateSplit Nvarchar(255);

Update NashvilleHousing
Set OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)



----------------------------------------------------------------------------------------------------


-- Change Y and N to yes and No in "Sold As Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject1..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
       CASE When SoldAsVacant = 'Y' THEN 'Yes'
	        When SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END 
From PortfolioProject1..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	        When SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END 


------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE As(
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
				
From PortfolioProject1..NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject1..NashvilleHousing


ALTER TABlE PortfolioProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


