
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
/*
Combine values in table MasterFlatFile from parts created previously.
*/
-----------------------------------------------------------------------------------------

--drop table AMI.MasterFlatFile if exists;


--****************************  need to make sure name data is present (ref_person using MRN)-----------------------------------
	--DONE add AMI.Table1_Rehabilitation for source of Rehab_Flag
	--DONE add new aki stage vars
	--DONE add new vessel vars from AMI.Table1_Presentation_Disease
	--DONE add AMI.Hypotension_Flag
	--DONE add AMI.Shock_Flag
	--DONE add AMI.AFib_Flag
	--DONE add AMI.proBNP_Calculation

drop table if exists AMI.MasterFlatFile;

select 
	 CB2.*
	,CASE	
		When P30.Prior_Sepsis_30D IS NOT NULL
		Then P30.Prior_Sepsis_30D
		Else 0
	 END as Prior_Sepsis_30D
    ,CASE	
		WHEN P30.Prior_Hyperkalemia_30D is not null
		then P30.Prior_Hyperkalemia_30D
		else 0
	 END as Prior_Hyperkalemia_30D
    ,CASE
		when P30.Prior_Hypokalemia_30D is not null
		then P30.Prior_Hypokalemia_30D
		else 0
	 END as Prior_Hypokalemia_30D
    ,CASE
		when P30.Prior_Hypervolemia_30D is not null
		then P30.Prior_Hypervolemia_30D
		else 0
	 END as Prior_Hypervolemia_30D
    ,CASE
		WHEN P30.Prior_AKF_30D is not null
		then P30.Prior_AKF_30D
		else 0
	 END as Prior_AKF_30D
    ,CASE
		when P30.Prior_UTI_30D is not null
		then P30.Prior_UTI_30D
		else 0
	 END as Prior_UTI_30D
    ,CASE
		WHEN P30.Prior_Longterm_Anticoagulants_30D is not null
		then P30.Prior_Longterm_Anticoagulants_30D
		else 0
	 END as Prior_Longterm_Anticoagulants_30D
	,CASE
		when P90.Prior_Sepsis_90D is not null
		then P90.Prior_Sepsis_90D
		else 0
	 END as Prior_Sepsis_90D
    ,case 
		when P90.Prior_Dis_Magn_Metab_90D is not null
		then P90.Prior_Dis_Magn_Metab_90D
		else 0
	 END as Prior_Dis_Magn_Metab_90D
    ,CASE
		WHEN P90.Prior_Hypokalemia_90D is not null
		then P90.Prior_Hypokalemia_90D
		else 0
	 END as Prior_Hypokalemia_90D
    ,CASE
		WHEN P90.Prior_LVEF_90D is not null
		then P90.Prior_LVEF_90D
		else 0
	 END as Prior_LVEF_90D
    ,CASE 
		when P90.Prior_AKF_90D is not null
		then P90.Prior_AKF_90D
		else 0
	 END as Prior_AKF_90D
    ,CASE
		WHEN P90.Prior_Cardiac_Device_90D is not null 
		then P90.Prior_Cardiac_Device_90D
		else 0
	 END as Prior_Cardiac_Device_90D
	,CASE
		WHEN H.LOS >= 0
		THEN H.LOS
		Else NULL
	 END AS LOS
	,H.LOS5_Flag
	,H.Procedure_Flag
	,H.Prior_Year_Admissions_Count
	,H.Nonelective_Admission_Flag
	,H.Oncology_Flag
	,H.Hemoglobin_Level_Last_12_Flag
	,H.Sodium_Level_Last_135_Flag
	,H.Hospital_Score
	,L.Sodium_Level_Avg
	,L.Sodium_Level_Min
	,L.Sodium_Level_Max
	,L.Sodium_Level_First
	,L.Sodium_Level_Last
	,L.Sodium_Level_Avg_136_Flag
	,L.Calcium_Level_Avg
	,L.Calcium_Level_Min
	,L.Calcium_Level_Max
	,L.Calcium_Level_First
	,L.Calcium_Level_Last
	,L.Calcium_Level_Avg_86_Flag
	,L.Creatinine_Level_Avg
	,L.Creatinine_Level_Min
	,L.Creatinine_Level_Max
	,L.Creatinine_Level_First
	,L.Creatinine_Level_Last
	,L.Hemoglobin_Level_Avg
	,L.Hemoglobin_Level_Min
	,L.Hemoglobin_Level_Max
	,L.Hemoglobin_Level_First
	,L.Hemoglobin_Level_Last
	,L.CK_Level_Avg
	,L.CK_Level_Min
	,L.CK_Level_Max
	,L.CK_Level_First
	,L.CK_Level_Last
	,L.BNP_Level_Avg
	,L.BNP_Level_Min
	,L.BNP_Level_Max
	,L.BNP_Level_First
	,L.BNP_Level_Last
	,L.ProBNP_Level_Last
	,PD.Transfer_Patient_Flag
	,PD.Chest_Pain_Flag
	,PD.Cardiac_Arrest_Flag
	,PD.Revascularization_Flag
	,PD.Vessels_1_Flag
	,PD.Vessels_2_Flag
	,PD.Vessels_3_Flag
	,PD.Vessels_4_Flag
	,PD.Vessels_Count
	,PD.Vessels_None_Flag
	,PD.Vessels_Single_Flag
	,PD.Vessels_Multiple_Flag
	,PD.Vessels_Category
	,CASE
		WHEN PD.Clopidogrel_Flag is not null
		THEN PD.Clopidogrel_Flag
		ELSE 0
	 END as Clopidogrel_Flag
	,PD.AMI_Location
	,AD.Index_LOS
	,AD.ED_Visit_Prior_180_Days_Count
	,AD.Admission_Prior_30_Days_Count
	,AD.ED_Visit_Prior_30_Days_Count
	,AD.ED_Visit_Prior_30_Days_Time_In_ED
	,AD.ED_Visit_Prior_30_Days_Minutes_In_ED
	,AD.ED_to_IP_Visit_Prior_30_Days_Count
	,DI.Unstable_Angina_Flag
	,DI.STEMI_Flag
	,DI.NSTEMI_Flag
	,D.Discharge_Location
	,D.Deceased_Flag
	,D.Death_Date
	,D.Deceased_Flag_Alt
	,D.Transfer_at_Discharge_Flag
	,Rehab.Rehab_Flag
	,PH.History_Chest_Pain_Flag
	,PH.History_AMI_Flag 
	,PH.History_CABG_Flag 
	,PH.History_PCI_Flag 
	,PH.History_PVD_Flag 
	,PH.History_Angina_Flag 	  
	,PH.History_Unstable_Angina_Flag 	  
	,PH.History_Hypertension_Flag 
	,PH.History_Depression_Flag  
	,PH.Family_Depression_Flag 
	,PH.Major_Depression_Count
	,HO.ECHOCARDIOGRAPHY_FLAG
	,HO.IN_HOSPITAL_HF_FLAG
	,HO.IN_HOSPITAL_ISCHEMIA_FLAG
	,HO.Cardiac_Procedure_Flag
    ,C.AGE_80_FLAG
    ,C.COMORBID_ARRHYTHMIA_FLAG
    ,C.COMORBID_ANEMIA_FLAG
    ,C.COMORBID_HYPERTENSION_FLAG
    ,C.COMORBID_COPD_FLAG
    ,C.COMORBID_CKD_FLAG
    ,C.COMORBID_STROKE_FLAG
    ,C.COMORBID_TOBACCO_USE_FLAG
    ,C.COMORBID_DEPRESSION_FLAG
    ,C.COMORBID_HYPERCHOLESTEROLEMIA_FLAG
    ,C.COMORBID_CAD_FLAG
    ,C.PRIOR_REVASCULARIZATION_FLAG
    ,C.COMORBID_DIABETES_CC_FLAG
    ,C.COMORBID_DIABETES_FLAG
    ,C.COMORBID_CHF_FLAG
    ,C.COMORBID_MI_FLAG
    ,C.COMORBID_PERIPHERAL_VASCULAR_DISEASE_FLAG
    ,C.COMORBID_CEREBROVASCULAR_DISEASE_FLAG
    ,C.COMORBID_DEMENTIA_FLAG
    ,C.COMORBID_CHRONIC_PULMONARY_DISEASE_FLAG
    ,C.COMORBID_RHEUMATOLOGIC_DISEASE_FLAG
    ,C.COMORBID_PEPTIC_ULCER_DISEASE_FLAG
    ,C.COMORBID_MILD_LIVER_DISEASE_FLAG
    ,C.COMORBID_HEMIPLEGIA_OR_PARAPLEGIA_FLAG
    ,C.COMORBID_RENAL_DISEASE_FLAG
    ,C.COMORBID_MODERATE_OR_SEVERE_LIVER_DISEASE_FLAG
    ,C.COMORBID_AIDS_FLAG
    ,C.COMORBID_DIABETES_CC_FLAG_SCORE
    ,C.COMORBID_DIABETES_FLAG_SCORE
    ,C.COMORBID_CHF_FLAG_SCORE
    ,C.COMORBID_MI_FLAG_SCORE
    ,C.COMORBID_PERIPHERAL_VASCULAR_DISEASE_FLAG_SCORE
    ,C.COMORBID_CEREBROVASCULAR_DISEASE_FLAG_SCORE
    ,C.COMORBID_DEMENTIA_FLAG_SCORE
    ,C.COMORBID_CHRONIC_PULMONARY_DISEASE_FLAG_SCORE
    ,C.COMORBID_RHEUMATOLOGIC_DISEASE_FLAG_SCORE
    ,C.COMORBID_PEPTIC_ULCER_DISEASE_FLAG_SCORE
    ,C.COMORBID_MILD_LIVER_DISEASE_FLAG_SCORE
    ,C.COMORBID_HEMIPLEGIA_OR_PARAPLEGIA_FLAG_SCORE
    ,C.COMORBID_RENAL_DISEASE_FLAG_SCORE
    ,C.COMORBID_MODERATE_OR_SEVERE_LIVER_DISEASE_FLAG_SCORE
    ,C.COMORBID_AIDS_FLAG_SCORE
    ,C.CHARLSON_DEYO_SCORE
	,LS.LACE_ACUITY_SCORE
	,LS.LACE_LOS_SCORE
    ,LS.LACE_CHARLSON_SCORE
    ,LS.LACE_ED_SCORE
    ,LS.LACE_SCORE
	,ES.KILLIP_CLASS
    ,ES.LVEF_FLAG
    ,ES.POST_MI_CABG_FLAG
    ,ES.CHF_FLAG
    ,ES.HISTORY_STROKE_FLAG
    ,ES.ENRICHD_SCORE
    ,GS.IN_HOSPITAL_PCI_FLAG
    ,GS.SYSTOLIC_BP_AVG
    ,GS.HEART_RATE_AVG
    ,GS.ST_SEGMENT_AVG
    ,GS.TROPONIN_I_AVG
	,GS.TROPONIN_T_AVG
    ,GS.CARDIAC_MARKER_ELEVATION_FLAG
    ,GS.GRACE_SCORE_AGE
    ,GS.GRACE_SCORE_HEART_RATE
    ,GS.GRACE_SCORE_SYSTOLIC_BP
    ,GS.GRACE_SCORE_CREATININE_LEVEL_FIRST
    ,GS.GRACE_SCORE_KILLIP_CLASS
    ,GS.GRACE_SCORE_CARDIAC_MARKER_ELEVATION
    ,GS.GRACE_SCORE_CARDIAC_ARREST
    ,GS.GRACE_SCORE_STEMI
    ,GS.GRACE_SCORE
    ,R.READMIT_RECORD_30_DAY_FLAG
    ,R.PLANNED_READMIT_RECORD_30_DAY_FLAG
    ,R.READMIT_PRESENT_30_DAY_FLAG
    ,R.PLANNED_READMIT_PRESENT_30_DAY_FLAG
	,DM.DISCH_MED_BB_FLAG
    ,DM.DISCH_MED_BB_METHOD
    ,DM.DISCH_MED_ANTIDEP_FLAG
    ,DM.DISCH_MED_ANTIDEP_METHOD
    ,DM.DISCH_MED_ACE_ARB_FLAG
    ,DM.DISCH_MED_ACE_ARB_METHOD
    ,DM.DISCH_MED_ASPIRIN_FLAG
    ,DM.DISCH_MED_ASPIRIN_METHOD
	,DM.DISCH_MED_STATIN_FLAG
    ,DM.DISCH_MED_STATIN_METHOD
	,AKI.AKI_Flag
	,AKI.AKI_Stage_Min
	,AKI.AKI_Stage_Max
	,AKI.AKI_Duration
	,AKI.AKI_Unresolved_Flag
	,AKI.AKI_Recovered_Flag
	,AKI.AKI_Stage
	,AKI.AKI_Stage_1_Flag
	,AKI.AKI_Stage_2_Flag
	,AKI.AKI_Stage_3_Flag
	,Hypo.Hypotension_Flag
	,Shock.Shock_Flag
	,AFib.AFib_Flag
	,CAD.CAD_Flag
	--,pro.proBNP_Calculated
	--replacing proBNP_Calculated with componenets of the calculation below
	,pro.proBNP_Calc_Age
	,pro.proBNP_Calc_BNP_Creatinine_Value
	,pro.proBNP_Calc_BNP_Creatinine_Weight_Value
	,pro.proBNP_Calc_CCr_Value
	,pro.proBNP_Calc_BNP_Level_Last
	,pro.proBNP_Calc_Gender
	,pro.proBNP_Calc_BNP_BMI_Value
	,pro.proBNP_Calc_AFib_Flag
	,pro.proBNP_Calc_BNP_Hemoglobin_Value
