
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
/*
PART 6: Add values to table Presentation_Disease for elements from Table 1.
Elements include the following:
Transfer patient
Chest Pain
Cardiac arrest
Clopidogrel use
AMI location
Revascularization
Number of diseased vessels
*/
-----------------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--Transfer patient
--------------------------------------------------------------------------------

/*
ADMITTING_SOURCE_CONCEPT_ID		CONCEPT_NAME
8717	Inpatient Hospital
*/

select 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, CB2.DISCHARGE_DATE
	,case 
		when
		VO.ADMITTING_SOURCE_CONCEPT_ID = 8717
		then 1
		else 0
	end as Transfer_Patient_Flag
into #Table1_Presentation_Disease_Transfer_Patient_Flag
from 
	AMI.COHORT_BASE_2 as CB2
	left join
		OMOP.VISIT_OCCURRENCE AS VO
		on CB2.VISIT_OCCURRENCE_ID = VO.VISIT_OCCURRENCE_ID
;

/*
select Transfer_Patient_Flag, count(*) from #Table1_Presentation_Disease_Transfer_Patient_Flag
group by Transfer_Patient_Flag;
*/


--------------------------------------------------------------------------------
--Chest Pain and Cardiac Arrest
--------------------------------------------------------------------------------
drop table if exists #Table1_Presentation_Disease_1;
GO

select 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when R.ConditionID = 1003 then 1 else 0 end) as Chest_Pain_Flag
	, MAX(case when R.ConditionID = 202	then 1 else 0 end) as Cardiac_Arrest_Flag
into #Table1_Presentation_Disease_1
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
	OMOP.CONDITION_OCCURRENCE as CO
		on CB2.PERSON_ID = CO.PERSON_ID
			and CB2.VISIT_OCCURRENCE_ID = CO.VISIT_OCCURRENCE_ID
	left join 
	AMI.Ref_Conditions_SNOMED as R
		on CO.CONDITION_CONCEPT_ID = R.TARGET_CONCEPT_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG;


--select Chest_Pain_Flag, Cardiac_Arrest_Flag, count(*) from #Table1_Presentation_Disease_1
--group by Chest_Pain_Flag, Cardiac_Arrest_Flag;


--------------------------------------------------------------------------------
--Revascularization (procedures)
--------------------------------------------------------------------------------

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when R.CONDITIONID = 1018 then 1 else 0 end) as Revascularization_Flag
into #Table1_Presentation_Disease_Revascularization_Flag
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
	OMOP.PROCEDURE_OCCURRENCE as OPO
		on CB2.PERSON_ID = OPO.PERSON_ID
			and CB2.VISIT_OCCURRENCE_ID = OPO.VISIT_OCCURRENCE_ID
	left join 
	AMI.REF_Conditions_SNOMED as R
		on OPO.PROCEDURE_Concept_ID = R.Target_Concept_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG;


/*
select count(*) from Table1_Presentation_Disease_Revascularization_Flag;

select Revascularization_Flag, count(*) from #Table1_Presentation_Disease_Revascularization_Flag
group by Revascularization_Flag;
*/


--------------------------------------------------------------------------------
--Number of diseased vessels
--------------------------------------------------------------------------------

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX
		(--1 Vessel
			case when R.Target_Concept_ID = 4106548 then 1 else 0 end
		) as Vessels_1_Flag
	, MAX
		(--2 Vessels
			case when R.Target_Concept_ID = 4234990 then 1 else 0 end
		) as Vessels_2_Flag
	, MAX
		(--3 Vessels
			case when R.Target_Concept_ID = 4031996 then 1 else 0 end
		) as Vessels_3_Flag
	, MAX
		(--4 Vessels
			case when R.Target_Concept_ID = 4008625 then 1 else 0 end
		) as Vessels_4_Flag
into #Table1_Presentation_Disease_Vessels_Flag_Part1
from AMI.COHORT_BASE_2 as CB2
	left join 
		OMOP.PROCEDURE_OCCURRENCE as PO
		on CB2.PERSON_ID = PO.PERSON_ID
			and CB2.VISIT_OCCURRENCE_ID = PO.VISIT_OCCURRENCE_ID
	left join 
		AMI.Ref_Conditions_SNOMED as R
		on PO.PROCEDURE_Concept_ID = R.TARGET_CONCEPT_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG;


select PERSON_ID
	, VISIT_OCCURRENCE_ID
	, ADMIT_DATE
	, PRIM_DIAG
	, Vessels_1_Flag
	, Vessels_2_Flag
	, Vessels_3_Flag
	, Vessels_4_Flag
	, case 
		when Vessels_1_Flag = 1 then 1
		when Vessels_2_Flag = 1 then 2
		when Vessels_3_Flag = 1 then 3
		when Vessels_4_Flag = 1 then 4
	  	else 0
	  end as Vessels_Count
into #Table1_Presentation_Disease_Vessels_Flag_Part2
from #Table1_Presentation_Disease_Vessels_Flag_Part1;



--select count(*) from Table1_Presentation_Disease_Vessels_Flag_Part2;

--select Vessels_Count, count(*) from #Table1_Presentation_Disease_Vessels_Flag_Part2 group by Vessels_Count;

--select Vessels_1_Flag, count(*) from #Table1_Presentation_Disease_Vessels_Flag_Part1 group by Vessels_1_Flag;

--select Vessels_2_Flag, count(*) from #Table1_Presentation_Disease_Vessels_Flag_Part1 group by Vessels_2_Flag;

