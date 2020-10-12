-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

USE AMI
GO

-----------------------------------------------------------------------------------------
--Preliminary Step:
--Build reference tables that contain patient names and SSN,
--so that data can be linked to CMS data to look for Medicare 
--readmissions outside of the home facility.
-----------------------------------------------------------------------------------------

/*  --Modify your source tables and fields in these 2 queries----------------------------------------------
--Patient Name
select
	OPer.Person_ID	--OMOP Person ID
	, OPer.Person_Source_Value	as MRN	--Medical Record Number
	, N.Your_First_Name_Field	as FIRST_NAME
	, N.Your_Last_Name_Field   	as LAST_NAME
	, N.Your_Middle_Name_Field	as MIDDLE_NAME
into
	AMI.Ref_Person_Names
from
	OMOP.Person as OPer
	left join
	Your_Internal_Data_Source_For_Patient_Names as N
		on OPer.PERSON_SOURCE_VALUE = N.Your_Internal_Patient_ID
;
		
	
--Patient Social Security Number		
select
	OPer.Person_Source_Value	as MRN	--Medical Record Number
	, S.Your_SSN_Field			as SSN  --Social Security Number
into
	AMI.Ref_Person_SSN
from
	OMOP.Person as OPer
	left join
	Your_Internal_Data_Source_For_Patient_SSN as S
		on OPer.PERSON_SOURCE_VALUE = S.Your_Internal_Patient_ID
;
*/


--VUMC Example------------------------------------------
--Patient Name
select
	OPer.Person_ID	--OMOP Person ID
	, OPer.Person_Source_Value	as MRN	--Medical Record Number
	, N.FIRST_NAME	as FIRST_NAME
	, N.LAST_NAME   as LAST_NAME
	, N.MIDDLE_NAME	as MIDDLE_NAME
into
	AMI.Ref_Person_Names
from
	OMOP.Person as OPer
	left join
	[AMI].[Ref_Person_Names_2020_0915] as N
		on OPer.PERSON_SOURCE_VALUE = N.MRN
;
		
	
--Patient Social Security Number		
select
	OPer.Person_Source_Value	as MRN	--Medical Record Number
	, S.SSN						as SSN  --Social Security Number
into
	AMI.Ref_Person_SSN
from
	OMOP.Person as OPer
	left join
	[AMI].[Ref_Person_SSN_2020_0913] as S
		on OPer.PERSON_SOURCE_VALUE = S.MRN
;
	