into
	AMI.MasterFlatFile
from 
	AMI.COHORT_BASE_2 as CB2
	left join 
		AMI.Table1_Prior_Month_Diagnosis as P30
		on CB2.PERSON_ID = P30.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = P30.VISIT_OCCURRENCE_ID
		and CB2.ADMIT_DATE = P30.ADMIT_DATE
		and CB2.PRIM_DIAG = P30.PRIM_DIAG
	left join 
		AMI.Table1_Prior_3Month_Diagnosis as P90
		on CB2.PERSON_ID = P90.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = P90.VISIT_OCCURRENCE_ID
		and CB2.ADMIT_DATE = P90.ADMIT_DATE
		and CB2.PRIM_DIAG = P90.PRIM_DIAG
	left join
		AMI.Table1_HOSPITAL_Score as H
		on CB2.PERSON_ID = H.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = H.VISIT_OCCURRENCE_ID
		and CB2.ADMIT_DATE = H.ADMIT_DATE
		and CB2.PRIM_DIAG = H.PRIM_DIAG
	left join
		AMI.Table1_Laboratories as L
		on CB2.PERSON_ID = L.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = L.VISIT_OCCURRENCE_ID
	left join
		AMI.Table1_Presentation_Disease as PD
		on CB2.PERSON_ID = PD.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = PD.VISIT_OCCURRENCE_ID
	left join
		AMI.Table1_Admin_Data as AD
		on CB2.PERSON_ID = AD.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = AD.VISIT_OCCURRENCE_ID
	left join
		AMI.Table1_Discharge_Information as DI
		on CB2.PERSON_ID = DI.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = DI.VISIT_OCCURRENCE_ID
	left join
		AMI.Table1_Demographics as D
		on CB2.PERSON_ID = D.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = D.VISIT_OCCURRENCE_ID
	left join 
		AMI.Table1_Patient_History as PH
		on CB2.PERSON_ID = PH.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = PH.VISIT_OCCURRENCE_ID
	left join 
		AMI.TABLE1_IN_HOSPITAL_OUTCOMES as HO
		on CB2.PERSON_ID = HO.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = HO.VISIT_OCCURRENCE_ID
	left join 
		AMI.Table1_Comorbidities as C
		on CB2.PERSON_ID = C.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = C.VISIT_OCCURRENCE_ID
	left join 
		AMI.Table1_LACE_Score as LS
		on CB2.PERSON_ID = LS.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = LS.VISIT_OCCURRENCE_ID
	left join 
		AMI.Table1_ENRICHD_Score as ES
		on CB2.PERSON_ID = ES.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = ES.VISIT_OCCURRENCE_ID
	left join 
		AMI.Table1_GRACE_Score as GS
		on CB2.PERSON_ID = GS.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = GS.VISIT_OCCURRENCE_ID
	left join
		AMI.READMISSIONS_FINAL as R
		on CB2.PERSON_ID = R.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = R.VISIT_OCCURRENCE_ID
	left join
		AMI.TABLE1_DISCHARGE_INFORMATION_MEDS as DM
		on CB2.PERSON_ID = DM.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = DM.VISIT_OCCURRENCE_ID
	left join
		AMI.Table1_AKI_Stage as AKI
		on CB2.PERSON_ID = AKI.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = AKI.VISIT_OCCURRENCE_ID 
	left join
		AMI.Table1_Rehabilitation as Rehab
		on CB2.PERSON_ID = Rehab.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = Rehab.VISIT_OCCURRENCE_ID 
	left join
		AMI.Hypotension_Flag as Hypo
		on CB2.PERSON_ID = Hypo.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = Hypo.VISIT_OCCURRENCE_ID 
	left join
		AMI.Shock_Flag as Shock
		on CB2.PERSON_ID = Shock.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = Shock.VISIT_OCCURRENCE_ID 
	left join
		AMI.AFib_Flag as AFib
		on CB2.PERSON_ID = AFib.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = AFib.VISIT_OCCURRENCE_ID 
	left join
		AMI.proBNP_Calculation as pro
		on CB2.PERSON_ID = pro.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = pro.VISIT_OCCURRENCE_ID 
	left join
		AMI.CAD_Flag as CAD
		on CB2.PERSON_ID = CAD.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = CAD.VISIT_OCCURRENCE_ID 
