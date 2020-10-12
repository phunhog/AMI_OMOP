
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------
USE AMI
GO

--Code	Description	icd version
--4580	Orthostatic hypotension	9
--4581	Chronic hypotension	9
--4582	Iatrogenic hypotension (begin 1995 end 2003)	9
--4588	Ot spec hypotension (begin 1997)	9
--4589	Hypotension nos	9
--I950	Idiopathic hypotension	10
--I951	Orthostatic hypotension	10
--I952	Hypotension due to drugs	10
--I953	Hypotension of hemodialysis	10
--I9581	Postprocedural hypotension	10
--I9589	Other hypotension	10
--I959	Hypotension, unspecified	10

--O2650	Maternal hypotension syndrome, unspecified trimester	10
--O2651	Maternal hypotension syndrome, first trimester	10
--O2652	Maternal hypotension syndrome, second trimester	10
--O2653	Maternal hypotension syndrome, third trimester	10


/*
Concept_ID_ICD	CONCEPT_NAME_ICD	Concept_Code_ICD	VOCABULARY_ID_ICD	RELATIONSHIP_ID	Concept_ID_SNOMED	CONCEPT_NAME_SNOMED	CONCEPT_CODE_SNOMED	VOCABULARY_ID_SNOMED
44819738	Orthostatic hypotension	458.0	ICD9CM	Maps to	319041	Orthostatic hypotension	28651003	SNOMED
44826658	Chronic hypotension	458.1	ICD9CM	Maps to	316447	Chronic hypotension	77545000	SNOMED
44823135	Iatrogenic hypotension	458.2	ICD9CM	Maps to	443447	Iatrogenic hypotension	408668005	SNOMED
44833593	Other specified hypotension	458.8	ICD9CM	Maps to	317002	Low blood pressure	45007003	SNOMED
44833594	Hypotension, unspecified	458.9	ICD9CM	Maps to	317002	Low blood pressure	45007003	SNOMED
35207915	Idiopathic hypotension	I95.0	ICD10CM	Maps to	4112334	Idiopathic hypotension	195506001	SNOMED
35207916	Orthostatic hypotension	I95.1	ICD10CM	Maps to	319041	Orthostatic hypotension	28651003	SNOMED
35207917	Hypotension due to drugs	I95.2	ICD10CM	Maps to	4120275	Drug-induced hypotension	234171009	SNOMED
45552871	Postprocedural hypotension	I95.81	ICD10CM	Maps to	443447	Iatrogenic hypotension	408668005	SNOMED
35207918	Hypotension, unspecified	I95.9	ICD10CM	Maps to	317002	Low blood pressure	45007003	SNOMED
45548722	Maternal hypotension syndrome, unspecified trimester	O26.50	ICD10CM	Maps to	314432	Maternal hypotension syndrome	88887003	SNOMED
45582464	Maternal hypotension syndrome, first trimester	O26.51	ICD10CM	Maps to	314432	Maternal hypotension syndrome	88887003	SNOMED
45567900	Maternal hypotension syndrome, second trimester	O26.52	ICD10CM	Maps to	314432	Maternal hypotension syndrome	88887003	SNOMED
45543927	Maternal hypotension syndrome, third trimester	O26.53	ICD10CM	Maps to	314432	Maternal hypotension syndrome	88887003	SNOMED
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
		'458.0'
		,'458.1'	
		,'458.2'
		,'458.29'
		,'458.8'	
		,'458.9'	
		,'I95.0'	
		,'I95.1'	
		,'I95.2'	
		,'I95.3'	
		,'I95.81'	
		,'I95.89	'
		,'I95.9'
		  ,'O26.50'
		  ,'O26.51'
		  ,'O26.52'
		  ,'O26.53'
	)
	and  C.domain_id = 'Condition'
	and C.vocabulary_id in ('ICD9CM', 'ICD10CM')
	and C2.VOCABULARY_ID = 'SNOMED'
	and C2.Concept_ID NOT IN (4299535, 4244438, 4239938, 4218813)
--order by 
--	C.concept_code
) sub
order by concept_ID_Snomed
;
*/

--concept_ID_Snomed
--314432
--316447
--317002
--319041
--4112334
--4120275
--443447

drop table if exists AMI.Hypotension_Flag;


with Hypotension
as
(
select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATETIME
	, CB2.ADMIT_DATETIME - 1 as Start_Range
	, OCO.[CONDITION_START_DATETIME]
	, CB2.DISCHARGE_DATETIME
from
	AMI.COHORT_BASE_2 as CB2
	left join
	[OMOP].[CONDITION_OCCURRENCE] as OCO
		on CB2.PERSON_ID = OCO.Person_ID
		and OCO.[CONDITION_START_DATETIME] between (CB2.ADMIT_DATETIME - 1) and (CB2.DISCHARGE_DATETIME)
where
	OCO.[CONDITION_CONCEPT_ID] IN
	(
		314432
		,316447
		,317002
		,319041
		,4112334
		,4120275
		,443447
	)
)


select distinct
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CASE	
		When H.VISIT_OCCURRENCE_ID is not null
		then 1 else 0
	  End as Hypotension_Flag
into
	AMI.Hypotension_Flag
from
	AMI.COHORT_BASE_2 as CB2
	left join
	Hypotension as H
		on CB2.PERSON_ID = H.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = H.VISIT_OCCURRENCE_ID
;


--select VISIT_OCCURRENCE_ID, count(*) from AMI.Hypotension_Flag group by VISIT_OCCURRENCE_ID having count(*) > 1


