
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
/*
PART 12: Add values to table HOSPITAL_SCORE for elements from Table 1.
Elements include the following:
Hemoglobin level at discharge <12 g/dL
Discharge from an oncology service
Low sodium level at discharge of <135 mEg/L
Procedure during hospital stay
Number of hospital admissions during the previous year
Admission type non-elective
Length of stay >= 5 days
*/
-----------------------------------------------------------------------------------------


---------------------------------------------------------------------------
--Length of stay >= 5 days
--------------------------------------------------------------------------

select 
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, CB2.DISCHARGE_DATE
	, datediff(dd,ADMIT_DATE, DISCHARGE_DATE) + 1 as LOS
	,case 
		when
		Datediff(dd, admit_date, DISCHARGE_DATE) + 1 >= 5
		then 1
		else 0
	end as LOS5_Flag
into #Table1_HOSPITAL_Score_LOS
from 
	AMI.COHORT_BASE_2 as CB2
;


----------------------------------------------------------------------------
--Procedure during hospital stay flag
----------------------------------------------------------------------------

select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, CB2.DISCHARGE_DATE
	,case 
		when 
		count(PO.PROCEDURE_OCCURRENCE_ID) > 0
		then 1
		else 0
	end as Procedure_Flag
into #Table1_HOSPITAL_Score_Any_Procedure
from 
	AMI.COHORT_BASE_2 as CB2
	left join
		OMOP.PROCEDURE_OCCURRENCE as PO
		on CB2.PERSON_ID = PO.PERSON_ID
where PO.Procedure_Date between CB2.Admit_date and CB2.DISCHARGE_DATE
group by
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, CB2.DISCHARGE_DATE
;


---------------------------------------------------------------------------
--Number of hospital admissions during the previous year
--------------------------------------------------------------------------

select
	  VO.PERSON_ID
	, VO.VISIT_OCCURRENCE_ID
	, VO.VISIT_START_DATE
	, VO.VISIT_END_DATE
	, CB2.VISIT_OCCURRENCE_ID as Index_Visit_ID
into #Related_IP_Visits
from OMOP.VISIT_OCCURRENCE as VO
join AMI.COHORT_BASE_2 as CB2
on VO.PERSON_ID = CB2.PERSON_ID
where
	VO.VISIT_CONCEPT_ID = 9201 --IP visit
	and VO.VISIT_START_DATE Between dateadd(dd, -365, CB2.ADMIT_DATE) and CB2.ADMIT_DATE
	and VO.VISIT_OCCURRENCE_ID != CB2.VISIT_OCCURRENCE_ID
;

--Count the IP visits up to 30 days prior
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
select
	CB2.Person_ID
	,CB2.VISIT_OCCURRENCE_ID
	,IP2.INDEX_VISIT_ID
	,case
		when IP2.Qty IS NULL then 0
		else IP2.Qty
	 end as Prior_Year_Admissions_Count
into #Table1_HOSPITAL_Score_Prior_Year_Admissions_Count
from AMI.Cohort_Base_2 as CB2
	left join 
	#Related_IP_Visits_2 as IP2
	on CB2.VISIT_OCCURRENCE_ID = IP2.INDEX_VISIT_ID
;


---------------------------------------------------------------------------
--Non-elective admission (ED visit day of or day prior to admission)
--------------------------------------------------------------------------

--Get related visits
select
	  VO.PERSON_ID
	, VO.VISIT_OCCURRENCE_ID
	, VO.VISIT_START_DATE
	, VO.VISIT_END_DATE
	, Datediff(minute,  VO.VISIT_START_DATETIME, VO.VISIT_END_DATETIME) as Time_In_ED
	, CB2.VISIT_OCCURRENCE_ID as Index_Visit_ID
into #Related_ED_Visits_1
from OMOP.VISIT_OCCURRENCE as VO
join AMI.COHORT_BASE_2 as CB2
on VO.PERSON_ID = CB2.PERSON_ID
where
	VO.VISIT_CONCEPT_ID = 9203 --ED visit
	and VO.VISIT_START_DATE Between Dateadd(dd, -1, CB2.ADMIT_DATE) and CB2.ADMIT_DATE
	and VO.VISIT_OCCURRENCE_ID != CB2.VISIT_OCCURRENCE_ID
;

--Count the ED visits up to 1 day prior
select 
	  ED.PERSON_ID
	, ED.INDEX_VISIT_ID
	, Count(*) as Qty
into #Related_ED_Visits_1_2
from #Related_ED_Visits_1 as ED
group by
	  ED.PERSON_ID
	, ED.INDEX_VISIT_ID
;

