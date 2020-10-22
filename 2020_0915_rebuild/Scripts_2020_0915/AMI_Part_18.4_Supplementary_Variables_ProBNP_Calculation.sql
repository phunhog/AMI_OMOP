-----------------------------------------------------------------------------------------
--AMI Readmissions Project---------------------------------------------------------------
-----------------------------------------------------------------------------------------
--USE AMI
USE OMOP_CDM --10/16/2020
GO

/*
Table1_Laboratories
--contains bnp and hemoglobin

select count(*) from Table1_Laboratories as L where L.[BNP_Last_Date] is not null
--10248

select count(*) from Table1_Laboratories as L where L.[proBNP_Last_Date] is not null
--46

select count(*) from Table1_Laboratories as L where L.[BNP_Last_Date] is  null and L.[proBNP_Last_Date] is not null
--17
*/

--drop table if exists #BNP_Data;

select
	L.PERSON_ID
	, L.VISIT_OCCURRENCE_ID
	, CB2.Index_Admission_Flag
	, L.BNP_Level_Last
	, L.BNP_Last_Date
into
	#BNP_Data
from
	COHORT_BASE_2 as CB2
	left join
	Table1_Laboratories as L
		on CB2.PERSON_ID = L.PERSON_ID
		and cb2.VISIT_OCCURRENCE_ID = L.VISIT_OCCURRENCE_ID
;
--select count(*) from #BNP_Data as L where L.[BNP_Last_Date] is not null and Index_Admission_Flag = 1
--4107

---------------------------------------------------------------------------------
--For Creatinine Clearance, we need:
--Gender
--Age
--Creatinine: within 30 days before BNP date
--Weight: Within 365 days before creatinine date
--Height?: Within 365 days before creatinine date

--CCr = ((140 - Age)x(Weight)/(72xSCr)) x 0.85 if female
--------------------------------------------------------------------------------------
--select count(*) from #BNP_Creatinine where BNP_Creatinine_Value is not null
--3702 on 2020_0916 8am
--7763 after including same day as bnp
--8040 afetr expanding to 90 days before
--out of 17556

--drop table if exists #BNP_Creatinine;

Select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.GENDER
	, CB2.Age_at_Admit as Age
	, CB2.Index_Admission_Flag
	, BNP1.BNP_Level_Last
	, BNP1.BNP_Last_Date
	, BNP1.BNP_Creatinine_Value
	, BNP1.BNP_Creatinine_Date
into 
	#BNP_Creatinine
from
	Cohort_Base_2 as CB2
	left join
	(
		select
			PERSON_ID
			, VISIT_OCCURRENCE_ID
			, BNP_Level_Last
			, BNP_Last_Date
			, BNP_Creatinine_Value
			, BNP_Creatinine_Date
		from
		
			(
				select 
					B.PERSON_ID
					, B.VISIT_OCCURRENCE_ID
					, B.BNP_Level_Last
					, B.BNP_Last_Date
					, M.VALUE_AS_NUMBER as BNP_Creatinine_Value
					, M.MEASUREMENT_DATE as BNP_Creatinine_Date
					, row_number() over (partition by B.PERSON_ID, B.VISIT_OCCURRENCE_ID, B.BNP_Last_Date order by M.MEASUREMENT_DATE desc) as rownum
				from
					#BNP_Data as B
					left join MEASUREMENT as M
						on B.PERSON_ID = M.PERSON_ID
						and	M.MEASUREMENT_DATE between dateadd(dd, -90, B.BNP_Last_Date) and B.BNP_Last_Date
				where
					M.MEASUREMENT_CONCEPT_ID IN (3051825, 3016723, 3032033, 3007760)
					and M.VALUE_AS_NUMBER between 0.3 and 20 --Exclude creatinine values that fall outside of normal range
			) as BNP
				
		where
			BNP.rownum = 1
	) as BNP1
		ON CB2.PERSON_ID = BNP1.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = BNP1.VISIT_OCCURRENCE_ID
;

