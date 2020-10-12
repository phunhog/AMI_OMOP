-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 5.1: Add values to Table1_Discharge_Information_Meds for elements from Table 1:
Anti-depressant on discharge
Aspirin on discharge
Beta blocker on discharge
ACE or ARB inhibitors combined at discharge
*/


--Part 1:
--Build reference table for discharge medications: Ref_Discharge_Medications

--USE AMI
USE OMOP_CDM --10/12 2020
GO

---drop table if exists Ref_Discharge_Medications
;

select 
	*
	,CASE
		WHEN
			--Beta blockers
			(
				LOWER(CONCEPT_NAME) like '%acebutolol%'
				or
				LOWER(CONCEPT_NAME) like '%atenolol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%betaxolol%'
				or
				LOWER(CONCEPT_NAME) like '%bisoprolol%'  --on Rashmee's list(abbreviated)
				or
				LOWER(CONCEPT_NAME) like '%carteolol%'
				or
				LOWER(CONCEPT_NAME) like '%carvedilol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%esmolol%'
				or
				LOWER(CONCEPT_NAME) like '%labetalol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%metoprolol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%nadolol%'
				or
				LOWER(CONCEPT_NAME) like '%nebivolol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%penbutolol%'
				or
				LOWER(CONCEPT_NAME) like '%pindolol%'
				or
				LOWER(CONCEPT_NAME) like '%propranolol%'
				or
				LOWER(CONCEPT_NAME) like '%sotalol%'
				or
				LOWER(CONCEPT_NAME) like '%timolol%'
			)
		THEN 'Beta Blocker'
		
		WHEN
			--Antidepressants
			(
				LOWER(CONCEPT_NAME) like '%aripiprazole%'
				or
				LOWER(CONCEPT_NAME) like '%doxepin%'
				or
				LOWER(CONCEPT_NAME) like '%clomipramine%'
				or
				LOWER(CONCEPT_NAME) like '%bupropion%'
				or
				LOWER(CONCEPT_NAME) like '%amoxapine%'
				or
				LOWER(CONCEPT_NAME) like '%nortriptyline%'
				or
				LOWER(CONCEPT_NAME) like '%citalopram%'
				or
				LOWER(CONCEPT_NAME) like '%duloxetine%'
				or
				LOWER(CONCEPT_NAME) like '%trazodone%'
				or
				LOWER(CONCEPT_NAME) like '%venlafaxine%'
				or
				LOWER(CONCEPT_NAME) like '%selegiline%'
				or
				LOWER(CONCEPT_NAME) like '%perphenazine%'
				or
				LOWER(CONCEPT_NAME) like '%amitriptyline%'
				or
				LOWER(CONCEPT_NAME) like '%amitriptyline%'
				or
				LOWER(CONCEPT_NAME) like '%levomilnacipran%'
				or
				LOWER(CONCEPT_NAME) like '%desvenlafaxine%'
				or
				LOWER(CONCEPT_NAME) like '%lurasidone%'
				or
				LOWER(CONCEPT_NAME) like '%lamotrigine%'
				or
				LOWER(CONCEPT_NAME) like '%escitalopram%'
				or
				LOWER(CONCEPT_NAME) like '%chlordiazepoxide%'
				or
				LOWER(CONCEPT_NAME) like '%isocarboxazid%'
				or
				LOWER(CONCEPT_NAME) like '%phenelzine%'
			)
		THEN 'Antidepressant'
		
		WHEN
			--ACE Inhibitors
			(
				LOWER(CONCEPT_NAME) like '%benazepril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%captopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%enalapril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%fosinopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%lisinopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%moexipril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%perindopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%quinapril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%ramipril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%trandolapril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%cilazapril%'  --on Rashmee's list (added)
			)
		THEN 'ACE Inhibitor'
		
		WHEN
			--ARB
			(
				LOWER(CONCEPT_NAME) like '%eprosartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%olmesartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%valsartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%losartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%telmisartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%candesartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%irbesartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%azilsartan%'  --on Rashmee's list (abbreviated)
			)
		THEN 'ARB'
		
		WHEN
			--Aspirin
			LOWER(CONCEPT_NAME) like '%aspirin%'
			or
			LOWER(CONCEPT_NAME) like '%clopidogrel%'
			or
			LOWER(CONCEPT_NAME) like '%ticlotidine%'
			or
			LOWER(CONCEPT_NAME) like '%ticagrelor%'
			or
			LOWER(CONCEPT_NAME) like '%prasugrel%'
			or
			LOWER(CONCEPT_NAME) like '%cangrelor%'
			or
			LOWER(CONCEPT_NAME) like '%cilostazol%'
			or
			LOWER(CONCEPT_NAME) like '%vorapaxar%'
		THEN 'Aspirin_Group'
		
		WHEN
			--Statin
			LOWER(CONCEPT_NAME) like '%atorvastatin%'  --on Rashmee's list
			or
			LOWER(CONCEPT_NAME) like '%fluvastatin%'  --on Rashmee's list
			or
			LOWER(CONCEPT_NAME) like '%lovastatin%'  --on Rashmee's list
			or
			LOWER(CONCEPT_NAME) like '%pitavastatin%'  --on Rashmee's list
			or
			LOWER(CONCEPT_NAME) like '%pravastatin%'  --on Rashmee's list
			or
			LOWER(CONCEPT_NAME) like '%rosuvastatin%'  --on Rashmee's list
			or
			LOWER(CONCEPT_NAME) like '%simvastatin%'  --on Rashmee's list
			or
			LOWER(CONCEPT_NAME) like '%vorapaxar%'  --on Rashmee's list
		THEN 'Statin'
	END AS Medication_Category
	
	,CASE
		WHEN
				--Beta blockers
				LOWER(CONCEPT_NAME) like '%atenolol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%bisoprolol%'  --on Rashmee's list(abbreviated)
				or
				LOWER(CONCEPT_NAME) like '%carvedilol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%labetalol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%metoprolol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%nebivolol%'  --on Rashmee's list
				or
				
				--ACE Inhibitors
				LOWER(CONCEPT_NAME) like '%benazepril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%captopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%enalapril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%fosinopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%lisinopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%moexipril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%perindopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%quinapril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%ramipril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%trandolapril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%cilazapril%'  --on Rashmee's list (added)
				or
				
				--ARB
				LOWER(CONCEPT_NAME) like '%eprosartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%olmesartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%valsartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%losartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%telmisartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%candesartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%irbesartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%azilsartan%'  --on Rashmee's list (abbreviated)
				or
				
				--Statin
				LOWER(CONCEPT_NAME) like '%atorvastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%fluvastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%lovastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%pitavastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%pravastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%rosuvastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%simvastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%vorapaxar%'  --on Rashmee's list
		THEN 1
		Else 0
	 End as Rashmee_List_Flag
