-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
--Preliminary Step:
--Build reference tables that contain patient names and SSN,
--so that data can be linked to CMS data to look for Medicare 
--readmissions outside of the home facility.

--completed Dh code JH Higgins 11/1/2019
-----------------------------------------------------------------------------------------

/*
Vandy code here
--Patient Name
select
	OPer.Person_ID	--OMOP Person ID
	, OPer.Person_Source_Value	as MRN	--Medical Record Number
	, N.Your_First_Name_Field	as FIRST_NAME
	, N.Your_Last_Name_Field   	as LAST_NAME
	, N.Your_Middle_Name_Field	as MIDDLE_NAME
	/*
into
	AMI.Ref_Person_Names
	*/
from
	OMOP.Person as OPer
	left join
	Your_Internal_Data_Source_For_Patient_Names as N
		on OPer.PERSON_SOURCE_VALUE = N.Your_Internal_Patient_ID
;
-------------------------------------------
*/


-- Begin DH code
SELECT        
OPer.person_id
, OPer.person_source_value AS MRN -- this an OMOP CDM integer

, N.Pat_First_Name AS FIRST_NAME
, N.Pat_Last_Name AS LAST_NAME
, N.MI	as MIDDLE_NAME

-- where should I oersist? in the OMOP_CDM db or over 
into ref_person_names


FROM            person AS OPer 
LEFT OUTER JOIN  [DH5772\CLARITY].oClarity.dbo.tblAMIIndexEvent AS N 
ON [dbo].[udfOMOP_MRN](OPer.person_source_value) = N.mrn
ORDER BY OPer.person_id
----------------------------------------------------------
		
	
--Patient Social Security Number
-- more DH code		
select
	OPer.Person_Source_Value	as MRN	--Medical Record Number
	, S.SSN						as SSN  --Social Security Number

INTO ref_person_SSN
from
	Person as OPer
	left join
	[DH5772\CLARITY].oClarity.dbo.tblAMIIndexEvent as S
		on [dbo].[udfOMOP_MRN](OPer.person_source_value) = s.mrn
;
	