/*******************************************************************************
Program name: gee_ob_sensi.sas
Purpose: Examine the associations between individual exposures and obesity risk - complete-case analysis
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Yiqing Wang (nhywa)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: 12/2024
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

*%include '/udd/nhywa/GUTSOB/merge_sensi.sas';
filename nhstools '/proj/nhsass/nhsas00/nhstools/sasautos/'; 
filename channing '/usr/local/channing/sasautos/';
filename ehmac '/udd/stleh/ehmac/';
options  mautosource sasautos=(channing nhstools);
libname  nhsfmt   "/proj/nhsass/nhsas00/formats";
options fmtsearch=(nhsfmt);
* options  fmtsearch=(nhsfmt) nofmterr nocenter nonumber nodate formdlim=' ';

options  linesize=150 pagesize=110;
			   
%include '/udd/nhywa/macros/cumavg.macro.sas'; *macro for calculation of CV;

*path to data;
libname here '/udd/nhywa/GUTSOB/sensi/';

/**********************************************************************/
data all;
  set here.allvar_sensi end=_end_;
  cohort=cohort-1;
  
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

proc freq data=all; 
	table ( mowestq mocalq mopaq mosmk2 mosmk3 moob moshiftq bpregob 
			abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
			sesq husbeduc income incom01 
			chwestq chstq chpaq chcalq 
   			cohort white sex 
   			prev_preg1 prev_preg2 prev_preg3
   			region)*chob; 
run; *keep pregcomp instead of individual complications to increase power;

%LET covar1= cohort chage white sex ;

run;

/**********************************************************************/
title ' maternal modifiable factors - not adjusting for moob because it may be on the causal pathways ';
proc genmod data = all descending;
 class id momid ;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3
  				&moshiftq_ 
  			    moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = mom;
 run;
 
proc genmod data = all descending;
 class id momid ;
   model chob = mowest_m mocal_m mopa_m mosmk2 mosmk3
   				moshift_m 
   				moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =mom_t;
 run;
 
 
title ' maternal modifiable factors - moob ';
proc genmod data = all descending;
 class id momid ;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 moob 
  				&moshiftq_ 
  			    moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = mob;
 run;

/**********************************************************************/
title ' in-uterine factors - adjusting for bpregob & oldbirth';
proc genmod data = all descending;
 class id momid ;
   model chob = agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = uter;
 run;


title ' bpregob & agebirth - not adjusting for other in-uterine factors factors because they may be on the causal pathways';
proc genmod data = all descending;
 class id momid ;
   model chob = agebirth bpregob prev_preg1 prev_preg2 prev_preg3 &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = preg;
 run;


/**************************************************************/
/**********************Sensitivity analysis********************/
/**************************************************************/
title ' maternal modifiable factors --- adjusting for in-uterine factors';
proc genmod data = all descending;
 class id momid ;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_
  				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
  			    prev_preg1 prev_preg2 prev_preg3 moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = momsensi;
 run;
 
proc genmod data = all descending;
 class id momid ;
   model chob = mowest_m mocal_m mopa_m mosmk2 mosmk3 moshift_m   
   				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2  bpregob 
   				prev_preg1 prev_preg2 prev_preg3 moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =momsensi_t;
 run;


title ' maternal modifiable factors - moob ';
proc genmod data = all descending;
 class id momid ;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_ moob 
  				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
  			    prev_preg1 prev_preg2 prev_preg3 moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = mobsensi;
 run;


/**********************************************************************/ 
title ' socio-environmental factors '; 
proc genmod data = all descending;
 class id momid region;
   model chob = heduc1 heduc2 fincome1 fincome2 fincome3
			    region  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = inc;
 run;
 
proc genmod data = all descending;
 class id momid region;
   model chob = husbeduc income
 				region  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =inc_t;
 run;
 

title ' socio-environmental factors '; 
proc genmod data = all descending;
 class id momid region;
   model chob = &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3
			    region  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = socio;
 run;
 
proc genmod data = all descending;
 class id momid region;
   model chob = ses_m husbeduc income
 				region  &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =socio_t;
 run;
 

/**********************************************************************/
title ' personal modifiable factors ';
proc genmod data = all descending;
 class id momid ;
   model chob = &chwestq_ &chstq_ &chpaq_ &chcalq_ chbmibase &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = life;
 run;
 
proc genmod data = all descending;
 class id momid ;
   model chob = chwest_m chst_m chpa_m chcal_m chbmibase &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =life_t;
 run;
 
 /**********************************************************************/
title ' all factors '; * to identify negative parameters for PAR;
proc genmod data = all descending;
 class id momid region;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 moob &moshiftq_ 
  				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
  				&sesq_ heduc1 heduc2 fincome1 fincome2 fincome3
				&chwestq_ &chstq_ &chpaq_ &chcalq_ 
   				prev_preg1 prev_preg2 prev_preg3 region
   				moage &covar1 chbmibase
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = complete;
 run;
 
proc genmod data = all descending;
 class id momid region;
   model chob = mowest_m mocal_m mopa_m  mosmk2 mosmk3 moob moshift_m 
   				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
   				ses_m husbeduc income
 				chwest_m chst_m chpa_m chcal_m 
   				prev_preg1 prev_preg2 prev_preg3 region
   				moage &covar1 chbmibase
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst =complete_t;
 run;

/**********************************************************************/
/*****   gestational weigh only available in GUTSI               *****/	
/*****   establish different baselines for different variables   *****/		
/**********************************************************************/
title 'gestational weight gain ';
data all1; set all;
  if cohort=0; *only available in GUTS1;
run; 

proc freq; 
	table (gotweight prev_preg1 prev_preg2 prev_preg3 bpregob
				white sex  )*chob;

proc genmod data = all1 descending;
 class id momid ;
   model chob = gotweight prev_preg1 prev_preg2 prev_preg3 agebirth bpregob chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = geswt;
 run;

*****************************************;
************** PREPARE DATA FOR TABLE *************************;
data allob;
length Parm $ 15;
   set mom(in=a) mom_t(in=b) mob(in=c) 
   	   momsensi(in=d) momsensi_t(in=e) mobsensi(in=f) 
   	   uter(in=g) preg(in=h) inc(in=i) inc_t(in=j) 
   	   socio(in=k) socio_t(in=l)  life(in=m) life_t(in=n)
   	   geswt(in=o) complete(in=p) complete_t(in=q);
  	
  	if a then mod="mom";
  	if b then mod="mom trend";
  	if c then mod="mom ob";
  	if d then mod="mom sensi";
  	if e then mod="mom sensi trend";
  	if f then mod="mom ob sensi";
  	if g then mod="uter";
  	if h then mod="pregob";
  	if i then mod="income";
  	if j then mod="income trend";
  	if k then mod="socio";
  	if l then mod="socio trend";
  	if m then mod="life";
  	if n then mod="life trend";
  	if o then mod="gest wt gain";
  	if p then mod="join";
  	if q then mod="join trend";

	RR=exp(Estimate); LCI=exp(LowerCL); UCI=exp(UpperCL);
   
run; 

proc export data=allob
     outfile='/udd/nhywa/GUTSOB/sensi/gee_ob_sensi.csv'
     dbms=csv
     replace;
run;


 