into Ref_Discharge_Medications
from 
	CONCEPT
where 
	standard_concept = 'S'
	and domain_id = 'Drug'
	and vocabulary_id = 'RxNorm'
	and
		(
			--Beta blockers
			
				LOWER(CONCEPT_NAME) like '%acebutolol%'
				or
				LOWER(CONCEPT_NAME) like '%atenolol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%betaxolol%'
				or
				LOWER(CONCEPT_NAME) like '%bisoprolol%'  --on Rashmee's list(abbreviated)
				or
				LOWER(CONCEPT_NAME) like '%carteolol%'
				or
				LOWER(CONCEPT_NAME) like '%carvedilol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%esmolol%'
				or
				LOWER(CONCEPT_NAME) like '%labetalol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%metoprolol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%nadolol%'
				or
				LOWER(CONCEPT_NAME) like '%nebivolol%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%penbutolol%'
				or
				LOWER(CONCEPT_NAME) like '%pindolol%'
				or
				LOWER(CONCEPT_NAME) like '%propranolol%'
				or
				LOWER(CONCEPT_NAME) like '%sotalol%'
				or
				LOWER(CONCEPT_NAME) like '%timolol%'
				
			--Antidepressants
				or
				LOWER(CONCEPT_NAME) like '%aripiprazole%'
				or
				LOWER(CONCEPT_NAME) like '%doxepin%'
				or
				LOWER(CONCEPT_NAME) like '%clomipramine%'
				or
				LOWER(CONCEPT_NAME) like '%bupropion%'
				or
				LOWER(CONCEPT_NAME) like '%amoxapine%'
				or
				LOWER(CONCEPT_NAME) like '%nortriptyline%'
				or
				LOWER(CONCEPT_NAME) like '%citalopram%'
				or
				LOWER(CONCEPT_NAME) like '%duloxetine%'
				or
				LOWER(CONCEPT_NAME) like '%trazodone%'
				or
				LOWER(CONCEPT_NAME) like '%venlafaxine%'
				or
				LOWER(CONCEPT_NAME) like '%selegiline%'
				or
				LOWER(CONCEPT_NAME) like '%perphenazine%'
				or
				LOWER(CONCEPT_NAME) like '%amitriptyline%'
				or
				LOWER(CONCEPT_NAME) like '%amitriptyline%'
				or
				LOWER(CONCEPT_NAME) like '%levomilnacipran%'
				or
				LOWER(CONCEPT_NAME) like '%desvenlafaxine%'
				or
				LOWER(CONCEPT_NAME) like '%lurasidone%'
				or
				LOWER(CONCEPT_NAME) like '%lamotrigine%'
				or
				LOWER(CONCEPT_NAME) like '%escitalopram%'
				or
				LOWER(CONCEPT_NAME) like '%chlordiazepoxide%'
				or
				LOWER(CONCEPT_NAME) like '%isocarboxazid%'
				or
				LOWER(CONCEPT_NAME) like '%phenelzine%'

			--ACE Inhibitors
				or
				LOWER(CONCEPT_NAME) like '%benazepril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%captopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%enalapril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%fosinopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%lisinopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%moexipril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%perindopril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%quinapril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%ramipril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%trandolapril%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%cilazapril%'  --on Rashmee's list (added)

			--ARB
				or
				LOWER(CONCEPT_NAME) like '%eprosartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%olmesartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%valsartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%losartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%telmisartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%candesartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%irbesartan%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%azilsartan%'  --on Rashmee's list (abbreviated)

			--Aspirin
				or
				LOWER(CONCEPT_NAME) like '%aspirin%'
				or
				LOWER(CONCEPT_NAME) like '%clopidogrel%'
				or
				LOWER(CONCEPT_NAME) like '%ticlotidine%'
				or
				LOWER(CONCEPT_NAME) like '%ticagrelor%'
				or
				LOWER(CONCEPT_NAME) like '%prasugrel%'
				or
				LOWER(CONCEPT_NAME) like '%cangrelor%'
				or
				LOWER(CONCEPT_NAME) like '%cilostazol%'
				or
				LOWER(CONCEPT_NAME) like '%vorapaxar%'
		
			--Statin
				or
				LOWER(CONCEPT_NAME) like '%atorvastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%fluvastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%lovastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%pitavastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%pravastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%rosuvastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%simvastatin%'  --on Rashmee's list
				or
				LOWER(CONCEPT_NAME) like '%vorapaxar%'  --on Rashmee's list
		)
