
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
Part 1.1: Add discharges one year prior and one year after the index admission
	for the set of patients that are part of the set of index admissions from Part 1.
*/
-----------------------------------------------------------------------------------------


--USE AMI
use OMOP_CDM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


select
	 ACB.MRN
	,ACB.PERSON_ID
	,ACB.GENDER
	,ACB.RACE
	,ACB.ETHNICITY
	--,ASSN.SSN
	--,ACB.ZIPCODE
	--,ACB.FIRST_NAME
	--,ACB.LAST_NAME
	--,ACB.MIDDLE_NAME
	,ACB.DOB
	,ACB.Age_at_Admit
	,min(OCO.CONDITION_SOURCE_VALUE) as PRIM_DIAG  --Account for the possibility of both ICD9 and ICD10 primary diagnosis records during transition to ICD10
	,OVO.VISIT_START_DATE as ADMIT_DATE
	,OVO.VISIT_START_TIME AS ADMIT_DATETIME
	,OVO.VISIT_END_DATE as DISCHARGE_DATE
	,OVO.visit_end_time as DISCHARGE_DATETIME
	,ACB.ADMIT_DATE AS Index_Admit_Date
	,ACB.DISCHARGE_DATE AS Index_Discharge_Date
	,ACB.VISIT_OCCURRENCE_ID AS Index_VISIT_OCCURRENCE_ID
	,OVO.VISIT_OCCURRENCE_ID as VISIT_OCCURRENCE_ID
into
	--temp AMI_COHORT_BASE_2a	--Netezza SQL
	#AMI_COHORT_BASE_2a
from 
	COHORT_BASE as ACB
	join
	VISIT_OCCURRENCE as OVO
		ON OVO.PERSON_ID = ACB.PERSON_ID
	left join 
	CONDITION_OCCURRENCE as OCO
		on OVO.VISIT_OCCURRENCE_ID = OCO.VISIT_OCCURRENCE_ID
	--left join
	--AMI.Ref_Person_SSN as ASSN
	--	on ACB.MRN = ASSN.MRN
where 
	OVO.VISIT_CONCEPT_ID = 9201 --Inpatient
	and OCO.CONDITION_TYPE_CONCEPT_ID = '38000200' --Inpatient Header first position
	--and OCO.CONDITION_STATUS_CONCEPT_ID = '4230359' --Final Diagnosis (VUMC)
	and (DateDiff(dd,OVO.VISIT_END_DATE, ACB.ADMIT_DATE) between 1 and 365
		or DateDiff(dd,ACB.DISCHARGE_DATE, OVO.VISIT_START_DATE) between 1 and 365)
--	and --Netezza SQL
--		(
--		(ACB.ADMIT_DATE - OVO.VISIT_END_DATE) between 0 and 365
--		or (OVO.VISIT_START_DATE - ACB.DISCHARGE_DATE) between 0 and 365
--		)
	and ACB.DISCHARGE_DATE <> OVO.VISIT_END_DATE --to account for a new one day visit on same day as discharge date of index admission
group by
	 ACB.MRN
	,ACB.PERSON_ID
	,ACB.GENDER
	,ACB.RACE
	,ACB.ETHNICITY
	--,ASSN.SSN
	--,ACB.ZIPCODE
	--,ACB.FIRST_NAME
	--,ACB.LAST_NAME
	--,ACB.MIDDLE_NAME
	,ACB.DOB
	,ACB.Age_at_Admit
	,OVO.VISIT_START_DATE
	,OVO.VISIT_START_TIME
	,OVO.VISIT_END_DATE
	,OVO.visit_end_time
	,ACB.ADMIT_DATE
	,ACB.DISCHARGE_DATE
	,ACB.VISIT_OCCURRENCE_ID
	,OVO.VISIT_OCCURRENCE_ID
;



--DROP TABLE IF EXISTS AMI.COHORT_BASE_2
--GO


IF OBJECT_ID('COHORT_BASE_2', 'U') IS NOT NULL 
	DROP table COHORT_BASE_2


GO


select
	*
	,0 as Index_Admission_Flag
into
	COHORT_BASE_2
from
	--AMI.COHORT_BASE_2a	--Netezza SQL
	#AMI_COHORT_BASE_2a

UNION

(
	SELECT 
		   ACB.MRN
	      ,ACB.PERSON_ID
	      ,ACB.GENDER
	      ,ACB.RACE
	      ,ACB.ETHNICITY
	   --   ,ASSN.MRN
		  --,ACB.ZIPCODE
	   --   ,ACB.FIRST_NAME
	   --   ,ACB.LAST_NAME
	   --   ,ACB.MIDDLE_NAME
	      ,ACB.DOB
		  ,ACB.Age_at_Admit
	      ,ACB.PRIM_DIAG
	      ,ACB.ADMIT_DATE
		  ,ACB.ADMIT_DATETIME
	      ,ACB.DISCHARGE_DATE
		  ,ACB.DISCHARGE_DATETIME
	      ,ACB.INDEX_ADMIT_DATE
	      ,ACB.INDEX_DISCHARGE_DATE
		  ,ACB.VISIT_OCCURRENCE_ID as INDEX_VISIT_OCCURRENCE_ID
	      ,ACB.VISIT_OCCURRENCE_ID
		  ,1 as Index_Admission_Flag
	FROM 
		COHORT_BASE as ACB
		--left join
		--AMI.Ref_Person_SSN as ASSN
		--	ON ACB.MRN = ASSN.MRN
	--where 
	--	discharge_date < '1/1/2017'
)
;
--End------------------------------------------------------------------------------
