--AMI Readmissions Project: AKI Stage Variables
USE AMI
GO

--Part 1----------------------------------------------------------------------------
--Get min and max dates from detail data to assign date range for creatinine values that need to be obtained.


drop table if exists #AKI_Pat_Visit_Min;

select 
	 CB2.PERSON_ID
	,Min(CB2.ADMIT_DATE) as Min_Admit_Date
	,Max(CB2.DISCHARGE_DATE) as Max_Disch_Date
into 
	#AKI_Pat_Visit_Min
from 
	AMI.COHORT_BASE_2 as CB2
group by 
	CB2.PERSON_ID
;


--Build set of applicable creatinine values--
--Creatine values up to 730 days before first admission may be needed (for calculation of baseline creatinine values).

--CONCEPT_ID	CONCEPT_NAME											DOMAIN_ID	VOCABULARY_ID	CONCEPT_CLASS_ID	STANDARD_CONCEPT	CONCEPT_CODE
--3051825		Creatinine [Mass/volume] in Blood						Measurement	LOINC			Lab Test			S					38483-4
--3016723		Creatinine serum/plasma									Measurement	LOINC			Lab Test			S					2160-0
--3032033		Creatinine [Mass or Moles/volume] in Serum or Plasma	Measurement	LOINC			Lab Test								35203-9
--3007760		Creatinine [Mass/volume] in Arterial blood				Measurement	LOINC			Lab Test			S					21232-4


drop table if exists #AKI_Creatinine_Labs;

select 
	M.*
into 
	#AKI_Creatinine_Labs
from
	#AKI_Pat_Visit_Min as V
	left join OMOP.MEASUREMENT as M
		on V.PERSON_ID = M.PERSON_ID
where
	M.MEASUREMENT_CONCEPT_ID IN (3051825, 3016723, 3032033, 3007760) --LOINC = '38483-4', '2160-0'
	and M.MEASUREMENT_DATE between dateadd(dd, -730, V.Min_Admit_Date) and dateadd(dd, 1, V.Max_Disch_Date)
	and M.VALUE_AS_NUMBER between 0.3 and 20 --Exclude creatinine values that fall outside of normal range
;


drop table if exists #AKI_Creatinine_Labs_2;

select 
	 L.*
	,VO.VISIT_OCCURRENCE_ID as VO_Visit_Occurrence_ID
	,VO.VISIT_CONCEPT_ID as VO_VISIT_CONCEPT_ID
	,VO.VISIT_TYPE_CONCEPT_ID as VO_VISIT_TYPE_CONCEPT_ID
	,VO.VISIT_SOURCE_CONCEPT_ID as VO_VISIT_SOURCE_CONCEPT_ID
into 
	#AKI_Creatinine_Labs_2
from 
	#AKI_Creatinine_Labs AS L
	left join
	OMOP.VISIT_OCCURRENCE as VO
		on L.Person_ID = VO.Person_ID
		and L.MEASUREMENT_DATETIME between VO.VISIT_START_DATETIME and VO.VISIT_END_DATETIME
;



--Part 3-------------------------------------------------------------------------------------
--Get Baseline Creatinine Values-------------------------------------------------------------

--3a
--Methodology Number 1 for baseline creatinine takes priority if a value can be found using this methodology
--Baseline_1 (Creatinine AVG 7-365 days before admission for outpatient visits)


drop table if exists #AKI_Baseline_Creatinine_AVG;

select 
	 CB2.VISIT_OCCURRENCE_ID
	,AVG(L.VALUE_AS_NUMBER) as Creatinine_AVG
into 
	#AKI_Baseline_Creatinine_AVG
from	
	AMI.COHORT_BASE_2 as CB2
	left join #AKI_Creatinine_Labs_2 as L
		on CB2.PERSON_ID = L.PERSON_ID
where 
	L.VO_VISIT_CONCEPT_ID = 9202 --Outpatient
	and datediff(dd, L.MEASUREMENT_DATE, CB2.ADMIT_DATE) between 7 and 365
group by
	CB2.VISIT_OCCURRENCE_ID
;


--3b
--Methodology Number 2 for baseline creatinine takes next priority if a value can be found using this methodology
--Baseline_2 (Last creatinine value 7-730 days before admission for IP or OP visits).

drop table if exists #AKI_Baseline_Creatinine_Last;

