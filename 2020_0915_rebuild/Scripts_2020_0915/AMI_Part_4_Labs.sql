-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
/*
PART 4: Add values to table Laboratories for elements from Table 1.
Elements include the following:
Sodium level of <136 mEg/L
Calcium level of < 8.6 mg/dL
CKMB
Serum markers hematocrit or hemoglobin
Blood urea nitrogen or creatinine
Brain Natriuretic Peptide (BNP)
*/
-----------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--Sodium level of < 136 mEq/L
--------------------------------------------------------------------------------
--3019550 =	Sodium serum/plasma

--USE AMI
USE OMOP_CDM --10/12/2020
GO
-- simple solution is to just comment out all drop table if exists lines

---drop table if exists#Table1_Laboratories_Sodium_Level_Flag_0
;

select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, OM.MEASUREMENT_DATETIME
	--, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, OM.VALUE_AS_NUMBER as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_Sodium_Level_Flag_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and OM.MEASUREMENT_DATETIME between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	OM.Measurement_Concept_ID IN (3019550, 3000285)
	and OM.VALUE_AS_NUMBER IS NOT NULL
;


---drop table if exists#Table1_Laboratories_Sodium_Level_Flag_1
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


---drop table if exists#Table1_Laboratories_Sodium_Level_Flag
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


---drop table if exists#Table1_Laboratories_Calcium_Level_0
;

select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, OM.MEASUREMENT_DATETIME
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_Calcium_Level_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and OM.MEASUREMENT_DATETIME between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	OM.Measurement_Concept_ID IN (3006906, 3036426)
	and OM.VALUE_AS_NUMBER IS NOT NULL
;


---drop table if exists#Table1_Laboratories_Calcium_Level_1
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


---drop table if exists#Table1_Laboratories_Calcium_Level_Flag
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


---drop table if exists#Table1_Laboratories_Creatinine_Level_0
;

select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, OM.MEASUREMENT_DATETIME
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_Creatinine_Level_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and OM.MEASUREMENT_DATETIME between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	OM.Measurement_Concept_ID IN (3051825, 3016723, 3032033, 3007760)
	and OM.VALUE_AS_NUMBER IS NOT NULL
	--and OM.UNIT_SOURCE_VALUE = 'mg/dL'
	--and OM.MEASUREMENT_SOURCE_VALUE = 'Creat'
;


---drop table if exists#Table1_Laboratories_Creatinine_Level_1
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


---drop table if exists#Table1_Laboratories_Creatinine_Level
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

--select top 1000 * from #Table1_Laboratories_Creatinine_Level;



--------------------------------------------------------------------------------
--Hemoglobin
--------------------------------------------------------------------------------
--3000963 =	Hemoglobin (Hgb)


---drop table if exists#Table1_Laboratories_Hemoglobin_Level_0
;

select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, OM.MEASUREMENT_DATETIME
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_Hemoglobin_Level_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and OM.MEASUREMENT_DATETIME between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	OM.Measurement_Concept_ID = 3000963
	and OM.VALUE_AS_NUMBER IS NOT NULL
	--and OM.UNIT_SOURCE_VALUE = 'g/dL'
	--and OM.MEASUREMENT_SOURCE_VALUE = 'Hgb'
;


---drop table if exists#Table1_Laboratories_Hemoglobin_Level_1
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


---drop table if exists#Table1_Laboratories_Hemoglobin_Level
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

--select top 1000 * from #Table1_Laboratories_Hemoglobin_Level;



--------------------------------------------------------------------------------
--Peak creatine kinase/troponin
--------------------------------------------------------------------------------
--3005785	Creatine kinase.MB [Mass/volume] in Serum or Plasma

--Revised 2020_0903
--3029790	Creatine kinase.MB [Enzymatic activity/volume] in Serum or Plasma
--3016070	Creatine kinase.MB [Enzymatic activity/volume] in Serum or Plasma by Electrophoresis
--3033236	Creatine kinase.MB [Mass/volume] in Blood
--3005785	Creatine kinase.MB [Mass/volume] in Serum or Plasma
--42529209	Creatine kinase.MB [Mass/volume] in Serum or Plasma by Immunoassay
--3048150	Creatine kinase.MB [Presence] in Serum or Plasma
--3005785	Creatine kinase.MB [Mass/volume] in Serum or Plasma


---drop table if exists#Table1_Laboratories_CK_Level_0
;

select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, OM.MEASUREMENT_DATETIME
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_VALUE_AS_NUMBER
into 
	#Table1_Laboratories_CK_Level_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and OM.MEASUREMENT_DATETIME between CB2.ADMIT_DATE and CB2.DISCHARGE_DATE
where 
	OM.Measurement_Concept_ID IN
		(
			3029790	
			,3016070	
			,3033236	
			,3005785	
			,42529209	
			,3048150	
			,3005785	
		)
	and OM.VALUE_AS_NUMBER IS NOT NULL
	--and M.UNIT_SOURCE_VALUE = 'ng/mL'
	--and M.MEASUREMENT_SOURCE_VALUE = 'CKMBRe'
