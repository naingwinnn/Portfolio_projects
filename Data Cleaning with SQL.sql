/*

Cleaning Data in SQL Queries

*/


Select *
From dbo.[Nashville Housing Data for Data Cleaning];

-- Populate Property Address data(if parcel id is equal and PorpertyAddress is not provided)

Select *
From dbo.[Nashville Housing Data for Data Cleaning]
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.[Nashville Housing Data for Data Cleaning] a
JOIN dbo.[Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.[Nashville Housing Data for Data Cleaning] a
JOIN dbo.[Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--breaking out address into individual columns(address,city,state)

select PorpertyAddres
from dbo.[Nashville Housing Data for Data Cleaning]

select
substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1 ) as address
,substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress))as address
from dbo.[Nashville Housing Data for Data Cleaning]

alter table dbo.[Nashville Housing Data for Data Cleaning]
add PropertySlipAddress varchar(50);

update  dbo.[Nashville Housing Data for Data Cleaning]
set PropertySlipAddress = substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1 )

alter table dbo.[Nashville Housing Data for Data Cleaning]
add PropertySlipCity varchar(50);

update  dbo.[Nashville Housing Data for Data Cleaning]
set PropertySlipCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress))

select * from dbo.[Nashville Housing Data for Data Cleaning]

--OwnerAddress
select OwnerAddress from dbo.[Nashville Housing Data for Data Cleaning]

select
PARSENAME(replace(OwnerAddress,',','.'),3) as street,
PARSENAME(replace(OwnerAddress,',','.'),2) as city,
PARSENAME(replace(OwnerAddress,',','.'),1) as township
from dbo.[Nashville Housing Data for Data Cleaning]

--remove duplciates--

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM dbo.[Nashville Housing Data for Data Cleaning]
)
delete from RowNumCTE
where row_num > 1
order by PropertyAddress

select * from RowNumCTE 
where row_num > 1
order by PropertyAddress

select * from dbo.[Nashville Housing Data for Data Cleaning]

--delete unused columns--

select * from dbo.[Nashville Housing Data for Data Cleaning]

alter table  [Nashville Housing Data for Data Cleaning]
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table  [Nashville Housing Data for Data Cleaning]
drop column SaleDate