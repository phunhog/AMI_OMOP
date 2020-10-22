
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------
--USE AMI
USE OMOP_CDM -- 10/16/2020
GO

/*
Code	Description	icd version
4082	Toxic shock syndrome (begin 2002)	9
6385	Attem abortion w shock	9
6395	Postabortion shock	9
9584	Traumatic shock	9
9950	Anaphylactic shock	9
9954	Shock due to anesthesia	9
9980	Postoperative shock (end 2011)	9
9994	Anaphylactic shock-serum (end 2011)	9
45821	Hypotension of hemodialysis (begin 2003)	9
45829	Other iatrogenic hypotension (begin 2003)	9
63450	Spon abort w shock-unsp	9
63451	Spon abort w shock-inc	9
63452	Spon abort w shock-comp	9
63550	Legal abort w shock-unsp	9
63551	Legal abort w shock-inc	9
63552	Legal abort w shock-comp	9
63650	Illeg abort w shock-unsp	9
63651	Illeg abort w shock-inc	9
63652	Illeg abort w shock-comp	9
63750	Abort nos w shock-unsp	9
63751	Abort nos w shock-inc	9
63752	Abort nos w shock-comp	9
66910	Obstetric shock-unspec	9
66911	Obstetric shock-deliver	9
66912	Obstet shock-deliv w p/p	9
66913	Obstetric shock-antepar	9
66914	Obstetric shock-postpart	9
78550	Shock nos	9
78551	Cardiogenic shock	9
78552	Septic shock (begin 2003)	9
78559	Shock w/o trauma nec	9
99560	Anaphylactic shock-unspec food (begin 1993)	9
99561	Anaphylactic shock-peanuts (begin 1993)	9
99562	Anaphylactic shock-crustaceans (begin 1993)	9
99563	Anaphylactic shock-fruits/vegs (begin 1993)	9
99564	Anaphylactic shock-nuts/seeds (begin 1993)	9
99565	Anaphylactic shock-fish (begin 1993)	9
99566	Anaphylactic shock-food additives (begin 1993)	9
99567	Anaphylactic shock-milk products (begin 1993)	9
99568	Anaphylactic shock-eggs (begin 1993)	9
99569	Anaphylactic shock-oth spec food (begin 1993)	9
99800	Postoperative shock nos (begin 2011)	9
99801	Postop shockcardiogenic (begin 2011)	9
99802	Postop shock septic (begin 2011)	9
99809	Postop shock other (begin 2011)	9
O0331	Shock following incomplete spontaneous abortion	10
O0381	Shock following complete or unspecified spontaneous abortion	10
O0481	Shock following (induced) termination of pregnancy	10
O0731	Shock following failed attempted termination of pregnancy	10
O083	Shock following ectopic and molar pregnancy	10
O2650	Maternal hypotension syndrome, unspecified trimester	10
O2651	Maternal hypotension syndrome, first trimester	10
O2652	Maternal hypotension syndrome, second trimester	10
O2653	Maternal hypotension syndrome, third trimester	10
O751	Shock during or following labor and delivery	10
R6521	Severe sepsis with septic shock	10
T8110xa	Postprocedural shock unspecified, initial encounter	10
T8111xa	Postprocedural cardiogenic shock, initial encounter	10
T8119xa	Other postprocedural shock, initial encounter	10
T882xxa	Shock due to anesthesia, initial encounter	10


Concept_ID_ICD	CONCEPT_NAME_ICD	Concept_Code_ICD	VOCABULARY_ID_ICD	RELATIONSHIP_ID	Concept_ID_SNOMED	CONCEPT_NAME_SNOMED	CONCEPT_CODE_SNOMED	VOCABULARY_ID_SNOMED
44836065	Spontaneous abortion, complicated by shock, unspecified	634.50	ICD9CM	Maps to	196746	Miscarriage complicated by shock	34270000	SNOMED
44821011	Spontaneous abortion, complicated by shock, incomplete	634.51	ICD9CM	Maps to	441631	Incomplete miscarriage with shock	198649006	SNOMED
44824373	Spontaneous abortion, complicated by shock, complete	634.52	ICD9CM	Maps to	438805	Complete miscarriage with shock	198661003	SNOMED
44825576	Legally induced abortion, complicated by shock, unspecified	635.50	ICD9CM	Maps to	197333	Legal termination of pregnancy complicated by shock	27169005	SNOMED
44826763	Legally induced abortion, complicated by shock, incomplete	635.51	ICD9CM	Maps to	439330	Incomplete legal termination of pregnancy with shock	198710002	SNOMED
44829088	Legally induced abortion, complicated by shock, complete	635.52	ICD9CM	Maps to	437934	Complete legal termination of pregnancy with shock	198723009	SNOMED
44830203	Illegally induced abortion, complicated by shock, unspecified	636.50	ICD9CM	Maps to	442596	Illegal termination of pregnancy complicated by shock	61752008	SNOMED
44837223	Illegally induced abortion, complicated by shock, incomplete	636.51	ICD9CM	Maps to	439320	Incomplete illegal termination of pregnancy with shock	198749004	SNOMED
44833707	Illegally induced abortion, complicated by shock, complete	636.52	ICD9CM	Maps to	439317	Complete illegal termination of pregnancy with shock	198761007	SNOMED
44832516	Unspecified abortion, complicated by shock, unspecified	637.50	ICD9CM	Maps to	43531711	Induced termination of pregnancy complicated by shock	609453002	SNOMED
44821015	Unspecified abortion, complicated by shock, incomplete	637.51	ICD9CM	Maps to	43531711	Induced termination of pregnancy complicated by shock	609453002	SNOMED
44833710	Unspecified abortion, complicated by shock, complete	637.52	ICD9CM	Maps to	43531711	Induced termination of pregnancy complicated by shock	609453002	SNOMED
44831371	Failed attempted abortion complicated by shock	638.5	ICD9CM	Maps to	201637	Failed attempted termination of pregnancy complicated by shock	67042008	SNOMED
44837229	Shock following abortion or ectopic and molar pregnancies	639.5	ICD9CM	Maps to	442271	Shock following molar AND/OR ectopic pregnancy	69344006	SNOMED
44834930	Shock during or following labor and delivery, unspecified as to episode of care or not applicable	669.10	ICD9CM	Maps to	444269	Shock during AND/OR following labor AND/OR delivery	84007008	SNOMED
44823295	Shock during or following labor and delivery, delivered, with or without mention of antepartum condition	669.11	ICD9CM	Maps to	442072	Obstetric shock - delivered	200105007	SNOMED
44830274	Shock during or following labor and delivery, delivered, with mention of postpartum complication	669.12	ICD9CM	Maps to	195025	Obstetric shock - delivered with postnatal problem	200106008	SNOMED
44837291	Shock during or following labor and delivery, antepartum condition or complication	669.13	ICD9CM	Maps to	442071	Obstetric shock with antenatal problem	200107004	SNOMED
44829162	Shock during or following labor and delivery, postpartum condition or complication	669.14	ICD9CM	Maps to	4065635	Obstetric shock with postnatal problem	200108009	SNOMED
44835083	Shock, unspecified	785.50	ICD9CM	Maps to	201965	Shock	27942005	SNOMED
44836295	Cardiogenic shock	785.51	ICD9CM	Maps to	198571	Cardiogenic shock	89138009	SNOMED
44825805	Septic shock	785.52	ICD9CM	Maps to	196236	Septic shock	76571007	SNOMED
44821247	Other shock without mention of trauma	785.59	ICD9CM	Maps to	201965	Shock	27942005	SNOMED
44829450	Traumatic shock	958.4	ICD9CM	Maps to	201478	Traumatic shock	64169002	SNOMED
44834121	Other anaphylactic reaction	995.0	ICD9CM	Maps to	441202	Anaphylaxis	39579001	SNOMED
44828341	Shock due to anesthesia, not elsewhere classified	995.4	ICD9CM	Maps to	198307	Shock due to anesthesia	16217003	SNOMED
44837633	Anaphylactic reaction due to unspecified food	995.60	ICD9CM	Maps to	434219	Food anaphylaxis	91941002	SNOMED
44824839	Anaphylactic reaction due to peanuts	995.61	ICD9CM	Maps to	435987	Peanut-induced anaphylaxis	241933001	SNOMED
44836484	Anaphylactic reaction due to crustaceans	995.62	ICD9CM	Maps to	442010	Seafood-induced anaphylaxis	241934007	SNOMED
44831787	Anaphylactic reaction due to fruits and vegetables	995.63	ICD9CM	Maps to	443567	Anaphylaxis due to vegetable	428795003	SNOMED
44832926	Anaphylactic reaction due to tree nuts and seeds	995.64	ICD9CM	Maps to	40479204	Anaphylaxis due to seed	441492003	SNOMED
44821406	Anaphylactic reaction due to fish	995.65	ICD9CM	Maps to	443560	Anaphylaxis due to fish	427903006	SNOMED
44827179	Anaphylactic reaction due to food additives	995.66	ICD9CM	Maps to	434219	Food anaphylaxis	91941002	SNOMED
44821407	Anaphylactic reaction due to milk products	995.67	ICD9CM	Maps to	437442	Cow's milk protein-induced anaphylaxis	241936009	SNOMED
44826025	Anaphylactic reaction due to eggs	995.68	ICD9CM	Maps to	4084635	Egg white-induced anaphylaxis	241935008	SNOMED
44828343	Anaphylactic reaction due to other specified food	995.69	ICD9CM	Maps to	434219	Food anaphylaxis	91941002	SNOMED
44828357	Postoperative shock	998.0	ICD9CM	Maps to	200618	Postoperative shock	58581001	SNOMED
44828358	Postoperative shock, unspecified	998.00	ICD9CM	Maps to	200618	Postoperative shock	58581001	SNOMED
44826037	Postoperative shock, cardiogenic	998.01	ICD9CM	Maps to	200618	Postoperative shock	58581001	SNOMED
44826037	Postoperative shock, cardiogenic	998.01	ICD9CM	Maps to	198571	Cardiogenic shock	89138009	SNOMED
44822525	Postoperative shock, septic	998.02	ICD9CM	Maps to	4308715	Postoperative septic shock	213256002	SNOMED
44824852	Postoperative shock, other	998.09	ICD9CM	Maps to	200618	Postoperative shock	58581001	SNOMED
44823658	Anaphylactic reaction due to serum, not elsewhere classified	999.4	ICD9CM	Maps to	442038	Anaphylactic shock due to serum	213320003	SNOMED
45572746	Shock following incomplete spontaneous abortion	O03.31	ICD10CM	Maps to	441631	Incomplete miscarriage with shock	198649006	SNOMED
45563039	Shock following complete or unspecified spontaneous abortion	O03.81	ICD10CM	Maps to	438805	Complete miscarriage with shock	198661003	SNOMED
45572750	Shock following (induced) termination of pregnancy	O04.81	ICD10CM	Maps to	43531711	Induced termination of pregnancy complicated by shock	609453002	SNOMED
45577550	Shock following failed attempted termination of pregnancy	O07.31	ICD10CM	Maps to	201637	Failed attempted termination of pregnancy complicated by shock	67042008	SNOMED
35209543	Shock following ectopic and molar pregnancy	O08.3	ICD10CM	Maps to	442271	Shock following molar AND/OR ectopic pregnancy	69344006	SNOMED
35210356	Shock during or following labor and delivery	O75.1	ICD10CM	Maps to	444269	Shock during AND/OR following labor AND/OR delivery	84007008	SNOMED
45577803	Severe sepsis with septic shock	R65.21	ICD10CM	Maps to	196236	Septic shock	76571007	SNOMED
45590048	Postprocedural shock unspecified, initial encounter	T81.10XA	ICD10CM	Maps to	200618	Postoperative shock	58581001	SNOMED
45594886	Postprocedural cardiogenic shock, initial encounter	T81.11XA	ICD10CM	Maps to	200618	Postoperative shock	58581001	SNOMED
45594886	Postprocedural cardiogenic shock, initial encounter	T81.11XA	ICD10CM	Maps to	198571	Cardiogenic shock	89138009	SNOMED
45599743	Other postprocedural shock, initial encounter	T81.19XA	ICD10CM	Maps to	200618	Postoperative shock	58581001	SNOMED
45570786	Shock due to anesthesia, initial encounter	T88.2XXA	ICD10CM	Maps to	198307	Shock due to anesthesia	16217003	SNOMED
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
		'408.2'
		,'638.5'	
		,'639.5'	
		,'958.4'	
		,'995.0'	
		,'995.4'	
		,'998.0'	
		,'999.4'	
		,'458.21'	
		,'634.50'	
		,'634.51'	
		,'634.52'	
		,'635.50'	
		,'635.51'	
		,'635.52'	
		,'636.50'	
		,'636.51'	
		,'636.52'	
		,'637.50'	
		,'637.51'	
		,'637.52'	
		,'669.10'	
		,'669.11'	
		,'669.12'	
		,'669.13'	
		,'669.14'	
		,'785.50'	
		,'785.51'	
		,'785.52'	
		,'785.59'	
		,'995.60'	
		,'995.61'	
		,'995.62'	
		,'995.63'	
		,'995.64'	
		,'995.65'	
		,'995.66'	
		,'995.67'	
		,'995.68'	
		,'995.69'	
		,'998.00'	
		,'998.01'	
		,'998.02'	
		,'998.09'	
		,'O03.31'	
		,'O03.81'	
		,'O04.81'	
		,'O07.31'	
		,'O08.3'
		,'O75.1'
		,'R65.21'	
		,'T81.10xa'
		,'T81.11xa'
		,'T81.19xa'
		,'T88.2xxa'
	)

	and  C.domain_id = 'Condition'
	and C.vocabulary_id in ('ICD9CM', 'ICD10CM')
	and C2.VOCABULARY_ID = 'SNOMED'
	and C2.concept_id not in (444094, 4041280)
--order by 
--	C.concept_code
) sub
order by concept_ID_Snomed
;
*/