;


---drop table if exists#Table1_Laboratories_CK_Level_1
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


---drop table if exists#Table1_Laboratories_CK_Level
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

--select top 1000 * from #Table1_Laboratories_CK_Level;



--------------------------------------------------------------------------------
--Brain natriuretic peptide (BNP)
--------------------------------------------------------------------------------
--CONCEPT_ID	CONCEPT_NAME
--3031569		Natriuretic peptide B [Mass/volume] in Blood
--3011960		Natriuretic peptide B [Mass/volume] in Serum or Plasma

--Refined 2020_0903
--3031569	Natriuretic peptide B [Mass/volume] in Blood
--3011960	Natriuretic peptide B [Mass/volume] in Serum or Plasma
--3052295	Natriuretic peptide B [Moles/volume] in Serum or Plasma
--42870364	Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Blood by Immunoassay
--3029187	Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Serum or Plasma
--42529224	Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Serum or Plasma by Immunoassay
--3029435	Natriuretic peptide.B prohormone N-Terminal [Moles/volume] in Serum or Plasma
--42529225	Natriuretic peptide.B prohormone N-Terminal [Moles/volume] in Serum or Plasma by Immunoassay



---drop table if exists#Table1_Laboratories_BNP_Level_0
;

select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, OM.MEASUREMENT_DATETIME
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_DATETIME) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_Measurement_Datetime
into 
	#Table1_Laboratories_BNP_Level_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		--and datediff(dd, OM.MEASUREMENT_DATETIME, CB2.ADMIT_DATE) between 0 and 365
		and	OM.MEASUREMENT_DATE between dateadd(dd, -365, CB2.ADMIT_DATE) and CB2.ADMIT_DATE
where 
	OM.Measurement_Concept_ID IN 
		(
			3031569
			,3011960
			,3052295

		----- was commented out
			
			,42870364
			,3029187
			,42529224
			,3029435
			,42529225
		)
	and OM.VALUE_AS_NUMBER IS NOT NULL
	--and M.UNIT_SOURCE_VALUE = 'pg/mL'
	--and M.MEASUREMENT_SOURCE_VALUE = 'BNP'
;
--select count(*), count(Last_VALUE_AS_NUMBER) from #Table1_Laboratories_BNP_Level_0

---drop table if exists#Table1_Laboratories_BNP_Level_1
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
	, Last_Measurement_Datetime
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
	, Last_Measurement_Datetime
;


---drop table if exists#Table1_Laboratories_BNP_Level
;

select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.Index_Admission_Flag
	, BNP.BNP_Level_Avg
	, BNP.BNP_Level_Min
	, BNP.BNP_Level_Max
	, BNP.BNP_Level_First
	, BNP.BNP_Level_Last
	, BNP.Last_MEASUREMENT_SOURCE_VALUE
	, BNP.Last_UNIT_SOURCE_VALUE
	, BNP.Last_Measurement_Datetime as BNP_Last_Date
into 
	#Table1_Laboratories_BNP_Level
from 
	COHORT_BASE_2 as CB2
	left join
	#Table1_Laboratories_BNP_Level_1 AS BNP
		on CB2.VISIT_OCCURRENCE_ID = BNP.VISIT_OCCURRENCE_ID
;

--select count(*), count(BNP_Level_Last) from #Table1_Laboratories_BNP_Level where Index_Admission_Flag = 1
--9238	4107



--------------------------------------------------------------------------------
--prohormone Brain natriuretic peptide (Pro_BNP)
--------------------------------------------------------------------------------
--CONCEPT_ID	CONCEPT_NAME
--3031569		Natriuretic peptide B [Mass/volume] in Blood
--3011960		Natriuretic peptide B [Mass/volume] in Serum or Plasma

--Refined 2020_0903
--3031569	Natriuretic peptide B [Mass/volume] in Blood
--3011960	Natriuretic peptide B [Mass/volume] in Serum or Plasma
--3052295	Natriuretic peptide B [Moles/volume] in Serum or Plasma
--42870364	Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Blood by Immunoassay
--3029187	Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Serum or Plasma
--42529224	Natriuretic peptide.B prohormone N-Terminal [Mass/volume] in Serum or Plasma by Immunoassay
--3029435	Natriuretic peptide.B prohormone N-Terminal [Moles/volume] in Serum or Plasma
--42529225	Natriuretic peptide.B prohormone N-Terminal [Moles/volume] in Serum or Plasma by Immunoassay



---drop table if exists#Table1_Laboratories_ProBNP_Level_0
;

