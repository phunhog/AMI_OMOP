-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 13: Add values to Table1_ENRICHD_Score for elements from Table 1:

Age - in Table1_Demographics
Prior AMI - in Table1_Patient_History
Creatinine Level - in Table1_Laboratories:
	,Creatinine_Level_Avg
	,Creatinine_Level_Min
	,Creatinine_Level_Max
	,Creatinine_Level_First
	,Creatinine_Level_Last
Diabetes Mellitus - Comorbidites table

Post-MI CABG
CHF
History Stroke
LVEF
Killup class II-IV
Total Score
*/
-----------------------------------------------------------------------------------------
--USE AMI
USE OMOP_CDM
GO


--Existing variables
--drop table if exists #Table1_ENRICHD_Score_Vars;

select 
	 CB2.PERSON_ID
	,CB2.VISIT_OCCURRENCE_ID
	,CB2.AGE_AT_ADMIT
	,PH.History_AMI_Flag
	,L.Creatinine_Level_Avg
	,C.Comorbid_Diabetes_Flag
into #Table1_ENRICHD_Score_Vars
from COHORT_BASE_2 as CB2
left join Table1_Patient_History as PH
	on CB2.VISIT_OCCURRENCE_ID = PH.VISIT_OCCURRENCE_ID
left join Table1_Laboratories as L
	on CB2.VISIT_OCCURRENCE_ID = L.VISIT_OCCURRENCE_ID
left join Table1_Comorbidities as C
	on CB2.VISIT_OCCURRENCE_ID = C.VISIT_OCCURRENCE_ID
;


--History of stroke-------------------------------------------------------------------
--drop table if exists #Table1_ENRICHD_Score_History_Stroke_Flag;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.conditionid IN (80) then 1 else 0 end) as History_Stroke_Flag
into #Table1_ENRICHD_Score_History_Stroke_Flag
from COHORT_BASE_2 as CB2
	left join 
	Condition_Occurrence as CO
		ON CB2.PERSON_ID = CO.PERSON_ID
		AND CO.Condition_Start_Date < CB2.ADMIT_DATE
	left join
	Ref_Conditions_SNOMED as Ref
		on CO.Condition_Concept_ID = Ref.Target_Concept_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;
/*
select History_Stroke_Flag, count(*)
from #Table1_ENRICHD_Score_History_Stroke_Flag
group by History_Stroke_Flag;
*/

--CHF------------------------------------------------------------------------------
--drop table if exists #Table1_ENRICHD_Score_CHF_Flag;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.conditionid IN (79) then 1 else 0 end) as CHF_Flag
into #Table1_ENRICHD_Score_CHF_Flag
from COHORT_BASE_2 as CB2
	left join 
	Condition_Occurrence as CO
		ON CB2.PERSON_ID = CO.PERSON_ID
		AND CO.Condition_Start_Date between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
	left join
	Ref_Conditions_SNOMED as Ref
		on CO.Condition_Concept_ID = Ref.Target_Concept_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;
/*
select CHF_Flag, count(*)
from #Table1_ENRICHD_Score_CHF_Flag
group by CHF_Flag;
*/

--Post MI CABG-----------------------------------------------------------------------------------
--drop table if exists #Table1_ENRICHD_Score_MI_Flag;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.conditionid IN (13, 280) then 1 else 0 end) as MI_Flag
into #Table1_ENRICHD_Score_MI_Flag
from COHORT_BASE_2 as CB2
	left join 
	Condition_Occurrence as CO
		ON CB2.PERSON_ID = CO.PERSON_ID
		AND CO.Condition_Start_Date between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
	left join
	Ref_Conditions_SNOMED as Ref
		on CO.Condition_Concept_ID = Ref.Target_Concept_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;

/*
select MI_Flag, count(*)
from Table1_ENRICHD_Score_MI_Flag
group by MI_Flag;
*/

--drop table if exists #Table1_ENRICHD_Score_Post_MI_CABG_Flag;

select MI.PERSON_ID
	, MI.VISIT_OCCURRENCE_ID
	, MI.ADMIT_DATE
	, MI.PRIM_DIAG
	, MAX(case when Ref.conditionid = 48 then 1 else 0 end) as Post_MI_CABG_Flag