;




/*
Create or alter View AMI.vMasterFlatFile 
as
Select 
	M.*
	, ssn.SSN 
	, P.FIRST_NAME
	, P.MIDDLE_NAME
	, P.LAST_NAME
from 
	AMI.MasterFlatFile as M
	left join 
	AMI.REF_PERSON_SSN as ssn
		ON ssn.MRN = m.MRN
	left join
	AMI.REF_PERSON_NAMES as P
		on M.PERSON_ID = P.Person_ID
;
*/


--End of PART 19--------------------------------------------------------------------------




/*
--Store latest iteration of master flat file data--

--PUT DATE FOR TODAY IN FILE NAME FIRST--
drop table if exists AMI.MasterFlatFile_2020_1006;

--PUT DATE FOR TODAY IN FILE NAME FIRST--
select *
into AMI.MasterFlatFile_2020_1006
from AMI.MasterFlatFile
;
*/


/*
--This is the export code for Netezza SQL
--Export to csv with comma delimiter--
--PUT DATE FOR TODAY IN FILE NAME FIRST; ALSO ALTER PATH AS NEEDED--
CREATE EXTERNAL TABLE 'U:\AMI\MasterFlatFile\MasterFlatFile_2020_0916.csv'
USING
(
	DELIMITER ','
	ENCODING 'internal' 
	REMOTESOURCE 'ODBC'
	ESCAPECHAR '\'
	INCLUDEHEADER TRUE
)
AS 
SELECT *
  FROM AMI.MasterFlatFile_2020_0916  --PUT DATE FOR TODAY IN FILE NAME FIRST--
;
*/
--THEN SAVE THIS AS EXCEL FILE AND UPLOAD THIS TO SYNOLOGY IN DATA/MASTERFLATFILE FOLDER--



