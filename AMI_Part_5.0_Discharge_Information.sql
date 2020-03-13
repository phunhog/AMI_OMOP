
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 5: Add values to Table1_Discharge_Information for elements from Table 1:
Unstable angina
STEMI
NSTEMI


Later in part 5.1 (separate script)
Anti-depressant on discharge
Aspirin on discharge
Beta blocker on discharge
ACE or ARB inhibitors combined at discharge
*/
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
--Unstable angina
-----------------------------------------------------------------------------------------

drop table if exists #Table1_Discharge_Information_Unstable_Angina_Flag
;
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.conditionid IN (53)	then 1 else 0 end) as Unstable_Angina_Flag
into #Table1_Discharge_Information_Unstable_Angina_Flag
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
	[OMOP].[CONDITION_OCCURRENCE] as OCO	
		ON CB2.PERSON_ID = OCO.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = OCO.VISIT_OCCURRENCE_ID
		--AND OCO.CONDITION_START_DATE = CB2.ADMIT_DATE
	left join
	[AMI].[Ref_Conditions_SNOMED] as Ref
		on OCO.CONDITION_CONCEPT_ID = Ref.TARGET_CONCEPT_ID
group by
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
;



-----------------------------------------------------------------------------------------
--STEMI and NSTEMI
-----------------------------------------------------------------------------------------

drop table if exists #Table1_Discharge_Information_STEMI_Flag
;
select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.conditionid IN (51)	then 1 else 0 end) as STEMI_Flag
	, MAX(case when Ref.conditionid IN (52)	then 1 else 0 end) as NSTEMI_Flag
into #Table1_Discharge_Information_STEMI_Flag
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
	[OMOP].[CONDITION_OCCURRENCE] as OCO	
		ON CB2.PERSON_ID = OCO.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = OCO.VISIT_OCCURRENCE_ID
	left join
	[AMI].[Ref_Conditions_SNOMED] as Ref
		on OCO.CONDITION_CONCEPT_ID = Ref.TARGET_CONCEPT_ID
group by
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
;


-----------------------------------------------------------------------------------------
--combine temp tables
-----------------------------------------------------------------------------------------

drop table if exists Table1_Discharge_Information
;
select 
	 CB2.PERSON_ID
	,CB2.VISIT_OCCURRENCE_ID
	,case
		when UA.Unstable_Angina_Flag is null then 0
		else UA.Unstable_Angina_Flag
	end as Unstable_Angina_Flag
	,case
		when SF.STEMI_Flag is null then 0
		else SF.STEMI_Flag
	end as STEMI_Flag
	,case
		when SF.NSTEMI_Flag is null then 0
		else SF.NSTEMI_Flag
	end as NSTEMI_Flag
into
	Table1_Discharge_Information
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
		#Table1_Discharge_Information_Unstable_Angina_Flag as UA
		on CB2.PERSON_ID = UA.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = UA.VISIT_OCCURRENCE_ID
	left join 
		#Table1_Discharge_Information_STEMI_Flag as SF
		on CB2.PERSON_ID = SF.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = SF.VISIT_OCCURRENCE_ID
;
 





--End---------------------------------------------------------------------------------------

/* counts
select top 1000 * from Table1_Discharge_Information;

select STEMI_Flag, count(*)
from Table1_Discharge_Information
group by STEMI_Flag;

select NSTEMI_Flag, count(*)
from Table1_Discharge_Information
group by NSTEMI_Flag;

select Unstable_Angina_Flag, count(*)
from Table1_Discharge_Information
group by Unstable_Angina_Flag;
*/