into #Table1_ENRICHD_Score_Post_MI_CABG_Flag
from #Table1_ENRICHD_Score_MI_Flag as MI
	left join
	Condition_Occurrence as CO
		ON MI.PERSON_ID = CO.PERSON_ID
		AND CO.Condition_Start_Date >= MI.ADMIT_DATE
	left join
	Ref_Conditions_SNOMED as Ref
		on CO.Condition_Concept_ID = Ref.Target_Concept_ID
where MI_Flag = 1
group by MI.PERSON_ID, MI.VISIT_OCCURRENCE_ID, MI.ADMIT_DATE, MI.PRIM_DIAG
;
/*
select Post_MI_CABG_Flag, count(*)
from #Table1_ENRICHD_Score_Post_MI_CABG_Flag
group by Post_MI_CABG_Flag;
*/

--LVEF---------------------------------------------------------------------------------------
--drop table if exists #Table1_ENRICHD_Score_LVEF_Flag;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when CO.Condition_Concept_ID = 439846 then 1 else 0 end) as LVEF_Flag
into #Table1_ENRICHD_Score_LVEF_Flag
from COHORT_BASE_2 as CB2
	left join 
		CONDITION_OCCURRENCE as CO
		on CB2.PERSON_ID = CO.PERSON_ID
			and CB2.VISIT_OCCURRENCE_ID = CO.VISIT_OCCURRENCE_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG;
/*
select LVEF_Flag, count(*)
from #Table1_ENRICHD_Score_LVEF_Flag
group by LVEF_Flag;
*/





--Killip class-----------------------------------------------------------------------------------
--History of CHF--
--drop table if exists #Table1_ENRICHD_Killip_CHF;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when ref.conditionid IN (79, 678) then 1 else 0 end) as History_CHF_Flag
into #Table1_ENRICHD_Killip_CHF
from COHORT_BASE_2 as CB2
	left join 
	CONDITION_OCCURRENCE as CO
		on CB2.PERSON_ID = CO.PERSON_ID
		and CO.CONDITION_START_DATE < CB2.ADMIT_DATE
	left join
	Ref_Conditions_SNOMED as Ref
		on CO.Condition_Concept_ID = Ref.Target_Concept_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;

--Other killip variables--
--drop table if exists #Table1_ENRICHD_Killip_Vars;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when ref.conditionid = 1016	then 1 else 0 end) as Rales_Flag
	, MAX(case when ref.conditionid = 1011	then 1 else 0 end) as JVD_Flag
	, MAX(case when ref.conditionid = 1015	then 1 else 0 end) as Pulmonary_Edema_Flag
into #Table1_ENRICHD_Killip_Vars
from COHORT_BASE_2 as CB2
	left join 
	CONDITION_OCCURRENCE as CO
		on CB2.PERSON_ID = CO.PERSON_ID
		and CO.CONDITION_START_DATE between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
	left join
	Ref_Conditions_SNOMED as Ref
		on CO.Condition_Concept_ID = Ref.Target_Concept_ID
group by 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG;
	
--Cardiogenic Shock--
--drop table if exists #Table1_ENRICHD_Killip_Shock;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when ref.conditionid = 202 then 1 else 0 end) as Cardiogenic_Shock_Flag
into #Table1_ENRICHD_Killip_Shock
from COHORT_BASE_2 as CB2
	left join 
	CONDITION_OCCURRENCE as CO
		on CB2.PERSON_ID = CO.PERSON_ID
		and CO.CONDITION_START_DATE between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
	left join
	Ref_Conditions_SNOMED as Ref
		on CO.Condition_Concept_ID = Ref.Target_Concept_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;

--Overall class assignment--
--drop table if exists #Table1_ENRICHD_Killip_Class;

select
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CHF.ADMIT_DATE
	, CHF.PRIM_DIAG
	, case 
		when CHF.History_CHF_Flag = 0 then 'I'
		when Vars.Rales_Flag = 1 or Vars.JVD_Flag = 1 then 'II'
		when Vars.Pulmonary_Edema_Flag = 1 then 'III'
	  	when KS.Cardiogenic_Shock_Flag = 1 then 'IV'
		else 'I'
	  end as Killip_Class
