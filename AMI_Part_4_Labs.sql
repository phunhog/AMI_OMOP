
-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
/*
PART 4: Add values to table Laboratories for elements from Table 1.
Elements include the following:
Sodium level of <136 mEg/L
Calcium level of < 8.6 mg/dL
Peak creatine kinase/troponin
Serum markers hematocrit or hemoglobin
Blood urea nitrogen or creatinine
Brain Natriuretic Peptide (BNP)
*/

/*
Update 4/10/2020-- code edited to match Dartmouth OMOP obj names
*/

-----------------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--Sodium level of < 136 mEq/L
--------------------------------------------------------------------------------
--3019550 =	Sodium serum/plasma

USE OMOP_CDM
go


IF OBJECT_ID('tempdb..#Table1_Laboratories_Sodium_Level_Flag_0', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Sodium_Level_Flag_0
END
;
select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, Convert(varchar(50),OM.MEASUREMENT_TIME) as measurement_time
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME)  DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME)) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_Sodium_Level_Flag_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		-- Dartmouth OMOP  OMOP_CDM.Measurement_time
		and Convert(varchar(50),OM.MEASUREMENT_TIME)between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
		and Convert(varchar(50),OM.MEASUREMENT_TIME) between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	Measurement_Concept_ID IN (3019550, 3000285)
	and OM.VALUE_AS_NUMBER IS NOT NULL
	and OM.VALUE_AS_NUMBER <> ''
;



