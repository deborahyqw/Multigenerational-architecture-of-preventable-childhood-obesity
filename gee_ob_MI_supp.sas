/*******************************************************************************
Program name: gee_ob_MI_supp.sas
Purpose: Examine the associations between individual exposures and obesity risk with multiple imputation -- gestational weigt
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Yiqing Wang (nhywa)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: 12/2024
Purpose: 1) gestational weight gain
		 2) physicians/desert
		 3) additional adjustment for in-uterine factors
*******************************************************************************/

%include '/udd/nhywa/GUTSOB/merge_ob_MI.sas';


/**********************************************************************/
/*****   gestational weigh only available in GUTSI               *****/	
/*****   establish different baselines for different variables   *****/		
/**********************************************************************/
title 'gestational weight gain ';
data all1; set all;
  if cohort=0; *only available in GUTS1;
run; 

proc sort data=all1; by _imputation_; run;

proc freq; table (gotweight prev_preg1 prev_preg2 prev_preg3 bpregob
				white sex  )*chob;

proc genmod data = all1 descending;
	by _imputation_ ;
 class id momid ;
   model chob = gotweight prev_preg1 prev_preg2 prev_preg3 agebirth bpregob chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = geswt;
 run;
 
 TITLE " multiple imputation - personal modifiable factors";
ods output ParameterEstimates=mi_gweight;
PROC MIANALYZE parms=geswt;
MODELEFFECTS INTERCEPT 
			gotweight prev_preg1 prev_preg2 prev_preg3 agebirth bpregob
  				 chage white sex  ;
RUN;

 *****************************************;
************** PREPARE DATA FOR TABLE *************************;
data allob;
length Parm $ 15;
   set  /*mi_swamp(in=a) mi_swampt(in=b) mi_indswamp(in=c) mi_indswampt(in=d)
		mi_swampz(in=e) mi_swampzt(in=f) mi_indswampz(in=g) mi_indswampzt(in=h)
		mi_swampa(in=i) mi_swampat(in=j) mi_indswampa(in=k) mi_indswampat(in=l)*/
		mi_gweight(in=m)
		/*mi_cl(in=n) mi_clt(in=o) mi_desert(in=p) mi_desertt(in=q) */  ;
  	
  	/*if a then mod="swamp";
  	if b then mod="swamp trend";
  	if c then mod="ind swamp";
  	if d then mod="ind swamp trend";
  	if e then mod="swamp zero";
  	if f then mod="swamp zero trend";
  	if g then mod="ind swamp zero";
  	if h then mod="ind swamp zero trend";
  	if i then mod="swamp absolute";
  	if j then mod="swamp absolute trend";
  	if k then mod="ind swamp absolute";
  	if l then mod="ind swamp absolute trend";*/
  	if m then mod="geswtgrain";
  	/*if n then mod="physician";
  	if o then mod="physician trend";
  	if p then mod="food desert";
  	if q then mod="food desert trend";*/

	RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
   
run; 


proc export data=allob
     outfile='/udd/nhywa/GUTSOB/gee_ob_MI_supp.csv'
     dbms=csv
     replace;
run;

/**********************************************************************/
/*******************          Food Swamp           ********************/		
/**********************************************************************/

/*
data all;
  set all;
  cohort=cohort-1;

	%indic3(vbl=sesq, reflev=3, missing=., min=0, max=2, prefix=sesq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');
    %indic3(vbl=foodswampq , reflev=0, missing=., min=1, max=3, prefix=foodswampq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=superq, reflev=0, missing=., min=1, max=3, prefix=superq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=restq, reflev=0, missing=., min=1, max=3, prefix=restq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=fastq, reflev=0, missing=., min=1, max=3, prefix=fastq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=convq, reflev=0, missing=., min=1, max=3, prefix=convq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');    
    %indic3(vbl=foodswampzq , reflev=0, missing=., min=1, max=3, prefix=foodswampzq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=superzq, reflev=0, missing=., min=1, max=3, prefix=superzq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=restzq, reflev=0, missing=., min=1, max=3, prefix=restzq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=fastzq, reflev=0, missing=., min=1, max=3, prefix=fastzq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=convzq, reflev=0, missing=., min=1, max=3, prefix=convzq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');    
    %indic3(vbl=foodswampaq , reflev=0, missing=., min=1, max=3, prefix=foodswampaq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=superaq, reflev=0, missing=., min=1, max=3, prefix=superaq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=restaq, reflev=0, missing=., min=1, max=3, prefix=restaq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=fastaq, reflev=0, missing=., min=1, max=3, prefix=fastaq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=convaq, reflev=0, missing=., min=1, max=3, prefix=convaq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');                   
run;

proc sort data=all; by _imputation_; run;

proc freq data=all; 
	where _imputation_ = 1 ;
	table (foodswampq superq restq fastq convq
			foodswampzq superzq restzq fastzq convzq
			foodswampaq superaq restaq fastaq convaq )*chob; 
run; 

*/

