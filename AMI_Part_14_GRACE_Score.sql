-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 14: Add values to Table1_GRACE_Score for elements from Table 1:

Age - in Table1_Demographics
History of AMI - in Table1_Patient_History
Initial Serum creatinine (Labs: Creatinine_Level_First)
killip class - get from Table1_ENRICHD_Score

History of CHF
In-Hospital PCI

ST-Segment depression (cardiac stress test)
Resting heart rate
Systolic BP
elevated cardiac enzymes
cardiac arrest at admission
Total Score
*/
-----------------------------------------------------------------------------------------
-- update 5/15/2020 chqnge obj names to match Dartmouth OMOP_CDM

--Existing variables---------------------------------------------------------------------
SELECT   
		 CB2.PERSON_ID
       , CB2.VISIT_OCCURRENCE_ID
       , CB2.AGE_AT_ADMIT
	   , H.HISTORY_AMI_FLAG
	   , L.CREATININE_LEVEL_FIRST
	   , E.Killip_Class
	   , DI.STEMI_FLAG
into #Table1_GRACE_Vars		
FROM 
	COHORT_BASE_2 as CB2
		left join TABLE1_PATIENT_HISTORY as H
			on CB2.VISIT_OCCURRENCE_ID = H.VISIT_OCCURRENCE_ID
		left join TABLE1_Laboratories as L
			on CB2.VISIT_OCCURRENCE_ID = L.VISIT_OCCURRENCE_ID
		left join Table1_ENRICHD_Score as E
			on CB2.VISIT_OCCURRENCE_ID = E.VISIT_OCCURRENCE_ID
		left join Table1_Discharge_Information as DI
			on CB2.VISIT_OCCURRENCE_ID = DI.VISIT_OCCURRENCE_ID
;


--In-hospital---------------------------------------------------------------------------
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.conditionid = 55	then 1 else 0 end) as In_Hospital_PCI_Flag
	, MAX(case when Ref.conditionid = 202 then 1 else 0 end) as Cardiac_Arrest_Flag
into #Table1_GRACE_InHospital_Vars
from COHORT_BASE_2 as CB2
	left join 
	Condition_Occurrence as CO
		ON CB2.PERSON_ID = CO.PERSON_ID
		and CO.CONDITION_START_DATE between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
	left join
	Ref_Conditions_SNOMED as Ref
		ON CO.CONDITION_CONCEPT_ID = Ref.TARGET_CONCEPT_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;


--Systolic BP  returns 0 cases-------------------------------------------------------------------------------
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, AVG(M.value_as_number) as Systolic_BP_Avg
	, max(M.unit_source_value) as Systolic_BP_Units
into #Table1_GRACE_Score_Systolic_BP_Avg
from COHORT_BASE_2 as CB2
	left join 
	MEASUREMENT as M
		on CB2.PERSON_ID = M.PERSON_ID
		and M.Measurement_Date between CB2.Admit_Date and CB2.Discharge_Date
where M.Measurement_Concept_ID = 3004249 --BP systolic
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG;

--select count(*) from Table1_GRACE_Score_Systolic_BP_Avg;
--select * from Table1_GRACE_Score_Systolic_BP_Avg limit 100;

--Heart Rate returns 0 cases--------------------------------------------------------------------------------
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, AVG(M.value_as_number) as Heart_Rate_Avg
	, max(M.unit_source_value) as Heart_Rate_Units
into #Table1_GRACE_Score_Heart_Rate_Avg
from COHORT_BASE_2 as CB2
	left join 
	MEASUREMENT as M
		on CB2.PERSON_ID = M.PERSON_ID
		and M.Measurement_Date between CB2.Admit_Date and CB2.Discharge_Date
where M.Measurement_Concept_ID = 3027018 --Heart rate	Measurement
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE;

--select count(*) from Table1_GRACE_Score_Heart_Rate_Avg; --9225
--select * from Table1_GRACE_Score_Heart_Rate_Avg limit 100;


--ST-Segment returns 0 cases---------------------------------------------------------------------
--CONCEPT_NAME	MEASUREMENT_CONCEPT_ID
--ST segment axis.horizontal plane	3007722

--For ST segment deviation use STEMI flag from discharge information

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, AVG(M.value_as_number) as ST_Segment_Avg
	, max(M.unit_source_value) as ST_Segment_Units
	, M.Measurement_Concept_ID
	into #Table1_GRACE_Score_ST_Segment_Avg
from COHORT_BASE_2 as CB2
	left join 
	MEASUREMENT as M
		on CB2.PERSON_ID = M.PERSON_ID
		and M.Measurement_Date between CB2.Admit_Date and CB2.Discharge_Date
where M.Measurement_Concept_ID = 3007722 --ST segment axis.horizontal plane
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, M.Measurement_Concept_ID;

--Values range from -90 to 270 degrees