select 
	 CB2.VISIT_OCCURRENCE_ID
	,L.MEASUREMENT_DATE
	,L.VALUE_AS_NUMBER
into 
	#AKI_Baseline_Creatinine_Last
from	
	AMI.COHORT_BASE_2 as CB2
	left join #AKI_Creatinine_Labs_2 as L
		on CB2.PERSON_ID = L.PERSON_ID
where  
	L.VO_VISIT_CONCEPT_ID IN (9201, 9202) --Outpatient = 9202, Inpatient = 9201
	and datediff(dd, L.MEASUREMENT_DATE, CB2.ADMIT_DATE) between 7 and 365
;
--143528 on 9/22


--Get last creatinine value only
drop table if exists #AKI_Baseline_Creatinine_Last_2;

select
	  *
into #AKI_Baseline_Creatinine_Last_2
from
(
       select *, ROW_NUMBER() OVER(PARTITION BY VISIT_OCCURRENCE_ID ORDER BY MEASUREMENT_DATE DESC) as RowNum
       from #AKI_Baseline_Creatinine_Last as L
) as OrderedSet
where RowNum = 1
;


--3c
--Baseline_3 (Creatinine minimum value 6 days before admit up to a day after discharge date).

drop table if exists #AKI_Baseline_Creatinine_MIN;

select 
	 CB2.VISIT_OCCURRENCE_ID
	,MIN(L.VALUE_AS_NUMBER) as Creatinine_MIN
into 
	#AKI_Baseline_Creatinine_MIN
from	
	AMI.COHORT_BASE_2 as CB2
	left join #AKI_Creatinine_Labs_2 as L
		on CB2.PERSON_ID = L.PERSON_ID
where  
	L.VO_VISIT_CONCEPT_ID IN (9201, 9202, 9203) --Outpatient = 9202, Inpatient = 9201, ER Visit = 9203
	and datediff(dd, L.MEASUREMENT_DATE, CB2.ADMIT_DATE) between -1 and 6
group by 
	CB2.VISIT_OCCURRENCE_ID
;


--3d
--Combine baseline creatinine values with encounter detail data
--Will use the first baseline creatinine available as the final baseline creatinine


drop table if exists #AKI_Baseline_Creatinine_All;

Select
	CB2.*
	,B1.Creatinine_AVG as Baseline_Creatinine_1
	,B2.Value_as_Number as Baseline_Creatinine_2
	,B3.Creatinine_MIN as Baseline_Creatinine_3
into
	#AKI_Baseline_Creatinine_All
From
	AMI.COHORT_BASE_2 as CB2
	left join #AKI_Baseline_Creatinine_AVG as B1
		on CB2.VISIT_OCCURRENCE_ID = B1.VISIT_OCCURRENCE_ID
	left join #AKI_Baseline_Creatinine_Last_2 as B2
		on CB2.VISIT_OCCURRENCE_ID = B2.VISIT_OCCURRENCE_ID
	left join #AKI_Baseline_Creatinine_MIN as B3
		on CB2.VISIT_OCCURRENCE_ID = B3.VISIT_OCCURRENCE_ID
;


--3e
--Use the first in priority order baseline creatinine available as the final baseline creatinine
drop table if exists #AKI_Baseline_Creatinine_Final;

Select
	*
	,case  
		when Baseline_Creatinine_1 IS NOT NULL then Baseline_Creatinine_1
		when Baseline_Creatinine_2 IS NOT NULL then Baseline_Creatinine_2
		when Baseline_Creatinine_3 IS NOT NULL then Baseline_Creatinine_3
		else null
	 end as Baseline_Creatinine_Final
into
	#AKI_Baseline_Creatinine_Final
From
	#AKI_Baseline_Creatinine_All
;


--Part 4---------------------------------------------------------------------------------
--Get anchor creatinine values from during the admission to compare with baseline value.
--Anchor creatinine values include all of the creatinine values during an admission.
--Also include creatinine values a day before and day after admission.

drop table if exists #AKI_Creatinine_Labs_Anchor;

select distinct
	  CB2.*
	 ,L.VALUE_AS_NUMBER as Anchor_Creatinine
	 ,L.MEASUREMENT_DATE as Anchor_Result_Date
	 ,L.MEASUREMENT_DATETIME
	 ,B.BASELINE_CREATININE_FINAL
into 
	#AKI_Creatinine_Labs_Anchor