--select count(*) from #BNP_Creatinine as B where B.BNP_Creatinine_Value is not null and Index_Admission_Flag = 1
--select count(*) from #BNP_Creatinine as B where Index_Admission_Flag = 1
--13854 out of 17556
--select count(*) from #BNP_Creatinine as B where B.BNP_Creatinine_Value is not null and Index_Admission_Flag = 1
--2882 of 9238

--Concept_IDs
--3025315	Body weight	Measurement	LOINC	Clinical Observation	S	29463-7
--3036277	Body height	Measurement	LOINC	Clinical Observation	S	8302-2
--3038553	Body mass index	Measurement	LOINC	Clinical Observation	S	39156-5

--Weight
--drop table if exists #BNP_Creatinine_Weight;

Select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.GENDER
	, CB2.Age_at_Admit as Age
	, CB2.Index_Admission_Flag
	, BNP1.BNP_Creatinine_Value
	, BNP1.BNP_Creatinine_Date
	, BNP1.BNP_Creatinine_Weight_Value
	, BNP1.BNP_Creatinine_Weight_Date
into 
	#BNP_Creatinine_Weight
from
	Cohort_Base_2 as CB2
	left join
	(
		select
			PERSON_ID
			, VISIT_OCCURRENCE_ID
			, BNP_Creatinine_Value
			, BNP_Creatinine_Date
			, BNP_Creatinine_Weight_Value
			, BNP_Creatinine_Weight_Date
		from
		
			(
				select 
					B.PERSON_ID
					, B.VISIT_OCCURRENCE_ID
					, B.BNP_Creatinine_Value
					, B.BNP_Creatinine_Date
					, M.VALUE_AS_NUMBER as BNP_Creatinine_Weight_Value
					, M.MEASUREMENT_DATE as BNP_Creatinine_Weight_Date
					, row_number() over (partition by B.PERSON_ID, B.VISIT_OCCURRENCE_ID, B.BNP_Creatinine_Date order by M.MEASUREMENT_DATE desc) as rownum
				from
					#BNP_Creatinine as B
					left join MEASUREMENT as M
						on B.PERSON_ID = M.PERSON_ID
						and	M.MEASUREMENT_DATE between dateadd(dd, -365, B.BNP_Creatinine_Date) and B.BNP_Creatinine_Date
				where
					M.MEASUREMENT_CONCEPT_ID = 3025315	--Weight
			) as BNP	
		where
			BNP.rownum = 1
	) as BNP1
		ON CB2.PERSON_ID = BNP1.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = BNP1.VISIT_OCCURRENCE_ID
;
--select count(*) from #BNP_Creatinine_Weight as B where B.BNP_Creatinine_Weight_Value is not null and B.Index_Admission_Flag = 1
--2736 out of 9238

--drop table if exists #BNP_Creatinine_Height;

Select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.GENDER
	, CB2.Age_at_Admit as Age
	, CB2.Index_Admission_Flag
	, BNP1.BNP_Creatinine_Value
	, BNP1.BNP_Creatinine_Date
	, BNP1.BNP_Creatinine_Height_Value
	, BNP1.BNP_Creatinine_Height_Date
into 
	#BNP_Creatinine_Height
from
	Cohort_Base_2 as CB2
	left join
	(
		select
			PERSON_ID
			, VISIT_OCCURRENCE_ID
			, BNP_Creatinine_Value
			, BNP_Creatinine_Date
			, BNP_Creatinine_Height_Value
			, BNP_Creatinine_Height_Date
		from
		
			(
				select 
					B.PERSON_ID
					, B.VISIT_OCCURRENCE_ID
					, B.BNP_Creatinine_Value
					, B.BNP_Creatinine_Date
					, M.VALUE_AS_NUMBER as BNP_Creatinine_Height_Value
					, M.MEASUREMENT_DATE as BNP_Creatinine_Height_Date
					, row_number() over (partition by B.PERSON_ID, B.VISIT_OCCURRENCE_ID, B.BNP_Creatinine_Date order by M.MEASUREMENT_DATE desc) as rownum
				from
					#BNP_Creatinine as B
					left join MEASUREMENT as M
						on B.PERSON_ID = M.PERSON_ID
						and	M.MEASUREMENT_DATE between dateadd(dd, -365, B.BNP_Creatinine_Date) and B.BNP_Creatinine_Date
				where
					M.MEASUREMENT_CONCEPT_ID = 3036277	--Height
			) as BNP
				
		where
			BNP.rownum = 1
	) as BNP1
		ON CB2.PERSON_ID = BNP1.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = BNP1.VISIT_OCCURRENCE_ID
