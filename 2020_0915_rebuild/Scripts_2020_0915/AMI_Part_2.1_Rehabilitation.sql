
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 2.1: Readmissions for rehabilitation to be excluded.

Rehab flag - below 

*/

--Rehabilitation Flag--------------------------------------------------------------------------

USE OMOP_CDM -- added this 10/11/2020
go

--drop table if exists Table1_Rehabilitation

-- and substituted this
if exists (select * from sys.objects where name = 'Table1_Rehabilitation' and type = 'u')
    drop table Table1_Rehabilitation
GO

select 
	 ACB2.PERSON_ID
	,ACB2.VISIT_OCCURRENCE_ID
	,ACB2.ADMIT_DATE
	,ACB2.PRIM_DIAG
	,MAX(
			case 
				when ARef.CONDITION_DESCRIPTION = 'Rehabilitation' 
				then 1 
				else 0 
			end
		) as Rehab_Flag
into Table1_Rehabilitation
from 
	COHORT_BASE_2 as ACB2
	left join 
	CONDITION_OCCURRENCE as OCO
		on ACB2.PERSON_ID = OCO.PERSON_ID
		and ACB2.VISIT_OCCURRENCE_ID = OCO.VISIT_OCCURRENCE_ID
	left join 
	Ref_Conditions_SNOMED as ARef
		on OCO.CONDITION_CONCEPT_ID = ARef.TARGET_CONCEPT_ID
group by 
	 ACB2.PERSON_ID
	,ACB2.VISIT_OCCURRENCE_ID
	,ACB2.ADMIT_DATE
	,ACB2.PRIM_DIAG
;

--End of PART 2.1--------------------------------------------------------------------------