from	
	AMI.COHORT_BASE_2 as CB2
	left join #AKI_Creatinine_Labs_2 as L
		on CB2.VISIT_OCCURRENCE_ID = L.VO_VISIT_OCCURRENCE_ID
	left join #AKI_Baseline_Creatinine_Final as B
		on CB2.VISIT_OCCURRENCE_ID = B.VISIT_OCCURRENCE_ID
;
--select * from AMI.COHORT_BASE_2


--Part 5---------------------------------------------------------------------------------
--Identify AKI stage related to IP creatinine measurements as compared to baseline.

--5a
--Add eGFR values to identify exclusions based on eGFR value.
drop table if exists #AKI_Creatinine_Labs_Anchor_eGFR;

select
	*
	 ,( --calculate eGFR using MDRD methodology
			175
			* 
			(
				CASE 
					WHEN (Baseline_Creatinine_Final IS NOT NULL and Baseline_Creatinine_Final > 0) 
						THEN
						power(Baseline_Creatinine_Final,-1.154)
						ELSE 0
				END
			)
			* 
			(
				CASE 
					WHEN (Age_at_Admit IS NOT NULL and Age_at_Admit > 0)
						THEN
						power(cast(Age_at_Admit as real),-0.203) 
						ELSE 0
				END
			)
			* 
			(
				CASE 
					WHEN Gender = 'FEMALE' THEN 0.742 
					ELSE 1.000 
				END 
			)
			* 
			(
				CASE 
					WHEN Race = 'BLACK' THEN 1.212 --African American
					ELSE 1.000 
				END
			)
		)
	  AS Baseline_eGFR_MDRD
	 ,CASE --calculate eGFR using CKD-EPI methodology
		WHEN 
			(Baseline_Creatinine_Final IS NOT NULL and Baseline_Creatinine_Final > 0)
			and (Age_at_Admit IS NOT NULL and Age_at_Admit > 0)
			and RACE = 'BLACK' 
			and Gender = 'FEMALE'
			and Baseline_Creatinine_Final <=0.7
			THEN 166*power((Baseline_Creatinine_Final/0.7), -0.329)*power((0.993), cast(Age_at_Admit as real))
		WHEN 
			(Baseline_Creatinine_Final IS NOT NULL and Baseline_Creatinine_Final > 0)
			and (Age_at_Admit IS NOT NULL and Age_at_Admit > 0)
			and RACE = 'BLACK' 
			and Gender = 'FEMALE'
			and Baseline_Creatinine_Final > 0.7
			THEN 166*power((Baseline_Creatinine_Final/0.7), -1.209)*power((0.993), cast(Age_at_Admit as real))
		WHEN 
			(Baseline_Creatinine_Final IS NOT NULL and Baseline_Creatinine_Final > 0)
			and (Age_at_Admit IS NOT NULL and Age_at_Admit > 0)
			and RACE = 'BLACK' 
			and Gender <> 'FEMALE'
			and Baseline_Creatinine_Final <= 0.9
			THEN 163*power((Baseline_Creatinine_Final/0.9), -0.411)*power((0.993), cast(Age_at_Admit as real))
		WHEN 
			(Baseline_Creatinine_Final IS NOT NULL and Baseline_Creatinine_Final > 0)
			and (Age_at_Admit IS NOT NULL and Age_at_Admit > 0)
			and RACE = 'BLACK' 
			and Gender <> 'FEMALE'
			and Baseline_Creatinine_Final > 0.9
			THEN 163*power((Baseline_Creatinine_Final/0.9), -1.209)*power((0.993), cast(Age_at_Admit as real))
		WHEN 
			(Baseline_Creatinine_Final IS NOT NULL and Baseline_Creatinine_Final > 0)
			and (Age_at_Admit IS NOT NULL and Age_at_Admit > 0)
			and RACE <> 'BLACK' 
			and Gender = 'FEMALE'
			and Baseline_Creatinine_Final <=0.7
			THEN 144*power((Baseline_Creatinine_Final/0.7), -0.329)*power((0.993), cast(Age_at_Admit as real))
		WHEN 
			(Baseline_Creatinine_Final IS NOT NULL and Baseline_Creatinine_Final > 0)
			and (Age_at_Admit IS NOT NULL and Age_at_Admit > 0)
			and RACE <> 'BLACK' 
			and Gender = 'FEMALE'
			and Baseline_Creatinine_Final > 0.7
			THEN 144*power((Baseline_Creatinine_Final/0.7), -1.209)*power((0.993), cast(Age_at_Admit as real))
		WHEN 
			(Baseline_Creatinine_Final IS NOT NULL and Baseline_Creatinine_Final > 0)
			and (Age_at_Admit IS NOT NULL and Age_at_Admit > 0)
			and RACE <> 'BLACK' 
			and Gender <> 'FEMALE'
			and Baseline_Creatinine_Final <= 0.9
			THEN 141*power((Baseline_Creatinine_Final/0.9), -0.411)*power((0.993), cast(Age_at_Admit as real))
		WHEN 
			(Baseline_Creatinine_Final IS NOT NULL and Baseline_Creatinine_Final > 0)
			and (Age_at_Admit IS NOT NULL and Age_at_Admit > 0)
			and RACE <> 'BLACK' 
			and Gender <> 'FEMALE'
			and Baseline_Creatinine_Final > 0.9
			THEN 141*power((Baseline_Creatinine_Final/0.9), -1.209)*power((0.993), cast(Age_at_Admit as real))
		ELSE 0
	END AS Baseline_eGFR_CKD_EPI
