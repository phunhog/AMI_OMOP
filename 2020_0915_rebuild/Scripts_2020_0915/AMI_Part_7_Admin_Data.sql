
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
/*
PART 7: Add values to table Administrative_Data for elements from Table 1.
Elements include the following:
Length of stay for index admission
Number of ED visits 6 months before the admission
Admission in the prior 30 days
Total time spent in ED in the prior 30 days
Number of emergencies in the prior 30 days
Emergency-to-ward-transfers in the prior 30 days
*/
-----------------------------------------------------------------------------------------
--USE AMI
USE OMOP_CDM
GO

---------------------------------------------------------------------------
--Length of stay for index admission
--------------------------------------------------------------------------
---drop table if exists #Table1_Admin_Data_Index_LOS_1
;

select 
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, ADMIT_DATE
	, PRIM_DIAG
	, DISCHARGE_DATE
	, datediff(dd, ADMIT_DATE, DISCHARGE_DATE) + 1 as Index_LOS
into #Table1_Admin_Data_Index_LOS_1
from 
	COHORT_BASE
;


---drop table if exists #Table1_Admin_Data_Index_LOS
;

select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, CB2.DISCHARGE_DATE
	, Index_LOS.Index_LOS
into #Table1_Admin_Data_Index_LOS
from 
	COHORT_BASE_2 as CB2
	 left join #Table1_Admin_Data_Index_LOS_1 as Index_LOS
	 on CB2.PERSON_ID = Index_LOS.PERSON_ID
;


---------------------------------------------------------------------------
--Number of ED visits 6 months before the admission
--------------------------------------------------------------------------
---drop table if exists #Related_ED_Visits
;

--Get related visits
select
	  OVO.PERSON_ID
	, OVO.VISIT_OCCURRENCE_ID
	, OVO.VISIT_START_DATE
	, OVO.VISIT_END_DATE
	, CB2.VISIT_OCCURRENCE_ID as Index_Visit_ID
into #Related_ED_Visits
from .VISIT_OCCURRENCE as OVO
join COHORT_BASE_2 as CB2
on OVO.PERSON_ID = CB2.PERSON_ID
where
	OVO.VISIT_CONCEPT_ID = 9203 --ED visit
	and OVO.VISIT_START_DATE Between dateadd(dd,-180, CB2.ADMIT_DATE) and CB2.ADMIT_DATE
	and OVO.VISIT_OCCURRENCE_ID != CB2.VISIT_OCCURRENCE_ID
;

--Count the ED visits up to 180 days prior
---drop table if exists #Related_ED_Visits_2
;

select 
	  ED.PERSON_ID
	, ED.INDEX_VISIT_ID
	, Count(*) as Qty
into #Related_ED_Visits_2
from #Related_ED_Visits as ED
group by
	  ED.PERSON_ID
	, ED.INDEX_VISIT_ID
;

--Join with Cohort_Base_2
---drop table if exists #Table1_Admin_Data_ED_Visit_Prior_180_Days_Count
;

select
	CB2.Person_ID
	,CB2.VISIT_OCCURRENCE_ID
	,ED2.INDEX_VISIT_ID
	,case
		when ED2.Qty IS NULL then 0
		else ED2.Qty
	 end as ED_Visit_Prior_180_Days_Count
into #Table1_Admin_Data_ED_Visit_Prior_180_Days_Count
from Cohort_Base_2 as CB2
	left join 
	#Related_ED_Visits_2 as ED2
	on CB2.VISIT_OCCURRENCE_ID = ED2.INDEX_VISIT_ID
;


---------------------------------------------------------------------------
--Number of hospital admissions during the previous 30 days
--------------------------------------------------------------------------
---drop table if exists #Related_IP_Visits
;

select
	  OVO.PERSON_ID
	, OVO.VISIT_OCCURRENCE_ID
	, OVO.VISIT_START_DATE
	, OVO.VISIT_END_DATE
	, CB2.VISIT_OCCURRENCE_ID as Index_Visit_ID
into #Related_IP_Visits
from .VISIT_OCCURRENCE as OVO
join COHORT_BASE_2 as CB2
on OVO.PERSON_ID = CB2.PERSON_ID
where
	OVO.VISIT_CONCEPT_ID = 9201 --IP visit
	and OVO.VISIT_START_DATE Between dateadd(dd, -30, CB2.ADMIT_DATE) and CB2.ADMIT_DATE
	and OVO.VISIT_OCCURRENCE_ID != CB2.VISIT_OCCURRENCE_ID
;

--Count the IP visits up to 30 days prior
---drop table if exists #Related_IP_Visits_2
;

select 
	  IP.PERSON_ID
	, IP.INDEX_VISIT_ID
	, Count(*) as Qty
into #Related_IP_Visits_2
from #Related_IP_Visits as IP
group by
	  IP.PERSON_ID
	, IP.INDEX_VISIT_ID
;

--Join with Cohort_Base_2
---drop table if exists #Table1_Admin_Data_Admission_Prior_30_Days_Count
;