IF OBJECT_ID('tempdb..#Table1_Laboratories_Sodium_Level_Flag_1', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Sodium_Level_Flag_1
END
;
select distinct
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, AVG(VALUE_AS_NUMBER) AS Sodium_Level_Avg
	, Min(VALUE_AS_NUMBER) AS Sodium_Level_Min
	, Max(VALUE_AS_NUMBER) AS Sodium_Level_Max
	, First_VALUE_AS_NUMBER AS Sodium_Level_First
	, Last_VALUE_AS_NUMBER AS Sodium_Level_Last
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_Unit_Source_Value
into 
	#Table1_Laboratories_Sodium_Level_Flag_1
from 
	#Table1_Laboratories_Sodium_Level_Flag_0
group by
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, First_VALUE_AS_NUMBER
	, Last_VALUE_AS_NUMBER
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_Unit_Source_Value
;


--drop table if exists #Table1_Laboratories_Sodium_Level_Flag--vandy drop code no worky


IF OBJECT_ID('tempdb..#Table1_Laboratories_Sodium_Level_Flag', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Sodium_Level_Flag
END

;
select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, S.Sodium_Level_Avg
	, S.Sodium_Level_Min
	, S.Sodium_Level_Max
	, S.Sodium_Level_First
	, S.Sodium_Level_Last
	, S.Last_MEASUREMENT_SOURCE_VALUE
	, S.Last_Unit_Source_Value
	, case
		when S.Sodium_Level_Avg IS NULL
			then 0
		when S.Sodium_Level_Avg < 136
			then 1
		else 0
	  end as Sodium_Level_Avg_136_Flag
into 
	#Table1_Laboratories_Sodium_Level_Flag
from 
	--AMI.COHORT_BASE_2 as CB2
	COHORT_BASE_2 as CB2
	left join
	#Table1_Laboratories_Sodium_Level_Flag_1 AS S
		on CB2.VISIT_OCCURRENCE_ID = S.VISIT_OCCURRENCE_ID
;

--select  top 1000 * from #Table1_Laboratories_Sodium_Level_Flag;



--------------------------------------------------------------------------------
--Calcium level of < 8.6 mg/dL
--------------------------------------------------------------------------------
--3006906 =	Calcium serum/plasma


--drop table if exists #Table1_Laboratories_Calcium_Level_0

IF OBJECT_ID('tempdb..#Table1_Laboratories_Calcium_Level_0', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Calcium_Level_0
END
  
;
select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, Convert(varchar(50),OM.MEASUREMENT_TIME) as measurement_time
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME)) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_Calcium_Level_0
from 
	COHORT_BASE_2 as CB2
	left join
	--OMOP.Measurement as OM
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and Convert(varchar(50),OM.MEASUREMENT_TIME) between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	OM.Measurement_Concept_ID IN (3006906, 3036426)
	and OM.VALUE_AS_NUMBER IS NOT NULL
	and OM.VALUE_AS_NUMBER <> ''
;


--drop table if exists #Table1_Laboratories_Calcium_Level_1

IF OBJECT_ID('tempdb..#Table1_Laboratories_Calcium_Level_1', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Calcium_Level_1
END
;
select
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, AVG(VALUE_AS_NUMBER) AS Calcium_Level_Avg
	, Min(VALUE_AS_NUMBER) AS Calcium_Level_Min
	, Max(VALUE_AS_NUMBER) AS Calcium_Level_Max
	, First_VALUE_AS_NUMBER AS Calcium_Level_First
	, Last_VALUE_AS_NUMBER AS Calcium_Level_Last
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
into 
	#Table1_Laboratories_Calcium_Level_1
from 
	#Table1_Laboratories_Calcium_Level_0
group by
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, First_VALUE_AS_NUMBER
	, Last_VALUE_AS_NUMBER
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
;


--drop table if exists #Table1_Laboratories_Calcium_Level_Flag

IF OBJECT_ID('tempdb..#Table1_Laboratories_Calcium_Level_Flag', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Calcium_Level_Flag
END


;

select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, C.Calcium_Level_Avg
	, C.Calcium_Level_Min
	, C.Calcium_Level_Max
	, C.Calcium_Level_First
	, C.Calcium_Level_Last
	, C.Last_MEASUREMENT_SOURCE_VALUE
	, C.Last_UNIT_SOURCE_VALUE
	, case
		when C.Calcium_Level_Avg IS NULL
			then 0
		when C.Calcium_Level_Avg < 8.6
			then 1
		else 0
	 end as Calcium_Level_Avg_86_Flag
into 
	#Table1_Laboratories_Calcium_Level_Flag
from 
	COHORT_BASE_2 as CB2
	left join
	#Table1_Laboratories_Calcium_Level_1 AS C
		on CB2.VISIT_OCCURRENCE_ID = C.VISIT_OCCURRENCE_ID
;

--select top 1000 * from #Table1_Laboratories_Calcium_Level_Flag;



--------------------------------------------------------------------------------
--Creatinine
--------------------------------------------------------------------------------
--3051825 = Creatinine [Mass/volume] in Blood: mg/dL
--3016723 = Creatinine serum plasma: mg/dL


--drop table if exists #Table1_Laboratories_Creatinine_Level_0

IF OBJECT_ID('tempdb..#Table1_Laboratories_Creatinine_Level_0', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Creatinine_Level_0
END
;
select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, Convert(varchar(50),Convert(varchar(50),OM.MEASUREMENT_TIME)) measurment_time
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),Convert(varchar(50),OM.MEASUREMENT_TIME)) DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),Convert(varchar(50),OM.MEASUREMENT_TIME)) DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),Convert(varchar(50),OM.MEASUREMENT_TIME))) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),Convert(varchar(50),OM.MEASUREMENT_TIME)) DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_Creatinine_Level_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and Convert(varchar(50),Convert(varchar(50),OM.MEASUREMENT_TIME)) between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	OM.Measurement_Concept_ID IN (3051825, 3016723)
	and OM.VALUE_AS_NUMBER IS NOT NULL
	and OM.VALUE_AS_NUMBER <> ''
	--and OM.UNIT_SOURCE_VALUE = 'mg/dL'
	--and OM.MEASUREMENT_SOURCE_VALUE = 'Creat'
;


--drop table if exists #Table1_Laboratories_Creatinine_Level_1

