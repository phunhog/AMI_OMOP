
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------
--USE AMI 
USE OMOP_CDM -- 10/16/2020
GO

/*
I48
, I48.0
, I48.1
, I48.11
, I48.19
, I48.2
, I48.20
, I48.21
, I48.91
, I48.92
, Z86.79
, 427.3
, 427.31
, 427.32
--, 427.4
--, 427.41
, 427.42



Concept_ID_ICD	CONCEPT_NAME_ICD	Concept_Code_ICD	VOCABULARY_ID_ICD	RELATIONSHIP_ID	Concept_ID_SNOMED	CONCEPT_NAME_SNOMED	CONCEPT_CODE_SNOMED	VOCABULARY_ID_SNOMED
44824248	Atrial fibrillation and flutter	427.3	ICD9CM	Maps to	4108832	Atrial fibrillation and flutter	195080001	SNOMED
44821957	Atrial fibrillation	427.31	ICD9CM	Maps to	313217	Atrial fibrillation	49436004	SNOMED
44820868	Atrial flutter	427.32	ICD9CM	Maps to	314665	Atrial flutter	5370000	SNOMED
1569170		Atrial fibrillation and flutter	I48	ICD10CM	Maps to	4108832	Atrial fibrillation and flutter	195080001	SNOMED
35207784	Paroxysmal atrial fibrillation	I48.0	ICD10CM	Maps to	4154290	Paroxysmal atrial fibrillation	282825002	SNOMED
35207785	Persistent atrial fibrillation	I48.1	ICD10CM	Maps to	4232697	Persistent atrial fibrillation	440059007	SNOMED
1569171		Chronic atrial fibrillation	I48.2	ICD10CM	Maps to	4141360	Chronic atrial fibrillation	426749004	SNOMED
45576876	Unspecified atrial fibrillation	I48.91	ICD10CM	Maps to	313217	Atrial fibrillation	49436004	SNOMED
45572094	Unspecified atrial flutter	I48.92	ICD10CM	Maps to	314665	Atrial flutter	5370000	SNOMED
*/

/* Get concept ids for snomed codes
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
		  'I48'
		, 'I48.0'
		, 'I48.1'
		, 'I48.11'
		, 'I48.19'
		, 'I48.2'
		, 'I48.20'
		, 'I48.21'
		, 'I48.91'
		, 'I48.92'
		, 'Z86.79'
		, '427.3'
		, '427.31'
		, '427.32'
		--, '427.4'
		--, '427.41'
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

--concept_ID_Snomed
--313217
--314665
--4108832
--4141360
--4154290
--4232697

--drop table if exists AMI.AFib_Flag;


if exists (select * from sys.objects where name = 'AFib_Flag' and type = 'u')
    drop table AFib_Flag


;



with AFib
as
(
select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATETIME
	--, CB2.ADMIT_DATETIME - 1 as Start_Range
	, (DATEADD(dd, - 1, CB2.ADMIT_DATETIME)) as Start_Range
	, OCO.[CONDITION_START_DATE]
	, CB2.DISCHARGE_DATETIME
from
	COHORT_BASE_2 as CB2
	left join
	[CONDITION_OCCURRENCE] as OCO
		on CB2.PERSON_ID = OCO.Person_ID
		--and OCO.[CONDITION_START_DATETIME] between (CB2.ADMIT_DATETIME - 1) and (CB2.DISCHARGE_DATETIME)

		and OCO.[CONDITION_START_DATE] between (DATEADD(dd, - 1, CB2.ADMIT_DATETIME)) and (CB2.DISCHARGE_DATETIME)
where
	OCO.[CONDITION_CONCEPT_ID] IN
	(
		313217
		,314665
		,4108832
		,4141360
		,4154290
		,4232697
	)
)


select distinct
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CASE	
		When A.VISIT_OCCURRENCE_ID is not null
		then 1 else 0
	  End as AFib_Flag
into
	AFib_Flag
from
	COHORT_BASE_2 as CB2
	left join
	AFib as A
		on CB2.PERSON_ID = A.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = A.VISIT_OCCURRENCE_ID
;


--select VISIT_OCCURRENCE_ID, count(*) from AMI.AFib_Flag group by VISIT_OCCURRENCE_ID having count(*) > 1


