-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-- edite code here to run against DH OMOP_CDM entity names
-----------------------------------------------------------------------------------------

--Initial test script
--This script pulls all of the AMI patients, some visit dates, and some demographic info

select distinct
	OVO.VISIT_OCCURRENCE_ID as VISIT_OCCURRENCE_ID
	, OCO.CONDITION_SOURCE_VALUE as PRIM_DIAG
	, OVO.VISIT_START_DATE as ADMIT_DATE
	, OVO.VISIT_START_DATE as ADMIT_DATETIME
	, OVO.VISIT_END_DATE as DISCHARGE_DATE
	, OVO.VISIT_END_DATE as DISCHARGE_DATETIME
	, OVO.PERSON_ID as PERSON_ID
	, OPer.PERSON_SOURCE_VALUE as MRN
	--, OPer.BIRTH_DATE as DOB
	, OCon1.CONCEPT_NAME as GENDER
	, OCon2.CONCEPT_NAME as RACE
	, OCon3.CONCEPT_NAME as ETHNICITY
	, OLoc.ZIP as ZIPCODE
INTO #AMICOHORTBASE
from 
	VISIT_OCCURRENCE as OVO
	left join 
	CONDITION_OCCURRENCE as OCO
		on OVO.VISIT_OCCURRENCE_ID = OCO.VISIT_OCCURRENCE_ID
	left join 
	PERSON as OPer
		on OVO.PERSON_ID = OPer.PERSON_ID
	left join
	CONCEPT as OCon1
		on OCon1.CONCEPT_ID = OPer.GENDER_CONCEPT_ID 
	left join
	CONCEPT as OCon2
		on OCon2.CONCEPT_ID = OPer.RACE_CONCEPT_ID 
	left join
	CONCEPT as OCon3
		 on OCon3.CONCEPT_ID = OPer.ETHNICITY_CONCEPT_ID 
	left join
	LOCATION as OLoc
		on OPer.LOCATION_ID = OLoc.LOCATION_ID
where 
	OVO.VISIT_CONCEPT_ID = 9201 --Inpatient
	and OCO.CONDITION_TYPE_CONCEPT_ID = '38000200' --Inpatient Header first position

	and OCO.Condition_Concept_ID IN --All of the target concept_IDs for AMI (reference below)
		(
			438438
			,434376
			,438447
			,441579
			,438170
			,436706
			,439693
			,444406
			,312327
			,4296653
			,46270163
			,4296653
			,4270024
		) 
		
		order by PERSON_ID, VISIT_OCCURRENCE_ID
		
		/*
		limit 1000
;



--For Reference (AMI Diagnosis codes mapped to standard OMOP concept, which is SNOMED):
CONDITION_SOURCE_VALUE	CONDITION_SOURCE_CONCEPT_ID		CONDITION_CONCEPT_ID 	CONCEPT_NAME											DOMAIN_ID	VOCABULARY_ID	CONCEPT_CLASS_ID	STANDARD_CONCEPT
410.00					44824237						438438					Acute myocardial infarction of anterolateral wall		Condition	SNOMED			Clinical Finding	S
410.01					44823111						438438					Acute myocardial infarction of anterolateral wall		Condition	SNOMED			Clinical Finding	S
410.10					44831236						434376					Acute myocardial infarction of anterior wall			Condition	SNOMED			Clinical Finding	S
410.11					44827782						434376					Acute myocardial infarction of anterior wall			Condition	SNOMED			Clinical Finding	S
410.20					44819699						438447					Acute myocardial infarction of inferolateral wall		Condition	SNOMED			Clinical Finding	S
410.21					44819700						438447					Acute myocardial infarction of inferolateral wall		Condition	SNOMED			Clinical Finding	S
410.30					44826635						441579					Acute myocardial infarction of inferoposterior wall		Condition	SNOMED			Clinical Finding	S
410.31					44833561						441579					Acute myocardial infarction of inferoposterior wall		Condition	SNOMED			Clinical Finding	S
410.40					44834719						438170					Acute myocardial infarction of inferior wall			Condition	SNOMED			Clinical Finding	S
410.41					44835926						438170					Acute myocardial infarction of inferior wall			Condition	SNOMED			Clinical Finding	S
410.50					44832375						436706					Acute myocardial infarction of lateral wall				Condition	SNOMED			Clinical Finding	S
410.51					44834720						436706					Acute myocardial infarction of lateral wall				Condition	SNOMED			Clinical Finding	S
410.60					44828972						439693					True posterior myocardial infarction					Condition	SNOMED			Clinical Finding	S
410.61					44837099						439693					True posterior myocardial infarction					Condition	SNOMED			Clinical Finding	S
410.70					44835927						444406					Acute subendocardial infarction							Condition	SNOMED			Clinical Finding	S
410.71					44825429						444406					Acute subendocardial infarction							Condition	SNOMED			Clinical Finding	S
410.80					44826636						312327					Acute myocardial infarction								Condition	SNOMED			Clinical Finding	S
410.81					44834724						312327					Acute myocardial infarction								Condition	SNOMED			Clinical Finding	S
410.90					44835928						312327					Acute myocardial infarction								Condition	SNOMED			Clinical Finding	S
410.91					44825430						312327					Acute myocardial infarction								Condition	SNOMED			Clinical Finding	S
I21.09					45576865						4296653					Acute ST segment elevation myocardial infarction		Condition	SNOMED			Clinical Finding	S
I21.11					45533436						46270163				Acute ST segment elevation myocardial infarction due...	Condition	SNOMED			Clinical Finding	S
I21.19					45605779						4296653					Acute ST segment elevation myocardial infarction		Condition	SNOMED			Clinical Finding	S
I21.29					45557536						4296653					Acute ST segment elevation myocardial infarction		Condition	SNOMED			Clinical Finding	S
I21.3					35207684						4296653					Acute ST segment elevation myocardial infarction		Condition	SNOMED			Clinical Finding	S
I21.4					35207685						4270024					Acute non-ST segment elevation myocardial infarction	Condition	SNOMED			Clinical Finding	S
*/
-------------------------------------------------------------------------------------------------------