into #Table1_ENRICHD_Killip_Class
from COHORT_BASE_2 as CB2
left join #Table1_ENRICHD_Killip_CHF as CHF
	on CB2.VISIT_OCCURRENCE_ID = CHF.VISIT_OCCURRENCE_ID
left join #Table1_ENRICHD_Killip_Vars as Vars
	on CB2.VISIT_OCCURRENCE_ID = Vars.VISIT_OCCURRENCE_ID
left join #Table1_ENRICHD_Killip_Shock As KS
	on CB2.VISIT_OCCURRENCE_ID = KS.VISIT_OCCURRENCE_ID
;

--select killip_class, count(*) from Table1_ENRICHD_Killip_Class group by killip_class;
-----------------------------------------------------------------------------------------------

--Combine temp tables
--drop table if exists #Table1_ENRICHD_Score1;

Select
	 KC.PERSON_ID
	,KC.VISIT_OCCURRENCE_ID
	,KC.Killip_Class
	,LVEF.LVEF_Flag
	,MI.Post_MI_CABG_Flag
	,CHF.CHF_Flag
	,HS.History_Stroke_Flag
	,V.AGE_AT_ADMIT
	,V.History_AMI_Flag
	,V.Creatinine_Level_Avg
	,V.Comorbid_Diabetes_Flag
into #Table1_ENRICHD_Score1
from #Table1_ENRICHD_Killip_Class as KC
left join #Table1_ENRICHD_Score_LVEF_Flag as LVEF
	on KC.VISIT_OCCURRENCE_ID = LVEF.VISIT_OCCURRENCE_ID
left join #Table1_ENRICHD_Score_Post_MI_CABG_Flag as MI
	on KC.VISIT_OCCURRENCE_ID = MI.VISIT_OCCURRENCE_ID
left join #Table1_ENRICHD_Score_CHF_Flag as CHF
	on KC.VISIT_OCCURRENCE_ID = CHF.VISIT_OCCURRENCE_ID
left join #Table1_ENRICHD_Score_History_Stroke_Flag as HS
	on KC.VISIT_OCCURRENCE_ID = HS.VISIT_OCCURRENCE_ID
left join #Table1_ENRICHD_Score_Vars as V
	on KC.VISIT_OCCURRENCE_ID = V.VISIT_OCCURRENCE_ID
;

--Final table---------------------------------------------------------------

--drop table if exists Table1_ENRICHD_Score;


if exists (select * from sys.objects where name = 'Table1_ENRICHD_Score' and type = 'u')
    drop table Table1_ENRICHD_Score

Select
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,Killip_Class
	,case
		when LVEF_Flag is null then 0 else LVEF_Flag 
	 end as LVEF_Flag
	 ,case
		when Post_MI_CABG_Flag is null then 0 else Post_MI_CABG_Flag 
	 end as Post_MI_CABG_Flag
	,case
		when CHF_Flag is null then 0 else CHF_Flag 
	 end as CHF_Flag
	,case
		when History_Stroke_Flag is null then 0 else History_Stroke_Flag 
	 end as History_Stroke_Flag
	/*Existing vars
	AGE_AT_ADMIT
	History_AMI_Flag
	Creatinine_Level_Avg
	Comorbid_Diabetes_Flag
	*/
	,0 as ENRICHD_Score	--all elements not available
into Table1_ENRICHD_Score
from #Table1_ENRICHD_Score1
;

--End of Part 13----------------------------------------------------------------------------------
/*
Select * from Table1_ENRICHD_Score limit 100;

select LVEF_Flag, count(*)
from Table1_ENRICHD_Score
group by LVEF_Flag;

select Killip_Class, count(*)
from Table1_ENRICHD_Score
group by Killip_Class;

select Post_MI_CABG_Flag, count(*)
from Table1_ENRICHD_Score
group by Post_MI_CABG_Flag;

select CHF_Flag, count(*)
from Table1_ENRICHD_Score
group by CHF_Flag;

select History_Stroke_Flag, count(*)
from Table1_ENRICHD_Score
group by History_Stroke_Flag;
*/


 