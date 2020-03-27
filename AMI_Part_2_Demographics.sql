
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 2: Add values to Table1_Demographics for elements from Table 1 and additions:

Deceased Flag - below (Based on Discharge Location)
Death Date - below
Deceased Flag Alt - below (based on date of death)
Discharge location - below
Transfer at discharge - below



*/
-----------------------------------------------------------------------------------------


--Discharge location--------------------------------------------------------------
select 
	 ACB2.PERSON_ID
	,ACB2.VISIT_OCCURRENCE_ID
	,OVO.DISCHARGE_TO_CONCEPT_ID
	,OCon.CONCEPT_NAME as Discharge_Location
into 
	#Table1_Additions_Discharge_Location
from 
	COHORT_BASE_2 as ACB2
	left join VISIT_OCCURRENCE as OVO
		on ACB2.PERSON_ID = OVO.PERSON_ID
		and ACB2.VISIT_OCCURRENCE_ID = OVO.VISIT_OCCURRENCE_ID
	left join CONCEPT as OCon
		on OVO.DISCHARGE_TO_CONCEPT_ID = OCon.CONCEPT_ID
group by 	
	 ACB2.PERSON_ID
	,ACB2.VISIT_OCCURRENCE_ID
	,OVO.DISCHARGE_TO_CONCEPT_ID
	,OCon.CONCEPT_NAME
;



--Deceased Flag and Transfer at Discharge Flag-----------------------------------------------------

select 
	 ACB2.PERSON_ID
	,ACB2.VISIT_OCCURRENCE_ID
	,DL.Discharge_Location
	,case
		when DL.Discharge_Location = 'Patient died' then 1 
		else 0
	 end as Deceased_Flag
	,case
		when DL.Discharge_Location = 'TRANSFER OTHER HOSPITAL' then 1 
		else 0
	 end as Transfer_at_Discharge_Flag
into 
	#Table1_Additions_Deceased_Flag
from 
	COHORT_BASE_2 as ACB2
	left join #Table1_Additions_Discharge_Location as DL
		on ACB2.PERSON_ID = DL.PERSON_ID
		and ACB2.VISIT_OCCURRENCE_ID = DL.VISIT_OCCURRENCE_ID
;



--Date of Death-------------------------------------------------------------------------

select 
	 ACB2.PERSON_ID
	,ACB2.VISIT_OCCURRENCE_ID
	,ACB2.ADMIT_DATE
	,ACB2.PRIM_DIAG
	,OD.DEATH_DATE
	,MAX(
			Case
				when OD.DEATH_DATE between ACB2.ADMIT_DATE and ACB2.DISCHARGE_DATE
				then 1
				else 0
	 		end
		) as Deceased_Flag_Alt
into 
	#Table1_Additions_Death
from 
	COHORT_BASE_2 as ACB2
	left join DEATH as OD
		on ACB2.PERSON_ID = OD.PERSON_ID
group by
	 ACB2.PERSON_ID
	,ACB2.VISIT_OCCURRENCE_ID
	,ACB2.ADMIT_DATE
	,ACB2.PRIM_DIAG
	,OD.DEATH_DATE



 --combine temp tables-------------------------------------------------------------------


IF OBJECT_ID('dbo.Table1_Demographics', 'U') IS NOT NULL 
  DROP TABLE Table1_Demographics 
 
 select
	 ACB2.PERSON_ID
	,ACB2.VISIT_OCCURRENCE_ID
	,DF.Discharge_Location
	,case 
		when DF.Deceased_Flag IS NOT NULL
		then DF.Deceased_Flag
		else 0
	 end as Deceased_Flag
	,case 
		when D.Deceased_Flag_Alt IS NOT NULL
		then D.Deceased_Flag_Alt
		else 0
	 end as Deceased_Flag_Alt
	,D.DEATH_DATE
	,case 
		when DF.Transfer_at_Discharge_Flag IS NOT NULL
		then DF.Transfer_at_Discharge_Flag
		else 0
	 end as Transfer_at_Discharge_Flag
into 
	Table1_Demographics
from
	COHORT_BASE_2 as ACB2
	left join #Table1_Additions_Deceased_Flag as DF
		on ACB2.PERSON_ID = DF.PERSON_ID
		and ACB2.VISIT_OCCURRENCE_ID = DF.VISIT_OCCURRENCE_ID
	left join #Table1_Additions_Death as D
		on ACB2.PERSON_ID = D.PERSON_ID
		and ACB2.VISIT_OCCURRENCE_ID = D.VISIT_OCCURRENCE_ID	
;


--clean up

Drop table #Table1_Additions_Discharge_Location
Drop table #Table1_Additions_Deceased_Flag
Drop table #Table1_Additions_Death

--End of PART 2--------------------------------------------------------------------------


/* Just some counts
select 
 	  count(PERSON_ID)
	, count(VISIT_OCCURRENCE_ID)
	, count(Age_at_Admit)
	, sum(Index_Admission_Flag)
	, count(Discharge_Location)
	, sum(Deceased_Flag)
	, sum(Transfer_at_Discharge_Flag)
	, count(Death_Date)
	, sum(Deceased_Flag_Alt)
from Table1_Demographics
*/