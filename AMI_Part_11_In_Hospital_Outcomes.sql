
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 11: Add values to Table1_In_Hospital_Outcomes for elements from Table 1:
In-hospital heart failure
In-hospital ischemia
Echocardiography
*/


--Update 5/14/2020 chqnge obj nmes tomatch Dartmouth OMOP_CDM
-----------------------------------------------------------------------------------------
use OMOP_CDM
go

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.CONDITIONID in (281, 401)	then 1 else 0 end) as In_Hospital_HF_Flag
	, MAX(case when Ref.CONDITIONID = 1010			then 1 else 0 end) as In_Hospital_Ischemia_Flag
into #Table1_In_Hospital_Outcomes_HF_Stroke
from COHORT_BASE_2 as CB2
	left join 
		CONDITION_OCCURRENCE as CO
		on CB2.PERSON_ID = CO.PERSON_ID
			and CB2.VISIT_OCCURRENCE_ID = CO.VISIT_OCCURRENCE_ID
	left join 
		Ref_Conditions_SNOMED as Ref
		on CO.CONDITION_CONCEPT_ID = Ref.TARGET_CONCEPT_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;


 --echocardiography
 SELECT 
 	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, max
		(
		 case 
			when
				c.concept_name like '%echocardiography%'
  				and c.domain_id = 'Procedure'
  				and c.standard_concept = 'S'
			then 1 else 0
		 end
		)
	  as Echocardiography_Flag
into #Table1_In_Hospital_Outcomes_Echo
from COHORT_BASE_2 as CB2
	left join 
  		PROCEDURE_OCCURRENCE as PO
		on CB2.VISIT_OCCURRENCE_ID = PO.VISIT_OCCURRENCE_ID
  	left join CONCEPT as C
  		on C.CONCEPT_ID = PO.PROCEDURE_CONCEPT_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;


select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, CB2.DISCHARGE_DATE
	, MAX(case when Ref.CONDITIONID = 1002 then 1 else 0 end) as Cardiac_Procedure_Flag
into #Table1_HOSPITAL_Outcomes_Cardiac_Procedure
from 
	COHORT_BASE_2 as CB2
	left join
	PROCEDURE_OCCURRENCE as PO
		on CB2.PERSON_ID = PO.PERSON_ID
		and PO.Procedure_Date between CB2.Admit_date and CB2.DISCHARGE_DATE
	left join 
	[Ref_Conditions_SNOMED] as Ref
		on Ref.TARGET_CONCEPT_ID = PO.PROCEDURE_CONCEPT_ID
group by
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, CB2.DISCHARGE_DATE
;

--select Cardiac_Procedure_Flag, count(*) from Table1_HOSPITAL_Outcomes_Cardiac_Procedure group by Cardiac_Procedure_Flag;


 
 --combine temp tables
 --drop table Table1_In_Hospital_Outcomes if exists;

 
IF OBJECT_ID('Table1_In_Hospital_Outcomes', 'U') IS NOT NULL 
BEGIN
  DROP TABLE Table1_In_Hospital_Outcomes
END
 
 go

 select 
 	  HS.PERSON_ID
	, HS.VISIT_OCCURRENCE_ID
	, HS.ADMIT_DATE
	, HS.PRIM_DIAG
	, HS.In_Hospital_HF_Flag
	, HS.In_Hospital_Ischemia_Flag
	, E.Echocardiography_Flag
	, case
		when CP.Cardiac_Procedure_Flag is null then 0
		else CP.Cardiac_Procedure_Flag
	  end as Cardiac_Procedure_Flag
into Table1_In_Hospital_Outcomes
from #Table1_In_Hospital_Outcomes_HF_Stroke as HS
	left join #Table1_In_Hospital_Outcomes_Echo as E
	on HS.PERSON_ID = E.PERSON_ID
		and HS.VISIT_OCCURRENCE_ID = E.VISIT_OCCURRENCE_ID
	left join #Table1_HOSPITAL_Outcomes_Cardiac_Procedure AS CP
	on HS.PERSON_ID = CP.PERSON_ID
		and HS.VISIT_OCCURRENCE_ID = CP.VISIT_OCCURRENCE_ID
;


--End of PART 11--------------------------------------------------------------------------

/* Counts
select 
	count(*) as qty
	,sum(In_Hospital_HF_Flag) as HF
	,sum(In_Hospital_Ischemia_Flag) as Isch
	,sum(Echocardiography_Flag) as Echo
	,sum(Cardiac_Procedure_Flag) as Cardiac
from AMI.Table1_In_Hospital_Outcomes
;

select In_Hospital_HF_Flag, count(*) from Table1_In_Hospital_Outcomes
group by In_Hospital_HF_Flag;

select In_Hospital_Ischemia_Flag, count(*) from Table1_In_Hospital_Outcomes
group by In_Hospital_Ischemia_Flag;

select Echocardiography_Flag, count(*) from Table1_In_Hospital_Outcomes
group by Echocardiography_Flag;

select Cardiac_Procedure_Flag, count(*) from Table1_In_Hospital_Outcomes
group by Cardiac_Procedure_Flag;
*/