into
	#AKI_Creatinine_Labs_Anchor_eGFR
from
	#AKI_Creatinine_Labs_Anchor
;





--5b
----Assign AKI Stage and exclude patients with ESRD (<15 eGFR)--------------------------------
drop table if exists #AKI_Detail_No_ESRD;

select
	  CA.*
	 ,CASE 
	 	WHEN CA.Baseline_eGFR_CKD_EPI < 15 THEN 0
		WHEN (CA.Anchor_Creatinine/nullif(CA.Baseline_Creatinine_Final,0)) >= 3.0 
			 OR (
			 		CA.Baseline_Creatinine_Final >= 4 AND (CA.Anchor_Creatinine - CA.Baseline_Creatinine_Final) >= 0.5
				) 
			 THEN 3
		WHEN (CA.Anchor_Creatinine/nullif(CA.Baseline_Creatinine_Final,0)) >= 2.0 THEN 2
		WHEN (CA.Anchor_Creatinine/nullif(CA.Baseline_Creatinine_Final,0)) >= 1.5
			 OR (CA.Anchor_Creatinine - CA.Baseline_Creatinine_Final) >= 0.3 THEN 1
		ELSE 0 
	  END AS AKI_Stage
into
	#AKI_Detail_No_ESRD
from
	#AKI_Creatinine_Labs_Anchor_eGFR as CA
;


--Get only the last Cr measurement of the day
drop table if exists #AKI_Detail_No_ESRD_Ordered;

select
	  *
	  ,ROW_NUMBER() OVER(PARTITION BY VISIT_OCCURRENCE_ID ORDER BY Anchor_Result_Date) as RowNum_Visit
into #AKI_Detail_No_ESRD_Ordered
from
(
       select 
	   		*
			,CASE
				WHEN AKI_Stage = 0 THEN 0 ELSE 1
			 END AS AKI_Flag
			,ROW_NUMBER() OVER(PARTITION BY VISIT_OCCURRENCE_ID, Anchor_Result_Date ORDER BY measurement_datetime desc) as RowNum_Date
       from #AKI_Detail_No_ESRD
) as OrderedSet
where
	RowNum_Date = 1  --Get only the last Cr measurement of the day
order by
	 VISIT_OCCURRENCE_ID
	,RowNum_Visit
;


--Get days between so that AKI duration can be obtained
drop table if exists #AKI_Detail_Days_Between;

select
	A.*
	,B.AKI_Flag as AKI_Flag_Previous
	,datediff(dd,B.Anchor_Result_Date, A.Anchor_Result_Date) AS Days_Between_Measures
	,CASE
		WHEN B.AKI_Flag = 1 
		THEN datediff(dd,B.Anchor_Result_Date, A.Anchor_Result_Date)
		ELSE 0
	 END AS AKI_Duration_Sub
	,first_value(A.Anchor_Result_Date) OVER(Partition By A.visit_occurrence_id Order By A.rownum_visit) as AKI_Result_Date_First
	,first_value(A.Anchor_Result_Date) OVER(Partition By A.visit_occurrence_id Order By A.rownum_visit desc) as AKI_Result_Date_Last
	,first_value(A.AKI_Stage) OVER(Partition By A.visit_occurrence_id Order By A.rownum_visit) as AKI_Stage_First
	,first_value(A.AKI_Stage) OVER(Partition By A.visit_occurrence_id Order By A.rownum_visit desc) as AKI_Stage_Last