--concept_ID_Snomed
--195025
--196236
--196746
--197333
--198307
--198571
--200618
--201478
--201637
--201965
--40479204
--4065635
--4084635
--4308715
--434219
--43531711
--435987
--437442
--437934
--438805
--439317
--439320
--439330
--441202
--441631
--442010
--442038
--442071
--442072
--442271
--442596
--443560
--443567
--444269

--drop table if exists AMI.Shock_Flag;

if exists (select * from sys.objects where name = 'Shock_Flag' and type = 'u')
    drop table Shock_Flag
	;

with Shock
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
		195025
		,196236
		,196746
		,197333
		,198307
		,198571
		,200618
		,201478
		,201637
		,201965
		,40479204
		,4065635
		,4084635
		,4308715
		,434219
		,43531711
		,435987
		,437442
		,437934
		,438805
		,439317
		,439320
		,439330
		,441202
		,441631
		,442010
		,442038
		,442071
		,442072
		,442271
		,442596
		,443560
		,443567
		,444269
	)
)


select distinct
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CASE	
		When S.VISIT_OCCURRENCE_ID is not null
		then 1 else 0
	  End as Shock_Flag
into
	Shock_Flag
from
	COHORT_BASE_2 as CB2
	left join
	Shock as S
		on CB2.PERSON_ID = S.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = S.VISIT_OCCURRENCE_ID
;


--select VISIT_OCCURRENCE_ID, count(*) from AMI.Shock_Flag group by VISIT_OCCURRENCE_ID having count(*) > 1