;


--Part 2:
--Assign reliability number for drug exposure groups

--Drug_Type_Concept_Name									Precedence		Vocabulary_ID
--Prescription written										1				Drug Type
--Prescription dispensed in pharmacy						1				Drug Type
--Physician administered drug (identified as procedure)		2				Drug Type
--Inpatient administration									2				Drug Type
--CPT Codes in Drug											2				VUMC Drug Type
--Medication list entry										3				Drug Type
--Patient Self-Reported Medication							3				Drug Type

---drop table if exists Ref_Discharge_Med_Methodology
;

select
	*
	,CASE
		WHEN Concept_Name IN
			(  	 'Prescription written'
			  	,'Prescription dispensed in pharmacy'
			)
		THEN 1
		
		WHEN Concept_Name IN
			(
				 'Physician administered drug (identified as procedure)'
				,'Inpatient administration'
				,'CPT Codes in Drug'
			)
		THEN 2
		
		WHEN Concept_Name IN
			(
				 'Medication list entry'
				,'Patient Self-Reported Medication'
			)
		THEN 3
	 END as Discharge_Med_Methodology
into Ref_Discharge_Med_Methodology
from 
	CONCEPT
where
	Concept_Name IN
	(
		 'Prescription written'
		,'Prescription dispensed in pharmacy'
		,'Physician administered drug (identified as procedure)'
		,'Inpatient administration'
		,'CPT Codes in Drug'
		,'Medication list entry'
		,'Patient Self-Reported Medication'
	)