--Some validation queries--
/*

select count(*) from AMI.MasterFlatFile;
--17556

select count(*) from AMI.MasterFlatFile where Index_Admission_Flag = 1;
--9238

SELECT 
	VISIT_OCCURRENCE_ID
	, count(*) as qty
FROM AMI.MasterFlatFile
group by VISIT_OCCURRENCE_ID
having count(*) > 1
;
--Should be zero results



select * from ami.masterflatfile
where index_admission_flag = 1 and ami_location = 'NA';
--Should be zero results

select count(*) from AMI.MasterFlatFile where DISCH_MED_BB_FLAG = 1;


SELECT top 1000 *
FROM AMI.MasterFlatFile
;
*/


/*

use AMI
GO

SELECT   count(MRN														) AS Count_MRN
       , count(PERSON_ID												) AS Count_PERSON_ID
       , count(GENDER													) AS Count_GENDER
       , count(RACE														) AS Count_RACE
       , count(ETHNICITY												) AS Count_ETHNICITY
       , count(SSN														) AS Count_SSN
       , count(ZIPCODE													) AS Count_ZIPCODE
       , count(FIRST_NAME												) AS Count_FIRST_NAME
       , count(LAST_NAME												) AS Count_LAST_NAME
       , count(MIDDLE_NAME												) AS Count_MIDDLE_NAME
       , count(DOB														) AS Count_DOB
       , count(PRIM_DIAG												) AS Count_PRIM_DIAG
       , count(ADMIT_DATE												) AS Count_ADMIT_DATE
       , count(DISCHARGE_DATE											) AS Count_DISCHARGE_DATE
       , count(INDEX_ADMIT_DATE											) AS Count_INDEX_ADMIT_DATE
       , count(INDEX_DISCHARGE_DATE										) AS Count_INDEX_DISCHARGE_DATE
       , count(VISIT_OCCURRENCE_ID										) AS Count_VISIT_OCCURRENCE_ID
       , count(PRIOR_SEPSIS_30D											) AS Count_PRIOR_SEPSIS_30D
       , count(PRIOR_HYPERKALEMIA_30D									) AS Count_PRIOR_HYPERKALEMIA_30D
       , count(PRIOR_HYPOKALEMIA_30D									) AS Count_PRIOR_HYPOKALEMIA_30D
       , count(PRIOR_HYPERVOLEMIA_30D									) AS Count_PRIOR_HYPERVOLEMIA_30D
       , count(PRIOR_AKF_30D											) AS Count_PRIOR_AKF_30D
       , count(PRIOR_UTI_30D											) AS Count_PRIOR_UTI_30D
       , count(PRIOR_LONGTERM_ANTICOAGULANTS_30D						) AS Count_PRIOR_LONGTERM_ANTICOAGULANTS_30D
       , count(PRIOR_SEPSIS_90D											) AS Count_PRIOR_SEPSIS_90D
       , count(PRIOR_DIS_MAGN_METAB_90D									) AS Count_PRIOR_DIS_MAGN_METAB_90D
       , count(PRIOR_HYPOKALEMIA_90D									) AS Count_PRIOR_HYPOKALEMIA_90D
       , count(PRIOR_LVEF_90D											) AS Count_PRIOR_LVEF_90D
       , count(PRIOR_AKF_90D											) AS Count_PRIOR_AKF_90D
       , count(PRIOR_CARDIAC_DEVICE_90D									) AS Count_PRIOR_CARDIAC_DEVICE_90D
       , count(LOS														) AS Count_LOS
       , count(LOS5_FLAG												) AS Count_LOS5_FLAG
       , count(PROCEDURE_FLAG											) AS Count_PROCEDURE_FLAG
       , count(PRIOR_YEAR_ADMISSIONS_COUNT								) AS Count_PRIOR_YEAR_ADMISSIONS_COUNT
       , count(NONELECTIVE_ADMISSION_FLAG								) AS Count_NONELECTIVE_ADMISSION_FLAG
       , count(ONCOLOGY_FLAG											) AS Count_ONCOLOGY_FLAG
       , count(HEMOGLOBIN_LEVEL_LAST_12_FLAG							) AS Count_HEMOGLOBIN_LEVEL_LAST_12_FLAG
       , count(SODIUM_LEVEL_LAST_135_FLAG								) AS Count_SODIUM_LEVEL_LAST_135_FLAG
       , count(HOSPITAL_SCORE											) AS Count_HOSPITAL_SCORE
       , count(SODIUM_LEVEL_AVG											) AS Count_SODIUM_LEVEL_AVG
       , count(SODIUM_LEVEL_MIN											) AS Count_SODIUM_LEVEL_MIN
       , count(SODIUM_LEVEL_MAX											) AS Count_SODIUM_LEVEL_MAX
       , count(SODIUM_LEVEL_FIRST										) AS Count_SODIUM_LEVEL_FIRST
       , count(SODIUM_LEVEL_LAST										) AS Count_SODIUM_LEVEL_LAST
       , count(SODIUM_LEVEL_AVG_136_FLAG								) AS Count_SODIUM_LEVEL_AVG_136_FLAG
       , count(CALCIUM_LEVEL_AVG										) AS Count_CALCIUM_LEVEL_AVG
       , count(CALCIUM_LEVEL_MIN										) AS Count_CALCIUM_LEVEL_MIN
       , count(CALCIUM_LEVEL_MAX										) AS Count_CALCIUM_LEVEL_MAX
       , count(CALCIUM_LEVEL_FIRST										) AS Count_CALCIUM_LEVEL_FIRST
       , count(CALCIUM_LEVEL_LAST										) AS Count_CALCIUM_LEVEL_LAST
       , count(CALCIUM_LEVEL_AVG_86_FLAG								) AS Count_CALCIUM_LEVEL_AVG_86_FLAG
       , count(CREATININE_LEVEL_AVG										) AS Count_CREATININE_LEVEL_AVG
       , count(CREATININE_LEVEL_MIN										) AS Count_CREATININE_LEVEL_MIN
       , count(CREATININE_LEVEL_MAX										) AS Count_CREATININE_LEVEL_MAX
       , count(CREATININE_LEVEL_FIRST									) AS Count_CREATININE_LEVEL_FIRST
       , count(CREATININE_LEVEL_LAST									) AS Count_CREATININE_LEVEL_LAST
       , count(HEMOGLOBIN_LEVEL_AVG										) AS Count_HEMOGLOBIN_LEVEL_AVG
       , count(HEMOGLOBIN_LEVEL_MIN										) AS Count_HEMOGLOBIN_LEVEL_MIN
       , count(HEMOGLOBIN_LEVEL_MAX										) AS Count_HEMOGLOBIN_LEVEL_MAX
       , count(HEMOGLOBIN_LEVEL_FIRST									) AS Count_HEMOGLOBIN_LEVEL_FIRST
       , count(HEMOGLOBIN_LEVEL_LAST									) AS Count_HEMOGLOBIN_LEVEL_LAST
       , count(CK_LEVEL_AVG												) AS Count_CK_LEVEL_AVG
       , count(CK_LEVEL_MIN												) AS Count_CK_LEVEL_MIN
       , count(CK_LEVEL_MAX												) AS Count_CK_LEVEL_MAX
       , count(CK_LEVEL_FIRST											) AS Count_CK_LEVEL_FIRST
       , count(CK_LEVEL_LAST											) AS Count_CK_LEVEL_LAST
       , count(BNP_LEVEL_AVG											) AS Count_BNP_LEVEL_AVG
       , count(BNP_LEVEL_MIN											) AS Count_BNP_LEVEL_MIN
       , count(BNP_LEVEL_MAX											) AS Count_BNP_LEVEL_MAX
       , count(BNP_LEVEL_FIRST											) AS Count_BNP_LEVEL_FIRST
       , count(BNP_LEVEL_LAST											) AS Count_BNP_LEVEL_LAST
       , count(TRANSFER_PATIENT_FLAG									) AS Count_TRANSFER_PATIENT_FLAG
       , count(CHEST_PAIN_FLAG											) AS Count_CHEST_PAIN_FLAG
       , count(CARDIAC_ARREST_FLAG										) AS Count_CARDIAC_ARREST_FLAG
       , count(REVASCULARIZATION_FLAG									) AS Count_REVASCULARIZATION_FLAG
       , count(VESSELS_1_FLAG											) AS Count_VESSELS_1_FLAG
       , count(VESSELS_2_FLAG											) AS Count_VESSELS_2_FLAG
       , count(VESSELS_3_FLAG											) AS Count_VESSELS_3_FLAG
       , count(VESSELS_4_FLAG											) AS Count_VESSELS_4_FLAG
       , count(VESSELS_COUNT											) AS Count_VESSELS_COUNT
       , count(CLOPIDOGREL_FLAG											) AS Count_CLOPIDOGREL_FLAG
       , count(AMI_LOCATION												) AS Count_AMI_LOCATION
       , count(INDEX_LOS												) AS Count_INDEX_LOS
       , count(ED_VISIT_PRIOR_180_DAYS_COUNT							) AS Count_ED_VISIT_PRIOR_180_DAYS_COUNT
       , count(ADMISSION_PRIOR_30_DAYS_COUNT							) AS Count_ADMISSION_PRIOR_30_DAYS_COUNT
       , count(ED_VISIT_PRIOR_30_DAYS_COUNT								) AS Count_ED_VISIT_PRIOR_30_DAYS_COUNT
       , count(ED_VISIT_PRIOR_30_DAYS_TIME_IN_ED						) AS Count_ED_VISIT_PRIOR_30_DAYS_TIME_IN_ED
       , count(ED_VISIT_PRIOR_30_DAYS_MINUTES_IN_ED						) AS Count_ED_VISIT_PRIOR_30_DAYS_MINUTES_IN_ED
       , count(ED_TO_IP_VISIT_PRIOR_30_DAYS_COUNT						) AS Count_ED_TO_IP_VISIT_PRIOR_30_DAYS_COUNT
       , count(UNSTABLE_ANGINA_FLAG										) AS Count_UNSTABLE_ANGINA_FLAG
       , count(STEMI_FLAG												) AS Count_STEMI_FLAG
       , count(NSTEMI_FLAG												) AS Count_NSTEMI_FLAG
       , count(AGE_AT_ADMIT												) AS Count_AGE_AT_ADMIT
       , count(INDEX_ADMISSION_FLAG										) AS Count_INDEX_ADMISSION_FLAG
       , count(DISCHARGE_LOCATION										) AS Count_DISCHARGE_LOCATION
       , count(DECEASED_FLAG											) AS Count_DECEASED_FLAG
       , count(DEATH_DATE												) AS Count_DEATH_DATE
       , count(DECEASED_FLAG_ALT										) AS Count_DECEASED_FLAG_ALT
       , count(TRANSFER_AT_DISCHARGE_FLAG								) AS Count_TRANSFER_AT_DISCHARGE_FLAG
       , count(REHAB_FLAG												) AS Count_REHAB_FLAG
       , count(HISTORY_CHEST_PAIN_FLAG									) AS Count_HISTORY_CHEST_PAIN_FLAG
       , count(HISTORY_AMI_FLAG											) AS Count_HISTORY_AMI_FLAG
       , count(HISTORY_CABG_FLAG										) AS Count_HISTORY_CABG_FLAG
       , count(HISTORY_PCI_FLAG											) AS Count_HISTORY_PCI_FLAG
       , count(HISTORY_PVD_FLAG											) AS Count_HISTORY_PVD_FLAG
       , count(HISTORY_ANGINA_FLAG										) AS Count_HISTORY_ANGINA_FLAG
       , count(HISTORY_UNSTABLE_ANGINA_FLAG								) AS Count_HISTORY_UNSTABLE_ANGINA_FLAG
       , count(HISTORY_HYPERTENSION_FLAG								) AS Count_HISTORY_HYPERTENSION_FLAG
       , count(HISTORY_DEPRESSION_FLAG									) AS Count_HISTORY_DEPRESSION_FLAG
       , count(FAMILY_DEPRESSION_FLAG									) AS Count_FAMILY_DEPRESSION_FLAG
       , count(MAJOR_DEPRESSION_COUNT									) AS Count_MAJOR_DEPRESSION_COUNT
       , count(ECHOCARDIOGRAPHY_FLAG									) AS Count_ECHOCARDIOGRAPHY_FLAG
       , count(IN_HOSPITAL_HF_FLAG										) AS Count_IN_HOSPITAL_HF_FLAG
       , count(IN_HOSPITAL_ISCHEMIA_FLAG								) AS Count_IN_HOSPITAL_ISCHEMIA_FLAG
       , count(CARDIAC_PROCEDURE_FLAG									) AS Count_CARDIAC_PROCEDURE_FLAG
       , count(AGE_80_FLAG												) AS Count_AGE_80_FLAG
       , count(COMORBID_ARRHYTHMIA_FLAG									) AS Count_COMORBID_ARRHYTHMIA_FLAG
       , count(COMORBID_ANEMIA_FLAG										) AS Count_COMORBID_ANEMIA_FLAG
       , count(COMORBID_HYPERTENSION_FLAG								) AS Count_COMORBID_HYPERTENSION_FLAG
       , count(COMORBID_COPD_FLAG										) AS Count_COMORBID_COPD_FLAG
       , count(COMORBID_CKD_FLAG										) AS Count_COMORBID_CKD_FLAG
       , count(COMORBID_STROKE_FLAG										) AS Count_COMORBID_STROKE_FLAG
       , count(COMORBID_TOBACCO_USE_FLAG								) AS Count_COMORBID_TOBACCO_USE_FLAG
       , count(COMORBID_DEPRESSION_FLAG									) AS Count_COMORBID_DEPRESSION_FLAG
       , count(COMORBID_HYPERCHOLESTEROLEMIA_FLAG						) AS Count_COMORBID_HYPERCHOLESTEROLEMIA_FLAG
       , count(COMORBID_CAD_FLAG										) AS Count_COMORBID_CAD_FLAG
       , count(PRIOR_REVASCULARIZATION_FLAG								) AS Count_PRIOR_REVASCULARIZATION_FLAG
       , count(COMORBID_DIABETES_CC_FLAG								) AS Count_COMORBID_DIABETES_CC_FLAG
       , count(COMORBID_DIABETES_FLAG									) AS Count_COMORBID_DIABETES_FLAG
       , count(COMORBID_CHF_FLAG										) AS Count_COMORBID_CHF_FLAG
       , count(COMORBID_MI_FLAG											) AS Count_COMORBID_MI_FLAG
       , count(COMORBID_PERIPHERAL_VASCULAR_DISEASE_FLAG				) AS Count_COMORBID_PERIPHERAL_VASCULAR_DISEASE_FLAG
       , count(COMORBID_CEREBROVASCULAR_DISEASE_FLAG					) AS Count_COMORBID_CEREBROVASCULAR_DISEASE_FLAG
       , count(COMORBID_DEMENTIA_FLAG									) AS Count_COMORBID_DEMENTIA_FLAG
       , count(COMORBID_CHRONIC_PULMONARY_DISEASE_FLAG					) AS Count_COMORBID_CHRONIC_PULMONARY_DISEASE_FLAG
       , count(COMORBID_RHEUMATOLOGIC_DISEASE_FLAG						) AS Count_COMORBID_RHEUMATOLOGIC_DISEASE_FLAG
       , count(COMORBID_PEPTIC_ULCER_DISEASE_FLAG						) AS Count_COMORBID_PEPTIC_ULCER_DISEASE_FLAG
       , count(COMORBID_MILD_LIVER_DISEASE_FLAG							) AS Count_COMORBID_MILD_LIVER_DISEASE_FLAG
       , count(COMORBID_HEMIPLEGIA_OR_PARAPLEGIA_FLAG					) AS Count_COMORBID_HEMIPLEGIA_OR_PARAPLEGIA_FLAG
       , count(COMORBID_RENAL_DISEASE_FLAG								) AS Count_COMORBID_RENAL_DISEASE_FLAG
       , count(COMORBID_MODERATE_OR_SEVERE_LIVER_DISEASE_FLAG			) AS Count_COMORBID_MODERATE_OR_SEVERE_LIVER_DISEASE_FLAG
       , count(COMORBID_AIDS_FLAG										) AS Count_COMORBID_AIDS_FLAG
       , count(COMORBID_DIABETES_CC_FLAG_SCORE							) AS Count_COMORBID_DIABETES_CC_FLAG_SCORE
       , count(COMORBID_DIABETES_FLAG_SCORE								) AS Count_COMORBID_DIABETES_FLAG_SCORE
       , count(COMORBID_CHF_FLAG_SCORE									) AS Count_COMORBID_CHF_FLAG_SCORE
       , count(COMORBID_MI_FLAG_SCORE									) AS Count_COMORBID_MI_FLAG_SCORE
       , count(COMORBID_PERIPHERAL_VASCULAR_DISEASE_FLAG_SCORE			) AS Count_COMORBID_PERIPHERAL_VASCULAR_DISEASE_FLAG_SCORE
       , count(COMORBID_CEREBROVASCULAR_DISEASE_FLAG_SCORE				) AS Count_COMORBID_CEREBROVASCULAR_DISEASE_FLAG_SCORE
       , count(COMORBID_DEMENTIA_FLAG_SCORE								) AS Count_COMORBID_DEMENTIA_FLAG_SCORE
       , count(COMORBID_CHRONIC_PULMONARY_DISEASE_FLAG_SCORE			) AS Count_COMORBID_CHRONIC_PULMONARY_DISEASE_FLAG_SCORE
       , count(COMORBID_RHEUMATOLOGIC_DISEASE_FLAG_SCORE				) AS Count_COMORBID_RHEUMATOLOGIC_DISEASE_FLAG_SCORE
       , count(COMORBID_PEPTIC_ULCER_DISEASE_FLAG_SCORE					) AS Count_COMORBID_PEPTIC_ULCER_DISEASE_FLAG_SCORE
       , count(COMORBID_MILD_LIVER_DISEASE_FLAG_SCORE					) AS Count_COMORBID_MILD_LIVER_DISEASE_FLAG_SCORE
       , count(COMORBID_HEMIPLEGIA_OR_PARAPLEGIA_FLAG_SCORE				) AS Count_COMORBID_HEMIPLEGIA_OR_PARAPLEGIA_FLAG_SCORE
       , count(COMORBID_RENAL_DISEASE_FLAG_SCORE						) AS Count_COMORBID_RENAL_DISEASE_FLAG_SCORE
       , count(COMORBID_MODERATE_OR_SEVERE_LIVER_DISEASE_FLAG_SCORE		) AS Count_COMORBID_MODERATE_OR_SEVERE_LIVER_DISEASE_FLAG_SCORE
       , count(COMORBID_AIDS_FLAG_SCORE									) AS Count_COMORBID_AIDS_FLAG_SCORE
       , count(CHARLSON_DEYO_SCORE										) AS Count_CHARLSON_DEYO_SCORE
       , count(LACE_ACUITY_SCORE										) AS Count_LACE_ACUITY_SCORE
       , count(LACE_LOS_SCORE											) AS Count_LACE_LOS_SCORE
       , count(LACE_CHARLSON_SCORE										) AS Count_LACE_CHARLSON_SCORE
       , count(LACE_ED_SCORE											) AS Count_LACE_ED_SCORE
       , count(LACE_SCORE												) AS Count_LACE_SCORE
       , count(KILLIP_CLASS												) AS Count_KILLIP_CLASS
       , count(LVEF_FLAG												) AS Count_LVEF_FLAG
       , count(POST_MI_CABG_FLAG										) AS Count_POST_MI_CABG_FLAG
       , count(CHF_FLAG													) AS Count_CHF_FLAG
       , count(HISTORY_STROKE_FLAG										) AS Count_HISTORY_STROKE_FLAG
       , count(ENRICHD_SCORE											) AS Count_ENRICHD_SCORE
       , count(IN_HOSPITAL_PCI_FLAG										) AS Count_IN_HOSPITAL_PCI_FLAG
       , count(SYSTOLIC_BP_AVG											) AS Count_SYSTOLIC_BP_AVG
       , count(HEART_RATE_AVG											) AS Count_HEART_RATE_AVG
       , count(ST_SEGMENT_AVG											) AS Count_ST_SEGMENT_AVG
       , count(TROPONIN_I_AVG											) AS Count_TROPONIN_I_AVG
       , count(TROPONIN_T_AVG											) AS Count_TROPONIN_T_AVG
       , count(CARDIAC_MARKER_ELEVATION_FLAG							) AS Count_CARDIAC_MARKER_ELEVATION_FLAG
       , count(GRACE_SCORE_AGE											) AS Count_GRACE_SCORE_AGE
       , count(GRACE_SCORE_HEART_RATE									) AS Count_GRACE_SCORE_HEART_RATE
       , count(GRACE_SCORE_SYSTOLIC_BP									) AS Count_GRACE_SCORE_SYSTOLIC_BP
       , count(GRACE_SCORE_CREATININE_LEVEL_FIRST						) AS Count_GRACE_SCORE_CREATININE_LEVEL_FIRST
       , count(GRACE_SCORE_KILLIP_CLASS									) AS Count_GRACE_SCORE_KILLIP_CLASS
       , count(GRACE_SCORE_CARDIAC_MARKER_ELEVATION						) AS Count_GRACE_SCORE_CARDIAC_MARKER_ELEVATION
       , count(GRACE_SCORE_CARDIAC_ARREST								) AS Count_GRACE_SCORE_CARDIAC_ARREST
       , count(GRACE_SCORE_STEMI										) AS Count_GRACE_SCORE_STEMI
       , count(GRACE_SCORE												) AS Count_GRACE_SCORE

  --FROM MATHENY_DB_RD.DORNCA.MASTERFLATFILE
  from [AMI].[vMasterFlatFile]
;
*/