select
	CB2.Person_ID
	,CB2.VISIT_OCCURRENCE_ID
	,IP2.INDEX_VISIT_ID
	,case
		when IP2.Qty IS NULL then 0
		else IP2.Qty
	 end as Admission_Prior_30_Days_Count
into #Table1_Admin_Data_Admission_Prior_30_Days_Count
from Cohort_Base_2 as CB2
	left join 
	#Related_IP_Visits_2 as IP2
	on CB2.VISIT_OCCURRENCE_ID = IP2.INDEX_VISIT_ID
;

---------------------------------------------------------------------------
--Number of ED visits 30 days before the admission and total time in ED
--------------------------------------------------------------------------
---drop table if exists #Related_ED_Visits_30;

--Get related visits
select
	  OVO.PERSON_ID
	, OVO.VISIT_OCCURRENCE_ID
	, OVO.VISIT_START_DATE
	, OVO.VISIT_END_DATE
	, datediff(hh, OVO.VISIT_START_TIME, OVO.VISIT_END_TIME) as Time_In_ED
	, datediff(mi, OVO.VISIT_START_TIME, OVO.VISIT_END_TIME) as Time_In_ED_Minutes
	, CB2.VISIT_OCCURRENCE_ID as Index_Visit_ID
into #Related_ED_Visits_30
from .VISIT_OCCURRENCE as OVO
join COHORT_BASE_2 as CB2
on OVO.PERSON_ID = CB2.PERSON_ID
where
	OVO.VISIT_CONCEPT_ID = 9203 --ED visit
	and OVO.VISIT_START_DATE Between dateadd(dd, -30, CB2.ADMIT_DATE) and CB2.ADMIT_DATE
	and OVO.VISIT_OCCURRENCE_ID != CB2.VISIT_OCCURRENCE_ID
;

--Count the ED visits up to 30 days prior
---drop table if exists #Related_ED_Visits_30_2;

select 
	  ED.PERSON_ID
	, ED.INDEX_VISIT_ID
	, Count(*) as Qty
	, SUM(ED.Time_In_ED) as Total_Time_In_ED
	, SUM(ED.Time_In_ED_Minutes) as Total_Minutes_In_ED
into #Related_ED_Visits_30_2
from #Related_ED_Visits_30 as ED
group by
	  ED.PERSON_ID
	, ED.INDEX_VISIT_ID
;

--Join with Cohort_Base_2
---drop table if exists #Table1_Admin_Data_ED_Visit_Prior_30_Days;

select
	 CB2.PERSON_ID
	,CB2.VISIT_OCCURRENCE_ID
	,case
		when ED2.Qty IS NULL then 0
		else ED2.Qty
	 end as ED_Visit_Prior_30_Days_Count
	,case
		when ED2.Total_Time_In_ED IS NULL then 0
		else ED2.Total_Time_In_ED
	 end as ED_Visit_Prior_30_Days_Time_In_ED
	 ,case
		when ED2.Total_Minutes_In_ED IS NULL then 0
		else ED2.Total_Minutes_In_ED
	 end as ED_Visit_Prior_30_Days_Minutes_In_ED
into #Table1_Admin_Data_ED_Visit_Prior_30_Days
from Cohort_Base_2 as CB2
	left join 
	#Related_ED_Visits_30_2 as ED2
	on CB2.VISIT_OCCURRENCE_ID = ED2.INDEX_VISIT_ID
;


---------------------------------------------------------------------------
--Emergency-to-ward-transfers in the prior 30 days
--------------------------------------------------------------------------

--Identify related IP admissions within 30 days
---drop table if exists #Related_Visits_IP
;

select
	  OVO.PERSON_ID
	, OVO.VISIT_OCCURRENCE_ID
	, OVO.VISIT_START_DATE
	, OVO.VISIT_END_DATE
	, CB2.VISIT_OCCURRENCE_ID as Index_Visit_ID
	, CB2.ADMIT_DATE as Index_Admit_Date
into #Related_Visits_IP
from .VISIT_OCCURRENCE as OVO
join COHORT_BASE_2 as CB2
on OVO.PERSON_ID = CB2.PERSON_ID
where
	OVO.VISIT_CONCEPT_ID = 9201 --Inpatient
	and OVO.VISIT_START_DATE Between dateadd(dd, -30, CB2.ADMIT_DATE) and CB2.ADMIT_DATE
	and OVO.VISIT_OCCURRENCE_ID != CB2.VISIT_OCCURRENCE_ID
;


--Identify related ED admissions within 30 days
---drop table if exists #Related_Visits_ED
;

select
	  OVO.PERSON_ID
	, OVO.VISIT_OCCURRENCE_ID
	, OVO.VISIT_START_DATE
	, OVO.VISIT_END_DATE
	, CB2.VISIT_OCCURRENCE_ID as Index_Visit_ID
	, CB2.ADMIT_DATE as Index_Admit_Date
