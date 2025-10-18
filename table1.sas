/*****************************************************************************************************************************************************************
Program name: /udd/nhywa/GUTSOB/table1.sas
Purpose: Generate Table 1 showing participants characteristics
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Yiqing Wang (nhywa)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: 02/2025
1) Purpose: Prepare GUTS1 dataset for analysis
2) Study Population: 
				- NHSII 1995-2013 (for maternal exposures)
                - GUTS1 1996-2005 (all offsprings were >=18 by then)
                - GUTS2 2004-2013 (all offsprings were >=18 by then)
3) Inclusion:
	-participants who had exposure and outcome data
   Exclusion:
	-Being obese or having missing BMI at the baseline for personal factors
	-BMI measurements excluded if pregnancy/breastfeeding during the past year
4) Exposures:
	- Maternal obesity, diet quality, physical activity, smoking, drinking, age at birth, Gestational diabetes, C-section, Small or large for gestational age 
	- Offspring diet quality, physical activity, sedentary behavior, Smoking, Drinking, Abnormal sleep duration 
    - Maternal education, Maternal job stress (job strain, rotating night-shift work schedule, job insecurity), Neighborhood socioeconomic status,
		Number of primary care providers in the county, Food deserts/swamps, Greenspace, Air pollution (personal exposure), Summer and winter temperature 
	- Child abuse (both for the moms and children)
	- Yale food addiction scale (NHS2 and later in GUTS)
5) Covariates: 
	- Maternal age at baseline (years), race/ethnicity, maternal total energy intake, maternal chronic diseases (?)
	- Offspring age, sex, race/ethnicity, offspring energy intake (?), offspring other chronic diseases (?)
6) Statistical analyses: multivariable log-binomial regression models with generalized estimating equations and specified an exchangeable correlation structure
*******************************************************************************/

%include '/udd/nhywa/GUTSOB/merge_ob_MI.sas';

data imp1; set all;
	where _Imputation_=1;
run;

/* Offspring */
data offspring; set imp1;
	if year=1996 or year=2004; 
	
	if fl_sch98 ne 1 then fl_sch98=0;
	if fl_sch99 ne 1 then fl_sch99=0;
	if fl_not_mom9698 ne 1 then fl_not_mom9698=0;
	
	if abwt1=1 then abwt=1;
		else if abwt3=1 then abwt=3;
		else abwt=2;
	if gweek1=1 then gweek=1;
		else if gweek3=1 then gweek=3;
		else gweek=2;
	if prev_preg1=1 then prev_preg=1;
		else if prev_preg2=1 then prev_preg=2;
		else if prev_preg3=1 then prev_preg=3; 
		else prev_preg=0;
	if mosmk2=1 then mosmk=2;
		else if mosmk3=1 then mosmk=3;
		else mosmk=1;
run;

%table1(data = offspring,
    exposure = cohort,
  	varlist  = agebirth obyear chage chbmi chbmibase chwest chcal chst chpa bmibpreg 
  			   sex white abwt1 abwt3 gweek1 gweek3 prev_preg1 prev_preg2 prev_preg3
  			   Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp2 gotweight bpregob 
  			   ,
  	cat      = sex white abwt1 abwt3 gweek1 gweek3 prev_preg1 prev_preg2 prev_preg3
  			   Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp2 gotweight bpregob 
  			   ,
  	rtftitle = GUTS baseline,
  	landscape= F,
	file     = guts_base_MI,
    dec      = 1,
	pctn     = pctn,
  	uselbl   = F,
	ageadj   = F);

proc means data=offspring n mean std min p25 median p75 max;	
	class cohort;	
	var agebirth obyear chage chbmi chbmibase chwest chcal chst chpa bmibpreg  
		moage  mowest    mocal  mopa    mobmi  moshift  ses  
  				   foodswamp supermarket restaurant fastfood convenience
  				   foodswampz supermarketz restaurantz fastfoodz conveniencez
  				   foodswampa supermarketa restauranta fastfooda conveniencea
  				   physician food_desert ; 
run;

proc freq data=offspring;
	table (sex white abwt1 abwt3 gweek1 gweek3 prev_preg1 prev_preg2 prev_preg3
  		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp2 gotweight bpregob
  		heduc1 heduc2  fincome1 fincome2 fincome3 mosmk2 mosmk3
  				   midwest south west moob) * cohort;
run;

/**************
proc means data=offspring n mean stddev;
   by _Imputation_;
   var age bmi;
   ods output summary=cont_stats;  
run;

* Put the statistics into MIANALYZE-friendly format (one row per imputation) ;
proc transpose data=cont_stats out=cont_t prefix=imp_;
   by _Imputation_;
   id _STAT_;          
   var age bmi;
run;

* Pool means and (optionally) SDs with PROC MIANALYZE       ;
proc mianalyze data=cont_t;
   modeleffects mean_age=MEAN_age  mean_bmi=MEAN_bmi;
   stderr        se_age = STDDEV_age  se_bmi = STDDEV_bmi;
run;
*************/

/* Mothers*/
proc sort data=offspring out=moms;
  by _Imputation_  momid; 
run;

*get unique id for mothers;
data moms2; set moms;
   by _Imputation_ momid;
   where _Imputation_=1;
   if first.momid; /* first record of momid *within* each _Imputation_ */
run;			
		
