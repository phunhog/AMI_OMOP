-----------------------------------------------------------------------------------------
/*
PART 1: Create base cohort table
Create AMI_COHORT_BASE table that contains MRNs and some demographic information for:
the first AMI encounter, where the primary diagnosis is AMI within the specified time frame.
*/
-----------------------------------------------------------------------------------------

USE OMOP_CDM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from sys.objects where name = 'COHORT_BASE' and type = 'u')
    drop table COHORT_BASE
GO
--drop table AMI.COHORT_BASE if exists;	--Netezza SQL


select 
	  OVO.VISIT_OCCURRENCE_ID 	 	as VISIT_OCCURRENCE_ID
	, OVO.VISIT_START_DATE 		 	as ADMIT_DATE

	--, OVO.VISIT_START_DATETIME 	 	as ADMIT_DATETIME -- leave the old code intact
	,Convert(date,Convert(nvarchar(50),OVO.VISIT_START_DATE,113)) as ADMIT_DATETIME

	, OVO.VISIT_END_DATE 		 	as DISCHARGE_DATE

	--, OVO.VISIT_END_DATETIME 	 	as DISCHARGE_DATETIME
	,Convert(date,Convert(nvarchar(50),OVO.VISIT_END_DATE,113)) as DISCHARGE_DATETIME

	, OVO.VISIT_START_DATE 		 	as INDEX_ADMIT_DATE
	, OVO.VISIT_END_DATE 		 	as INDEX_DISCHARGE_DATE
	, OCO.CONDITION_SOURCE_VALUE 	as PRIM_DIAG
	, OVO.PERSON_ID 				as PERSON_ID
	, OPer.PERSON_SOURCE_VALUE 		as MRN
	, OPer.BIRTH_DATE	 			as DOB
	, RefPer.FIRST_NAME  			as FIRST_NAME
	, RefPer.LAST_NAME   			as LAST_NAME
	, RefPer.MIDDLE_NAME 			as MIDDLE_NAME
	, OCon1.CONCEPT_NAME 			as GENDER
	, OCon2.CONCEPT_NAME 			as RACE
	, OCon3.CONCEPT_NAME 			as ETHNICITY
	, OLoc.ZIP 						as ZIPCODE
	, datediff(yyyy,OPer.BIRTH_DATE, OVO.VISIT_START_DATE) as Age_at_Admit

into
	#COHORT_BASE_part1	--temporary table
	
from 
	VISIT_OCCURRENCE as OVO
	left join 
	CONDITION_OCCURRENCE as OCO
		on OVO.VISIT_OCCURRENCE_ID = OCO.VISIT_OCCURRENCE_ID
	left join 
	PERSON as OPer
		on OVO.PERSON_ID = OPer.PERSON_ID
	join
	REF_DIAG_CODES as RefDiag
		on OCO.Condition_Concept_ID = RefDiag.Target_Concept_ID
	left join
	[LOCATION] as OLoc
		on OPer.LOCATION_ID = OLoc.LOCATION_ID
	left join
	CONCEPT as OCON1
		on OCon1.CONCEPT_ID = OPer.GENDER_CONCEPT_ID 
	left join
	CONCEPT as OCON2
		on OCon2.CONCEPT_ID = OPer.RACE_CONCEPT_ID 
	left join
	CONCEPT as OCON3
		on OCon3.CONCEPT_ID = OPer.ETHNICITY_CONCEPT_ID 
	left join
	REF_PERSON_NAMES AS RefPer
		ON OPer.PERSON_SOURCE_VALUE = RefPer.MRN
where 
	OVO.VISIT_CONCEPT_ID = 9201 --Inpatient
	and 
		(
			OCO.CONDITION_TYPE_CONCEPT_ID = '38000200' 		--Inpatient Header first position
			OR OCO.CONDITION_TYPE_CONCEPT_ID = '38000199' 	--Inpatient Header - Primary
		)
		
	--Specific to VUMC OMOP implementation
	--and OCO.CONDITION_STATUS_CONCEPT_ID = '4230359' 		--Final Diagnosis
	/*
	--The combination of CO.CONDITION_TYPE_CONCEPT_ID and CO.CONDITION_STATUS_CONCEPT_ID above
	--is being used to identify principal diagnosis. This may need to be reworked in the
	--Vanderbilt implementation of OMOP to exclude the CONDITION_STATUS_CONCEPT_ID because
	--the current implementation seems to be nonstandard.
	*/
	and cast(convert(char(11), OVO.Visit_end_date, 113) as datetime) >= '2007-011-01 00:00:00.000'
	and cast(convert(char(11), OVO.VISIT_END_DATE, 113) as datetime)  <= '2017-011-01 00:00:00.000'
	and RefDiag.DIAGNOSIS = 'AMI'
;

select
	*
into
	COHORT_BASE
from
	(
		select
			*
			,ROW_NUMBER() OVER (PARTITION BY PERSON_ID ORDER BY ADMIT_DATE ASC, Prim_Diag ASC) AS Date_Row
		from
			#COHORT_BASE_part1
			--AMI.COHORT_BASE_part1	--Netezza SQL
	) sub
where Date_Row = 1
;

--now clean up

DROP TABLE #COHORT_BASE_part1
--End of PART 1--------------------