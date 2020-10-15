
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 8: Add values to Table1_Patient_History for elements from Table 1:
History of:
Myocardial infarction
PCI
CABG
Peripheral vascular disease
Angina
Hypertension
Chest pain
Unstable Angina
Depression


Number of major depressive episodes
Family history of depression
*/
-----------------------------------------------------------------------------------------
--USE AMI

USE OMOP_CDM -- 10/13/2020
GO

/*
Myocardial infarction
PCI
CABG
Peripheral vascular disease
Angina
Unstable Angina
Hypertension
Chest Pain
*/

---drop table if exists #Table1_Patient_History1
;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when AR.conditionid IN (13, 280)			then 1 else 0 end) as History_AMI_Flag
	, MAX(case when AR.conditionid = 48					then 1 else 0 end) as History_CABG_Flag
	, MAX(case when AR.conditionid = 55					then 1 else 0 end) as History_PCI_Flag
	, MAX(case when AR.conditionid IN (282, 12)			then 1 else 0 end) as History_PVD_Flag
	, MAX(case when AR.conditionid = 203				then 1 else 0 end) as History_Angina_Flag
	, MAX(case when AR.conditionid = 53					then 1 else 0 end) as History_Unstable_Angina_Flag
	, MAX(case when AR.conditionid IN (6, 406, 407)		then 1 else 0 end) as History_Hypertension_Flag
	, MAX(case when AR.conditionid = 431				then 1 else 0 end) as History_Depression_Flag 
	, MAX(case when AR.conditionid = 1003				then 1 else 0 end) as History_Chest_Pain_Flag     
into #Table1_Patient_History1
from 
	COHORT_BASE_2 as CB2
	left join 
	Condition_Occurrence as OCO
		ON CB2.PERSON_ID = OCO.PERSON_ID
		and OCO.Condition_Start_Date < CB2.ADMIT_DATE
	left join
	Ref_Conditions_SNOMED as AR
		ON OCO.Condition_Concept_ID = AR.Target_Concept_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;
--select * from #Table1_Patient_History1




--Family history of depression-------------------------------------------------------------------------------------
---drop table if exists #Table1_Patient_History_Family_Depression_I10
;

--I10
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when CO.CONDITION_SOURCE_VALUE = 'Z81.8'	then 1 else 0 end) as History_Family_Depression_I10_Flag
into #Table1_Patient_History_Family_Depression_I10
from COHORT_BASE_2 as CB2
	left join 
		CONDITION_OCCURRENCE as CO
		on CB2.PERSON_ID = CO.PERSON_ID
			and CO.CONDITION_START_DATE <= CB2.ADMIT_DATE
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;
/*
select History_Family_Depression_I10_Flag, count(*)
from Table1_Patient_History_Family_Depression_I10
group by History_Family_Depression_I10_Flag;
*/

--I9
---drop table if exists #Table1_Patient_History_Family_Depression_I9
;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when O.OBSERVATION_SOURCE_VALUE = 'V17.0'	then 1 else 0 end) as History_Family_Depression_I9_Flag
into #Table1_Patient_History_Family_Depression_I9
from COHORT_BASE_2 as CB2
	left join 
		OBSERVATION as O
		on CB2.PERSON_ID = O.PERSON_ID
			and O.OBSERVATION_DATE <= CB2.ADMIT_DATE
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;
/*
select History_Family_Depression_I9_Flag, count(*)
from Table1_Patient_History_Family_Depression_I9
group by History_Family_Depression_I9_Flag;
*/


--I9 and I10 combined
---drop table if exists #Table1_Patient_History_Family_Depression_Flag
;

select 
	  D1.PERSON_ID
	, d1.VISIT_OCCURRENCE_ID
	, case
		when D2.History_Family_Depression_I9_Flag = 1
			or D1.History_Family_Depression_I10_Flag = 1
		then 1
		else 0
	  end as Family_Depression_Flag
into #Table1_Patient_History_Family_Depression_Flag
from #Table1_Patient_History_Family_Depression_I10 as D1
	left join 
		#Table1_Patient_History_Family_Depression_I9 as D2
		on D1.PERSON_ID = D2.PERSON_ID
			and D1.VISIT_OCCURRENCE_ID = D2.VISIT_OCCURRENCE_ID
;
/*
select Family_Depression_Flag, count(*)
from Table1_Patient_History_Family_Depression
group by Family_Depression_Flag;
*/


--number of major depressive episodes----------------------------------------------------
--De-duplicate multiples on the same day
--Count up the number of episodes in the year prior to the admission (but only count them once for a given day if multiple)

---drop table if exists #Table1_Patient_History_Major_Depression_Flag
;

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, OCO.CONDITION_START_DATE
	, Max(case when Ref.conditionid = 431 then 1 else 0 end) as Major_Depression_Flag    