;


--Part 3
--Get discharge medications for applicable encounters
---drop table if exists #AMI_Discharge_Medications_for_CB2
;

select 
	 CB2.person_id
	,CB2.Visit_Occurrence_ID
	,CB2.INDEX_ADMIT_DATE
	,CB2.INDEX_DISCHARGE_DATE
	,CB2.Admit_Date
	,CB2.Discharge_Date
	,CB2.Discharge_DateTime
	,DE.DRUG_EXPOSURE_START_DATE
	--,DE.DRUG_EXPOSURE_START_DATETIME
	--,extract(epoch from (CB2.Discharge_DateTime - DE.DRUG_EXPOSURE_START_DATETIME))/60 as Discharge_Med_Timing
	,DM.CONCEPT_NAME as DRUG_NAME
	,DMM.CONCEPT_NAME as DRUG_TYPE_NAME
	,DM.MEDICATION_CATEGORY
	,DM.Rashmee_List_Flag
	,CASE
		when DM.MEDICATION_CATEGORY = 'Beta Blocker'
			then 1
			else 0
	 End as Discharge_Med_BB_Flag 
	,CASE
		when DM.MEDICATION_CATEGORY = 'Antidepressant'
			then 1
			else 0
	 End as Discharge_Med_Antidep_Flag 
	,CASE
		when DM.MEDICATION_CATEGORY IN ('ARB', 'ACE Inhibitor')
			then 1
			else 0
	 End as Discharge_Med_ACE_ARB_Flag
	,CASE
		when DM.MEDICATION_CATEGORY IN ('Aspirin_Group')
			then 1
			else 0
	 End as Discharge_Med_Aspirin_Flag
	,CASE
		when DM.MEDICATION_CATEGORY IN ('Statin')
			then 1
			else 0
	 End as Discharge_Med_Statin_Flag
	,DMM.DISCHARGE_MED_METHODOLOGY
	,DE.DRUG_CONCEPT_ID
	,DE.DRUG_TYPE_CONCEPT_ID
into
	#AMI_Discharge_Medications_for_CB2
from COHORT_BASE_2 as CB2
	left join DRUG_EXPOSURE AS DE
		on CB2.Person_ID = DE.Person_ID
		and DE.DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, CB2.Discharge_Date) and dateadd(dd, 1, CB2.Discharge_Date)
	left join REF_DISCHARGE_MEDICATIONS as DM
		on DE.DRUG_CONCEPT_ID = DM.CONCEPT_ID
	left join REF_DISCHARGE_MED_METHODOLOGY as DMM
		on DE.DRUG_TYPE_CONCEPT_ID = DMM.CONCEPT_ID	
where
	DM.CONCEPT_ID IS NOT NULL
group by				
	 CB2.person_id
	,CB2.Visit_Occurrence_ID
	,CB2.INDEX_ADMIT_DATE
	,CB2.INDEX_DISCHARGE_DATE
	,CB2.Admit_Date
	,CB2.Discharge_date
	,CB2.Discharge_DateTime
	,DE.DRUG_EXPOSURE_START_DATE
	--,DE.DRUG_EXPOSURE_START_DATETIME
	,DM.CONCEPT_NAME
	,DMM.CONCEPT_NAME
	,DM.MEDICATION_CATEGORY
	,DMM.DISCHARGE_MED_METHODOLOGY
	,DM.Rashmee_List_Flag
	,DE.DRUG_CONCEPT_ID
	,DE.DRUG_TYPE_CONCEPT_ID
order by
	 CB2.person_id
	,CB2.INDEX_ADMIT_DATE
	,CB2.INDEX_DISCHARGE_DATE
	,CB2.Admit_Date
	,CB2.Discharge_date
	,DE.DRUG_EXPOSURE_START_DATE
	,DE.DRUG_CONCEPT_ID
	,DE.DRUG_TYPE_CONCEPT_ID
	,DM.MEDICATION_CATEGORY
