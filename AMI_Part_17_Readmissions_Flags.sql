
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


--Identify Readmissions and planned readmissions----------------------------------------
--Uses CCS codes from AHRQ based on CMS guidelines for planned readmissions (these codes are not in OMOP).

--update 2020/06/04 chamge obj names to match dartmouth OMOP_CDM

USE OMOP_CDM
GO


--drop table if exists Readmit_Flags;

select 
	 CB2.*
	,D.Discharge_Location
	,D.Deceased_Flag
	,D.Death_Date
	,D.Deceased_Flag_Alt
into
	#AMI_Index_Admission_Flag
from 
	COHORT_BASE_2 as CB2
	left join
		Table1_Demographics as D
		on CB2.PERSON_ID = D.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = D.VISIT_OCCURRENCE_ID
;


--Identify readmission within 30 days of index admission
select
	 datediff(dd, I.Index_Discharge_Date, I.Admit_Date) as Days_to_Readmit
	,1 as Readmit_30_Day_Flag
	,I.*
	,ROW_NUMBER() OVER (PARTITION BY I.PERSON_ID ORDER BY I.Admit_Date, I.Visit_Occurrence_ID) AS Readmit_Counter
into 
	#AMI_30_Day_Readmit
from
	#AMI_Index_Admission_Flag as I
where
	I.Index_Admission_Flag = 0
	and
	datediff(dd, I.Index_Discharge_Date, I.Admit_Date) between 0 and 30
;


--Get only first readmission
--drop table AMI_30_Day_Readmit_First if exists;

select 
	*
into 
	#AMI_30_Day_Readmit_First 
from 
	#AMI_30_Day_Readmit
where
	Readmit_Counter = 1
;



--PR1: (Procedures always planned) Procedure CCS 64, 105, 134, 135, 176
--drop table if exists #Planned_Readmit_PR1 

select R.person_id, sum(1) as Planned_Readmit_PR1_Count
into #Planned_Readmit_PR1
from
	#AMI_30_Day_Readmit_First as R
	join
	PROCEDURE_OCCURRENCE as P
		on R.visit_occurrence_id = P.VISIT_OCCURRENCE_ID
	join
	REF_CONDITION_CODES as CCS
		on P.PROCEDURE_SOURCE_VALUE = CCS.CODE_DECIMAL
where 
	CCS.CODE_TYPE IN ('I10_PR', 'I9_PR')
	and CCS.CCS_CATEGORY IN (64, 105, 134, 135, 176)
group by
	R.person_id	
;
--select count(*) from #Planned_Readmit_PR1;
--
--select * from #Planned_Readmit_PR1;



--PR2: (Diagnoses always planned) Procedure CCS 45, 194, 196, 254
select R.person_id, sum(1) as Planned_Readmit_PR2_Count
into #Planned_Readmit_PR2
from
	#AMI_30_Day_Readmit_First as R
	join
		Condition_OCCURRENCE as C
		on R.visit_occurrence_id = C.VISIT_OCCURRENCE_ID
	join
		REF_CONDITION_CODES as CCS
		on C.Condition_SOURCE_VALUE = CCS.CODE_DECIMAL
where 
	CCS.CODE_TYPE IN ('I10_DX', 'I9_DX')
	and 
	CCS.CCS_CATEGORY IN (45, 194, 196, 254)
group by
	R.person_id	
;
--select count(*) from Planned_Readmit_PR2;
--select * from Planned_Readmit_PR2 limit 100;


--PR3: (Procedures sometimes planned)
select R.person_id, sum(1) as Planned_Readmit_PR3_Count
into #Planned_Readmit_PR3
from
	#AMI_30_Day_Readmit_First as R
	join
	PROCEDURE_OCCURRENCE as P
		on R.visit_occurrence_id = P.VISIT_OCCURRENCE_ID
	join
	REF_CONDITION_CODES as CCS
		on P.PROCEDURE_SOURCE_VALUE = CCS.CODE_DECIMAL