***************************************************************;

/*
TITLE ' Swamp ';  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = &foodswampq_ &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = swamp;
 run;
  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = foodswamp_m ses_m husbeduc income 
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = swamp_t;
 run;
 
TITLE " multiple imputation - Swamp ";
ods output ParameterEstimates=mi_swamp;
PROC MIANALYZE parms=swamp;
MODELEFFECTS INTERCEPT 
		foodswampq1 foodswampq2 foodswampq3 sesq0 sesq1 sesq2 
		heduc1 heduc2 fincome1 fincome2 fincome3 
		midwest south west cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_swampt;
PROC MIANALYZE parms=swamp_t;
MODELEFFECTS INTERCEPT 
				foodswamp_m ses_m husbeduc income
   				midwest south west cohort chage white sex  ;
RUN;

TITLE ' Individual Swamp ';  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = &superq_ &restq_ &fastq_ &convq_ &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = indswamp;
 run;
  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = super_m rest_m fast_m conv_m ses_m husbeduc income
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = indswamp_t;
 run;
 
TITLE " multiple imputation - individual swamp ";
ods output ParameterEstimates=mi_indswamp;
PROC MIANALYZE parms=indswamp;
MODELEFFECTS INTERCEPT 
		superq1 superq2 superq3 restq1 restq2 restq3 fastq1 fastq2 fastq3 convq1 convq2 convq3 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		midwest south west cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_indswampt;
PROC MIANALYZE parms=indswamp_t;
MODELEFFECTS INTERCEPT 
			super_m rest_m fast_m conv_m ses_m husbeduc income
   				midwest south west cohort chage white sex  ;
RUN;

************************************************************;

TITLE ' Swamp zero ';  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = &foodswampzq_ &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = swampz;
 run;
  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = foodswampz_m ses_m husbeduc income 
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = swampz_t;
 run;
 
TITLE " multiple imputation - Swamp zero";
ods output ParameterEstimates=mi_swampz;
PROC MIANALYZE parms=swampz;
MODELEFFECTS INTERCEPT 
		foodswampzq1 foodswampzq2 foodswampzq3 sesq0 sesq1 sesq2 
		heduc1 heduc2 fincome1 fincome2 fincome3 
		midwest south west cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_swampzt;
PROC MIANALYZE parms=swampz_t;
MODELEFFECTS INTERCEPT 
				foodswampz_m ses_m husbeduc income
   				midwest south west cohort chage white sex  ;
RUN;

TITLE ' Individual Swamp zero ';  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = &superzq_ &restzq_ &fastzq_ &convzq_ &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = indswampz;
 run;
  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = superz_m restz_m fastz_m convz_m ses_m husbeduc income
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = indswampz_t;
 run;
 
TITLE " multiple imputation - individual swamp zero";
ods output ParameterEstimates=mi_indswampz;
PROC MIANALYZE parms=indswampz;
MODELEFFECTS INTERCEPT 
		superzq1 superzq2 superzq3 restzq1 restzq2 restzq3 fastzq1 fastzq2 fastzq3 convzq1 convzq2 convzq3 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		midwest south west cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_indswampzt;
PROC MIANALYZE parms=indswampz_t;
MODELEFFECTS INTERCEPT 
			superz_m restz_m fastz_m convz_m ses_m husbeduc income
   				midwest south west cohort chage white sex  ;
RUN;

**************************************************************;

TITLE ' Swamp absolute';  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = &foodswampaq_ &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = swampa;
 run;
  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = foodswampa_m ses_m husbeduc income 
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = swampa_t;
 run;
 
TITLE " multiple imputation - Swamp absolute ";
ods output ParameterEstimates=mi_swampa;
PROC MIANALYZE parms=swampa;
MODELEFFECTS INTERCEPT 
		foodswampaq1 foodswampaq2 foodswampaq3 sesq0 sesq1 sesq2 
		heduc1 heduc2 fincome1 fincome2 fincome3 
		midwest south west cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_swampat;
PROC MIANALYZE parms=swampa_t;
MODELEFFECTS INTERCEPT 
				foodswampa_m ses_m husbeduc income
   				midwest south west cohort chage white sex  ;
RUN;

TITLE ' Individual Swamp absolute ';  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = &superaq_ &restaq_ &fastaq_ &convaq_ &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = indswampa;
 run;
  
proc genmod data = all descending;
 by _imputation_ ;
 class id momid;
   model chob = supera_m resta_m fasta_m conva_m ses_m husbeduc income
   				midwest south west cohort chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = indswampa_t;
 run;
 
TITLE " multiple imputation - individual swamp ";
ods output ParameterEstimates=mi_indswampa;
PROC MIANALYZE parms=indswampa;
MODELEFFECTS INTERCEPT 
		superaq1 superaq2 superaq3 restaq1 restaq2 restaq3 fastaq1 fastaq2 fastaq3 convaq1 convaq2 convaq3 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		midwest south west cohort chage white sex  ;
RUN;
ods output ParameterEstimates=mi_indswampat;
PROC MIANALYZE parms=indswampa_t;
MODELEFFECTS INTERCEPT 
			supera_m resta_m fasta_m conva_m ses_m husbeduc income
   				midwest south west cohort chage white sex  ;
RUN;

*/