--Cardiac enzymes----------------------------------------------------------------------

--Troponin I returns 0 cases------------------
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, AVG(M.value_as_number) as Troponin_I_Avg
	, max(M.unit_source_value) as Troponin_I_Units
	, case 
		when AVG(M.value_as_number) >= .04 then 1 else 0
	  end as Trop_I_Cardiac_Marker_Elevation_Flag
into #Table1_GRACE_Score_Troponin_I_Avg
from COHORT_BASE_2 as CB2
	left join 
	MEASUREMENT as M
		on CB2.PERSON_ID = M.PERSON_ID
		and M.Measurement_Date between CB2.Admit_Date and CB2.Discharge_Date
where M.Measurement_Concept_ID IN
	(
	 	 3021337 --Concept_ID = 3021337  for Troponin I.cardiac [Mass/volume] in Serum or Plasma
		,3033745 --Concept_ID = 3033745 for Troponin I.cardiac [Mass/volume] in Blood
	)
group by 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
;

--select count(*) from Table1_GRACE_Score_Troponin_I_Avg; --7512 for Trop I --7302 for 3021337  --7512 for 3021337 plus 3033745


--Troponin T-------------------
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, AVG(M.value_as_number) as Troponin_T_Avg 
	, max(M.unit_source_value) as Troponin_T_Units
	, case 
			when AVG(M.value_as_number) > MAX(M.RANGE_HIGH)
			then 1 else 0
	  end as Trop_T_Cardiac_Marker_Elevation_Flag
into #Table1_GRACE_Score_Troponin_T_Avg
from COHORT_BASE_2 as CB2
	left join 
	MEASUREMENT as M
		on CB2.PERSON_ID = M.PERSON_ID
		and M.Measurement_Date between CB2.Admit_Date and CB2.Discharge_Date
where M.Measurement_Concept_ID IN
	(
	 	 3048529	--Troponin T.cardiac [Mass/volume] in Blood
		,3019800	--Troponin T.cardiac [Mass/volume] in Serum or Plasma
	)
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, M.Measurement_Concept_ID
;

--select count(*) from Table1_GRACE_Score_Troponin_T_Avg; --834






--Combine temp tables-------------------------------------------------------------------------
Select
		 V.PERSON_ID
       , V.VISIT_OCCURRENCE_ID
       , V.AGE_AT_ADMIT
	   , V.HISTORY_AMI_FLAG
	   , V.CREATININE_LEVEL_FIRST
	   , V.Killip_Class
	   , V.STEMI_FLAG
	   , case 
	   		when IHV.In_Hospital_PCI_Flag is null 
			then 0 
			else In_Hospital_PCI_Flag
	     end as In_Hospital_PCI_Flag
	   , case 
	   		when IHV.Cardiac_Arrest_Flag is null 
			then 0 
			else Cardiac_Arrest_Flag
	     end as Cardiac_Arrest_Flag 
	   , BP.Systolic_BP_Avg
	   , BP.Systolic_BP_Units
	   , HR.Heart_Rate_Avg
	   , HR.Heart_Rate_Units
	   , ST.ST_Segment_Avg
	   , ST.ST_Segment_Units
	   , TI.Troponin_I_Avg
	   , TI.Troponin_I_Units
	   , TT.Troponin_T_Avg
	   , TT.Troponin_T_Units
	   , case 
	   		when TI.Trop_I_Cardiac_Marker_Elevation_Flag = 1 or TT.Trop_T_Cardiac_Marker_Elevation_Flag = 1
			then 1
			else 0
	     end as Cardiac_Marker_Elevation_Flag
into #Table1_GRACE_Score1
from #Table1_GRACE_Vars as V
left join #Table1_GRACE_InHospital_Vars as IHV
	on V.VISIT_OCCURRENCE_ID = IHV.VISIT_OCCURRENCE_ID
left join #Table1_GRACE_Score_Systolic_BP_Avg as BP
	on V.VISIT_OCCURRENCE_ID = BP.VISIT_OCCURRENCE_ID
left join #Table1_GRACE_Score_Heart_Rate_Avg as HR
	on V.VISIT_OCCURRENCE_ID = HR.VISIT_OCCURRENCE_ID
left join #Table1_GRACE_Score_ST_Segment_Avg as ST
	on V.VISIT_OCCURRENCE_ID = ST.VISIT_OCCURRENCE_ID
left join #Table1_GRACE_Score_Troponin_I_Avg as TI
	on V.VISIT_OCCURRENCE_ID = TI.VISIT_OCCURRENCE_ID
left join #Table1_GRACE_Score_Troponin_T_Avg as TT
	on V.VISIT_OCCURRENCE_ID = TT.VISIT_OCCURRENCE_ID
;