where 
		(
				CCS.CODE_TYPE IN ('I9_PR') AND CCS.CCS_CATEGORY IN 
				(
					3, 5, 9, 10,12,33,36,38,40,43,44,45,47,48,49,
					51,52,53,55,56,59,62,66,67,74,78,79,84,85,86,
					99,104,106,107,109,112,113,114,119,120,124,
					129,132,142,152,153,154,157,158,159,166,167,
					169,170,172
				)
			or
				CCS.CODE_TYPE IN ('I10_PR') AND CCS.CCS_CATEGORY IN 
				(
					3,5,9,10,12,33,36,38,40,43,44,45,47,48,49,51,
					52,53,55,56,59,66,67,74,78,79,84,85,86,99,104,
					106,107,109,112,113,114,119,120,124,129,132,
					142,152,153,154,158,159,166,167,172,175,1
				)
			or
				--Laryngectomy, revision of tracheostomy, scarification of pleura 
				--(from Proc CCS 42- Other OR Rx procedures on respiratory system and mediastinum)
				(
					CCS.CODE_TYPE IN ('I10_PR', 'I9_PR') AND CCS.CCS_CATEGORY = 42 and CCS.CODE_DECIMAL IN 
						('30.1', '30.29', '30.3', '30.4', '31.74', '34.6', 
						 '0CBS4ZZ', '0CBS7ZZ', '0CBS8ZZ', '0B5N0ZZ', '0B5N3ZZ', '0B5N4ZZ', 
						 '0B5P0ZZ', '0B5P3ZZ', '0B5P4ZZ', '0BW10FZ', '0BW13FZ', '0BW14FZ'
						)
				)
			or
				--Endarterectomy leg vessel 
				--(from Proc CCS 60- Embolectomy and endarterectomy of lower limbs)
				(
					CCS.CODE_TYPE IN ('I10_PR', 'I9_PR') AND CCS.CCS_CATEGORY = 60 and CCS.CODE_DECIMAL IN ('38.18')
				)
			or
				--Percutaneous nephrostomy with and without fragmentation 
				--(from Proc CCS 103- Nephrotomy and nephrostomy)
				(
					CCS.CODE_TYPE IN ('I10_PR', 'I9_PR') AND CCS.CCS_CATEGORY = 103 and CCS.CODE_DECIMAL IN 
						('55.03', '55.04', '0TC03ZZ', '0TC04ZZ', '0TC13ZZ', 
						 '0TC14ZZ', '0TC33ZZ', '0TC34ZZ', '0TC43ZZ', '0TC44ZZ'
						)
				)
			or
				--Electroshock therapy 
				--(from Proc CCS 218- Psychological and psychiatric evaluation and therapy)
				(
					CCS.CODE_TYPE IN ('I10_PR', 'I9_PR') AND CCS.CCS_CATEGORY = 218 and CCS.CODE_DECIMAL IN 
						('94.26', '94.27', 'GZB0ZZZ', 'GZB1ZZZ', 'GZB2ZZZ', 'GZB3ZZZ', 'GZB4ZZZ')
				)
			or
				--Kidney procedures
				(
					CCS.CODE_TYPE IN ('I10_PR', 'I9_PR') AND CCS.CODE_DECIMAL IN ('0T9030Z', '0T9130Z')
				)
		)
group by
	R.person_id	
;

--select count(*) from Planned_Readmit_PR3;
--select * from Planned_Readmit_PR3 limit 100;



--PR4: (Acute diagnoses)
select R.person_id, sum(1) as Planned_Readmit_PR4_Count
into #Planned_Readmit_PR4
from
	#AMI_30_Day_Readmit_First as R
	join
		Condition_OCCURRENCE as C
		on R.visit_occurrence_id = C.VISIT_OCCURRENCE_ID
	join
		REF_CONDITION_CODES as CCS
		on C.Condition_SOURCE_VALUE = CCS.CODE_DECIMAL
