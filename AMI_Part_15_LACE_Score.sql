-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
/*
PART 15: Add values to Table1_LACE_Score for elements from Table 1:

Depends upon some earlier tables:
Table1_HOSPITAL_Score
Table1_Comorbidities
Table1_Admin_Data


LOS (Hospital Score)
Acuity (Hospital score nonelective admission)
Comorbidities (Charlson score in Comorbidities)
ED visits last 6 months (Administrative Data)
*/

-- update 5/39 2020 change pbj names to match dartmouth OMOP

use OMOP_CDM

go

Select 
	 HS.PERSON_ID
	,HS.VISIT_OCCURRENCE_ID
	,case
		when HS.Nonelective_Admission_Flag = 0 then 0
		when HS.Nonelective_Admission_Flag = 1 then 3
		else 0
	 end as LACE_Acuity_Score
	,case
		when HS.LOS between 0 and 1 then 1
		when HS.LOS = 2 then 2
		when HS.LOS = 3 then 3
		when HS.LOS between 4 and 6 then 4
		when HS.LOS between 7 and 13 then 5
		when HS.LOS >= 14 then 7
	 end as LACE_LOS_Score
into #LACE_Part1
from Table1_HOSPITAL_Score as HS
;


select
	 C.PERSON_ID
	,C.VISIT_OCCURRENCE_ID
	,case
		when C.Charlson_Deyo_Score = 0 then 0
		when C.Charlson_Deyo_Score = 1 then 1
		when C.Charlson_Deyo_Score = 2 then 2
		when C.Charlson_Deyo_Score = 3 then 3
		when C.Charlson_Deyo_Score >= 4 then 5
	 end as LACE_Charlson_Score
into #LACE_Part2
from Table1_Comorbidities as C
;


select distinct
	 A.PERSON_ID
	,A.VISIT_OCCURRENCE_ID
	,case
		when A.ED_Visit_Prior_180_Days_Count = 0 then 0
		when A.ED_Visit_Prior_180_Days_Count = 1 then 1
		when A.ED_Visit_Prior_180_Days_Count = 2 then 2
		when A.ED_Visit_Prior_180_Days_Count = 3 then 3
		when A.ED_Visit_Prior_180_Days_Count >= 4 then 4
	 end as LACE_ED_Score
into #LACE_Part3
from Table1_Admin_Data as A
;

--drop table Table1_LACE_Score if exists;


IF OBJECT_ID('Table1_LACE_Score', 'U') IS NOT NULL 
BEGIN
  DROP TABLE Table1_LACE_Score
END
GO

Select distinct 
	 L1.PERSON_ID
	,L1.VISIT_OCCURRENCE_ID
	,L1.LACE_Acuity_Score
	,L1.LACE_LOS_Score
	,L2.LACE_Charlson_Score
	,L3.LACE_ED_Score
	,(L1.LACE_Acuity_Score
	  + L1.LACE_LOS_Score
	  + L2.LACE_Charlson_Score
	  + L3.LACE_ED_Score
	  ) as LACE_Score
into Table1_LACE_Score
from #LACE_Part1 as L1
left join
	#LACE_Part2 as L2
	on L1.VISIT_OCCURRENCE_ID = L2.VISIT_OCCURRENCE_ID
left join 
	#LACE_Part3 as L3
	on L1.VISIT_OCCURRENCE_ID = L3.VISIT_OCCURRENCE_ID
;

--End Part 15--------------------------------------------------------
/*
select * from Table1_LACE_Score Limit 100;

select LACE_Score, count(*) from Table1_LACE_Score group by LACE_Score order by LACE_Score Limit 100;

select LACE_Acuity_Score, count(*) from Table1_LACE_Score group by LACE_Acuity_Score order by LACE_Acuity_Score Limit 100;


SELECT PERSON_ID
       , VISIT_OCCURRENCE_ID
       , LACE_ACUITY_SCORE
       , LACE_LOS_SCORE
       , LACE_CHARLSON_SCORE
       , LACE_ED_SCORE
       , LACE_SCORE

  FROM MATHENY_DB_RD.DORNCA.TABLE1_LACE_SCORE
 LIMIT 100;
*/