into #Related_Visits_ED
from .VISIT_OCCURRENCE as OVO
join COHORT_BASE_2 as CB2
on OVO.PERSON_ID = CB2.PERSON_ID
where
	OVO.VISIT_CONCEPT_ID = 9203 --ED
	and OVO.VISIT_START_DATE Between dateadd(dd, -30, CB2.ADMIT_DATE) and CB2.ADMIT_DATE
	and OVO.VISIT_OCCURRENCE_ID != CB2.VISIT_OCCURRENCE_ID
;

---drop table if exists #Related_Visits_ED_to_IP;

select
	  ED.PERSON_ID
	, ED.VISIT_OCCURRENCE_ID
	, ED.VISIT_START_DATE AS ED_Admit
	, ED.VISIT_END_DATE AS ED_Discharge
	, IP.VISIT_START_DATE AS IP_Admit
	, ED.Index_Visit_ID
	, ED.Index_Admit_Date
	, 1 as ED_to_IP_Flag
into #Related_Visits_ED_to_IP
from #Related_Visits_ED as ED
	join #Related_Visits_IP as IP
	on ED.PERSON_ID = IP.PERSON_ID
	and ED.Index_Visit_ID = IP.Index_Visit_ID
where
	ED.VISIT_END_DATE Between dateadd(dd,-1,IP.VISIT_START_DATE) and IP.VISIT_START_DATE
;


---drop table if exists #Related_Visits_ED_to_IP_Sum
;

select 
	 PERSON_ID
	,Index_Visit_ID
	,SUM(ED_to_IP_Flag) as Qty
into #Related_Visits_ED_to_IP_Sum
from #Related_Visits_ED_to_IP
group by
	 PERSON_ID
	,Index_Visit_ID
;


---drop table if exists #Table1_Admin_Data_ED_to_IP_Visit_Prior_30_Days
;

select
	 CB2.PERSON_ID
	,CB2.VISIT_OCCURRENCE_ID
	,case
		when ED2.Qty IS NULL then 0
		else ED2.Qty
	 end as ED_to_IP_Visit_Prior_30_Days_Count
into #Table1_Admin_Data_ED_to_IP_Visit_Prior_30_Days
from Cohort_Base_2 as CB2
	left join 
	#Related_Visits_ED_to_IP_Sum as ED2
	on CB2.VISIT_OCCURRENCE_ID = ED2.INDEX_VISIT_ID
;


--------------------------------------------------------------------------
--Combine variables from temp tables
--------------------------------------------------------------------------

---drop table if exists Table1_Admin_Data;

select 
	  L.PERSON_ID
	, L.VISIT_OCCURRENCE_ID
	, L.ADMIT_DATE
	, L.PRIM_DIAG
	, L.DISCHARGE_DATE
	, L.Index_LOS
	, ED180.ED_Visit_Prior_180_Days_Count
	, A.Admission_Prior_30_Days_Count
	, ED30.ED_Visit_Prior_30_Days_Count
	, ED30.ED_Visit_Prior_30_Days_Time_In_ED
	, ED30.ED_Visit_Prior_30_Days_Minutes_In_ED
	, EDIP.ED_to_IP_Visit_Prior_30_Days_Count
into Table1_Admin_Data
from 
	#Table1_Admin_Data_Index_LOS as L
	left join
	#Table1_Admin_Data_ED_Visit_Prior_180_Days_Count as ED180
		on
		L.VISIT_OCCURRENCE_ID = ED180.VISIT_OCCURRENCE_ID
	left join
	#Table1_Admin_Data_Admission_Prior_30_Days_Count as A
		on 
		L.VISIT_OCCURRENCE_ID = A.VISIT_OCCURRENCE_ID
	left join
	#Table1_Admin_Data_ED_Visit_Prior_30_Days as ED30
		on
		L.VISIT_OCCURRENCE_ID = ED30.VISIT_OCCURRENCE_ID
	left join
	#Table1_Admin_Data_ED_to_IP_Visit_Prior_30_Days as EDIP
		on
		L.VISIT_OCCURRENCE_ID = EDIP.VISIT_OCCURRENCE_ID
;




/*
select * from Table1_Admin_Data limit 100;

select * from Table1_Admin_Data where ED_to_IP_Visit_Prior_30_Days > 0 limit 100;

select Index_LOS, count(*) from Table1_Admin_Data group by Index_LOS;

select ED_Visit_Prior_180_Days_Count, count(*) from Table1_Admin_Data group by ED_Visit_Prior_180_Days_Count;

select Admission_Prior_30_Days_Count, count(*) from Table1_Admin_Data group by Admission_Prior_30_Days_Count;

select ED_Visit_Prior_30_Days_Count, count(*) from Table1_Admin_Data group by ED_Visit_Prior_30_Days_Count;

select ED_Visit_Prior_30_Days_Time_In_ED, count(*) from Table1_Admin_Data group by ED_Visit_Prior_30_Days_Time_In_ED;

select ED_to_IP_Visit_Prior_30_Days, count(*) from Table1_Admin_Data group by ED_to_IP_Visit_Prior_30_Days;
*/