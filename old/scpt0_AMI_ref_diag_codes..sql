----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
/*
Contents:
PART 0: Create preliminary reference table for diagnoses
*/
-----------------------------------------------------------------------------------------


--Use AMI;

-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
/*
Contents:
PART 0: Create preliminary reference table for diagnoses
*/
-----------------------------------------------------------------------------------------

/*
comprehensive update 3/13/2020
this is the working copy to be used on the dartmouth OMOP

JH Higgins MS

*/


Use OMOP_CDM


GO

IF OBJECT_ID('dbo.ref_diag_codes', 'U') IS NOT NULL 
	DROP table dbo.ref_diag_codes

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ref_diag_codes](
	[DIAGNOSIS] [nvarchar](255) NULL,
	[SOURCE_CONCEPT_ID] [float] NULL,
	[SOURCE_CONCEPT_CODE] [nvarchar](255) NULL,
	[SOURCE_VOCABULARY_ID] [nvarchar](255) NULL,
	[SOURCE_CONCEPT_NAME] [nvarchar](255) NULL,
	[SOURCE_DOMAIN_ID] [nvarchar](255) NULL,
	[RELATIONSHIP_ID] [nvarchar](255) NULL,
	[TARGET_CONCEPT_ID] [float] NULL,
	[TARGET_CONCEPT_CODE] [nvarchar](255) NULL,
	[TARGET_VOCABULARY_ID] [nvarchar](255) NULL,
	[TARGET_CONCEPT_NAME] [nvarchar](255) NULL,
	[TARGET_DOMAIN_ID] [nvarchar](255) NULL,
	[STANDARD_CONCEPT] [nvarchar](255) NULL
)
GO


--AMI I9
insert into REF_DIAG_CODES values ('AMI',	44834719,	'410.40',	'ICD9CM', 	'Acute myocardial infarction of other inferior wall, episode of care unspecified				','Condition',  'Maps to',	438170,		73795002,			'SNOMED',	'Acute myocardial infarction of inferior wall												', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44835926,	'410.41',	'ICD9CM', 	'Acute myocardial infarction of other inferior wall, initial episode of care					','Condition',  'Maps to',	438170,		73795002,			'SNOMED',	'Acute myocardial infarction of inferior wall												', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44835927,	'410.70',	'ICD9CM', 	'Subendocardial infarction, episode of care unspecified											','Condition',  'Maps to',	444406,		70422006,			'SNOMED',	'Acute subendocardial infarction															', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44825429,	'410.71',	'ICD9CM', 	'Subendocardial infarction, initial episode of care												','Condition',  'Maps to',	444406,		70422006,			'SNOMED',	'Acute subendocardial infarction															', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44826635,	'410.30',	'ICD9CM', 	'Acute myocardial infarction of inferoposterior wall, episode of care unspecified				','Condition',  'Maps to',	441579,		76593002,			'SNOMED',	'Acute myocardial infarction of inferoposterior wall										', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44833561,	'410.31',	'ICD9CM', 	'Acute myocardial infarction of inferoposterior wall, initial episode of care					','Condition',  'Maps to',	441579,		76593002,			'SNOMED',	'Acute myocardial infarction of inferoposterior wall										', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44832375,	'410.50',	'ICD9CM', 	'Acute myocardial infarction of other lateral wall, episode of care unspecified					','Condition',  'Maps to',	436706,		58612006,			'SNOMED',	'Acute myocardial infarction of lateral wall												', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44834720,	'410.51',	'ICD9CM', 	'Acute myocardial infarction of other lateral wall, initial episode of care						','Condition',  'Maps to',	436706,		58612006,			'SNOMED',	'Acute myocardial infarction of lateral wall												', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44831236,	'410.10',	'ICD9CM', 	'Acute myocardial infarction of other anterior wall, episode of care unspecified				','Condition',  'Maps to',	434376,		54329005,			'SNOMED',	'Acute myocardial infarction of anterior wall												', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44827782,	'410.11',	'ICD9CM', 	'Acute myocardial infarction of other anterior wall, initial episode of care					','Condition',  'Maps to',	434376,		54329005,			'SNOMED',	'Acute myocardial infarction of anterior wall												', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44826636,	'410.80',	'ICD9CM', 	'Acute myocardial infarction of other specified sites, episode of care unspecified				','Condition',  'Maps to',	312327,		57054005,			'SNOMED',	'Acute myocardial infarction																', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44834724,	'410.81',	'ICD9CM', 	'Acute myocardial infarction of other specified sites, initial episode of care					','Condition',  'Maps to',	312327,		57054005,			'SNOMED',	'Acute myocardial infarction																', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44835928,	'410.90',	'ICD9CM', 	'Acute myocardial infarction of unspecified site, episode of care unspecified					','Condition',  'Maps to',	312327,		57054005,			'SNOMED',	'Acute myocardial infarction																', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44825430,	'410.91',	'ICD9CM', 	'Acute myocardial infarction of unspecified site, initial episode of care						','Condition',  'Maps to',	312327,		57054005,			'SNOMED',	'Acute myocardial infarction																', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44828972,	'410.60',	'ICD9CM', 	'True posterior wall infarction, episode of care unspecified									','Condition',  'Maps to',	439693,		194802003,			'SNOMED',	'True posterior myocardial infarction														', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44837099,	'410.61',	'ICD9CM', 	'True posterior wall infarction, initial episode of care										','Condition',  'Maps to',	439693,		194802003,			'SNOMED',	'True posterior myocardial infarction														', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44819699,	'410.20',	'ICD9CM', 	'Acute myocardial infarction of inferolateral wall, episode of care unspecified					','Condition',  'Maps to',	438447,		65547006,			'SNOMED',	'Acute myocardial infarction of inferolateral wall											', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44819700,	'410.21',	'ICD9CM', 	'Acute myocardial infarction of inferolateral wall, initial episode of care						','Condition',  'Maps to',	438447,		65547006,			'SNOMED',	'Acute myocardial infarction of inferolateral wall											', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44824237,	'410.00',	'ICD9CM', 	'Acute myocardial infarction of anterolateral wall, episode of care unspecified					','Condition',  'Maps to',	438438,		70211005,			'SNOMED',	'Acute myocardial infarction of anterolateral wall											', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	44823111,	'410.01',	'ICD9CM', 	'Acute myocardial infarction of anterolateral wall, initial episode of care						','Condition',  'Maps to',	438438,		70211005,			'SNOMED',	'Acute myocardial infarction of anterolateral wall											', 'Condition',	'S');

