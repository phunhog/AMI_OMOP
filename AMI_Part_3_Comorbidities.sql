-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 3: Add values to Table1_Comorbidities for elements from Table 1:
Arrhythmia
Diabetes
Anemia
CHF
Hypertension
Chronic kidney disease
Chronic obstructive pulmonary disease
Cerebrovascular accident / stroke
Tobacco use
Depression status
Prior revascularization
Hypercholesterolemia
Coronary artery disease
Age >= 80

BDI score (unable to obtain)

Charlson Comorbidity Score:
Condition/Score:
Myocardial Infarction				1		
Congestive Heart Failure			1		
Peripheral Vascular Disease			1		
Cerebrovascular Disease				1		
Dementia							1		
Chronic Pulmonary Disease			1		
Rheumatologic Disease				1		
Peptic Ulcer Disease				1		
Mild Liver Disease					1		
Diabetes							1		
Diabetes with Chronic Complications	2		
Hemiplegia or Paraplegia			2		
Renal Disease						2		
Moderate or Severe Liver Disease	3		
AIDS								6		
*/
-----------------------------------------------------------------------------------------

--Age >= 80-----------------------------------------------------------------------------
select 
	 CB2.PERSON_ID
	,CB2.VISIT_OCCURRENCE_ID
	,CB2.ADMIT_DATE
	,CB2.PRIM_DIAG
--	,case when date_part('year',age(cb2.admit_date,cb2.dob)) >= 80 then 1 else 0 end as Age_80_Flag
	,case when CB2.Age_at_Admit >= 80 then 1 else 0 end as Age_80_Flag
into #Table1_Comorbidities_Age_80_Flag
from AMI.COHORT_BASE_2 as CB2
;
--select top 1000 * from #Table1_Comorbidities_Age_80_Flag;

--Conditions-----------------------------------------------------------------------------
select 
	 CB2.PERSON_ID
	,CB2.VISIT_OCCURRENCE_ID
	,CB2.ADMIT_DATE
	,CB2.PRIM_DIAG
	,MAX(case when Ref.conditionid IN (35, 402)					then 1 else 0 end) as Comorbid_Arrhythmia_Flag
	,MAX(case when Ref.conditionid IN (40, 426, 427, 642)		then 1 else 0 end) as Comorbid_Anemia_Flag
	,MAX(case when Ref.conditionid IN (6, 76, 320, 406, 407)	then 1 else 0 end) as Comorbid_Hypertension_Flag
	,MAX(case when Ref.conditionid IN (45, 98)					then 1 else 0 end) as Comorbid_COPD_Flag
	,MAX(case when Ref.conditionid = 2							then 1 else 0 end) as Comorbid_CKD_Flag   
	,MAX(case when Ref.conditionid = 80							then 1 else 0 end) as Comorbid_Stroke_Flag 
	,MAX(case when Ref.conditionid = 49							then 1 else 0 end) as Comorbid_Tobacco_Use_Flag 
	,MAX(case when Ref.conditionid IN (431, 654)				then 1 else 0 end) as Comorbid_Depression_Flag    
into 
	#Table1_Comorbidities1
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
	[OMOP].[CONDITION_OCCURRENCE] as OCO	
		ON CB2.PERSON_ID = OCO.PERSON_ID
		AND datediff(dd, OCO.CONDITION_START_DATE, CB2.ADMIT_DATE) between 1 and 365
	left join
	[AMI].[Ref_Conditions_SNOMED] as Ref
		on OCO.CONDITION_CONCEPT_ID = Ref.TARGET_CONCEPT_ID
group by 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
;

--select top 1000 * from #Table1_Comorbidities1;