--Grace score elements
select
		   PERSON_ID
		 , VISIT_OCCURRENCE_ID
		 , In_Hospital_PCI_Flag
		 , Cardiac_Arrest_Flag
		 , Systolic_BP_Avg
	     --, Systolic_BP_Units
	     , Heart_Rate_Avg
	     --, Heart_Rate_Units
	     , ST_Segment_Avg
	     --, ST_Segment_Units
	     , Troponin_I_Avg
	     --, Troponin_I_Units
		 , Troponin_T_Avg
	     --, Troponin_T_Units
	     , Cardiac_Marker_Elevation_Flag	
		 , case 
		  	when AGE_AT_ADMIT < 30 then 0
		  	when AGE_AT_ADMIT between 30 and 39 then 8
		  	when AGE_AT_ADMIT between 40 and 49 then 25
		  	when AGE_AT_ADMIT between 50 and 59 then 41
		  	when AGE_AT_ADMIT between 60 and 69 then 58
		  	when AGE_AT_ADMIT between 70 and 79 then 75
		  	when AGE_AT_ADMIT between 80 and 89 then 91
		  	when AGE_AT_ADMIT >= 90  then 100
		   end as Grace_Score_Age
		 , case 
		  	when Heart_Rate_Avg < 50 then 0
		  	when Heart_Rate_Avg between 50 and 69 then 3
		  	when Heart_Rate_Avg between 70 and 89 then 9
		  	when Heart_Rate_Avg between 90 and 109 then 15
		  	when Heart_Rate_Avg between 110 and 149 then 24
		  	when Heart_Rate_Avg between 150 and 199 then 38
		  	when Heart_Rate_Avg >= 200 then 46
		  	else 0
		   end as Grace_Score_Heart_Rate
		 , case 
		  	when Systolic_BP_Avg < 80 then 0
		  	when Systolic_BP_Avg between 80 and 99 then 53
		  	when Systolic_BP_Avg between 100 and 119 then 43
		  	when Systolic_BP_Avg between 120 and 139 then 34
		  	when Systolic_BP_Avg between 140 and 159 then 24
		  	when Systolic_BP_Avg between 160 and 199 then 10
		  	when Systolic_BP_Avg >= 200 then 0
		  	else 0
		   end as Grace_Score_Systolic_BP
		 , case 
		  	when CREATININE_LEVEL_FIRST < 0.4 then 1
		  	when CREATININE_LEVEL_FIRST between 0.4 and 0.79 then 4
		  	when CREATININE_LEVEL_FIRST between 0.8 and 1.19 then 7
		  	when CREATININE_LEVEL_FIRST between 1.2 and 1.59 then 10
		  	when CREATININE_LEVEL_FIRST between 1.6 and 1.99 then 13
		  	when CREATININE_LEVEL_FIRST between 0.2 and 3.99 then 21
		  	when CREATININE_LEVEL_FIRST >= 4 then 28
		  	else 0
		   end as Grace_Score_CREATININE_LEVEL_FIRST
		 , case
		  	when Killip_Class = 'I' then 0
		  	when Killip_Class = 'II' then 20
		  	when Killip_Class = 'III' then 39
		  	when Killip_Class = 'IV' then 59
		  	else 0
		   end as Grace_Score_Killip_Class
		 , case
		  	when Cardiac_Marker_Elevation_Flag = 1 then 14
		  	else 0
		   end as Grace_Score_Cardiac_Marker_Elevation
		 , case
		  	when Cardiac_Arrest_Flag  = 1 then 39
		  	else 0
		   end as Grace_Score_Cardiac_Arrest
		 , case
		  	when STEMI_FLAG  = 1 then 28
		  	else 0
		   end as Grace_Score_STEMI
into #Table1_GRACE_Score2
from #Table1_GRACE_Score1;

--Final table---------------------------------------------------------
--drop table Table1_GRACE_Score if exists;


IF OBJECT_ID('Table1_GRACE_Score', 'U') IS NOT NULL 
BEGIN
  DROP TABLE Table1_GRACE_Score
END

GO

select
	GS2.*
	,(  
	    Grace_Score_Age
	  + Grace_Score_Heart_Rate
	  + Grace_Score_Systolic_BP
	  + Grace_Score_CREATININE_LEVEL_FIRST
	  + Grace_Score_Killip_Class
	  + Grace_Score_Cardiac_Marker_Elevation
	  + Grace_Score_Cardiac_Arrest
	  + Grace_Score_STEMI
	 ) as Grace_Score
into Table1_GRACE_Score
from #Table1_GRACE_Score2 as GS2;

/*
SYSTOLIC_BP_UNITS
mmHg

HEART_RATE_UNITS
bpm

ST_SEGMENT_UNITS
deg

TROPONIN_UNITS
ng/mL
*/

--End of Part 14----------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------
/*

Select * from Table1_GRACE_Score limit 100;

Select count(*) from Table1_GRACE_Score;

*/