--Join with Cohort_Base_2
select
	 CB2.PERSON_ID
	,CB2.VISIT_OCCURRENCE_ID
	,case
		when ED2.Qty IS NULL then 0
		else 1
	 end as Nonelective_Admission_Flag
into #Table1_HOSPITAL_Score_Nonelective_Admission_Flag
from AMI.Cohort_Base_2 as CB2
	left join 
	#Related_ED_Visits_1_2 as ED2
	on CB2.VISIT_OCCURRENCE_ID = ED2.INDEX_VISIT_ID
;

--------------------------------------------------------------------------
--Discharge from an oncology service
--------------------------------------------------------------------------

select CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.ADMIT_DATE
	, CB2.PRIM_DIAG
	, MAX(case when Ref.CONDITIONID IN (10, 419) then 1 else 0 end) as Oncology_Flag
into #Table1_HOSPITAL_Score_Oncology_Flag
from AMI.COHORT_BASE_2 as CB2
	left join 
	OMOP.CONDITION_OCCURRENCE as CO
		ON CB2.PERSON_ID = CO.PERSON_ID
		AND CO.CONDITION_START_DATE between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
	left join
	AMI.Ref_Conditions_SNOMED as Ref
		ON Ref.TARGET_CONCEPT_ID = CO.CONDITION_CONCEPT_ID
group by CB2.PERSON_ID, CB2.VISIT_OCCURRENCE_ID, CB2.ADMIT_DATE, CB2.PRIM_DIAG
;


--------------------------------------------------------------------------------
--Low sodium level at discharge of <135 mEq/L
--------------------------------------------------------------------------------

--3019550 =	Sodium serum/plasma

select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, M.MEASUREMENT_DATETIME
	, M.VALUE_AS_NUMBER
	, M.MEASUREMENT_SOURCE_VALUE
	, M.UNIT_SOURCE_VALUE
	, FIRST_VALUE(VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY M.MEASUREMENT_DATETIME) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY M.MEASUREMENT_DATETIME DESC) AS Last_VALUE_AS_NUMBER
into #Table1_HOSPITAL_Score_Sodium_Level_Last_135_Flag_0
from 
	AMI.COHORT_BASE_2 as CB2
	left join
	OMOP.Measurement as M
		on CB2.PERSON_ID = M.PERSON_ID
		and M.MEASUREMENT_DATETIME between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where M.Measurement_Concept_ID = 3019550
	and M.MEASUREMENT_DATETIME between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
	and M.UNIT_SOURCE_VALUE = 'mEq/L'
	and M.MEASUREMENT_SOURCE_VALUE = 'Na'
	and M.VALUE_AS_NUMBER IS NOT NULL
;


select distinct
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, AVG(VALUE_AS_NUMBER) AS Sodium_Level_Avg
	, Min(VALUE_AS_NUMBER) AS Sodium_Level_Min
	, Max(VALUE_AS_NUMBER) AS Sodium_Level_Max
	, First_VALUE_AS_NUMBER AS Sodium_Level_First
	, Last_VALUE_AS_NUMBER AS Sodium_Level_Last
	, MEASUREMENT_SOURCE_VALUE
	, UNIT_SOURCE_VALUE
into #Table1_HOSPITAL_Score_Sodium_Level_Last_135_Flag_1
from 
	#Table1_HOSPITAL_Score_Sodium_Level_Last_135_Flag_0
group by
	PERSON_ID
	, VISIT_OCCURRENCE_ID
	, First_VALUE_AS_NUMBER
	, Last_VALUE_AS_NUMBER
	, MEASUREMENT_SOURCE_VALUE
	, UNIT_SOURCE_VALUE
;



select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, S.Sodium_Level_Avg
	, S.Sodium_Level_Min
	, S.Sodium_Level_Max
	, S.Sodium_Level_First
	, S.Sodium_Level_Last
	, S.MEASUREMENT_SOURCE_VALUE
	, S.UNIT_SOURCE_VALUE
	, case
		when S.Sodium_Level_Last IS NULL
			then 0
		when S.Sodium_Level_Last < 135
			then 1
		else 0
	  end as Sodium_Level_Last_135_Flag
into #Table1_HOSPITAL_Score_Sodium_Level_Last_135_Flag
from 
	AMI.COHORT_BASE_2 as CB2
	left join
	#Table1_HOSPITAL_Score_Sodium_Level_Last_135_Flag_1 AS S
		on CB2.VISIT_OCCURRENCE_ID = S.VISIT_OCCURRENCE_ID
;



--------------------------------------------------------------------------------
--Low Hemoglobin level < 12 g/DL
--------------------------------------------------------------------------------

--3000963 =	Hemoglobin (Hgb)