--Conditions for Charlson Deyo Score-----------------------------------------------------------------------------
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.conditionid IN (290)					then 1 else 0 end) as Comorbid_Diabetes_CC_Flag
	, MAX(case when Ref.conditionid IN (3, 289, 290, 411, 412)	then 1 else 0 end) as Comorbid_Diabetes_Flag
	, MAX(case when Ref.conditionid IN (79, 678)				then 1 else 0 end) as Comorbid_CHF_Flag
	, MAX(case when Ref.conditionid IN (13, 280)				then 1 else 0 end) as Comorbid_MI_Flag
	, MAX(case when Ref.conditionid IN (12, 282, 405)			then 1 else 0 end) as Comorbid_Peripheral_Vascular_Disease_Flag
	, MAX(case when Ref.conditionid IN (5, 283)					then 1 else 0 end) as Comorbid_Cerebrovascular_Disease_Flag   
	, MAX(case when Ref.conditionid IN (284, 61, 644, 645)		then 1 else 0 end) as Comorbid_Dementia_Flag 
	, MAX(case when Ref.conditionid IN (285, 410)				then 1 else 0 end) as Comorbid_Chronic_Pulmonary_Disease_Flag 
	, MAX(case when Ref.conditionid IN (151, 286)				then 1 else 0 end) as Comorbid_Rheumatologic_Disease_Flag 
	, MAX(case when Ref.conditionid IN (287, 416, 152)			then 1 else 0 end) as Comorbid_Peptic_Ulcer_Disease_Flag 
	, MAX(case when Ref.conditionid IN (288)					then 1 else 0 end) as Comorbid_Mild_Liver_Disease_Flag 
	, MAX(case when Ref.conditionid IN (153, 291)				then 1 else 0 end) as Comorbid_Hemiplegia_or_Paraplegia_Flag 
	, MAX(case when Ref.conditionid IN (292)					then 1 else 0 end) as Comorbid_Renal_Disease_Flag 
	, MAX(case when Ref.conditionid IN (294)					then 1 else 0 end) as Comorbid_Moderate_or_Severe_Liver_Disease_Flag 
	, MAX(case when Ref.conditionid IN (296, 417)				then 1 else 0 end) as Comorbid_AIDS_Flag 
into #Table1_Comorbidities_CD
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
	[OMOP].[CONDITION_OCCURRENCE] as OCO	
		ON CB2.PERSON_ID = OCO.PERSON_ID
		AND datediff(dd, OCO.CONDITION_START_DATE, CB2.ADMIT_DATE) between 1 and 365
	left join
	[AMI].[Ref_Conditions_SNOMED] as Ref
		on OCO.CONDITION_CONCEPT_ID = Ref.TARGET_CONCEPT_ID
group by 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
;

--select top 1000 * from #Table1_Comorbidities_CD;


--Hypercholesterolemia and Coronary Artery Disease---------------------------------------
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.conditionid IN (1007) then 1 else 0 end) as Comorbid_Hypercholesterolemia_Flag  --condition 1007
	, MAX(case when Ref.conditionid IN (1004) then 1 else 0 end) as Comorbid_CAD_Flag  --condition 1004
into #Table1_Comorbidities2
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
	[OMOP].[CONDITION_OCCURRENCE] as OCO	
		ON CB2.PERSON_ID = OCO.PERSON_ID
		AND datediff(dd, OCO.CONDITION_START_DATE, CB2.ADMIT_DATE) between 1 and 365
	left join
	[AMI].[Ref_Conditions_SNOMED] as Ref
		on OCO.CONDITION_CONCEPT_ID = Ref.TARGET_CONCEPT_ID
group by 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
;
--select top 1000 * from #Table1_Comorbidities2;


--Prior revascularization--------------------------------------------------------------------------------
select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.conditionid IN (1018) then 1 else 0 end)  as Prior_Revascularization_Flag
into #Table1_Comorbidities_Prior_Revascularization_Flag
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
	[OMOP].[Procedure_OCCURRENCE] as OPO	
		ON CB2.PERSON_ID = OPO.PERSON_ID
		AND datediff(dd, OPO.Procedure_DATE, CB2.ADMIT_DATE) between 1 and 365
	left join
	[AMI].[Ref_Conditions_SNOMED] as Ref
		on OPO.Procedure_CONCEPT_ID = Ref.TARGET_CONCEPT_ID
