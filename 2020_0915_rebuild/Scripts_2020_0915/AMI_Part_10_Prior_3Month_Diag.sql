
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
/*
PART 10: Add values to Table1_Prior_3Month_Diagnosis for elements from Table 1:
Sepsis
Disorders of magnesium metabolism
Hypokalemia
Left ventricle failure
Acute kidney failure
Presence of cardiac device
*/
-----------
USE OMOP_CDM------------------------------------------------------------------------------
--USE AMI
GO


--drop table if exists Table1_Prior_3Month_Diagnosis;

if exists (select * from sys.objects where name = 'Table1_Prior_3Month_Diagnosis' and type = 'u')
    drop table Table1_Prior_3Month_Diagnosis

select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.CONDITIONID IN (95, 96)			then 1 else 0 end) as Prior_Sepsis_90D
	, MAX(case when Ref.CONDITIONID IN (1005)			then 1 else 0 end) as Prior_Dis_Magn_Metab_90D
	, MAX(case when Ref.CONDITIONID IN (1009)			then 1 else 0 end) as Prior_Hypokalemia_90D
	, MAX(case when Ref.CONDITIONID IN (1013)			then 1 else 0 end) as Prior_LVEF_90D
	, MAX(case when CO.CONDITION_CONCEPT_ID = 197320	then 1 else 0 end) as Prior_AKF_90D
	, MAX(case when CO.CONDITION_CONCEPT_ID = 4323360	then 1 else 0 end) as Prior_Cardiac_Device_90D
into Table1_Prior_3Month_Diagnosis
from COHORT_BASE_2 as CB2
	left join 
	CONDITION_OCCURRENCE as CO
		on CB2.PERSON_ID = CO.PERSON_ID
			and CO.CONDITION_START_DATE >= DateAdd(dd,-90,CB2.ADMIT_DATE)
			and CO.CONDITION_START_DATE < CB2.ADMIT_DATE
	left join 
	[Ref_Conditions_SNOMED] as Ref
		on CO.CONDITION_Concept_ID = Ref.TARGET_CONCEPT_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG;


--End of PART 10--------------------------------------------------------------------------



--Totals
/*
  SELECT
       SUM(Prior_Sepsis_90D)
      ,SUM(Prior_Dis_Magn_Metab_90D)
      ,SUM(Prior_Hypokalemia_90D)
      ,SUM(Prior_LVEF_90D)
      ,SUM(Prior_AKF_90D)
      ,SUM(Prior_Cardiac_Device_90D)
  FROM 
	  Table1_Prior_3Month_Diagnosis
  ;
*/