;


--Part 4:
--Assign flags for discharge meds
---drop table if exists #AMI_DISCHARGE_MED_Flags_FOR_CB2
;

SELECT
		PERSON_ID
       ,VISIT_OCCURRENCE_ID
       ,INDEX_ADMIT_DATE
       ,INDEX_DISCHARGE_DATE
       ,ADMIT_DATE
       ,DISCHARGE_DATE
       ,DISCHARGE_MED_METHODOLOGY
	   ,CASE --Beta blocker
	   		WHEN 
				(
					(
						DISCHARGE_MED_BB_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 1 --Prescription
						--and DRUG_EXPOSURE_START_DATE between (DISCHARGE_DATE - 1) and (DISCHARGE_DATE + 1)
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and dateadd(dd, 1, Discharge_Date)
					)
					OR
					(
						DISCHARGE_MED_BB_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 2 --Administered during visit
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and Discharge_Date

					)
					OR
					(
						DISCHARGE_MED_BB_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 3 --Medication list
						and DRUG_EXPOSURE_START_DATE = DISCHARGE_DATE
					)
				)
			THEN 1 Else 0
		 END as DISCHARGE_MED_BB_FLAG
		,CASE --Antidepressant
	   		WHEN 
				(
					(
						DISCHARGE_MED_ANTIDEP_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 1 --Prescription
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and dateadd(dd, 1, Discharge_Date)
					)
					OR
					(
						DISCHARGE_MED_ANTIDEP_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 2 --Administered during visit
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and Discharge_Date
					)
					OR
					(
						DISCHARGE_MED_ANTIDEP_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 3 --Medication list
						and DRUG_EXPOSURE_START_DATE = DISCHARGE_DATE
					)
				)
			THEN 1 Else 0
		 END as DISCHARGE_MED_ANTIDEP_FLAG
		,CASE  --ACE or ARB
	   		WHEN 
				(
					(
						DISCHARGE_MED_ACE_ARB_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 1 --Prescription
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and dateadd(dd, 1, Discharge_Date)
					)
					OR
					(
						DISCHARGE_MED_ACE_ARB_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 2 --Administered during visit
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and Discharge_Date
					)
					OR
					(
						DISCHARGE_MED_ACE_ARB_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 3 --Medication list
						and DRUG_EXPOSURE_START_DATE = DISCHARGE_DATE
					)
				)
			THEN 1 Else 0
		 END as DISCHARGE_MED_ACE_ARB_FLAG
		,CASE  --Aspirin Group
	   		WHEN 
				(
					(
						DISCHARGE_MED_ASPIRIN_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 1 --Prescription
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and dateadd(dd, 1, Discharge_Date)
					)
					OR
					(
						DISCHARGE_MED_ASPIRIN_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 2 --Administered during visit
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and Discharge_Date
					)
					OR
					(
						DISCHARGE_MED_ASPIRIN_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 3 --Medication list
						and DRUG_EXPOSURE_START_DATE = DISCHARGE_DATE
					)
				)
			THEN 1 Else 0
		 END as DISCHARGE_MED_ASPIRIN_FLAG
		 ,CASE  --Statin
	   		WHEN 
				(
					(
						DISCHARGE_MED_STATIN_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 1 --Prescription
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and dateadd(dd, 1, Discharge_Date)
					)
					OR
					(
						DISCHARGE_MED_STATIN_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 2 --Administered during visit
						and DRUG_EXPOSURE_START_DATE between dateadd(dd, -1, Discharge_Date) and Discharge_Date
					)
					OR
					(
						DISCHARGE_MED_STATIN_FLAG = 1
						and DISCHARGE_MED_METHODOLOGY = 3 --Medication list
						and DRUG_EXPOSURE_START_DATE = DISCHARGE_DATE
					)
				)
			THEN 1 Else 0
		 END as DISCHARGE_MED_STATIN_FLAG
INTO
	#AMI_DISCHARGE_MED_Flags_FOR_CB2
FROM 
	#AMI_DISCHARGE_MEDICATIONS_FOR_CB2
