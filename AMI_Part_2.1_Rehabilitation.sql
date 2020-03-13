
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 2.1: Readmissions for rehabilitation to be excluded.

Rehab flag - below 

*/

--Rehabilitation Flag--------------------------------------------------------------------------


drop table if exists AMI.Table1_Rehabilitation;

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
into AMI.Table1_Rehabilitation
from 
	AMI.COHORT_BASE_2 as ACB2
	left join 
	OMOP.CONDITION_OCCURRENCE as OCO
		on ACB2.PERSON_ID = OCO.PERSON_ID
		and ACB2.VISIT_OCCURRENCE_ID = OCO.VISIT_OCCURRENCE_ID
	left join 
	AMI.Ref_Conditions_SNOMED as ARef
		on OCO.CONDITION_CONCEPT_ID = ARef.TARGET_CONCEPT_ID
group by 
	 ACB2.PERSON_ID
	,ACB2.VISIT_OCCURRENCE_ID
	,ACB2.ADMIT_DATE
	,ACB2.PRIM_DIAG
;

--End of PART 2.1--------------------------------------------------------------------------