group by 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
;

--select top 1000 * from #Table1_Comorbidities_Prior_Revascularization_Flag;



--Combine temp tables-----------------------------------------------------------------
 select 
 	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, case when	A.Age_80_Flag IS NOT NULL
		then A.Age_80_Flag
		else 0
	  end as Age_80_Flag	      
	, case when	C1.Comorbid_Arrhythmia_Flag IS NOT NULL
		then C1.Comorbid_Arrhythmia_Flag
		else 0
	  end as Comorbid_Arrhythmia_Flag
	, case when	C1.Comorbid_Anemia_Flag IS NOT NULL
		then C1.Comorbid_Anemia_Flag
		else 0
	  end as Comorbid_Anemia_Flag 
	, case when	C1.Comorbid_Hypertension_Flag IS NOT NULL
		then C1.Comorbid_Hypertension_Flag
		else 0
	  end as Comorbid_Hypertension_Flag 	  
	, case when	C1.Comorbid_COPD_Flag IS NOT NULL
		then C1.Comorbid_COPD_Flag
		else 0
	  end as Comorbid_COPD_Flag 	  
	, case when	 C1.Comorbid_CKD_Flag IS NOT NULL
		then  C1.Comorbid_CKD_Flag
		else 0
	  end as Comorbid_CKD_Flag 
	, case when	C1.Comorbid_Stroke_Flag IS NOT NULL
		then C1.Comorbid_Stroke_Flag
		else 0
	  end as Comorbid_Stroke_Flag  
	, case when	C1.Comorbid_Tobacco_Use_Flag IS NOT NULL
		then C1.Comorbid_Tobacco_Use_Flag
		else 0
	  end as Comorbid_Tobacco_Use_Flag 
	, case when	C1.Comorbid_Depression_Flag IS NOT NULL
		then C1.Comorbid_Depression_Flag
		else 0
	  end as Comorbid_Depression_Flag 
	, case when	C2.Comorbid_Hypercholesterolemia_Flag IS NOT NULL
		then C2.Comorbid_Hypercholesterolemia_Flag
		else 0
	  end as Comorbid_Hypercholesterolemia_Flag 
	, case when	C2.Comorbid_CAD_Flag IS NOT NULL
		then C2.Comorbid_CAD_Flag
		else 0
	  end as Comorbid_CAD_Flag	  
	, case when	RF.Prior_Revascularization_Flag IS NOT NULL
		then RF.Prior_Revascularization_Flag
		else 0
	  end as Prior_Revascularization_Flag
	, case when	CD.Comorbid_Diabetes_CC_Flag IS NOT NULL
		then CD.Comorbid_Diabetes_CC_Flag
		else 0  
	  end as Comorbid_Diabetes_CC_Flag
	, case when	CD.Comorbid_Diabetes_Flag IS NOT NULL
		then CD.Comorbid_Diabetes_Flag
		else 0  
	  end as Comorbid_Diabetes_Flag
	, case when	CD.Comorbid_CHF_Flag IS NOT NULL
		then CD.Comorbid_CHF_Flag
		else 0  
	  end as Comorbid_CHF_Flag 
	, case when	CD.Comorbid_MI_Flag IS NOT NULL
		then CD.Comorbid_MI_Flag
		else 0  
	  end as Comorbid_MI_Flag
	, case when	CD.Comorbid_Peripheral_Vascular_Disease_Flag IS NOT NULL
		then CD.Comorbid_Peripheral_Vascular_Disease_Flag
		else 0  
	  end as Comorbid_Peripheral_Vascular_Disease_Flag 
	, case when	CD.Comorbid_Cerebrovascular_Disease_Flag IS NOT NULL
		then CD.Comorbid_Cerebrovascular_Disease_Flag
		else 0  
	  end as Comorbid_Cerebrovascular_Disease_Flag 
	, case when	CD.Comorbid_Dementia_Flag IS NOT NULL
		then CD.Comorbid_Dementia_Flag
		else 0  
	  end as Comorbid_Dementia_Flag 
	, case when	CD.Comorbid_Chronic_Pulmonary_Disease_Flag IS NOT NULL
		then CD.Comorbid_Chronic_Pulmonary_Disease_Flag
		else 0  
	  end as Comorbid_Chronic_Pulmonary_Disease_Flag 
	, case when	CD.Comorbid_Rheumatologic_Disease_Flag IS NOT NULL
		then CD.Comorbid_Rheumatologic_Disease_Flag
		else 0  
	  end as Comorbid_Rheumatologic_Disease_Flag
	, case when	CD.Comorbid_Peptic_Ulcer_Disease_Flag IS NOT NULL
		then CD.Comorbid_Peptic_Ulcer_Disease_Flag
		else 0  
	  end as Comorbid_Peptic_Ulcer_Disease_Flag
	, case when	CD.Comorbid_Mild_Liver_Disease_Flag IS NOT NULL
		then CD.Comorbid_Mild_Liver_Disease_Flag
		else 0  
	  end as Comorbid_Mild_Liver_Disease_Flag
	, case when	CD.Comorbid_Hemiplegia_or_Paraplegia_Flag IS NOT NULL
		then CD.Comorbid_Hemiplegia_or_Paraplegia_Flag
		else 0  
	  end as Comorbid_Hemiplegia_or_Paraplegia_Flag
	, case when	CD.Comorbid_Renal_Disease_Flag IS NOT NULL
		then CD.Comorbid_Renal_Disease_Flag
		else 0  
	  end as Comorbid_Renal_Disease_Flag
	, case when	CD.Comorbid_Moderate_or_Severe_Liver_Disease_Flag IS NOT NULL
		then CD.Comorbid_Moderate_or_Severe_Liver_Disease_Flag
		else 0  
	  end as Comorbid_Moderate_or_Severe_Liver_Disease_Flag 
	, case when	CD.Comorbid_AIDS_Flag IS NOT NULL
		then CD.Comorbid_AIDS_Flag
		else 0  
	  end as Comorbid_AIDS_Flag   