select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, M.MEASUREMENT_DATETIME
	, M.VALUE_AS_NUMBER
	, M.MEASUREMENT_SOURCE_VALUE
	, M.UNIT_SOURCE_VALUE
	, FIRST_VALUE(VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY M.MEASUREMENT_DATETIME) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY M.MEASUREMENT_DATETIME DESC) AS Last_VALUE_AS_NUMBER
into #Table1_HOSPITAL_Score_Hemoglobin_Level_0
from 
	AMI.COHORT_BASE_2 as CB2
	left join
	OMOP.Measurement as M
		on CB2.PERSON_ID = M.PERSON_ID
where M.Measurement_Concept_ID = 3000963
	and M.MEASUREMENT_DATETIME between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
	and M.UNIT_SOURCE_VALUE = 'g/dL'
	and M.MEASUREMENT_SOURCE_VALUE = 'Hgb'
	and M.VALUE_AS_NUMBER IS NOT NULL
;


select
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, AVG(VALUE_AS_NUMBER) AS Hemoglobin_Level_Avg
	, Min(VALUE_AS_NUMBER) AS Hemoglobin_Level_Min
	, Max(VALUE_AS_NUMBER) AS Hemoglobin_Level_Max
	, First_VALUE_AS_NUMBER AS Hemoglobin_Level_First
	, Last_VALUE_AS_NUMBER AS Hemoglobin_Level_Last
	, MEASUREMENT_SOURCE_VALUE
	, UNIT_SOURCE_VALUE
into #Table1_HOSPITAL_Score_Hemoglobin_Level_1
from 
	#Table1_HOSPITAL_Score_Hemoglobin_Level_0
group by
	PERSON_ID
	, VISIT_OCCURRENCE_ID
	, First_VALUE_AS_NUMBER
	, Last_VALUE_AS_NUMBER
	, MEASUREMENT_SOURCE_VALUE
	, UNIT_SOURCE_VALUE
;


select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, H.Hemoglobin_Level_Avg
	, H.Hemoglobin_Level_Min
	, H.Hemoglobin_Level_Max
	, H.Hemoglobin_Level_First
	, H.Hemoglobin_Level_Last
	, H.MEASUREMENT_SOURCE_VALUE
	, H.UNIT_SOURCE_VALUE
	, case
		when H.Hemoglobin_Level_Last IS NULL
			then 0
		when H.Hemoglobin_Level_Last < 12
			then 1
		else 0
	  end as Hemoglobin_Level_Last_12_Flag
into #Table1_HOSPITAL_Score_Hemoglobin_Level_Last_12_Flag
from 
	AMI.COHORT_BASE_2 as CB2
	left join
	#Table1_HOSPITAL_Score_Hemoglobin_Level_1 AS H
		on CB2.VISIT_OCCURRENCE_ID = H.VISIT_OCCURRENCE_ID
;


--------------------------------------------------------------------------
--Combine variables from temp tables
--------------------------------------------------------------------------

select 
	  L.PERSON_ID
	, L.VISIT_OCCURRENCE_ID
	, L.ADMIT_DATE
	, L.PRIM_DIAG
	, L.DISCHARGE_DATE
	, L.LOS
	, L.LOS5_Flag
	, case when P.Procedure_Flag > 0 and P.Procedure_Flag IS NOT NULL
		then 1
		else 0
	  end as Procedure_Flag
	, case when A.Prior_Year_Admissions_Count IS NOT NULL
		then A.Prior_Year_Admissions_Count
		else 0
	  end as Prior_Year_Admissions_Count
	, case when	NAF.Nonelective_Admission_Flag IS NOT NULL
		then NAF.Nonelective_Admission_Flag
		else 0
	  end as Nonelective_Admission_Flag
	, case when	OSF.Oncology_Flag IS NOT NULL
		then OSF.Oncology_Flag
		else 0
	  end as Oncology_Flag
	, case when	S.Sodium_Level_Last_135_Flag IS NOT NULL
		then S.Sodium_Level_Last_135_Flag
		else 0
	  end as Sodium_Level_Last_135_Flag
	, case when	H.Hemoglobin_Level_Last_12_Flag IS NOT NULL
		then H.Hemoglobin_Level_Last_12_Flag
		else 0
	  end as Hemoglobin_Level_Last_12_Flag