where 
(	
	(
		--ICD-9 criteria
		CCS.CODE_TYPE IN ('I9_DX')
		and 
			(
				CCS.CCS_CATEGORY IN 
				(
					1,2,3,4,5,7,8,9,54,55,60,61,63,76,77,78,82,
					83,84,85,87,89,90,91,92,93,99,100,102,104,
					107,109,112,116,118,120,122,123,124,125,126,
					127,128,129,130,131,135,137,139,140,142,145,
					146,148,153,154,157,159,165,168,172,197,198,
					225,226,227,228,229,230,232,233,234,235,237,
					238,239,240,241,242,243,244,245,246,247,249,
					250,251,252,253,259,650,651,652,653,656,658,
					660,661,662,663,670
				)
			or
				(
					CCS.CCS_CATEGORY = 97
					AND CCS.CODE_DECIMAL IN
						(
							'112.81',
							'115.03',
							'115.04',
							'115.13',
							'115.14',
							'115.93',
							'115.94',
							'130.3',
							'328.2',
							'364.0',
							'364.1',
							'364.2',
							'364.3',
							'391.0',
							'391.1',
							'391.2',
							'391.8',
							'391.9',
							'392.0',
							'398.0',
							'398.90',
							'398.99',
							'420.0',
							'420.90',
							'420.91',
							'420.99',
							'421.0',
							'421.1',
							'421.9',
							'422.0',
							'422.90',
							'422.91',
							'422.92',
							'422.93',
							'422.99',
							'423.0',
							'423.1',
							'423.2',
							'423.3',
							'429.0',
							'742.0',
							'742.1',
							'742.2',
							'742.3'
						)
				)
			or
				(
					CCS.CCS_CATEGORY = 105
					AND CCS.CODE_DECIMAL IN
						(
							'426.0',
							'426.10',
							'426.11',
							'426.12',
							'426.13',
							'426.2',
							'426.3',
							'426.4',
							'426.50',
							'426.51',
							'426.52',
							'426.53',
							'426.54',
							'426.6',
							'426.7',
							'426.81',
							'426.82',
							'426.9'
						)
				)
			or
				(
					CCS.CCS_CATEGORY = 106
					AND CCS.CODE_DECIMAL IN
						(
							'427.2',
							'427.69',
							'427.89',
							'427.9',
							'785.0'
						)
				)
			or
				(
					CCS.CCS_CATEGORY = 108
					AND CCS.CODE_DECIMAL IN
						(
							'398.91',
							'428.0',
							'428.1',
							'428.20',
							'428.21',
							'428.23',
							'428.30',
							'428.31',
							'428.33',
							'428.40',
							'428.41',
							'428.43',
							'428.9',
							'574.0',
							'574.00',
							'574.01',
							'574.3',
							'574.30',
							'574.31',
							'574.6',
							'574.60',
							'574.61',
							'574.8',
							'574.80',
							'574.81',
							'575.0',
							'575.12',
							'576.1'
						)
				)
			or
				(
					CCS.CCS_CATEGORY = 152
					AND CCS.CODE_DECIMAL IN
						(
							'577.0'
						)
				)
			)
	)
		
	OR --ICD-10 criteria
		
	(
		CCS.CODE_TYPE IN ('I10_DX')
		and 
			(
				CCS.CCS_CATEGORY IN 
				(
					1,
					2,
					3,
					4,
					5,
					7,
					8,
					9,
					54,
					55,
					60,
					61,
					63,
					76,
					77,
					78,
					82,
					83,
					84,
					85,
					87,
					89,
					90,
					91,
					92,
					93,
					99,
					102,
					104,
					107,
					109,
					112,
					116,
					118,
					120,
					122,
					123,
					124,
					125,
					126,
					127,
					128,
					129,
					130,
					131,
					135,
					137,
					139,
					140,
					142,
					145,
					146,
					148,
					153,
					154,
					157,
					159,
					165,
					168,
					172,
					197,
					198,
					225,
					226,
					227,
					228,
					229,
					230,
					232,
					233,
					234,
					235,
					237,
					238,
					239,
					240,
					241,
					242,
					243,
					244,
					245,
					246,
					247,
					249,
					250,
					251,
					252,
					253,
					259,
					650,
					651,
					652,
					653,
					656,
					658,
					660,
					661,
					662,
					663,
					670
				)
			or
				(
					--Peri-; endo-; and myocarditis; cardiomyopathy
					CCS.CODE_DECIMAL IN
						(
							'A36.81', 'A39.50', 'A39.51', 'A39.52', 'A39.53', 'B33.20', 'B33.21', 
							'B33.22', 'B33.23', 'B37.6', 'B58.81', 'I01.0', 'I01.1', 'I01.2', 'I01.8', 
							'I01.9', 'I02.0', 'I09.0', 'I09.89', 'I09.9', 'I30.0', 'I30.1', 'I30.8', 
							'I30.9', 'I31.0', 'I31.1', 'I31.2', 'I31.4', 'I32', 'I33.0', 'I33.9', 'I39', 
							'I40.0', 'I40.1', 'I40.8', 'I40.9', 'I41', 'I51.4'
						)
				)
			or
				(
					--Acute myocardial infarction (without subsequent MI)
					CCS.CODE_DECIMAL IN
						(
							'I21.01', 'I21.02', 'I21.09', 'I21.11',
							'I21.19', 'I21.21', 'I21.29', 'I21.3', 'I21.4'
						)
				)
			or
				(
					--Conduction disorders
					CCS.CODE_DECIMAL IN
						(
							'I44.0', 'I44.1', 'I44.2', 'I44.30', 'I44.39', 'I44.4', 
							'I44.5', 'I44.60', 'I44.69', 'I44.7', 'I45.0', 'I45.10', 
							'I45.19', 'I45.2', 'I45.3', 'I45.4', 'I45.5', 'I45.6', 
							'I45.81', 'I45.9'
						)
				)
			or
				(
					--Dysrhythmia
					CCS.CODE_DECIMAL IN
						(
							'I47.9', 'I49.3', 'I49.49', 'I49.8', 'I49.9', 'R00.0', 'R00.1'
						)
				)
			or
				(
					--Congestive heart failure; nonhypertensive
					CCS.CODE_DECIMAL IN
						(
							'I09.81', 'I50.1', 'I50.20', 'I50.21', 'I50.23', 'I50.30',
							'I50.31', 'I50.33', 'I50.40', 'I50.41', 'I50.43', 'I50.9'
						)
				)
			or
				(
					--Biliary tract disease
					CCS.CODE_DECIMAL IN
						(
							'K80.00', 'K80.01', 'K80.12', 'K80.13', 'K80.30', 'K80.31', 'K80.32', 
							'K80.33', 'K80.36', 'K80.37', 'K80.42', 'K80.43', 'K80.46', 'K80.47', 
							'K80.62', 'K80.63', 'K80.66', 'K80.67', 'K81.0', 'K81.2', 'K83.0'
						)
				)
			or
				(
					--Pancreatic disorders
					CCS.CODE_DECIMAL IN
						(
							'K85.0', 'K85.1', 'K85.2', 'K85.3', 'K85.8', 'K85.9'
						)
				)
			)
	)
)
group by
	R.person_id	