into #Table1_Comorbidities_Part_1
from AMI.COHORT_BASE_2 as CB2
	left join #Table1_Comorbidities_Age_80_Flag as A
	on CB2.PERSON_ID = A.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = A.VISIT_OCCURRENCE_ID
	left join #Table1_Comorbidities1 as C1
	on CB2.PERSON_ID = C1.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = C1.VISIT_OCCURRENCE_ID
	left join #Table1_Comorbidities2 as C2
	on CB2.PERSON_ID = C2.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = C2.VISIT_OCCURRENCE_ID
	left join #Table1_Comorbidities_Prior_Revascularization_Flag as RF
	on CB2.PERSON_ID = RF.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = RF.VISIT_OCCURRENCE_ID
	left join #Table1_Comorbidities_CD as CD
	on CB2.PERSON_ID = CD.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = CD.VISIT_OCCURRENCE_ID
;

--select top 1000 * from #Table1_Comorbidities_Part_1;

------------------------------------------------------------------
--Overall Charlson Deyo Score
-------------------------------------------------------------------

/*
Charlson Comorbidity Score:
Condition	Score
Myocardial Infarction				1		
Congestive Heart Failure			1		
Peripheral Vascular Disease			1		
Cerebrovascular Disease				1		
Dementia							1		
Chronic Pulmonary Disease			1		
Rheumatologic Disease				1		
Peptic Ulcer Disease				1		
Mild Liver Disease					1		
Diabetes							1		
Diabetes with Chronic Complications	2		
Hemiplegia or Paraplegia			2		
Renal Disease						2		
Moderate or Severe Liver Disease	3		
AIDS								6		
*/