into #Table1_HOSPITAL_Score_Part1
from 
	#Table1_HOSPITAL_Score_LOS as L
	left join
	#Table1_HOSPITAL_Score_Any_Procedure as P
	on
		L.PERSON_ID = P.PERSON_ID
		and L.VISIT_OCCURRENCE_ID = P.VISIT_OCCURRENCE_ID
		and L.ADMIT_DATE = P.ADMIT_DATE
		and L.PRIM_DIAG = P.PRIM_DIAG
		and  L.DISCHARGE_DATE = P.DISCHARGE_DATE
	left join
	#Table1_HOSPITAL_Score_Prior_Year_Admissions_Count as A
	on 
		P.VISIT_OCCURRENCE_ID = A.VISIT_OCCURRENCE_ID
	left join
	#Table1_HOSPITAL_Score_Nonelective_Admission_Flag as NAF
	on
		A.VISIT_OCCURRENCE_ID = NAF.VISIT_OCCURRENCE_ID
	left join
	#Table1_HOSPITAL_Score_Oncology_Flag as OSF
	on
		L.VISIT_OCCURRENCE_ID = OSF.VISIT_OCCURRENCE_ID
	left join
	#Table1_HOSPITAL_Score_Sodium_Level_Last_135_Flag as S
	on
		L.VISIT_OCCURRENCE_ID = S.VISIT_OCCURRENCE_ID	
	left join
	#Table1_HOSPITAL_Score_Hemoglobin_Level_Last_12_Flag as H
	on
		L.VISIT_OCCURRENCE_ID = H.VISIT_OCCURRENCE_ID
;


------------------------------------------------------------------
--Overall HOSPITAL Score
-------------------------------------------------------------------

select 
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, ADMIT_DATE
	, PRIM_DIAG
	, DISCHARGE_DATE
	, LOS
	, LOS5_Flag
	, Procedure_Flag
	, Prior_Year_Admissions_Count
	, Nonelective_Admission_Flag
	, Oncology_Flag
	, Hemoglobin_Level_Last_12_Flag
	, Sodium_Level_Last_135_Flag
	, case when LOS5_Flag = 1
		then 2
		else 0
	  end as LOS5_Flag_Score
	, case when Procedure_Flag = 1
		then 1
		else 0
	  end as Procedure_Flag_Score
	, case when Prior_Year_Admissions_Count <=1
		then 0
		when Prior_Year_Admissions_Count > 5
		then 5
		else 2
	  end as Prior_Year_Admissions_Count_Score
	, case when	Nonelective_Admission_Flag = 1
		then 1
		else 0
	  end as Nonelective_Admission_Flag_Score
	, case when	Oncology_Flag = 1
		then 2
		else 0
	  end as Oncology_Flag_Score
	, case when	Sodium_Level_Last_135_Flag = 1
		then 1
		else 0
	  end as Sodium_Level_Last_135_Flag_Score
	, case when	Hemoglobin_Level_Last_12_Flag = 1
		then 1
		else 0
	  end as Hemoglobin_Level_Last_12_Flag_Score
into #Table1_HOSPITAL_Score_Part2
from 
	#Table1_HOSPITAL_Score_Part1
;


--drop table Table1_HOSPITAL_Score if exists;

select
	*
	,(
	 	LOS5_Flag_Score + 
	 	Procedure_Flag_Score + 
	 	Prior_Year_Admissions_Count_Score + 
	 	Nonelective_Admission_Flag_Score + 
	 	Oncology_Flag_Score + 
	 	Hemoglobin_Level_Last_12_Flag_Score + 
	 	Sodium_Level_Last_135_Flag_Score
	 ) as HOSPITAL_Score
into Table1_HOSPITAL_Score
from
	#Table1_HOSPITAL_Score_Part2
;

--End of PART 12--------------------------------------------------------------------------

/*
--Counts
select
	Procedure_Flag
	, count(*) as qty
from
	Table1_HOSPITAL_Score
group by
	Procedure_Flag
;

select
	LOS5_Flag
	, count(*) as qty
from
	Table1_HOSPITAL_Score
group by
	LOS5_Flag
;

select
	Prior_Year_Admissions_Count
	, count(*) as qty
from
	Table1_HOSPITAL_Score
group by
	Prior_Year_Admissions_Count
order by Prior_Year_Admissions_Count
;

select 
	Nonelective_Admission_Flag
	, count(*) 
from 
	Table1_HOSPITAL_Score 
group by Nonelective_Admission_Flag 
;

select 
	Oncology_flag
	, count(*) as qty 
from 
	Table1_HOSPITAL_Score 
group by oncology_flag
;

select 
	Prior_Year_Admissions_Count_Score
	, count(*) as qty 
from 
	Table1_HOSPITAL_Score
group by Prior_Year_Admissions_Count_Score
order by Prior_Year_Admissions_Count_Score
;

select 
	Hospital_Score
	, count(*) as qty 
from 
	Table1_HOSPITAL_Score
group by Hospital_Score
order by Hospital_Score
;

*/