IF OBJECT_ID('tempdb..#Table1_Laboratories_Creatinine_Level_1', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Creatinine_Level_1
END
;
select distinct
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, AVG(VALUE_AS_NUMBER) AS Creatinine_Level_Avg
	, Min(VALUE_AS_NUMBER) AS Creatinine_Level_Min
	, Max(VALUE_AS_NUMBER) AS Creatinine_Level_Max
	, First_VALUE_AS_NUMBER AS Creatinine_Level_First
	, Last_VALUE_AS_NUMBER AS Creatinine_Level_Last
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
into 
	#Table1_Laboratories_Creatinine_Level_1
from 
	#Table1_Laboratories_Creatinine_Level_0
group by
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, First_VALUE_AS_NUMBER
	, Last_VALUE_AS_NUMBER
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
;


--drop table if exists #Table1_Laboratories_Creatinine_Level

IF OBJECT_ID('tempdb..#Table1_Laboratories_Creatinine_Level', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Creatinine_Level
END
;
select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, C.Creatinine_Level_Avg
	, C.Creatinine_Level_Min
	, C.Creatinine_Level_Max
	, C.Creatinine_Level_First
	, C.Creatinine_Level_Last
	, C.Last_MEASUREMENT_SOURCE_VALUE
	, C.Last_UNIT_SOURCE_VALUE
into 
	#Table1_Laboratories_Creatinine_Level
from 
	COHORT_BASE_2 as CB2
	left join
	#Table1_Laboratories_Creatinine_Level_1 AS C
		on CB2.VISIT_OCCURRENCE_ID = C.VISIT_OCCURRENCE_ID
;

--select  * from #Table1_Laboratories_Creatinine_Level;



--------------------------------------------------------------------------------
--Hemoglobin
--------------------------------------------------------------------------------
--3000963 =	Hemoglobin (Hgb)


--drop table if exists #Table1_Laboratories_Hemoglobin_Level_0


IF OBJECT_ID('tempdb..#Table1_Laboratories_Hemoglobin_Level_0', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Hemoglobin_Level_0
END
;
select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, Convert(varchar(50),OM.MEASUREMENT_TIME) MEASUREMENT_TIME
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME)) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_Hemoglobin_Level_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and Convert(varchar(50),OM.MEASUREMENT_TIME) between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	OM.Measurement_Concept_ID = 3000963
	and OM.VALUE_AS_NUMBER IS NOT NULL
	and OM.VALUE_AS_NUMBER <> ''
	--and OM.UNIT_SOURCE_VALUE = 'g/dL'
	--and OM.MEASUREMENT_SOURCE_VALUE = 'Hgb'
;


--drop table if exists #Table1_Laboratories_Hemoglobin_Level_1

IF OBJECT_ID('tempdb..#Table1_Laboratories_Hemoglobin_Level_1', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Hemoglobin_Level_1
END
;
select
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, AVG(VALUE_AS_NUMBER) AS Hemoglobin_Level_Avg
	, Min(VALUE_AS_NUMBER) AS Hemoglobin_Level_Min
	, Max(VALUE_AS_NUMBER) AS Hemoglobin_Level_Max
	, First_VALUE_AS_NUMBER AS Hemoglobin_Level_First
	, Last_VALUE_AS_NUMBER AS Hemoglobin_Level_Last
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
into 
	#Table1_Laboratories_Hemoglobin_Level_1
from 
	#Table1_Laboratories_Hemoglobin_Level_0
group by
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, First_VALUE_AS_NUMBER
	, Last_VALUE_AS_NUMBER
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
;


--drop table if exists #Table1_Laboratories_Hemoglobin_Level

IF OBJECT_ID('tempdb..#Table1_Laboratories_Hemoglobin_Level', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_Hemoglobin_Level
END
;
select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, H.Hemoglobin_Level_Avg
	, H.Hemoglobin_Level_Min
	, H.Hemoglobin_Level_Max
	, H.Hemoglobin_Level_First
	, H.Hemoglobin_Level_Last
	, H.Last_MEASUREMENT_SOURCE_VALUE
	, H.Last_UNIT_SOURCE_VALUE
into 
	#Table1_Laboratories_Hemoglobin_Level
from 
	COHORT_BASE_2 as CB2
	left join
	#Table1_Laboratories_Hemoglobin_Level_1 AS H
		on CB2.VISIT_OCCURRENCE_ID = H.VISIT_OCCURRENCE_ID
;

select top 1000 * from #Table1_Laboratories_Hemoglobin_Level;



--------------------------------------------------------------------------------
--Peak creatine kinase/troponin
--------------------------------------------------------------------------------
--3030170	Creatine kinase [Mass/volume] in Blood
--here at 12:52

--


/*
recoded 4/14/2020 but DHMC returns 0 cases ?? why?

*/



--drop table if exists #Table1_Laboratories_CK_Level_0
IF OBJECT_ID('tempdb..#Table1_Laboratories_CK_Level_0', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_CK_Level_0
END

;
select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, Convert(varchar(50),OM.MEASUREMENT_TIME) measurement_time
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME)) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_CK_Level_0
from 
	--AMI.COHORT_BASE_2 as CB2
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and Convert(varchar(50),OM.MEASUREMENT_TIME) between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	--8/31/2020--OM.Measurement_Concept_ID = 3005785
        OM.Measurement_Concept_ID in ( 3005785, 3007220)
	and OM.VALUE_AS_NUMBER IS NOT NULL
	and OM.VALUE_AS_NUMBER <> ''
	--and M.UNIT_SOURCE_VALUE = 'ng/mL'
	--and M.MEASUREMENT_SOURCE_VALUE = 'CKMBRe'
;


--drop table if exists #Table1_Laboratories_CK_Level_1

IF OBJECT_ID('tempdb..#Table1_Laboratories_CK_Level_1', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_CK_Level_1
END
;
select
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, AVG(VALUE_AS_NUMBER) AS CK_Level_Avg
	, Min(VALUE_AS_NUMBER) AS CK_Level_Min
	, Max(VALUE_AS_NUMBER) AS CK_Level_Max
	, First_VALUE_AS_NUMBER AS CK_Level_First
	, Last_VALUE_AS_NUMBER AS CK_Level_Last
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
into 
	#Table1_Laboratories_CK_Level_1
from 
	#Table1_Laboratories_CK_Level_0
group by
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, First_VALUE_AS_NUMBER
	, Last_VALUE_AS_NUMBER
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
;


--drop table if exists #Table1_Laboratories_CK_Level

IF OBJECT_ID('tempdb..#Table1_Laboratories_CK_Level', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_CK_Level
END
;
select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CK.CK_Level_Avg
	, CK.CK_Level_Min
	, CK.CK_Level_Max
	, CK.CK_Level_First
	, CK.CK_Level_Last
	, CK.Last_MEASUREMENT_SOURCE_VALUE
	, CK.Last_UNIT_SOURCE_VALUE
into 
	#Table1_Laboratories_CK_Level
from 
	COHORT_BASE_2 as CB2
	left join
	#Table1_Laboratories_CK_Level_1 AS CK
		on CB2.VISIT_OCCURRENCE_ID = CK.VISIT_OCCURRENCE_ID
;

select top 1000 * from #Table1_Laboratories_CK_Level;



--------------------------------------------------------------------------------
--Brain natriuretic peptide (BNP)
--------------------------------------------------------------------------------
--CONCEPT_ID	CONCEPT_NAME
--3031569		Natriuretic peptide B [Mass/volume] in Blood
--3011960		Natriuretic peptide B [Mass/volume] in Serum or Plasma

/*

similar to CPK Dartmouth returns 0 for BNP

*/

--drop table if exists #Table1_Laboratories_BNP_Level_0



IF OBJECT_ID('tempdb..#Table1_Laboratories_BNP_Level_0', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_BNP_Level_0
END
;
select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, Convert(varchar(50),OM.MEASUREMENT_TIME) MEASUREMENT_TIME
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME)) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY Convert(varchar(50),OM.MEASUREMENT_TIME) DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_BNP_Level_0
from 
	--AMI.COHORT_BASE_2 as CB2
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and Convert(varchar(50),OM.MEASUREMENT_TIME) between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	--8/31/2020 OM.Measurement_Concept_ID IN (3011960)
OM.Measurement_Concept_ID IN (3011960,3029187)
	and OM.VALUE_AS_NUMBER IS NOT NULL
	and OM.VALUE_AS_NUMBER <> ''
	--and M.UNIT_SOURCE_VALUE = 'pg/mL'
	--and M.MEASUREMENT_SOURCE_VALUE = 'BNP'
;


--drop table if exists #Table1_Laboratories_BNP_Level_1

IF OBJECT_ID('tempdb..#Table1_Laboratories_BNP_Level_1', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_BNP_Level_1
END
;
select
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, AVG(VALUE_AS_NUMBER) AS BNP_Level_Avg
	, Min(VALUE_AS_NUMBER) AS BNP_Level_Min
	, Max(VALUE_AS_NUMBER) AS BNP_Level_Max
	, First_VALUE_AS_NUMBER AS BNP_Level_First
	, Last_VALUE_AS_NUMBER AS BNP_Level_Last
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
into 
	#Table1_Laboratories_BNP_Level_1
from 
	#Table1_Laboratories_BNP_Level_0
group by
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, First_VALUE_AS_NUMBER
	, Last_VALUE_AS_NUMBER
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
;


--drop table if exists #Table1_Laboratories_BNP_Level

IF OBJECT_ID('tempdb..#Table1_Laboratories_BNP_Level', 'U') IS NOT NULL 
BEGIN
  DROP TABLE #Table1_Laboratories_BNP_Level
END

;
select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, BNP.BNP_Level_Avg
	, BNP.BNP_Level_Min
	, BNP.BNP_Level_Max
	, BNP.BNP_Level_First
	, BNP.BNP_Level_Last
	, BNP.Last_MEASUREMENT_SOURCE_VALUE
	, BNP.Last_UNIT_SOURCE_VALUE
into 
	#Table1_Laboratories_BNP_Level
from 
	COHORT_BASE_2 as CB2
	left join
	#Table1_Laboratories_BNP_Level_1 AS BNP
		on CB2.VISIT_OCCURRENCE_ID = BNP.VISIT_OCCURRENCE_ID
;

select top 1000 * from #Table1_Laboratories_BNP_Level;



-------------------------------------------------------------------
--Join the temp tables
-------------------------------------------------------------------

--drop table if exists Table1_Laboratories

IF OBJECT_ID('Table1_Laboratories', 'U') IS NOT NULL 
BEGIN
  DROP TABLE Table1_Laboratories
END
;
select
	  S.PERSON_ID
	, S.VISIT_OCCURRENCE_ID
	, S.Sodium_Level_Avg
	, S.Sodium_Level_Min
	, S.Sodium_Level_Max
	, S.Sodium_Level_First
	, S.Sodium_Level_Last
	, S.Sodium_Level_Avg_136_Flag
	, C.Calcium_Level_Avg
	, C.Calcium_Level_Min
	, C.Calcium_Level_Max
	, C.Calcium_Level_First
	, C.Calcium_Level_Last
	, C.Calcium_Level_Avg_86_Flag
	, CR.Creatinine_Level_Avg
	, CR.Creatinine_Level_Min
	, CR.Creatinine_Level_Max
	, CR.Creatinine_Level_First
	, CR.Creatinine_Level_Last
	, H.Hemoglobin_Level_Avg
	, H.Hemoglobin_Level_Min
	, H.Hemoglobin_Level_Max
	, H.Hemoglobin_Level_First
	, H.Hemoglobin_Level_Last
	, CK.CK_Level_Avg
	, CK.CK_Level_Min
	, CK.CK_Level_Max
	, CK.CK_Level_First
	, CK.CK_Level_Last
	, BNP.BNP_Level_Avg
	, BNP.BNP_Level_Min
	, BNP.BNP_Level_Max
	, BNP.BNP_Level_First
	, BNP.BNP_Level_Last
into 
	Table1_Laboratories
from 
	#Table1_Laboratories_Sodium_Level_Flag AS S
	left join
	#Table1_Laboratories_Calcium_Level_Flag AS C
		on S.VISIT_OCCURRENCE_ID = C.VISIT_OCCURRENCE_ID
	left join
	#Table1_Laboratories_Creatinine_Level AS CR
		on C.VISIT_OCCURRENCE_ID = CR.VISIT_OCCURRENCE_ID
	left join 
	#Table1_Laboratories_Hemoglobin_Level AS H
		on CR.VISIT_OCCURRENCE_ID = H.VISIT_OCCURRENCE_ID
	left join 
	#Table1_Laboratories_CK_Level AS CK
		on H.VISIT_OCCURRENCE_ID = CK.VISIT_OCCURRENCE_ID
	left join
	#Table1_Laboratories_BNP_Level AS BNP
		on CK.VISIT_OCCURRENCE_ID = BNP.VISIT_OCCURRENCE_ID
;



--END-------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
select count(distinct person_id) from Table1_Laboratories;

select count(distinct VISIT_OCCURRENCE_ID) from Table1_Laboratories;