--AMI I10
insert into REF_DIAG_CODES values ('AMI',	45576865,	'I21.09',	'ICD10CM', 	'ST elevation (STEMI) myocardial infarction involving other coronary artery of anterior wall	','Condition', 	'Maps to',	4296653,	401303003,			'SNOMED',	'Acute ST segment elevation myocardial infarction											', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	45533436,	'I21.11',	'ICD10CM', 	'ST elevation (STEMI) myocardial infarction involving right coronary artery						','Condition',  'Maps to',	46270163,	15713121000119105,	'SNOMED',	'Acute ST segment elevation myocardial infarction due to right coronary artery occlusion	', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	45605779,	'I21.19',	'ICD10CM', 	'ST elevation (STEMI) myocardial infarction involving other coronary artery of inferior wall	','Condition', 	'Maps to',	4296653,	401303003,			'SNOMED',	'Acute ST segment elevation myocardial infarction											', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	45557536,	'I21.29',	'ICD10CM', 	'ST elevation (STEMI) myocardial infarction involving other sites								','Condition',  'Maps to',	4296653,	401303003,			'SNOMED',	'Acute ST segment elevation myocardial infarction											', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	35207684,	'I21.3'	,	'ICD10CM', 	'ST elevation (STEMI) myocardial infarction of unspecified site									','Condition',  'Maps to',	4296653,	401303003,			'SNOMED',	'Acute ST segment elevation myocardial infarction											', 'Condition',	'S');
insert into REF_DIAG_CODES values ('AMI',	35207685,	'I21.4'	,	'ICD10CM', 	'Non-ST elevation (NSTEMI) myocardial infarction												','Condition',  'Maps to',	4270024,	401314000,			'SNOMED',	'Acute non-ST segment elevation myocardial infarction										', 'Condition',	'S');