Group by
		PERSON_ID
       ,VISIT_OCCURRENCE_ID
       ,INDEX_ADMIT_DATE
       ,INDEX_DISCHARGE_DATE
       ,ADMIT_DATE
       ,DISCHARGE_DATE
	   ,DISCHARGE_MED_BB_FLAG
	   ,DISCHARGE_MED_Antidep_FLAG
	   ,DISCHARGE_MED_ACE_ARB_FLAG
	   ,DISCHARGE_MED_Aspirin_FLAG
	   ,DISCHARGE_MED_STATIN_FLAG
	   ,DISCHARGE_MED_METHODOLOGY
	   ,DRUG_EXPOSURE_START_DATE
	   --,DISCHARGE_MED_TIMING
;


--Part 5:
--Get BB summary data

---drop table if exists #AMI_DISCHARGE_MED_FLAGS_Grouped_BB
;

SELECT
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_BB_FLAG
	,MIN(DISCHARGE_MED_METHODOLOGY) as DISCHARGE_MED_BB_Methodology
INTO
	#AMI_DISCHARGE_MED_FLAGS_Grouped_BB
FROM 
	#AMI_DISCHARGE_MED_FLAGS_FOR_CB2
where
	DISCHARGE_MED_BB_FLAG = 1
Group by
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_BB_FLAG
;


--Part 6:
--Get Antidep summary data

---drop table if exists #AMI_DISCHARGE_MED_FLAGS_Grouped_Antidep
;

SELECT
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_ANTIDEP_FLAG
	,MIN(DISCHARGE_MED_METHODOLOGY) as DISCHARGE_MED_ANTIDEP_Methodology
INTO
	#AMI_DISCHARGE_MED_FLAGS_Grouped_Antidep
FROM 
	#AMI_DISCHARGE_MED_FLAGS_FOR_CB2
where
	DISCHARGE_MED_ANTIDEP_FLAG = 1
Group by
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_ANTIDEP_FLAG
;


--Part 7:
--Get ACE ARB summary data

---drop table if exists #AMI_DISCHARGE_MED_FLAGS_Grouped_ACE_ARB
;

SELECT
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_ACE_ARB_FLAG
	,MIN(DISCHARGE_MED_METHODOLOGY) as DISCHARGE_MED_ACE_ARB_Methodology
INTO
	#AMI_DISCHARGE_MED_FLAGS_Grouped_ACE_ARB
FROM 
	#AMI_DISCHARGE_MED_FLAGS_FOR_CB2
where
	DISCHARGE_MED_ACE_ARB_FLAG = 1
Group by
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_ACE_ARB_FLAG
;


--Part 8:
--Get Aspirin summary data

---drop table if exists #AMI_DISCHARGE_MED_FLAGS_Grouped_Aspirin;

SELECT
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_ASPIRIN_FLAG
	,MIN(DISCHARGE_MED_METHODOLOGY) as DISCHARGE_MED_Aspirin_Methodology
INTO
	#AMI_DISCHARGE_MED_FLAGS_Grouped_Aspirin
FROM 
	#AMI_DISCHARGE_MED_FLAGS_FOR_CB2
where
	DISCHARGE_MED_ASPIRIN_FLAG = 1
Group by
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_ASPIRIN_FLAG
;


--Get Statin summary data
---drop table if exists #AMI_DISCHARGE_MED_FLAGS_Grouped_Statin;

SELECT
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_Statin_FLAG
	,MIN(DISCHARGE_MED_METHODOLOGY) as DISCHARGE_MED_Statin_Methodology
INTO
	#AMI_DISCHARGE_MED_FLAGS_Grouped_Statin
FROM 
	#AMI_DISCHARGE_MED_FLAGS_FOR_CB2
where
	DISCHARGE_MED_Statin_FLAG = 1
Group by
	 PERSON_ID
	,VISIT_OCCURRENCE_ID
	,INDEX_ADMIT_DATE
	,INDEX_DISCHARGE_DATE
	,ADMIT_DATE
	,DISCHARGE_DATE
	,DISCHARGE_MED_Statin_FLAG
;


--Part 9:
--Combine variables for discharge meds

---drop table if exists Table1_Discharge_Information_Meds;