select distinct
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, OM.MEASUREMENT_DATETIME
	, CAST(OM.VALUE_AS_NUMBER AS Float) as VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_MEASUREMENT_SOURCE_VALUE
	, FIRST_VALUE(OM.UNIT_SOURCE_VALUE) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_Unit_Source_Value
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME) AS First_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.VALUE_AS_NUMBER) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_VALUE_AS_NUMBER
	, FIRST_VALUE(OM.MEASUREMENT_DATETIME) OVER(PARTITION BY CB2.VISIT_OCCURRENCE_ID ORDER BY OM.MEASUREMENT_DATETIME DESC) AS Last_Measurement_Datetime
into 
	#Table1_Laboratories_ProBNP_Level_0
from 
	COHORT_BASE_2 as CB2
	left join
	Measurement as OM
		on CB2.PERSON_ID = OM.PERSON_ID
		and datediff(dd, OM.MEASUREMENT_DATETIME, CB2.ADMIT_DATE) between 0 and 365
where 
	OM.Measurement_Concept_ID IN 
		(
			3031569
			,3011960
			,3052295


			,42870364
			,3029187
			,42529224
			,3029435
			,42529225
		)
	and OM.VALUE_AS_NUMBER IS NOT NULL
	--and M.UNIT_SOURCE_VALUE = 'pg/mL'
	--and M.MEASUREMENT_SOURCE_VALUE = 'BNP'
;


---drop table if exists#Table1_Laboratories_ProBNP_Level_1
;

select
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, AVG(VALUE_AS_NUMBER) AS ProBNP_Level_Avg
	, Min(VALUE_AS_NUMBER) AS ProBNP_Level_Min
	, Max(VALUE_AS_NUMBER) AS ProBNP_Level_Max
	, First_VALUE_AS_NUMBER AS ProBNP_Level_First
	, Last_VALUE_AS_NUMBER AS ProBNP_Level_Last
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
	, Last_Measurement_Datetime
into 
	#Table1_Laboratories_ProBNP_Level_1
from 
	#Table1_Laboratories_ProBNP_Level_0
group by
	  PERSON_ID
	, VISIT_OCCURRENCE_ID
	, First_VALUE_AS_NUMBER
	, Last_VALUE_AS_NUMBER
	, Last_MEASUREMENT_SOURCE_VALUE
	, Last_UNIT_SOURCE_VALUE
	, Last_Measurement_Datetime
;


---drop table if exists#Table1_Laboratories_ProBNP_Level
;
select 
	  CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, ProBNP.ProBNP_Level_Avg
	, ProBNP.ProBNP_Level_Min
	, ProBNP.ProBNP_Level_Max
	, ProBNP.ProBNP_Level_First
	, ProBNP.ProBNP_Level_Last
	, ProBNP.Last_MEASUREMENT_SOURCE_VALUE
	, ProBNP.Last_UNIT_SOURCE_VALUE
	, ProBNP.Last_Measurement_Datetime as ProBNP_Last_Date
into 
	#Table1_Laboratories_ProBNP_Level
from 
	COHORT_BASE_2 as CB2
	left join
	#Table1_Laboratories_ProBNP_Level_1 AS ProBNP
		on CB2.VISIT_OCCURRENCE_ID = ProBNP.VISIT_OCCURRENCE_ID
;


--select * from #Table1_Laboratories_BNP_Level order by person_id
--select count(*) from COHORT_BASE_2	--9817

--select min(ADMIT_DATE), max(ADMIT_DATE) from COHORT_BASE_2 as c
--(No column name)	(No column name)
--2007-01-23	2018-11-14

--select min(DISCHARGE_DATE), max(DISCHARGE_DATE) from COHORT_BASE_2 as c where DISCHARGE_DATE is not null and DISCHARGE_DATE <> ''
--2007-01-26	2018-11-16













-------------------------------------------------------------------
--Join the temp tables
-------------------------------------------------------------------

---drop table if existsAMI.Table1_Laboratories

if exists (select * from sys.objects where name = 'Table1_Laboratories' and type = 'u')
    drop table Table1_Laboratories
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
	, BNP.BNP_Last_Date

	, ProBNP.ProBNP_Level_Avg
	, ProBNP.ProBNP_Level_Min
	, ProBNP.ProBNP_Level_Max
	, ProBNP.ProBNP_Level_First
	, ProBNP.ProBNP_Level_Last
	, ProBNP.ProBNP_Last_Date
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
	left join
	#Table1_Laboratories_ProBNP_Level AS ProBNP
		on CK.VISIT_OCCURRENCE_ID = ProBNP.VISIT_OCCURRENCE_ID
;

--select L.ProBNP_Level_Last
--from Table1_Laboratories as L
--order by L.ProBNP_Level_Last desc

--END-------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--select count(distinct person_id) from Table1_Laboratories;

--select count(distinct VISIT_OCCURRENCE_ID) from Table1_Laboratories;

--select count(*), count(L.BNP_Level_Last), count(L.BNP_Last_Date)
--from Table1_Laboratories as L