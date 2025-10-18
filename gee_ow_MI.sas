/*******************************************************************************
Program name: gee_ow_MI.sas
Purpose: Examine the associations between individual exposures and obesity risk with multiple imputation
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Yiqing Wang (nhywa)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: 12/2024
1) Purpose: Secondary analysis for overweight
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

%include '/udd/nhywa/GUTSOB/merge_ow_MI.sas';

/**********************************************************************/
data all;
  set all;
  cohort=cohort-1;
  
  /*if agebirth >=35 then oldbirth=1; else oldbirth=0;*/
  
     %indic3(vbl=mowestq, reflev=0, missing=., min=1, max=3, prefix=mowestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mocalq, reflev=0, missing=., min=1, max=3, prefix=mocalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mopaq, reflev=3, missing=., min=0, max=2, prefix=mopaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');        
     %indic3(vbl=moshiftq, reflev=0, missing=., min=1, max=3, prefix=moshiftq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
            
    %indic3(vbl=sesq, reflev=3, missing=., min=0, max=2, prefix=sesq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');

	%indic3(vbl=chwestq, reflev=0, missing=., min=1, max=3, prefix=chwestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chcalq, reflev=0, missing=., min=1, max=3, prefix=chcalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chstq, reflev=0, missing=., min=1, max=3, prefix=chstq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chpaq, reflev=3, missing=., min=0, max=2, prefix=chpaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');

	/*if mosmk2=1 or mosmk3=1 then mosmkever=1; else mosmkever=0;*/
run;

proc sort data=all; by _imputation_; run;

proc freq data=all; 
	where _imputation_ = 1 ;
	table ( mowestq mocalq mopaq mosmk2 mosmk3 moow moshiftq bpregow 
			abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
			sesq husbeduc income incom01 
			chwestq chstq chpaq chcalq chsleep chsleepc 
   			cohort white sex 
   			prev_preg1 prev_preg2 prev_preg3
   			midwest south west)*chow; 
run; *keep pregcomp instead of individual complications to increase power;

%LET covar1= cohort chage white sex ;

run;

/**********************************************************************/
title ' maternal modifiable factors - not adjusting for moow because it may be on the causal pathways ';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3
  				&moshiftq_ 
  			    moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = mom;
 run;
 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = mowest_m mocal_m mopa_m mosmk2 mosmk3
   				moshift_m 
   				moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =mom_t;
 run;
 
TITLE " multiple imputation - maternal modifiable factors - no moow";
ods output ParameterEstimates=mi_mom;
PROC MIANALYZE parms=mom;
MODELEFFECTS INTERCEPT mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
	    mopaq0 mopaq1 mopaq2 mosmk2 mosmk3
		moshiftq1 moshiftq2 moshiftq3 
  		moage cohort chage white sex  ;
RUN;

ods output ParameterEstimates=mi_momt;
PROC MIANALYZE parms=mom_t;
MODELEFFECTS INTERCEPT mowest_m mocal_m mopa_m mosmk2 mosmk3
		moshift_m 
  		moage cohort chage white sex  ;
RUN;

title ' maternal modifiable factors - moow ';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 moow 
  				&moshiftq_ 
  			    moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = mob;
 run;
 
TITLE " multiple imputation - moow";
ods output ParameterEstimates=mi_mob;
PROC MIANALYZE parms=mob;
MODELEFFECTS INTERCEPT mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
	    mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moow
		moshiftq1 moshiftq2 moshiftq3 
  		moage cohort chage white sex  ;
RUN;

/**********************************************************************/
title ' in-uterine factors - adjusting for bpregow & oldbirth';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
  				bpregow prev_preg1 prev_preg2 prev_preg3 &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = uter;
 run;

TITLE " multiple imputation - in-uterine factors";
ods output ParameterEstimates=mi_uter;
PROC MIANALYZE parms=uter;
MODELEFFECTS INTERCEPT 
		agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
  				bpregow prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex  ;
RUN;

title ' bpregow & agebirth - not adjusting for other in-uterine factors factors because they may be on the causal pathways';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = agebirth bpregow prev_preg1 prev_preg2 prev_preg3 &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = preg;
 run;

TITLE " multiple imputation - in-uterine factors";
ods output ParameterEstimates=mi_pregob;
PROC MIANALYZE parms=preg;
MODELEFFECTS INTERCEPT 
		agebirth  bpregow prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex  ;
RUN;

/**************************************************************/
/**********************Sensitivity analysis********************/
/**************************************************************/
title ' maternal modifiable factors --- adjusting for in-uterine factors';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_
  				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregow 
  			    prev_preg1 prev_preg2 prev_preg3 moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = momsensi;
 run;
 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = mowest_m mocal_m mopa_m mosmk2 mosmk3 moshift_m   
   				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2  bpregow 
   				prev_preg1 prev_preg2 prev_preg3 moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =momsensi_t;
 run;

TITLE " multiple imputation - maternal modifiable factors - no moow";
ods output ParameterEstimates=mi_momsensi;
PROC MIANALYZE parms=momsensi;
MODELEFFECTS INTERCEPT mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
	    mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moshiftq1 moshiftq2 moshiftq3 
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregow 
  		prev_preg1 prev_preg2 prev_preg3 moage cohort chage white sex  ;
RUN;

ods output ParameterEstimates=mi_momsensit;
PROC MIANALYZE parms=momsensi_t;
MODELEFFECTS INTERCEPT mowest_m mocal_m mopa_m mosmk2 mosmk3 moshift_m   
   			abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregow 
  		prev_preg1 prev_preg2 prev_preg3 moage cohort chage white sex  ;
RUN;

title ' maternal modifiable factors - moow ';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_ moow 
  				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregow 
  			    prev_preg1 prev_preg2 prev_preg3 moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = mobsensi;
 run;
 
TITLE " multiple imputation - moow";
ods output ParameterEstimates=mi_mobsensi;
PROC MIANALYZE parms=mobsensi;
MODELEFFECTS INTERCEPT mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
	    mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moshiftq1 moshiftq2 moshiftq3 moow
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregow 
  		prev_preg1 prev_preg2 prev_preg3 moage cohort chage white sex  ;
RUN;


/**********************************************************************/
title ' socio-environmental factors '; 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = heduc1 heduc2 
			    midwest south west  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = edu;
 run;
 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = husbeduc 
 				midwest south west  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =edu_t;
 run;
 
TITLE " multiple imputation - socio-environmental factors";
ods output ParameterEstimates=mi_edu;
PROC MIANALYZE parms=edu;
MODELEFFECTS INTERCEPT 
		    heduc1 heduc2 
			midwest south west cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_edut;
PROC MIANALYZE parms=edu_t;
MODELEFFECTS INTERCEPT 
		    husbeduc 
		    midwest south west cohort chage white sex ;
RUN;

title ' socio-environmental factors '; 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = heduc1 heduc2 fincome1 fincome2 fincome3
			    midwest south west  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = inc;
 run;
 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = husbeduc income
 				midwest south west  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =inc_t;
 run;
 
TITLE " multiple imputation - socio-environmental factors";
ods output ParameterEstimates=mi_inc;
PROC MIANALYZE parms=inc;
MODELEFFECTS INTERCEPT 
		   heduc1 heduc2 fincome1 fincome2 fincome3
			midwest south west cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_inct;
PROC MIANALYZE parms=inc_t;
MODELEFFECTS INTERCEPT 
		        husbeduc income  
		        midwest south west cohort chage white sex ;
RUN;

title ' socio-environmental factors '; 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3
			    midwest south west  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = socio;
 run;
 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = ses_m husbeduc income
 				midwest south west  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =socio_t;
 run;
 
TITLE " multiple imputation - socio-environmental factors";
ods output ParameterEstimates=mi_soc;
PROC MIANALYZE parms=socio;
MODELEFFECTS INTERCEPT 
		sesq0 sesq1 sesq2  heduc1 heduc2 fincome1 fincome2 fincome3
			midwest south west cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_soct;
PROC MIANALYZE parms=socio_t;
MODELEFFECTS INTERCEPT 
		ses_m husbeduc income  midwest south west
  				cohort chage white sex ;
RUN;

/**********************************************************************/
title ' personal modifiable factors ';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = &chwestq_ &chstq_ &chpaq_ &chcalq_ chbmibase &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = life;
 run;
 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = chwest_m chst_m chpa_m chcal_m chbmibase &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =life_t;
 run;

TITLE " multiple imputation - personal modifiable factors";
ods output ParameterEstimates=mi_life;
PROC MIANALYZE parms=life;
MODELEFFECTS INTERCEPT 
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 
		chcalq1 chcalq2 chcalq3 
  			chbmibase	cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_lifet;
PROC MIANALYZE parms=life_t;
MODELEFFECTS INTERCEPT  
		chwest_m chst_m chpa_m chcal_m 
  			chbmibase	cohort chage white sex ;
RUN;	
		
  
*****************************************;
************** PREPARE DATA FOR TABLE *************************;
data allow;
length Parm $ 15;
   set mi_mom(in=a) mi_momt(in=b) mi_mob(in=c) 
   	   mi_momsensi(in=d) mi_momsensit(in=e) mi_mobsensi(in=f) 
   	   mi_uter(in=g) mi_pregob(in=h)  
   	   mi_soc(in=i) mi_soct(in=j) mi_edu(in=k) mi_edut(in=l)
   	   mi_inc(in=m) mi_inct(in=n)  mi_life(in=o) mi_lifet(in=p) ;
  	
  	if a then mod="mom";
  	if b then mod="mom trend";
  	if c then mod="mom ow";
  	if d then mod="mom sensi";
  	if e then mod="mom sensi trend";
  	if f then mod="mom ow sensi";
  	if g then mod="uter";
  	if h then mod="pregow";
  	if i then mod="socio";
  	if j then mod="socio trend";
  	if k then mod="edu";
  	if l then mod="edu trend";
  	if m then mod="income";
  	if n then mod="income trend";
  	if o then mod="life";
  	if p then mod="life trend";

	RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
   
run; 

proc export data=allow
     outfile='/udd/nhywa/GUTSOB/gee_ow_MI.csv'
     dbms=csv
     replace;
run;


 