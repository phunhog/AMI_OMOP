
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------
--use AMI

USE OMOP_CDM
GO

--CAD diagnoses------------

/* Get concept ids for snomed codes (CAD ICD codes from common core, version 4)
select distinct concept_ID_Snomed from
(
select 
	C.CONCEPT_ID as Concept_ID_ICD
	, C.CONCEPT_NAME as CONCEPT_NAME_ICD
	, C.CONCEPT_CODE as Concept_Code_ICD
	, C.VOCABULARY_ID as VOCABULARY_ID_ICD
	, R.RELATIONSHIP_ID as RELATIONSHIP_ID
	, C2.CONCEPT_ID as Concept_ID_SNOMED
	, C2.CONCEPT_NAME as CONCEPT_NAME_SNOMED
	, C2.CONCEPT_CODE as CONCEPT_CODE_SNOMED
	, C2.VOCABULARY_ID as VOCABULARY_ID_SNOMED
	
from 
	omop.concept as C
	join
	omop.Concept_Relationship as R
		on C.CONCEPT_ID = R.CONCEPT_ID_1
	join
	omop.concept as C2
		on R.CONCEPT_ID_2 = C2.CONCEPT_ID
where C.concept_code in
	(
		'I21.21'
		,'I21.29'
		,'I21.3'
		,'I21.4'
		,'I21.9'
		,'I21.A1'
		,'I21.A9'
		,'I22.0'
		,'I22.1'
		,'I22.2'
		,'I22.8'
		,'I22.9'
		,'I24.0'
		,'I24.8'
		,'I24.9'
		,'I25.10'
		,'I25.110'
		,'I25.111'
		,'I25.118'
		,'I25.119'
		,'I25.2'
		,'I25.5'
		,'I25.6'
		,'I25.700'
		,'I25.701'
		,'I25.708'
		,'I25.709'
		,'I25.710'
		,'I25.711'
		,'I25.718'
		,'I25.719'
		,'I25.720'
		,'I25.721'
		,'I25.728'
		,'I25.729'
		,'I25.730'
		,'I25.731'
		,'I25.738'
		,'I25.739'
		,'I25.750'
		,'I25.751'
		,'I25.758'
		,'I25.759'
		,'I25.760'
		,'I25.761'
		,'I25.768'
		,'I25.769'
		,'I25.790'
		,'I25.791'
		,'I25.798'
		,'I25.799'
		,'I25.810'
		,'I25.811'
		,'I25.812'
		,'I25.82'
		,'I25.83'
		,'I25.84'
		,'I25.89'
		,'I25.9'
		,'Z95.1'
		,'Z95.5'
		,'Z98.61'
		,'410.0'
		,'410.00'
		,'410.01'
		,'410.02'
		,'410.1'
		,'410.10'
		,'410.11'
		,'410.12'
		,'410.2'
		,'410.20'
		,'410.21'
		,'410.22'
		,'410.3'
		,'410.30'
		,'410.31'
		,'410.32'
		,'410.4'
		,'410.40'
		,'410.41'
		,'410.42'
		,'410.5'
		,'410.50'
		,'410.51'
		,'410.52'
		,'410.6'
		,'410.60'
		,'410.61'
		,'410.62'
		,'410.7'
		,'410.70'
		,'410.71'
		,'410.72'
		,'410.8'
		,'410.80'
		,'410.81'
		,'410.82'
		,'410.9'
		,'410.90'
		,'410.91'
		,'410.92'
		,'411.0'
		,'411.1'
		,'411.8'
		,'411.81'
		,'411.89'
		,'412'
		,'413.0'
		,'413.1'
		,'413.9'
		,'414.0'
		,'414.00'
		,'414.01'
		,'414.02'
		,'414.03'
		,'414.04'
		,'414.05'
		,'414.06'
		,'414.07'
		,'414.2'
		,'414.3'
		,'414.4'
		,'414.8'
		,'414.9'
		,'V45.81'
		,'V45.82'
	)
	and  C.domain_id = 'Condition'
	and C.vocabulary_id in ('ICD9CM', 'ICD10CM')
	and C2.VOCABULARY_ID = 'SNOMED'
--order by 
--	C.concept_code
) sub
order by concept_ID_Snomed
;
*/


--drop table if exists AMI.CAD_Flag;

if exists (select * from sys.objects where name = 'CAD_Flag' and type = 'u')
    drop table CAD_Flag;

with CAD
as
(
select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATETIME
	--, CB2.ADMIT_DATETIME - 1 as Start_Range
	,(DATEADD(dd, - 1, CB2.ADMIT_DATETIME)) as Start_Range
	, OCO.[CONDITION_START_DATE]
	, CB2.DISCHARGE_DATETIME
from
	COHORT_BASE_2 as CB2
	left join
	[CONDITION_OCCURRENCE] as OCO
		on CB2.PERSON_ID = OCO.Person_ID
		--and OCO.[CONDITION_START_DATE] between (CB2.ADMIT_DATETIME - 1) and (CB2.DISCHARGE_DATETIME)
		and OCO.[CONDITION_START_DATE] between (DATEADD(dd, - 1, CB2.ADMIT_DATETIME)) and (CB2.DISCHARGE_DATETIME)
where
	OCO.[CONDITION_CONCEPT_ID] IN
	(
		312327
		,314666
		,315286
		,315296
		,315830
		,315832
		,317576
		,319038
		,319844
		,321318
		,36712779
		,40481132
		,40481919
		,40482638
		,40482655
		,40483189
		,4108215
		,4108218
		,4108677
		,4110961
		,4124683
		,4127089
		,4177223
		,4184832
		,4185932
		,4270024
		,42872402
		,4296653
		,43021821
		,43021857
		,434376
		,436706
		,438170
		,438438
		,438447
		,439693
		,441579
		,443563
		,444406
		,44784623
		,45766114
		,45766241
	)
)


select distinct
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CASE	
		When H.VISIT_OCCURRENCE_ID is not null
		then 1 else 0
	  End as CAD_Flag
into
	CAD_Flag
from
	COHORT_BASE_2 as CB2
	left join
	CAD as H
		on CB2.PERSON_ID = H.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = H.VISIT_OCCURRENCE_ID
;


--select VISIT_OCCURRENCE_ID, count(*) from AMI.CAD_Flag group by VISIT_OCCURRENCE_ID having count(*) > 1