;



select person_id, 1 as PR1_Flag, 0 as PR2_Flag, 0 as PR3_Flag, 0 as PR4_Flag
into #AMI_Planned_Readmit_Flag_Components
from #Planned_Readmit_PR1;

insert into #AMI_Planned_Readmit_Flag_Components
select person_id, 0, 1, 0, 0
from #Planned_Readmit_PR2;

insert into #AMI_Planned_Readmit_Flag_Components
select person_id, 0, 0, 1, 0
from #Planned_Readmit_PR3;

insert into #AMI_Planned_Readmit_Flag_Components
select person_id, 0, 0, 0, 1
from #Planned_Readmit_PR4;

--drop table AMI_Planned_Readmit_Flag_All if exists;
select person_id, max(PR1_Flag) as PR1_Flag, max(PR2_Flag) as PR2_Flag, max(PR3_Flag) as PR3_Flag, max(PR4_Flag) as PR4_Flag
into #AMI_Planned_Readmit_Flag_All
from #AMI_Planned_Readmit_Flag_Components
group by person_id;

--select * from AMI_Planned_Readmit_Flag_All;

--drop table AMI_Planned_Readmit_Patients if exists;
select
	person_id,
	case
		when PR1_Flag = 1 then 1
		when pr2_flag = 1 then 1
		when PR3_Flag = 1 and PR4_Flag = 0 then 1
		else 0
	end as Planned_Readmit_Patient_Flag