select 
	*
	,case when Comorbid_Diabetes_CC_Flag = 1
		then 2
		else 0
	  end as Comorbid_Diabetes_CC_Flag_Score
	,case when Comorbid_Diabetes_Flag = 1
		then 1
		else 0
	  end as Comorbid_Diabetes_Flag_Score
	,case when Comorbid_CHF_Flag = 1
		then 1
		else 0
	  end as Comorbid_CHF_Flag_Score
	,case when Comorbid_MI_Flag = 1
		then 1
		else 0
	  end as Comorbid_MI_Flag_Score
	,case when Comorbid_Peripheral_Vascular_Disease_Flag = 1
		then 1
		else 0
	  end as Comorbid_Peripheral_Vascular_Disease_Flag_Score
	,case when Comorbid_Cerebrovascular_Disease_Flag = 1
		then 1
		else 0
	  end as Comorbid_Cerebrovascular_Disease_Flag_Score   
	,case when Comorbid_Dementia_Flag = 1
		then 1
		else 0
	  end as Comorbid_Dementia_Flag_Score 
	,case when Comorbid_Chronic_Pulmonary_Disease_Flag = 1
		then 1
		else 0
	  end as Comorbid_Chronic_Pulmonary_Disease_Flag_Score 
	,case when Comorbid_Rheumatologic_Disease_Flag = 1
		then 1
		else 0
	  end as Comorbid_Rheumatologic_Disease_Flag_Score 
	,case when Comorbid_Peptic_Ulcer_Disease_Flag = 1
		then 1
		else 0
	  end as Comorbid_Peptic_Ulcer_Disease_Flag_Score 
	,case when Comorbid_Mild_Liver_Disease_Flag = 1
		then 1
		else 0
	  end as Comorbid_Mild_Liver_Disease_Flag_Score 
	,case when Comorbid_Hemiplegia_or_Paraplegia_Flag = 1
		then 2
		else 0
	  end as Comorbid_Hemiplegia_or_Paraplegia_Flag_Score 
	,case when Comorbid_Renal_Disease_Flag = 1
		then 2
		else 0
	  end as Comorbid_Renal_Disease_Flag_Score 
	,case when Comorbid_Moderate_or_Severe_Liver_Disease_Flag = 1
		then 3
		else 0
	  end as Comorbid_Moderate_or_Severe_Liver_Disease_Flag_Score
	,case when Comorbid_AIDS_Flag = 1
		then 6
		else 0
	  end as Comorbid_AIDS_Flag_Score
into #Table1_Comorbidities_Part_2
from 
	#Table1_Comorbidities_Part_1
;

--select top 1000 * from #Table1_Comorbidities_Part_2;


--Final table-------------------------------------------------------------------------
drop table if exists Table1_Comorbidities
;

select
	*
	,(
		Comorbid_Diabetes_CC_Flag_Score
		 + Comorbid_Diabetes_Flag_Score
		 + Comorbid_CHF_Flag_Score
		 + Comorbid_MI_Flag_Score
		 + Comorbid_Peripheral_Vascular_Disease_Flag_Score
		 + Comorbid_Cerebrovascular_Disease_Flag_Score   
		 + Comorbid_Dementia_Flag_Score 
		 + Comorbid_Chronic_Pulmonary_Disease_Flag_Score 
		 + Comorbid_Rheumatologic_Disease_Flag_Score 
		 + Comorbid_Peptic_Ulcer_Disease_Flag_Score 
		 + Comorbid_Mild_Liver_Disease_Flag_Score 
		 + Comorbid_Hemiplegia_or_Paraplegia_Flag_Score 
		 + Comorbid_Renal_Disease_Flag_Score 
		 + Comorbid_Moderate_or_Severe_Liver_Disease_Flag_Score
		 + Comorbid_AIDS_Flag_Score
	 ) as Charlson_Deyo_Score
into Table1_Comorbidities
from
	#Table1_Comorbidities_Part_2
;

--select top 1000 * from Table1_Comorbidities;

--End Part 3-------------------------------------------------------------------------------------------

/*
select Charlson_Deyo_Score, count(*) as qty from Table1_Comorbidities group by Charlson_Deyo_Score order by Charlson_Deyo_Score;
*/