into #Table1_Patient_History_Major_Depression_Flag
from 
	COHORT_BASE_2 as CB2
	left join 
	CONDITION_OCCURRENCE as OCO
		ON CB2.PERSON_ID = OCO.PERSON_ID
		AND OCO.CONDITION_START_DATE <= CB2.ADMIT_DATE
		AND OCO.CONDITION_START_DATE >= DateAdd(dd,-365, CB2.ADMIT_DATE)
	left join
	Ref_Conditions_SNOMED as Ref
		on OCO.CONDITION_CONCEPT_ID = Ref.TARGET_CONCEPT_ID
where
	Ref.conditionid = 431
group by 
	CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, OCO.CONDITION_START_DATE
;


---drop table if exists #Table1_Patient_History_Major_Depression_Count
;

select PERSON_ID, VISIT_OCCURRENCE_ID, SUM(Major_Depression_Flag) as Major_Depression_Count
into #Table1_Patient_History_Major_Depression_Count
from #Table1_Patient_History_Major_Depression_Flag
group by PERSON_ID, VISIT_OCCURRENCE_ID;
/*
select Major_Depression_Count, count(*)
from Table1_Patient_History_Major_Depression_Count
group by Major_Depression_Count;
*/
 

--Combine temp tables-----------------------------------------------------------------
 ---drop table if exists Table1_Patient_History;

 if exists (select * from sys.objects where name = 'Table1_Patient_History' and type = 'u')
    drop table Table1_Patient_History
 
 select 
 	  H1.PERSON_ID
	, H1.VISIT_OCCURRENCE_ID
	, H1.ADMIT_DATE
	, H1.PRIM_DIAG
	, case when	H1.History_Chest_Pain_Flag IS NOT NULL
		then H1.History_Chest_Pain_Flag
		else 0
	  end as History_Chest_Pain_Flag
	, case when	H1.History_AMI_Flag IS NOT NULL
		then H1.History_AMI_Flag
		else 0
	  end as History_AMI_Flag 
	, case when	H1.History_CABG_Flag IS NOT NULL
		then H1.History_CABG_Flag
		else 0
	  end as History_CABG_Flag 
	, case when	H1.History_PCI_Flag IS NOT NULL
		then H1.History_PCI_Flag
		else 0
	  end as History_PCI_Flag 
	, case when	H1.History_PVD_Flag IS NOT NULL
		then H1.History_PVD_Flag
		else 0
	  end as History_PVD_Flag 
	, case when	H1.History_Angina_Flag IS NOT NULL
		then H1.History_Angina_Flag
		else 0
	  end as History_Angina_Flag 	  
	, case when	H1.History_Unstable_Angina_Flag IS NOT NULL
		then H1.History_Unstable_Angina_Flag
		else 0
	  end as History_Unstable_Angina_Flag 	  
	, case when	H1.History_Hypertension_Flag IS NOT NULL
		then H1.History_Hypertension_Flag
		else 0
	  end as History_Hypertension_Flag 
	, case when	H1.History_Depression_Flag IS NOT NULL
		then H1.History_Depression_Flag
		else 0
	  end as History_Depression_Flag  
	, case when	FD.Family_Depression_Flag IS NOT NULL
		then FD.Family_Depression_Flag
		else 0
	  end as Family_Depression_Flag 
	, case when	MDC.Major_Depression_Count IS NOT NULL
		then MDC.Major_Depression_Count
		else 0
	  end as Major_Depression_Count 
into Table1_Patient_History
from 
	#Table1_Patient_History1 as H1
	left join 
	#Table1_Patient_History_Family_Depression_Flag as FD
		on H1.PERSON_ID = FD.PERSON_ID
		and H1.VISIT_OCCURRENCE_ID = FD.VISIT_OCCURRENCE_ID
	left join 
	#Table1_Patient_History_Major_Depression_Count as MDC
		on H1.PERSON_ID = MDC.PERSON_ID
		and H1.VISIT_OCCURRENCE_ID = MDC.VISIT_OCCURRENCE_ID
;


--End of PART 8--------------------------------------------------------------------------



/*
--Totals

select * from Table1_Patient_History limit 100;

select count(*) from Table1_Patient_History;


  SELECT
       SUM(History_AMI_Flag)
      ,SUM(History_CABG_Flag)
      ,SUM(History_PCI_Flag)
      ,SUM(History_PVD_Flag)
      ,SUM(History_Angina_Flag)
      ,SUM(History_Unstable_Angina_Flag)
      ,SUM(History_Hypertension_Flag)
	  ,SUM(History_Depression_Flag)
	  ,SUM(History_Chest_Pain_Flag)
	  ,SUM(Family_Depression_Flag)
	FROM 	        
	  Table1_Patient_History
  ;
  
  
select Major_Depression_Count, count(*)
from Table1_Patient_History
group by Major_Depression_Count;
*/