into 
	#AMI_Planned_Readmit_Patients
from 
	#AMI_Planned_Readmit_Flag_All
;
	

--Contains data for visits that counted as a readmission (first readmission):
--select * from #AMI_30_Day_Readmit_First;

--Contains data for planned readmit patients
--select * from #AMI_Planned_Readmit_Patients



--Identify records that are readmits and whether or not those are planned

--Identify index admissions that have a readmit or planned readmit
--drop table Readmissions_Final if exists;
select 
	 CB2.PERSON_ID
	,CB2.VISIT_OCCURRENCE_ID
	,CB2.Index_Admission_Flag
	,case
		when (CB2.VISIT_OCCURRENCE_ID in
			(select VISIT_OCCURRENCE_ID from #AMI_30_Day_Readmit_First))
			then 1
			else 0
	 end as Readmit_Record_30_Day_Flag
	,case
		when (CB2.VISIT_OCCURRENCE_ID in
			(select VISIT_OCCURRENCE_ID from #AMI_30_Day_Readmit_First)
				and CB2.PERSON_ID IN 
					(select person_id from #AMI_Planned_Readmit_Patients where planned_readmit_patient_flag = 1))
			then 1
			else 0
	 end as Planned_Readmit_Record_30_Day_Flag
	,case
		when (CB2.PERSON_ID in (select PERSON_ID from #AMI_30_Day_Readmit_First)
				and CB2.Index_Admission_Flag = 1)
			then 1
			else 0
	 end as Readmit_Present_30_Day_Flag	
	,case
		when (CB2.PERSON_ID in (select person_id from #AMI_Planned_Readmit_Patients where planned_readmit_patient_flag = 1)
				and CB2.Index_Admission_Flag = 1)
			then 1
			else 0
	 end as Planned_Readmit_Present_30_Day_Flag	
into
	Readmissions_Final
from 
	#AMI_Index_Admission_Flag as CB2
;
	
	
--select * from Readmissions_Final;
--select count(*) from Readmissions_Final;
/*
select sum(index_admission_flag) as Index_Admits, sum(readmit_record_30_day_flag) as r_record, sum(planned_readmit_record_30_day_flag) as pr_record,
		sum(READMIT_PRESENT_30_DAY_FLAG) as r_present, sum(PLANNED_READMIT_PRESENT_30_DAY_FLAG) as pr_present
from Readmissions_Final
where index_admission_flag = 1;

*/
--
/*
select sum(index_admission_flag) as Index_Admits, sum(readmit_record_30_day_flag) as r_record, sum(planned_readmit_record_30_day_flag) as pr_record,
		sum(READMIT_PRESENT_30_DAY_FLAG) as r_present, sum(PLANNED_READMIT_PRESENT_30_DAY_FLAG) as pr_present
from Readmissions_Final
where index_admission_flag = 0;

*/