;
--select count(*) from #BNP_Creatinine_Height as B where B.BNP_Creatinine_Height_Value is not null and B.Index_Admission_Flag = 1
--1928 of 9238

--CCr calculation
--drop table if exists #CCr_Components;

select
	C.PERSON_ID
	, C.VISIT_OCCURRENCE_ID
	, C.Index_Admission_Flag
	, 140-C.Age as Age_Component
	, C.BNP_Creatinine_Weight_Value as Weight_Component
	, 72*C.BNP_Creatinine_Value as SCr_Component
	, Case	
		when C.GENDER = 'FEMALE' then 0.85
		else 1
	  End as Gender_Component
into 
	#CCr_Components
from
	#BNP_Creatinine_Weight as C
;



--drop table if exists #CCr_Values;

select
	PERSON_ID
	, VISIT_OCCURRENCE_ID
	, Index_Admission_Flag
	, ((Age_Component*Weight_Component)/SCr_Component)*Gender_Component as CCr_Value
into 
	#CCr_Values
from
	#CCr_Components as C
;

--select count(*) from #CCr_Values where CCr_Value is not null and Index_Admission_Flag = 1
--not null 7862 of 17556 after including day of anchor measure in calculation
--not null 2736 of 9238





-----------------------------------------------------------
--For probnp calculation, we need:
--Age(#BNP_BMI), gender(#BNP_BMI), Afib_Flag(AFib_Flag), BMI(#BNP_BMI), CCr(#CCr_Values), Hemoglobin(#BNP_Hemoglobin)
----------------------------------------------------------------
--drop table if exists #BNP_BMI;

Select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.GENDER
	, CB2.Age_at_Admit as Age
	, CB2.Index_Admission_Flag
	, BNP1.BNP_Level_Last
	, BNP1.BNP_Last_Date
	, BNP1.BNP_BMI_Value
	, BNP1.BNP_BMI_Date
into 
	#BNP_BMI
from
	Cohort_Base_2 as CB2
	left join
	(
		select
			PERSON_ID
			, VISIT_OCCURRENCE_ID
			, BNP_Level_Last
			, BNP_Last_Date
			, BNP_BMI_Value
			, BNP_BMI_Date
		from
		
			(
				select 
					B.PERSON_ID
					, B.VISIT_OCCURRENCE_ID
					, B.BNP_Level_Last
					, B.BNP_Last_Date
					, M.VALUE_AS_NUMBER as BNP_BMI_Value
					, M.MEASUREMENT_DATE as BNP_BMI_Date
					, row_number() over (partition by B.PERSON_ID, B.VISIT_OCCURRENCE_ID, B.BNP_Last_Date order by M.MEASUREMENT_DATE desc) as rownum
				from
					#BNP_Data as B
					left join MEASUREMENT as M
						on B.PERSON_ID = M.PERSON_ID
						and	M.MEASUREMENT_DATE between dateadd(dd, -365, B.BNP_Last_Date) and B.BNP_Last_Date
				where
					M.MEASUREMENT_CONCEPT_ID = 3038553	--BMI
			) as BNP
				
		where
			BNP.rownum = 1
	) as BNP1
		ON CB2.PERSON_ID = BNP1.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = BNP1.VISIT_OCCURRENCE_ID
;



--drop table if exists #BNP_Hemoglobin;

Select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.GENDER
	, CB2.Age_at_Admit as Age
	, BNP1.BNP_Level_Last
	, BNP1.BNP_Last_Date
	, BNP1.BNP_Hemoglobin_Value
	, BNP1.BNP_Hemoglobin_Date
into 
	#BNP_Hemoglobin
from
	Cohort_Base_2 as CB2
	left join
	(
		select
			PERSON_ID
			, VISIT_OCCURRENCE_ID
			, BNP_Level_Last
			, BNP_Last_Date
			, BNP_Hemoglobin_Value
			, BNP_Hemoglobin_Date
		from
		
			(
				select 
					B.PERSON_ID
					, B.VISIT_OCCURRENCE_ID
					, B.BNP_Level_Last
					, B.BNP_Last_Date
					, M.VALUE_AS_NUMBER as BNP_Hemoglobin_Value
					, M.MEASUREMENT_DATE as BNP_Hemoglobin_Date
					, row_number() over (partition by B.PERSON_ID, B.VISIT_OCCURRENCE_ID, B.BNP_Last_Date order by M.MEASUREMENT_DATE desc) as rownum
				
				from
					#BNP_Data as B
					left join MEASUREMENT as M
						on B.PERSON_ID = M.PERSON_ID
						and	M.MEASUREMENT_DATE between dateadd(dd, -365, B.BNP_Last_Date) and B.BNP_Last_Date
				where
					M.MEASUREMENT_CONCEPT_ID = 3000963
			) as BNP
				
		where
			BNP.rownum = 1
	) as BNP1
		ON CB2.PERSON_ID = BNP1.PERSON_ID
		and CB2.VISIT_OCCURRENCE_ID = BNP1.VISIT_OCCURRENCE_ID
;



--drop table if exists #proBNP_Vars;

--Age(#BNP_BMI), gender(#BNP_BMI), Afib_Flag(AFib_Flag), BMI(#BNP_BMI), CCr(#CCr_Values), Hemoglobin(#BNP_Hemoglobin)
select
	B.PERSON_ID
	, B.VISIT_OCCURRENCE_ID
	, B.Age
	, B.GENDER
	, B.BNP_BMI_Value
	, B.Index_Admission_Flag
	, cast(B.BNP_Level_Last as float) as BNP_Level_Last
	, H.BNP_Hemoglobin_Value
	, C.CCr_Value
	, A.AFib_Flag
into
	#proBNP_Vars
from
	#BNP_BMI as B
	left join
	#BNP_Hemoglobin as H
		on B.PERSON_ID = H.PERSON_ID
		and B.VISIT_OCCURRENCE_ID = H.VISIT_OCCURRENCE_ID
	left join
	#CCr_Values as C
		on B.PERSON_ID = C.PERSON_ID
		and B.VISIT_OCCURRENCE_ID = C.VISIT_OCCURRENCE_ID
	left join
	AFib_Flag as A
		on B.PERSON_ID = A.PERSON_ID
		and B.VISIT_OCCURRENCE_ID = A.VISIT_OCCURRENCE_ID
;


--ProBNP calculation moving to R code---------
----drop table if exists #proBNP_Components;

--select
--	P.person_id
--	, P.VISIT_OCCURRENCE_ID
--	, P.Index_Admission_Flag
--	, P.BNP_BMI_Value
--	,case
--		when P.BNP_Level_Last is not null and P.BNP_Level_Last <> 0
--		then log10(P.BNP_Level_Last)*0.907 
--		else null
--	end as BNP_Component
--	,P.Age*0.00522 as Age_Component
--	, P.BNP_BMI_Value*0.00283 as BMI_Component
--	, P.BNP_Hemoglobin_Value*0.00866 as Hb_Component
--	, P.CCr_Value*0.0422 as CCr1_Component
--	, P.CCr_Value*0.00053 as CCr2_Component
--	, P.CCr_Value*0.00000214 as CCr3_Component
--	, CASE	
--		when (P.CCr_Value-56.5) > 0 
--		then (P.CCr_Value-56.5)*0.00000278
--		else 0
--	  End as CCrMax1_Component
--	, CASE	
--		when (P.CCr_Value-72.4) > 0 
--		then (P.CCr_Value-72.4)*0.00000621
--		else 0
--	  End as CCrMax2_Component
--	, CASE	
--		when (P.CCr_Value-93.7) > 0 
--		then (P.CCr_Value-93.7)*0.00000133
--		else 0
--	  End as CCrMax3_Component
--	, CASE
--		when P.GENDER = 'FEMALE' 
--		then 0.0164
--		else 1
--	  End as Gender_Component
--	, CASE
--		when P.AFib_Flag = 1
--		then 0.194
--		else 1
--	  End as AFib_Component
--into
--	#proBNP_Components
--from
--	#proBNP_Vars as P
--;


----drop table if exists #proBNP_Exponent;

--need to cube some of these: check equation

--select
--	P.PERSON_ID
--	, P.VISIT_OCCURRENCE_ID
--	, P.Index_Admission_Flag
--	, P.BNP_BMI_Value
--	--,power(10,(2.05 + P.BNP_Component - P.Age_Component + P.BMI_Component - P.Hb_Component - P.CCr1_Component
--	--+ P.CCr2_Component - P.CCr3_Component - P.CCrMax1_Component + P.CCrMax2_Component - P.CCrMax3_Component
--	--+ P.Gender_Component + P.AFib_Component)) as proBNP_Calculated
--	, round((2.05 + P.BNP_Component - P.Age_Component + P.BMI_Component - P.Hb_Component - P.CCr1_Component
--	+ P.CCr2_Component - P.CCr3_Component - P.CCrMax1_Component + P.CCrMax2_Component - P.CCrMax3_Component
--	+ P.Gender_Component + P.AFib_Component),2) as proBNP_exponent
--into
--	#proBNP_Exponent
--from	
--	#proBNP_Components as P
--;

----select * from #proBNP_Exponent


----drop table if exists proBNP_Calculation;

--select
--	P.PERSON_ID
--	, P.VISIT_OCCURRENCE_ID
--	, P.BNP_BMI_Value
--	, P.Index_Admission_Flag
--	, CASE
--		when P.proBNP_exponent <= 3 
--		then power(10, P.proBNP_exponent) 
--		else null
--	  End as proBNP_Calculated
--into
--	 proBNP_Calculation
--from	
--	#proBNP_Exponent as P
--;

--drop table if exists proBNP_Calculation;

if exists (select * from sys.objects where name = 'proBNP_Calculation' and type = 'u')
    drop table proBNP_Calculation


;


Select
	CB2.PERSON_ID
	, CB2.VISIT_OCCURRENCE_ID
	, CB2.Index_Admission_Flag
	, CB2.Age_at_Admit as proBNP_Calc_Age
	, W.BNP_Creatinine_Value as proBNP_Calc_BNP_Creatinine_Value
	, W.BNP_Creatinine_Weight_Value as proBNP_Calc_BNP_Creatinine_Weight_Value
	, P.CCr_Value as proBNP_Calc_CCr_Value
	, P.BNP_Level_Last as proBNP_Calc_BNP_Level_Last
	, P.GENDER as proBNP_Calc_Gender
	, P.BNP_BMI_Value as proBNP_Calc_BNP_BMI_Value
	, P.AFib_Flag as proBNP_Calc_AFib_Flag
	, P.BNP_Hemoglobin_Value as proBNP_Calc_BNP_Hemoglobin_Value
into 
	proBNP_Calculation	
from
	COHORT_BASE_2 as CB2
	left join
	#BNP_Creatinine_Weight as W
		on CB2.PERSON_ID = W.PERSON_ID
		and cb2.VISIT_OCCURRENCE_ID = W.VISIT_OCCURRENCE_ID	
	left join
	#proBNP_Vars as P
		on CB2.PERSON_ID = P.PERSON_ID
		and cb2.VISIT_OCCURRENCE_ID = P.VISIT_OCCURRENCE_ID
;

--select count(*) from #proBNP_Exponent where proBNP_exponent is not null
----7359


--select count(*) from #proBNP_Exponent where proBNP_exponent is not null and Index_Admission_Flag = 1
----2426 of 9238

--select count(*) from  proBNP_Calculation where proBNP_Calculated is not null and Index_Admission_Flag = 1
--1552

--select count(*) from  proBNP_Calculation where BNP_BMI_Value is not null and Index_Admission_Flag = 1
--3548