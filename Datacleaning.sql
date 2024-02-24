#populating .The null values of the PropertyAddress field are replaced using the values of the same field having common parcelid
update project.housingdata a
join project.housingdata b
on a.ParcelID=b.ParcelID and
a.UniqueID<>b.UniqueID
set a.PropertyAddress=ifnull(a.PropertyAddress,b.PropertyAddress);


# splitting the propertyaddress field into propertyaddress_area and  propertyaddress_city
alter table project.housingdata
add column propertyaddress_area varchar(200) after propertyaddress  ;
update project.housingdata
set propertyaddress_area=substring_index(PropertyAddress,',',1);

alter table project.housingdata
add column propertyaddress_city varchar(200) after propertyaddress_area  ;
update project.housingdata
set propertyaddress_city=substring_index(PropertyAddress,',',-1);


#splitting the owneraddress field into owneraddress_area,owneraddress_city and owneraddress_state
alter table project.housingdata
add column owneraddress_area varchar(200) after owneraddress;
update project.housingdata
set owneraddress_area=substring_index(ownerAddress,',',1);

alter table project.housingdata
add column owneraddress_city varchar(20) after owneraddress_area;
update project.housingdata
set owneraddress_city=substring_index(substring_index(OwnerAddress,',',2),',',-1);

alter table project.housingdata
add column owneraddress_state varchar(20) after owneraddress_city;
update project.housingdata
set owneraddress_state=substring_index(OwnerAddress,',',-1);


#change Y and N to YES and NO SoldAsVacant feild
select distinct(SoldAsVacant)  from project.housingdata;
update project.housingdata
set SoldAsVacant= (case SoldAsVacant
						when 'y' then 'yes'
                        when 'n' then 'no'
                        else SoldAsVacant
                        end);


#remove duplicates
create table project.housingdata_new as
(select * from
(select *,row_number() over(partition by ParcelID ,PropertyAddress,SaleDate,SalePrice,LegalReference,SoldAsVacant order by UniqueID) as rnum
 from project.housingdata) a
 where rnum=1);


#delete unused columns
alter table project.housingdata_new
drop column OwnerAddress,
drop column TaxDistrict,
drop column PropertyAddress;