into
	#AKI_Detail_Days_Between
from
	#AKI_Detail_No_ESRD_Ordered as A
	left join #AKI_Detail_No_ESRD_Ordered as B
		ON A.RowNum_Visit = B.RowNum_Visit + 1
		AND A.VISIT_OCCURRENCE_ID = B.VISIT_OCCURRENCE_ID
		AND A.admit_date = B.admit_date
;

--select top 100 * from #AKI_Detail_Days_Between
	

drop table if exists #AKI_Detail_Days_Between_Grouped;
	
Select
	 visit_occurrence_id
	,admit_date
	,discharge_date
	,max(AKI_Flag) as AKI_Flag
	,AKI_Stage_First
	,AKI_Stage_Last
	,min(AKI_Stage) as AKI_Stage_Min
	,max(AKI_Stage) as AKI_Stage_Max
	,AKI_Result_Date_First
	,AKI_Result_Date_Last
	,datediff(dd, AKI_Result_Date_First, discharge_date) as Duration_First_to_DD
	,datediff(dd, AKI_Result_Date_Last, discharge_date) as Duration_Last_to_DD
	,count(*) as AKI_Measures_Count
	,sum(AKI_Duration_Sub) as AKI_Duration_Sum
into
	#AKI_Detail_Days_Between_Grouped
from
	#AKI_Detail_Days_Between
group by
	visit_occurrence_id
	,admit_date
	,discharge_date
	,AKI_Stage_First
	,AKI_Stage_Last
	,AKI_Result_Date_First
	,AKI_Result_Date_Last
;


drop table if exists #AKI_Duration;
	
Select
	 visit_occurrence_id
	,admit_date
	,discharge_date
	,AKI_Flag
	,AKI_Stage_First
	,AKI_Stage_Last
	,AKI_Stage_Min
	,AKI_Stage_Max
	,AKI_Result_Date_First
	,AKI_Result_Date_Last
	,Duration_First_to_DD
	,Duration_Last_to_DD
	,AKI_Measures_Count
	,AKI_Duration_Sum
	,CASE
		WHEN AKI_Stage_Min=0 AND AKI_Stage_Max=0 THEN 0
		WHEN AKI_Stage_Min>0 AND AKI_Stage_Max>0 THEN Duration_First_to_DD
		WHEN AKI_Stage_Min=0 AND AKI_Stage_Max>0 AND AKI_Stage_Last=0 THEN AKI_Duration_Sum
		WHEN AKI_Stage_Min=0 AND AKI_Stage_Max>0 AND AKI_Stage_Last>0 THEN AKI_Duration_Sum + Duration_Last_to_DD
	 END AS AKI_Duration
	,CASE
		WHEN AKI_Stage_Last > 0 THEN 1
		ELSE 0
	 END as AKI_Unresolved_Flag
	,CASE
		WHEN AKI_Stage_Max>0 AND AKI_Stage_Last=0
		THEN 1
		ELSE 0
	 END as AKI_Recovered_Flag
into
	#AKI_Duration
from
	#AKI_Detail_Days_Between_Grouped
;


drop table if exists AMI.Table1_AKI_Stage;

select
	CB2.*
	,AKI_Flag
	,AKI_Stage_First
	,AKI_Stage_Last
	,AKI_Stage_Min
	,AKI_Stage_Max
	,AKI_Duration
	,AKI_Unresolved_Flag
	,AKI_Recovered_Flag
	,AKI_Stage_Max as AKI_Stage
	,Case	
		when AKI_Stage_Max = 1 then 1 else 0
	 End as AKI_Stage_1_Flag
	,Case	
		when AKI_Stage_Max = 2 then 1 else 0
	 End as AKI_Stage_2_Flag
	,Case	
		when AKI_Stage_Max = 3 then 1 else 0
	 End as AKI_Stage_3_Flag
into
	AMI.Table1_AKI_Stage
from 
	ami.cohort_base_2 as CB2
	left join #AKI_Duration as D
		on CB2.visit_occurrence_ID = D.visit_occurrence_id
;

--select top 100 * from AMI.Table1_AKI_Stage
