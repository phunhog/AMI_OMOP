
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 9: Add values to Table1_Prior_Month_Diagnosis for elements from Table 1:
Sepsis
Hyperkalemia
Hypokalemia
Hypervolemia
Acute kidney failure
Urinary tract infection
Long-term anticoagulants
*/
-----------------------------------------------------------------------------------------
--USE AMI
USE OMOP_CDM -- 10/14/2020
GO


--drop table if exists Table1_Prior_Month_Diagnosis;

if exists (select * from sys.objects where name = 'Table1_Prior_Month_Diagnosis' and type = 'u')
    drop table Table1_Prior_Month_Diagnosis

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.CONDITIONID IN (95, 96)			then 1 else 0 end) as Prior_Sepsis_30D
	, MAX(case when Ref.CONDITIONID IN (235)			then 1 else 0 end) as Prior_Hyperkalemia_30D
	, MAX(case when Ref.CONDITIONID IN (1009)			then 1 else 0 end) as Prior_Hypokalemia_30D
	, MAX(case when Ref.CONDITIONID IN (1008)			then 1 else 0 end) as Prior_Hypervolemia_30D
	, MAX(case when CO.CONDITION_CONCEPT_ID = 197320	then 1 else 0 end) as Prior_AKF_30D
	, MAX(case when Ref.CONDITIONID IN (1019)			then 1 else 0 end) as Prior_UTI_30D
	, MAX(case when Ref.CONDITIONID IN (1012)			then 1 else 0 end) as Prior_Longterm_Anticoagulants_30D
into Table1_Prior_Month_Diagnosis
from COHORT_BASE_2 as CB2
	left join 
	CONDITION_OCCURRENCE as CO
		on CB2.PERSON_ID = CO.PERSON_ID
			and CO.CONDITION_START_DATE >= DateAdd(dd,-30,CB2.ADMIT_DATE)
			and CO.CONDITION_START_DATE < CB2.ADMIT_DATE
	left join 
	[Ref_Conditions_SNOMED] as Ref
		on CO.CONDITION_Concept_ID = Ref.TARGET_CONCEPT_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG;


--End of PART 9--------------------------------------------------------------------------


--Check totals
/*
  SELECT
       SUM(Prior_Sepsis_30D)
      ,SUM(Prior_Hyperkalemia_30D)
      ,SUM(Prior_Hypokalemia_30D)
      ,SUM(Prior_Hypervolemia_30D)
      ,SUM(Prior_AKF_30D)
      ,SUM(Prior_UTI_30D)
      ,SUM(Prior_Longterm_Anticoagulants_30D)
  FROM 
	  Table1_Prior_Month_Diagnosis
  ;
*/