--select Vessels_3_Flag, count(*) from #Table1_Presentation_Disease_Vessels_Flag_Part1 group by Vessels_3_Flag;

--select Vessels_4_Flag, count(*) from #Table1_Presentation_Disease_Vessels_Flag_Part1 group by Vessels_4_Flag;


--------------------------------------------------------------------------------
--Clopidogrel use
--------------------------------------------------------------------------------

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX
	  (
		case 
			when OCon.CONCEPT_NAME like '%CLOPIDOGREL%' or OCon.CONCEPT_NAME like '%PLAVIX%'
			then 1 
			else 0 
		end
	  ) as Clopidogrel_Flag
into #Table1_Presentation_Disease_Clopidogrel_Flag
from AMI.COHORT_BASE_2 as CB2
	left join 
	OMOP.DRUG_EXPOSURE as DE
		on CB2.PERSON_ID = DE.PERSON_ID
			and CB2.VISIT_OCCURRENCE_ID = DE.VISIT_OCCURRENCE_ID
	left join
	OMOP.Concept as OCon
		on DE.DRUG_CONCEPT_ID = OCon.CONCEPT_ID
where OCon.DOMAIN_ID = 'Drug' and OCon.VOCABULARY_ID = 'RxNorm' and OCon.STANDARD_CONCEPT = 'S'
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG;



--select count(*) from Table1_Presentation_Disease_Clopidogrel_Flag;

--select Clopidogrel_Flag, count(*) from #Table1_Presentation_Disease_Clopidogrel_Flag group by Clopidogrel_Flag;


--------------------------------------------------------------------------------
--AMI location
--------------------------------------------------------------------------------

/*
--410.*(0 or1) 
410.01 anterolateral wall 	I21.09
410.11 anterior wall 	
410.21 inferolateral wall. 	
410.31 inferoposterior wall, 	
410.41 other inferior wall 	
410.51 other lateral wall 	
410.61 True posterior wall infarction initial episode of care 	
410.71 Subendocardial infarction 	
410.81 Acute myocardial infarction of other specified sites 	
410.91 Acute myocardial infarction of unspecified site	
*/

select 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, CB2.DISCHARGE_DATE
	,case 
		when CB2.Prim_Diag IN ('410.00', '410.01')						then 'Anterolateral wall'
		when CB2.Prim_Diag IN ('410.10', 'I21.09')						then 'Other anterior wall'
		when CB2.Prim_Diag IN ('410.11', 'I21.0', 'I21.02')				then 'Anterior wall'
		when CB2.Prim_Diag IN ('410.20','410.21', 'I21.19')				then 'Inferolateral wall'
		when CB2.Prim_Diag IN ('410.30', '410.31', 'I21.11')			then 'Inferoposterior wall'
		when CB2.Prim_Diag IN ('410.40', '410.41', 'I21.19')			then 'Other inferior wall'
		when CB2.Prim_Diag IN ('410.50','410.51')						then 'Other lateral wall'
		when CB2.Prim_Diag IN ('410.60', '410.61')						then 'True posterior wall infarction initial episode of care'
		when CB2.Prim_Diag IN ('410.70', '410.71', 'I21.4')				then 'Subendocardial infarction'
		when CB2.Prim_Diag IN ('410.80', '410.81', 'I21.29', 'I21.2')	then 'Other specified sites'
		when CB2.Prim_Diag IN ('410.90', '410.91', 'I21.3')				then 'Unspecified site'
		else 'NA'
	end as AMI_Location
into #Table1_Presentation_Disease_AMI_Location
from 
	AMI.COHORT_BASE_2 as CB2
;


--select count(*) from Table1_Presentation_Disease_AMI_Location;

--select AMI_Location, count(*) from #Table1_Presentation_Disease_AMI_Location group by AMI_Location;


-------------------------------------------------------------------
--Join the temp tables
-------------------------------------------------------------------

drop table if exists AMI.Table1_Presentation_Disease;

select
	  T.PERSON_ID
	, T.VISIT_OCCURRENCE_ID
	, T.Transfer_Patient_Flag
	, PD.Chest_Pain_Flag
	, PD.Cardiac_Arrest_Flag
	, R.Revascularization_Flag
	, V.Vessels_1_Flag
	, V.Vessels_2_Flag
	, V.Vessels_3_Flag
	, V.Vessels_4_Flag
	, V.Vessels_Count
	, C.Clopidogrel_Flag
	, L.AMI_Location
into AMI.Table1_Presentation_Disease
from 
	#Table1_Presentation_Disease_Transfer_Patient_Flag AS T
	left join
	#Table1_Presentation_Disease_1 AS PD
		on T.VISIT_OCCURRENCE_ID = PD.VISIT_OCCURRENCE_ID
	left join
	#Table1_Presentation_Disease_Revascularization_Flag AS R
		on T.VISIT_OCCURRENCE_ID = R.VISIT_OCCURRENCE_ID
	left join 
	#Table1_Presentation_Disease_Vessels_Flag_Part2 AS V
		on T.VISIT_OCCURRENCE_ID = V.VISIT_OCCURRENCE_ID
	left join 
	#Table1_Presentation_Disease_Clopidogrel_Flag AS C
		on T.VISIT_OCCURRENCE_ID = C.VISIT_OCCURRENCE_ID
	left join
	#Table1_Presentation_Disease_AMI_Location AS L
		on T.VISIT_OCCURRENCE_ID = L.VISIT_OCCURRENCE_ID
;


/*
select count(*) from AMI.Table1_Presentation_Disease;
*/