--Test 2: Procedure link
--Slightly customized to fit our OMOP instance
select
	ACB.PERSON_ID
	, ACB.VISIT_OCCURRENCE_ID
	, ACB.ADMIT_DATE
	, ACB.DISCHARGE_DATE
	, ACB.PRIM_DIAG
	, count(OPO.PROCEDURE_OCCURRENCE_ID) as Procedure_Count
from
	-- just created this temp table 
	#AMICOHORTBASE as ACB
	left join
	PROCEDURE_OCCURRENCE as OPO
		on 	ACB.PERSON_ID = OPO.PERSON_ID
			AND OPO.Procedure_Date between ACB.ADMIT_DATE and ACB.DISCHARGE_DATE
group by
	  ACB.PERSON_ID
	, ACB.VISIT_OCCURRENCE_ID
	, ACB.ADMIT_DATE
	, ACB.DISCHARGE_DATE
	, ACB.PRIM_DIAG


	-----------------------------------------

	
--Test 3: Drug Exposure link
--Test 3: Drug Exposure link
select
	ACB.PERSON_ID
	, ACB.VISIT_OCCURRENCE_ID
	, ACB.ADMIT_DATE
	, ACB.DISCHARGE_DATE
	, ACB.PRIM_DIAG
	, count(ODE.DRUG_EXPOSURE_ID) as Drug_Exposure_Count
from 
	-- just dreated this table
	#AMICOHORTBASE as ACB
	left join
	DRUG_EXPOSURE as ODE
		on 	ACB.PERSON_ID = ODE.PERSON_ID
			AND ODE.DRUG_EXPOSURE_START_DATE between ACB.ADMIT_DATE and ACB.DISCHARGE_DATE
group by
	  ACB.PERSON_ID
	, ACB.VISIT_OCCURRENCE_ID
	, ACB.ADMIT_DATE
	, ACB.DISCHARGE_DATE
	, ACB.PRIM_DIAG
;





-------------------------------

--Test 4: Measurement link
select
	ACB.PERSON_ID
	, ACB.VISIT_OCCURRENCE_ID
	, ACB.ADMIT_DATE
	, ACB.DISCHARGE_DATE
	, ACB.PRIM_DIAG
	, count(MEASUREMENT_ID) as Measurement_Count
from
	-- just dreated this table 
	#AMICOHORTBASE as ACB
	left join
	Measurement as OM
		on 	ACB.PERSON_ID = OM.PERSON_ID
			AND MEASUREMENT_DATE between ACB.ADMIT_DATE and ACB.DISCHARGE_DATE
group by
	  ACB.PERSON_ID
	, ACB.VISIT_OCCURRENCE_ID
	, ACB.ADMIT_DATE
	, ACB.DISCHARGE_DATE
	, ACB.PRIM_DIAG
	order by Measurement_Count
	
	
	
	
	--clean up
	Drop table #AMICOHORTBASE