************************************************************;
************** only in GUTS2 *******************************;
************** physicians & Desert *************************;
************************************************************;

/*
data all2; set all;
  if cohort=1; *only available in GUTS1;
	
	%indic3(vbl=sesq, reflev=3, missing=., min=0, max=2, prefix=sesq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');
	%indic3(vbl=physicianq, reflev=0, missing=., min=1, max=3, prefix=physicianq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=desertq, reflev=0, missing=., min=1, max=3, prefix=desertq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');   
run;
proc freq data=all2; 
	where _imputation_ = 1 ;
	table ( physicianq desertq )*chob; 
run; 

title ' PHYSICIAN RATIO '; 

 proc genmod data = all2 descending;
 by _imputation_ ;
 class id momid;
   model chob = &physicianq_ &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = clinic;
 run;
  
 proc genmod data = all2 descending;
 by _imputation_ ;
 class id momid;
   model chob = physician_m ses_m husbeduc income
   				midwest south west chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = clinic_t;
 run;
 
TITLE " multiple imputation - physician ";
ods output ParameterEstimates=mi_cl;
PROC MIANALYZE parms=clinic;
MODELEFFECTS INTERCEPT 
		physicianq1 physicianq2 physicianq3 sesq0 sesq1 sesq2 
		heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west chage white sex;
RUN;
ods output ParameterEstimates=mi_clt;
PROC MIANALYZE parms=clinic_t;
MODELEFFECTS INTERCEPT 
				physician_m ses_m husbeduc income
   				midwest south west chage white sex ;
RUN;

title ' FOOD DESERT ';  

 proc genmod data = all2 descending;
 by _imputation_ ;
 class id momid;
   model chob = &desertq_ &sesq_ heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west chage white sex
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = desert;
 run;
  
 proc genmod data = all2 descending;
 by _imputation_ ;
 class id momid;
   model chob = desert_m ses_m husbeduc income
   				 midwest south west chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEEEmpPEst = desert_t;
 run;
 
TITLE " multiple imputation - desert ";
ods output ParameterEstimates=mi_desert;
PROC MIANALYZE parms=desert;
MODELEFFECTS INTERCEPT 
		desertq1 desertq2 desertq3 sesq0 sesq1 sesq2 
		heduc1 heduc2 fincome1 fincome2 fincome3 
   				midwest south west chage white sex;
RUN;
ods output ParameterEstimates=mi_desertt;
PROC MIANALYZE parms=desert_t;
MODELEFFECTS INTERCEPT 
				desert_m  ses_m husbeduc income
   				midwest south west chage white sex ;
RUN;

*/
 
