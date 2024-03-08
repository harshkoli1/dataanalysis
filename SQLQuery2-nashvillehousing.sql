--cleaning data in sql queries

select * from 
POrtfolio.dbo.NashvilleHousing

--standardize date format
select SaleDate,CONVERT(Date,SaleDate) 
from POrtfolio.dbo.NashvilleHousing


update POrtfolio.dbo.NashvilleHousing
Set SaleDate=convert(date,Saledate)

ALTER TABLE POrtfolio.dbo.NashvilleHousing
Add saledateconverted  date;

update POrtfolio.dbo.NashvilleHousing
set saledateconverted=convert(date,SaleDate)

select saledateconverted,CONVERT(Date,SaleDate) 
from POrtfolio.dbo.NashvilleHousing


--populate property address data


select *
from POrtfolio.dbo.NashvilleHousing
--where PropertyAddress is null 
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from POrtfolio.dbo.NashvilleHousing a
join POrtfolio.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set Propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from POrtfolio.dbo.NashvilleHousing a
join POrtfolio.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual column (address,city,state)
select PropertyAddress
from POrtfolio.dbo.NashvilleHousing
order by ParcelID

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) AS address

from POrtfolio.dbo.NashvilleHousing

ALTER TABLE POrtfolio.dbo.NashvilleHousing
Add Propertysplitaddress nvarchar(255);

update POrtfolio.dbo.NashvilleHousing
Set Propertysplitaddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE POrtfolio.dbo.NashvilleHousing
Add Propertysplitcity nvarchar(255);

update POrtfolio.dbo.NashvilleHousing
set Propertysplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select Propertysplitaddress,Propertysplitcity
from POrtfolio.dbo.NashvilleHousing



--another way of splitting 

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)

from POrtfolio.dbo.NashvilleHousing


ALTER TABLE POrtfolio.dbo.NashvilleHousing
Add Ownersplitaddress nvarchar(255);

update POrtfolio.dbo.NashvilleHousing
Set Ownersplitaddress=PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER TABLE POrtfolio.dbo.NashvilleHousing
Add Ownersplitcity nvarchar(255);

update POrtfolio.dbo.NashvilleHousing
set Ownersplitcity=PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER TABLE POrtfolio.dbo.NashvilleHousing
Add Ownersplitstate nvarchar(255);

update POrtfolio.dbo.NashvilleHousing
set Ownersplitstate=PARSENAME(replace(OwnerAddress,',','.'),1)




select *
from POrtfolio.dbo.NashvilleHousing


select distinct(SoldAsVacant),count(SoldAsVacant)
from POrtfolio.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
  case when SoldAsVacant ='Y'then'Yes'
       when SoldAsVacant ='N'then'No'
       else SoldAsVacant
  end
from POrtfolio.dbo.NashvilleHousing

update POrtfolio.dbo.NashvilleHousing

set SoldAsVacant= case when SoldAsVacant ='Y'then'Yes'
       when SoldAsVacant ='N'then'No'
       else SoldAsVacant
  end


  --remove duplicates
with RowNumCTE AS(
select * ,
    ROW_NUMBER()Over(
	partition by ParcelID,
	             SaleDate,
				 SalePrice,
				 PropertyAddress,
				 LegalReference
				 order by 
				 UniqueID
				 )row_num
from POrtfolio.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num>1
--order by PropertyAddress






select *
from POrtfolio.dbo.NashvilleHousing


--DELETE UNUSED COLUMNS

select *
from POrtfolio.dbo.NashvilleHousing

ALTER TABLE POrtfolio.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE POrtfolio.dbo.NashvilleHousing
drop column SaleDate