if exists (select * from sys.objects where name = 'Table1_Discharge_Information_Meds' and type = 'u')
    drop table Table1_Discharge_Information_Meds

select
	 CB2.Person_ID
	,CB2.VISIT_OCCURRENCE_ID
	,CB2.INDEX_ADMIT_DATE
	,CB2.INDEX_DISCHARGE_DATE
	,CB2.ADMIT_DATE
	,CB2.DISCHARGE_DATE
	,CASE
		WHEN BB.DISCHARGE_MED_BB_FLAG IS NOT NULL
		THEN BB.DISCHARGE_MED_BB_FLAG 
		ELSE 0
	 END as DISCH_MED_BB_FLAG
	,CASE
		WHEN BB.DISCHARGE_MED_BB_Methodology IS NOT NULL
		THEN BB.DISCHARGE_MED_BB_Methodology
		ELSE 0
	 END as DISCH_MED_BB_Method
	,CASE
		WHEN A.DISCHARGE_MED_Antidep_FLAG IS NOT NULL
		THEN A.DISCHARGE_MED_Antidep_FLAG
		ELSE 0
	 END as DISCH_MED_Antidep_FLAG
	,CASE
		WHEN A.DISCHARGE_MED_Antidep_Methodology IS NOT NULL
		THEN A.DISCHARGE_MED_Antidep_Methodology
		ELSE 0
	 END as DISCH_MED_Antidep_Method
	,CASE
		WHEN Ace.DISCHARGE_MED_ACE_ARB_FLAG IS NOT NULL
		THEN Ace.DISCHARGE_MED_ACE_ARB_FLAG
		ELSE 0
	 END as DISCH_MED_ACE_ARB_FLAG
	,CASE
		WHEN Ace.DISCHARGE_MED_ACE_ARB_Methodology IS NOT NULL
		THEN Ace.DISCHARGE_MED_ACE_ARB_Methodology
		ELSE 0
	 END as DISCH_MED_ACE_ARB_Method
	,CASE
		WHEN Asp.DISCHARGE_MED_ASPIRIN_FLAG IS NOT NULL
		THEN Asp.DISCHARGE_MED_ASPIRIN_FLAG
		ELSE 0
	 END as DISCH_MED_ASPIRIN_FLAG
	,CASE
		WHEN Asp.DISCHARGE_MED_Aspirin_Methodology IS NOT NULL
		THEN Asp.DISCHARGE_MED_Aspirin_Methodology
		ELSE 0
	 END as DISCH_MED_Aspirin_Method
	,CASE
		WHEN St.DISCHARGE_MED_STATIN_FLAG IS NOT NULL
		THEN St.DISCHARGE_MED_STATIN_FLAG
		ELSE 0
	 END as DISCH_MED_STATIN_FLAG
	,CASE
		WHEN St.DISCHARGE_MED_STATIN_Methodology IS NOT NULL
		THEN St.DISCHARGE_MED_STATIN_Methodology
		ELSE 0
	 END as DISCH_MED_STATIN_Method
into
	Table1_Discharge_Information_Meds
from
	COHORT_BASE_2 as CB2
	left join #AMI_DISCHARGE_MED_FLAGS_Grouped_BB as BB
		on CB2.VISIT_OCCURRENCE_ID = BB.VISIT_OCCURRENCE_ID
	left join #AMI_DISCHARGE_MED_FLAGS_Grouped_Antidep as A
		on CB2.VISIT_OCCURRENCE_ID = A.VISIT_OCCURRENCE_ID
	left join #AMI_DISCHARGE_MED_FLAGS_Grouped_ACE_ARB as Ace
		on CB2.VISIT_OCCURRENCE_ID = Ace.VISIT_OCCURRENCE_ID
	left join #AMI_DISCHARGE_MED_FLAGS_Grouped_Aspirin as Asp
		on CB2.VISIT_OCCURRENCE_ID = Asp.VISIT_OCCURRENCE_ID
	left join #AMI_DISCHARGE_MED_FLAGS_Grouped_Statin as St
		on CB2.VISIT_OCCURRENCE_ID = St.VISIT_OCCURRENCE_ID
;