%table1(data     = moms2,
		exposure = cohort,
  		varlist  = moage  mowest    mocal  mopa    mobmi  moshift  ses  
  				   foodswamp supermarket restaurant fastfood convenience
  				   foodswampz supermarketz restaurantz fastfoodz conveniencez
  				   foodswampa supermarketa restauranta fastfooda conveniencea
  				   physician food_desert 
  				   heduc1 heduc2  fincome1 fincome2 fincome3 mosmk2 mosmk3
  				   midwest south west moob,
  		cat      = heduc1 heduc2  fincome1 fincome2 fincome3 mosmk2 mosmk3
  				   midwest south west moob,
  		rtftitle = Moms Baseline,
  		landscape= F,
		file     = moms_base_MI,
  		dec      = 1,
		pctn     = pctn,
		uselbl   = F,
		ageadj   = F);
run;

proc means data=moms2 n mean std min p25 median p75 max;	
	class cohort;	
	var moage  mowest    mocal  mopa    mobmi  moshift  ses  
  				   foodswamp supermarket restaurant fastfood convenience
  				   foodswampz supermarketz restaurantz fastfoodz conveniencez
  				   foodswampa supermarketa restauranta fastfooda conveniencea
  				   physician food_desert   ; 
run;

proc freq data=moms2;
	table (heduc1 heduc2  fincome1 fincome2 fincome3 mosmk2 mosmk3
  				   midwest south west moob) * cohort;
run;

/*********************************************************************/
/********************** correlation figure ***************************/
 		
proc corr data=offspring noprint Spearman outs=correlation;
	var cohort white sex chage  chob chbmi  chbmibase 
		bmibpreg  abwt gweek prev_preg
	    incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc mosmk agebirth 
		chwest chcal chst chpa  
		moage  mowest   mocal  mopa    mobmi    moshift  ses  
		supermarket restaurant fastfood convenience foodswamp 
		supermarketz restaurantz fastfoodz conveniencez foodswampz
		supermarketa restauranta fastfooda conveniencea foodswampa ;
	with cohort white sex chage  chob chbmi  chbmibase 
		bmibpreg  abwt gweek prev_preg
		incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc mosmk agebirth 
		chwest chcal chst chpa  
		moage  mowest   mocal  mopa    mobmi    moshift  ses  
		supermarket restaurant fastfood convenience foodswamp 
		supermarketz restaurantz fastfoodz conveniencez foodswampz
		supermarketa restauranta fastfooda conveniencea foodswampa;
run;

proc corr data=offspring noprint Spearman outs=correlation1;
where  cohort=1;
	var gotweight chob chbmi 
		bmibpreg  abwt gweek prev_preg
		incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc mosmk agebirth 
		chwest chcal chst chpa  
		moage  mowest   mocal  mopa    mobmi    moshift  ses  
		supermarket restaurant fastfood convenience foodswamp 
		supermarketz restaurantz fastfoodz conveniencez foodswampz
		supermarketa restauranta fastfooda conveniencea foodswampa;
	with gotweight chob chbmi 
		bmibpreg  abwt gweek prev_preg
		incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc mosmk agebirth 
		chwest chcal chst chpa  
		moage  mowest   mocal  mopa    mobmi    moshift  ses  
		supermarket restaurant fastfood convenience foodswamp 
		supermarketz restaurantz fastfoodz conveniencez foodswampz
		supermarketa restauranta fastfooda conveniencea foodswampa;
run;

proc corr data=offspring noprint Spearman outs=correlation2;
where cohort=2;
	var physician food_desert chob chbmi 
		bmibpreg  abwt gweek prev_preg
		incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc mosmk agebirth 
		chwest chcal chst chpa  
		moage  mowest   mocal  mopa    mobmi    moshift  ses  
		supermarket restaurant fastfood convenience foodswamp 
		supermarketz restaurantz fastfoodz conveniencez foodswampz
		supermarketa restauranta fastfooda conveniencea foodswampa ;
	with physician food_desert chob chbmi 
		bmibpreg  abwt gweek prev_preg
		incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc mosmk agebirth 
		chwest chcal chst chpa  
		moage  mowest   mocal  mopa    mobmi    moshift  ses  
		supermarket restaurant fastfood convenience foodswamp 
		supermarketz restaurantz fastfoodz conveniencez foodswampz
		supermarketa restauranta fastfooda conveniencea foodswampa ;
run;
	
proc export data=correlation
  outfile='corr_exposure.csv'
  dbms=csv
  replace;
run;
proc export data=correlation1
  outfile='corr_exposure1.csv'
  dbms=csv
  replace;
run;
proc export data=correlation2
  outfile='corr_exposure2.csv'
  dbms=csv
  replace;
run;

/**********************************************/
* calculate average follow-up year;
proc sort data=imp1 out=imp1;
  by id year; 
run;

data offspring2; set imp1;
	by id year;
   if last.id; 
   if cohort=1 then follow=year-1996;
   		else if cohort=2 then follow=year-2004;
run;
proc means data=offspring2 n mean std min p25 median p75 max;		
	class cohort;
	var year follow; 
run;
proc means data=offspring2 n mean std min p25 median p75 max;		
	var year follow; 
run;	

****** exclude lost follow-up *****;
data offspring2; set imp1;
   by id year;
   if chirt >0;
   if last.id; 
   if cohort=1 then follow=year-1996;
   		else if cohort=2 then follow=year-2004;
run;
proc means data=offspring2 n mean std min p25 median p75 max;		
	class cohort;
	var year follow; 
run;
proc means data=offspring2 n mean std min p25 median p75 max;		
	var year follow; 
run;	
	

