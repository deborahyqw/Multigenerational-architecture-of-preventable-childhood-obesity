/*******************************************************************************
Program name: gee_ob_par_sensi.sas
Purpose: Calculate PAR for all exposures for obesity risk - complete case analysis
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
            
    if region=2 then region2=1; else region2=0;
    if region=3 then region3=1; else region3=0;
    if region=4 then region4=1; else region4=0;

run; 

%LET covar1= cohort chage white sex ;
run;

/**********************************************************************/
/**********************************************************************/
title ' personal modifiable factors ';
proc genmod data = all descending;
 class id momid ;
   model chob = &chwestq_ &chstq_ &chpaq_ &chcalq_ chbmibase &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covchild GEEEmpPEst = child;
 run;
   
data betas; 
  set child end=_end_ ;  
  _type_ = 'PARM';
	retain intercept chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		    chbmibase cohort chage white sex;
	
    if _n_ eq 1 then intercept = estimate;
    else if _n_ eq 2 then chwestq1  = estimate;
    else if _n_ eq 3 then chwestq2  = estimate;
    else if _n_ eq 4 then chwestq3  = estimate;
    else if _n_ eq 5 then chstq1   = estimate;
    else if _n_ eq 6 then chstq2   = estimate;
	else if _n_ eq 7 then chstq3   = estimate;
	else if _n_ eq 8 then chpaq0   = estimate;
	else if _n_ eq 9 then chpaq1   = estimate;
	else if _n_ eq 10 then chpaq2  = estimate;
	else if _n_ eq 11 then chcalq1   = estimate;
	else if _n_ eq 12 then chcalq2   = estimate;
	else if _n_ eq 13 then chcalq3   = estimate;
	else if _n_ eq 14 then chbmibase = estimate;
    else if _n_ eq 15 then cohort   = estimate;
    else if _n_ eq 16 then chage    = estimate;
    else if _n_ eq 17 then white    = estimate;
    else if _n_ eq 18 then sex      = estimate;
    
    if _end_ then output;
run;

data covparms;  
	set covchild;  
	length _type_ $4;  _type_ = 'COV';

	rename  Prm1=intercept   Prm2=chwestq1   Prm3=chwestq2   Prm4=chwestq3   Prm5=chstq1  
			Prm6=chstq2      Prm7=chstq3     Prm8=chpaq0     Prm9=chpaq1     Prm10=chpaq2 
			Prm11=chcalq1    Prm12=chcalq2   Prm13=chcalq3   Prm14=chbmibase
			Prm15=cohort     Prm16=chage     Prm17=white     Prm18=sex   ;

	length _name_ $10;
	
		if _n_ eq 1 then  _name_ = 'INTERCEPT';
		else if _n_ eq 2 then  _name_ = 'chwestq1';
		else if _n_ eq 3 then  _name_ = 'chwestq2';
		else if _n_ eq 4 then  _name_ = 'chwestq3';
		else if _n_ eq 5 then  _name_ = 'chstq1';
		else if _n_ eq 6 then  _name_ = 'chstq2';
		else if _n_ eq 7 then  _name_ = 'chstq3';
		else if _n_ eq 8 then  _name_ = 'chpaq0';
		else if _n_ eq 9 then  _name_ = 'chpaq1';
		else if _n_ eq 10 then  _name_ = 'chpaq2';
		else if _n_ eq 11 then  _name_ = 'chcalq1';
		else if _n_ eq 12 then  _name_ = 'chcalq2';
		else if _n_ eq 13 then  _name_ = 'chcalq3';
		else if _n_ eq 14 then  _name_ = 'chbmibase';
		else if _n_ eq 15 then  _name_ = 'cohort';
		else if _n_ eq 16 then  _name_ = 'chage';
		else if _n_ eq 17 then  _name_ = 'white';
		else if _n_ eq 18 then  _name_ = 'sex';

keep _type_ _name_ prm1-prm18 ;

run;

data betacov;  
	set betas covparms;  
	keep _type_ _name_ 
			intercept chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex ;
run;

*frequency/prevalence dataset;
proc sort data=all;
	by  chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex ;
run;
proc means noprint data=all; 
	by  chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex  ;
	var momid;
	output out=freqs n=fq;
run;

%par(bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chwestq1 chwestq2 chwestq3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= west,
	fixedvar= chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);

%par(bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chwestq1  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= west1,
	fixedvar= chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chwestq2 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= west2,
	fixedvar= chwestq1 chwestq3  chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chwestq3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= west3,
	fixedvar= chwestq1 chwestq2 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chstq1 chstq2 chstq3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= sed,
	fixedvar= chwestq1 chwestq2 chwestq3  
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chstq1 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= sed1,
	fixedvar= chwestq1 chwestq2 chwestq3  chstq2 chstq3
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chstq2 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= sed2,
	fixedvar= chwestq1 chwestq2 chwestq3  chstq1 chstq3
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chstq3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= sed3,
	fixedvar= chwestq1 chwestq2 chwestq3 chstq1 chstq2
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chpaq0 chpaq1 chpaq2,
	missvarlist=NONE,
	partialpar= T,
	outdat= pa,
	fixedvar= chstq1 chstq2 chstq3 chwestq1 chwestq2 chwestq3
			 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chpaq0 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= pa0,
	fixedvar= chstq1 chstq2 chstq3 chwestq1 chwestq2 chwestq3
			 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chpaq1 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= pa1,
	fixedvar= chstq1 chstq2 chstq3 chwestq1 chwestq2 chwestq3
			chpaq0 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chpaq2,
	missvarlist=NONE,
	partialpar= T,
	outdat= pa2,
	fixedvar= chstq1 chstq2 chstq3 chwestq1 chwestq2 chwestq3
			 chpaq0 chpaq1  chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2,
	missvarlist=NONE,
	partialpar= T,
	outdat= child,
	fixedvar=  chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);
			
/**********************************************************************/
/**********************************************************************/
title ' education & income '; 
proc genmod data = all descending;
 class id momid ;
   model chob = heduc1 heduc2 fincome1 fincome2 fincome3
			    region2 region3 region4 &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covsoc GEEEmpPEst = soc;
 run;
   
data betas; 
  set soc end=_end_ ;  
  _type_ = 'PARM';
	retain intercept  heduc1 heduc2 fincome1 fincome2 fincome3
			region2 region3 region4 cohort chage white sex;
	
    if _n_ eq 1 then intercept = estimate;
 	else if _n_ eq 2 then heduc1   = estimate;
    else if _n_ eq 3 then heduc2   = estimate;
    else if _n_ eq 4 then fincome1   = estimate;
    else if _n_ eq 5 then fincome2   = estimate;
    else if _n_ eq 6 then fincome3   = estimate;
    else if _n_ eq 7 then region2  = estimate;
    else if _n_ eq 8 then region3  = estimate;
    else if _n_ eq 9 then region4  = estimate;
    else if _n_ eq 10 then cohort   = estimate;
    else if _n_ eq 11 then chage    = estimate;
    else if _n_ eq 12 then white    = estimate;
    else if _n_ eq 13 then sex      = estimate;
    
    if _end_ then output;
	  
run;

data covparms;  
	set covsoc;  
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=heduc1    Prm3=heduc2     
			Prm4=fincome1    Prm5=fincome2     Prm6=fincome3
			Prm7=region2     Prm8=region3     Prm9=region4  
			Prm10=cohort     Prm11=chage     Prm12=white    Prm13=sex   ;

	length _name_ $10;
	
		if _n_ eq 1 then  _name_ = 'INTERCEPT';
		else if _n_ eq 2 then  _name_ = 'heduc1';
		else if _n_ eq 3 then  _name_ = 'heduc2';
		else if _n_ eq 4 then  _name_ = 'fincome1';
		else if _n_ eq 5 then  _name_ = 'fincome2';
		else if _n_ eq 6 then  _name_ = 'fincome3';
		else if _n_ eq 7 then  _name_ = 'region2';
		else if _n_ eq 8 then  _name_ = 'region3';
		else if _n_ eq 9 then  _name_ = 'region4';
		else if _n_ eq 10 then  _name_ = 'cohort';
		else if _n_ eq 11 then  _name_ = 'chage';
		else if _n_ eq 12 then  _name_ = 'white';
		else if _n_ eq 13 then  _name_ = 'sex';

keep  _type_ _name_ prm1-prm13 ;

run;
*proc print data=covparms; 

data betacov;  
	set betas covparms;  
	keep _type_ _name_ 
			intercept heduc1 heduc2
				fincome1 fincome2 fincome3
				region2 region3 region4 cohort chage white sex ;
run;

*frequency/prevalence dataset;
proc sort data=all;
	by  heduc1 heduc2
				fincome1 fincome2 fincome3
				 region2 region3 region4 cohort chage white sex ;
run;
proc means noprint data=all; 
	by  heduc1 heduc2
				fincome1 fincome2 fincome3
				region2 region3 region4 cohort chage white sex  ;
	var momid;
	output out=freqs n=fq;
run;

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= heduc1 heduc2 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= educ,
	fixedvar= fincome1 fincome2 fincome3
   			region2 region3 region4 cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= heduc1 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= educ1,
	fixedvar= heduc2 fincome1 fincome2 fincome3
   			region2 region3 region4 cohort chage white sex );
					 
%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= heduc2 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= educ2,
	fixedvar= heduc1 fincome1 fincome2 fincome3
   			region2 region3 region4 cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= fincome1 fincome2 fincome3,
	missvarlist=NONE,
	partialpar= T,
	outdat= inc,
	fixedvar= heduc1  heduc2
   			region2 region3 region4 cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= fincome1 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= inc1,
	fixedvar= heduc1  heduc2 fincome2 fincome3
   			region2 region3 region4 cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= fincome2 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= inc2,
	fixedvar= heduc1  heduc2 fincome1 fincome3
   			region2 region3 region4 cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= fincome3,
	missvarlist=NONE,
	partialpar= T,
	outdat= inc3,
	fixedvar= heduc1  heduc2 fincome1 fincome2
   			region2 region3 region4 cohort chage white sex );

/**********************************************************************/
/**********************************************************************/ 
title ' socio-environmental factors '; 
proc genmod data = all descending;
 class id momid;
   model chob = heduc1 heduc2 fincome1 fincome2 fincome3
			    region2 region3 region4 &covar1 sesq0 sesq1 sesq2 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covsoc GEEEmpPEst = soc;
 run;
   
data betas; 
  set soc end=_end_ ;  
  _type_ = 'PARM';
	retain intercept heduc1 heduc2 fincome1 fincome2 fincome3
			region2 region3 region4 cohort chage white sex  sesq0 sesq1 sesq2 ;
	
    if _n_ eq 1 then intercept = estimate;
 	else if _n_ eq 2 then heduc1   = estimate;
    else if _n_ eq 3 then heduc2   = estimate;
    else if _n_ eq 4 then fincome1   = estimate;
    else if _n_ eq 5 then fincome2   = estimate;
    else if _n_ eq 6 then fincome3   = estimate;
    else if _n_ eq 7 then region2  = estimate;
    else if _n_ eq 8 then region3  = estimate;
    else if _n_ eq 9 then region4  = estimate;
    else if _n_ eq 10 then cohort   = estimate;
    else if _n_ eq 11 then chage    = estimate;
    else if _n_ eq 12 then white    = estimate;
    else if _n_ eq 13 then sex      = estimate;
    else if _n_ eq 14 then sesq0   = estimate;
    else if _n_ eq 15 then sesq1   = estimate;
    else if _n_ eq 16 then sesq2   = estimate;
    
    if _end_ then output;
  
run;

data covparms;  
	set covsoc;  
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=heduc1    Prm3=heduc2     
			Prm4=fincome1    Prm5=fincome2     Prm6=fincome3
			Prm7=region2     Prm8=region3      Prm9=region4     
			Prm10=cohort     Prm11=chage     Prm12=white    Prm13=sex   
			Prm14=sesq0      Prm15=sesq1     Prm16=sesq2;

	length _name_ $10;
	
		if _n_ eq 1 then  _name_ = 'INTERCEPT';
		else if _n_ eq 2 then  _name_ = 'heduc1';
		else if _n_ eq 3 then  _name_ = 'heduc2';
		else if _n_ eq 4 then  _name_ = 'fincome1';
		else if _n_ eq 5 then  _name_ = 'fincome2';
		else if _n_ eq 6 then  _name_ = 'fincome3';
		else if _n_ eq 7 then  _name_ = 'region2';
		else if _n_ eq 8 then  _name_ = 'region3';
		else if _n_ eq 9 then  _name_ = 'region4';
		else if _n_ eq 10 then  _name_ = 'cohort';
		else if _n_ eq 11 then  _name_ = 'chage';
		else if _n_ eq 12 then  _name_ = 'white';
		else if _n_ eq 13 then  _name_ = 'sex';
		else if _n_ eq 14 then  _name_ = 'sesq0';
		else if _n_ eq 15 then  _name_ = 'sesq1';
		else if _n_ eq 16 then  _name_ = 'sesq2';

keep  _type_ _name_ prm1-prm16 ;

run;

data betacov;  
	set betas covparms;  
	keep  _type_ _name_ 
			intercept heduc1 heduc2 fincome1 fincome2 fincome3
			region2 region3 region4 cohort chage white sex sesq0 sesq1 sesq2;
run;

*frequency/prevalence dataset;
proc sort data=all;
	by  heduc1 heduc2 fincome1 fincome2 fincome3
		region2 region3 region4 cohort chage white sex sesq0 sesq1 sesq2;
run;
proc means noprint data=all; 
	by heduc1 heduc2 fincome1 fincome2 fincome3
		region2 region3 region4 cohort chage white sex sesq0 sesq1 sesq2 ;
	var momid;
	output out=freqs n=fq;
run;

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  sesq0 sesq1 sesq2  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= ses,
	fixedvar= heduc1 heduc2 fincome1 fincome2 fincome3
   			region2 region3 region4 cohort chage white sex);

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  sesq0  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= ses0,
	fixedvar= heduc1 heduc2 fincome1 fincome2 fincome3
   			region2 region3 region4 cohort chage white sex sesq1 sesq2);

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  sesq1 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= ses1,
	fixedvar= heduc1 heduc2 fincome1 fincome2 fincome3
   			region2 region3 region4 cohort chage white sex sesq0 sesq2 );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= sesq2  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= ses2,
	fixedvar= heduc1 heduc2 fincome1 fincome2 fincome3
   			region2 region3 region4 cohort chage white sex sesq0 sesq1);

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= sesq0 sesq1 sesq2 heduc1 heduc2
        			fincome1 fincome2 fincome3  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= soc,
	fixedvar= region2 region3 region4 cohort chage white sex );

/**********************************************************************/
/**********************************************************************/
title ' maternal modifiable factors - not adjusting for moob because it may be on the causal pathways ';
proc genmod data = all descending;
 class id momid ;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_ 
  			    moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covmom GEEEmpPEst = mom;
 run;
   
data betas; 
  set mom end=_end_ ;  
  _type_ = 'PARM';
	retain intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
					 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3
					moshiftq1 moshiftq2 moshiftq3
					moage cohort chage white sex;
	
     if _n_ eq 1 then intercept = estimate;
    else if _n_ eq 2 then mowestq1  = estimate;
    else if _n_ eq 3 then mowestq2  = estimate;
    else if _n_ eq 4 then mowestq3  = estimate;
    else if _n_ eq 5 then mocalq1   = estimate;
    else if _n_ eq 6 then mocalq2   = estimate;
	else if _n_ eq 7 then mocalq3   = estimate;
	else if _n_ eq 8 then mopaq0   = estimate;
	else if _n_ eq 9 then mopaq1   = estimate;
	else if _n_ eq 10 then mopaq2   = estimate;
	else if _n_ eq 11 then mosmk2  = estimate;
	else if _n_ eq 12 then mosmk3  = estimate;
	else if _n_ eq 13 then moshiftq1= estimate;
	else if _n_ eq 14 then moshiftq2= estimate;
	else if _n_ eq 15 then moshiftq3= estimate;
    else if _n_ eq 16 then moage    = estimate;
    else if _n_ eq 17 then cohort   = estimate;
    else if _n_ eq 18 then chage    = estimate;
    else if _n_ eq 19 then white    = estimate;
    else if _n_ eq 20 then sex      = estimate;
	
	if _end_ then output;
	
	if mowestq1 < 0 then  mowestq1=0;
run;
*proc print data=betas; 

data covparms;  
	set covmom;  
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=mowestq1   Prm3=mowestq2   Prm4=mowestq3   Prm5=mocalq1  
			Prm6=mocalq2     Prm7=mocalq3    
			Prm8=mopaq0     Prm9=mopaq1    Prm10=mopaq2    Prm11=mosmk2   Prm12=mosmk3 
			Prm13=moshiftq1  Prm14=moshiftq2  Prm15=moshiftq3   Prm16=moage 
			Prm17=cohort     Prm18=chage      Prm19=white       Prm20=sex   ;

	length _name_ $10;
	
		if _n_ eq 1 then  _name_ = 'INTERCEPT';
		else if _n_ eq 2 then  _name_ = 'mowestq1';
		else if _n_ eq 3 then  _name_ = 'mowestq2';
		else if _n_ eq 4 then  _name_ = 'mowestq3';
		else if _n_ eq 5 then  _name_ = 'mocalq1';
		else if _n_ eq 6 then  _name_ = 'mocalq2';
		else if _n_ eq 7 then  _name_ = 'mocalq3';
		else if _n_ eq 8 then  _name_ = 'mopaq0';
		else if _n_ eq 9 then  _name_ = 'mopaq1';
		else if _n_ eq 10 then  _name_ = 'mopaq2';
		else if _n_ eq 11 then  _name_ = 'mosmk2';
		else if _n_ eq 12 then  _name_ = 'mosmk3';
		else if _n_ eq 13 then  _name_ = 'moshiftq1';
		else if _n_ eq 14 then  _name_ = 'moshiftq2';
		else if _n_ eq 15 then  _name_ = 'moshiftq3';
		else if _n_ eq 16 then  _name_ = 'moage';
		else if _n_ eq 17 then  _name_ = 'cohort';
		else if _n_ eq 18 then  _name_ = 'chage';
		else if _n_ eq 19 then  _name_ = 'white';
		else if _n_ eq 20 then  _name_ = 'sex';

keep  _type_ _name_ prm1-prm20 ;

run;

data betacov;  
	set betas covparms;  
	keep  _type_ _name_ 
			intercept mowestq1   mowestq2   mowestq3   mocalq1  
			  mocalq2    mocalq3    mopaq0     mopaq1     mopaq2     
			  mosmk2 mosmk3  moshiftq1  moshiftq2  moshiftq3  
			  moage      cohort     chage    white   sex ;
run;

*frequency/prevalence dataset;
proc sort data=all;
	by  mowestq1   mowestq2   mowestq3   mocalq1  
			  mocalq2    mocalq3   
			  mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
			  moshiftq2  moshiftq3  moage      cohort     chage    white   sex ;
run;
proc means noprint data=all; 
	by  mowestq1   mowestq2   mowestq3   mocalq1  
		 mocalq2    mocalq3    
		 mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
		 moshiftq2  moshiftq3  moage      cohort     chage    white   sex  ;
	var momid;
	output out=freqs n=fq;
run;

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= mowestq1 mowestq2 mowestq3  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mwest,
	fixedvar= mocalq1  mocalq2  mocalq3    
		 		 mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= mowestq1  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mwest1,
	fixedvar=  mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		 mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= mowestq2  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mwest2,
	fixedvar=  mowestq1 mowestq3 mocalq1  mocalq2  mocalq3    
		 		 mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  mowestq3  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mwest3,
	fixedvar= mowestq1 mowestq2 mocalq1  mocalq2  mocalq3    
		 		 mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  mopaq0    mopaq1    mopaq2   ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mpa,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  mopaq0 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mpa0,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		 mopaq1    mopaq2   mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  mopaq1 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mpa1,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		 mopaq0    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=   mopaq2   ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mpa2,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		mopaq0    mopaq1     mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= mosmk2 mosmk3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= msmk,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		mopaq0    mopaq1    mopaq2       
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= mosmk2 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= msmk2,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		mopaq0    mopaq1    mopaq2    mosmk3    
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  mosmk3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= msmk3,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		mopaq0    mopaq1    mopaq2   mosmk2    
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= moshiftq1 moshiftq2 moshiftq3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mshift,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		mopaq0    mopaq1    mopaq2   mosmk2  mosmk3  
		 		  moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= moshiftq1  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mshift1,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		mopaq0    mopaq1    mopaq2   mosmk2  mosmk3  
		 		moshiftq2 moshiftq3  moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= moshiftq2 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mshift2,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		mopaq0    mopaq1    mopaq2   mosmk2  mosmk3  
		 	moshiftq1 moshiftq3  moage cohort chage white sex );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= moshiftq3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mshift3,
	fixedvar= mowestq1 mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
		 		mopaq0    mopaq1    mopaq2   mosmk2  mosmk3  
		 	moshiftq1 moshiftq2  moage cohort chage white sex );
        		  		 		 		 		 		 		 
/**********************************************************************/
title ' maternal modifiable factors - moob ';
proc genmod data = all descending;
 class id momid ;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_ 
  			    moage &covar1 moob
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covmom GEEEmpPEst = mom;
 run;
   
data betas; 
  set mom end=_end_ ;  
  _type_ = 'PARM';
	retain intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
					 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 
					moshiftq1 moshiftq2 moshiftq3
					moage cohort chage white sex moob;
	
         if _n_ eq 1 then intercept = estimate;
    else if _n_ eq 2 then mowestq1  = estimate;
    else if _n_ eq 3 then mowestq2  = estimate;
    else if _n_ eq 4 then mowestq3  = estimate;
    else if _n_ eq 5 then mocalq1   = estimate;
    else if _n_ eq 6 then mocalq2   = estimate;
	else if _n_ eq 7 then mocalq3   = estimate;
	else if _n_ eq 8 then mopaq0   = estimate;
	else if _n_ eq 9 then mopaq1   = estimate;
	else if _n_ eq 10 then mopaq2   = estimate;
	else if _n_ eq 11 then mosmk2  = estimate;
	else if _n_ eq 12 then mosmk3  = estimate;
	else if _n_ eq 13 then moshiftq1= estimate;
	else if _n_ eq 14 then moshiftq2= estimate;
	else if _n_ eq 15 then moshiftq3= estimate;
    else if _n_ eq 16 then moage    = estimate;
    else if _n_ eq 17 then cohort   = estimate;
    else if _n_ eq 18 then chage    = estimate;
    else if _n_ eq 19 then white    = estimate;
    else if _n_ eq 20 then sex      = estimate;
    else if _n_ eq 21 then moob     = estimate;
   
   if _end_ then output;
   
  if mowestq1 <0 then  mowestq1 =0;    if mowestq2 <0 then  mowestq2 =0;

run;

data covparms;  
	set covmom;  
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=mowestq1   Prm3=mowestq2   Prm4=mowestq3   Prm5=mocalq1  
			Prm6=mocalq2     Prm7=mocalq3    
			Prm8=mopaq0      Prm9=mopaq1     Prm10=mopaq2    Prm11=mosmk2  Prm12=mosmk3 
			Prm13=moshiftq1  Prm14=moshiftq2  Prm15=moshiftq3 Prm16=moage 
			Prm17=cohort     Prm18=chage     Prm19=white     Prm20=sex   Prm21=moob ;

	length _name_ $10;
	
		     if _n_ eq 1 then  _name_ = 'INTERCEPT';
		else if _n_ eq 2 then  _name_ = 'mowestq1';
		else if _n_ eq 3 then  _name_ = 'mowestq2';
		else if _n_ eq 4 then  _name_ = 'mowestq3';
		else if _n_ eq 5 then  _name_ = 'mocalq1';
		else if _n_ eq 6 then  _name_ = 'mocalq2';
		else if _n_ eq 7 then  _name_ = 'mocalq3';
		else if _n_ eq 8 then  _name_ = 'mopaq0';
		else if _n_ eq 9 then  _name_ = 'mopaq1';
		else if _n_ eq 10 then  _name_ = 'mopaq2';
		else if _n_ eq 11 then  _name_ = 'mosmk2';
		else if _n_ eq 12 then  _name_ = 'mosmk3';
		else if _n_ eq 13 then  _name_ = 'moshiftq1';
		else if _n_ eq 14 then  _name_ = 'moshiftq2';
		else if _n_ eq 15 then  _name_ = 'moshiftq3';
		else if _n_ eq 16 then  _name_ = 'moage';
		else if _n_ eq 17 then  _name_ = 'cohort';
		else if _n_ eq 18 then  _name_ = 'chage';
		else if _n_ eq 19 then  _name_ = 'white';
		else if _n_ eq 20 then  _name_ = 'sex';
		else if _n_ eq 21 then  _name_ = 'moob';	

keep  _type_ _name_ prm1-prm21 ;

run;
*proc print data=covparms; 

data betacov;  
	set betas covparms;  
	keep  _type_ _name_ 
			intercept mowestq1   mowestq2   mowestq3   mocalq1  
			  mocalq2    mocalq3    mopaq0     mopaq1     mopaq2     
			  mosmk2  mosmk3  moshiftq1 moshiftq2  moshiftq3  
			  moage      cohort     chage    white   sex moob ;
run;

*frequency/prevalence dataset;
proc sort data=all;
	by mowestq1   mowestq2   mowestq3   mocalq1  
			  mocalq2    mocalq3    
			  mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
			  moshiftq2  moshiftq3  moage      cohort     chage    white   sex moob;
run;
proc means noprint data=all; 
	by  mowestq1   mowestq2   mowestq3   mocalq1  
		 mocalq2    mocalq3    
		 mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
		 moshiftq2  moshiftq3  moage      cohort     chage    white   sex moob ;
	var momid;
	output out=freqs n=fq;
run;

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= moob ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mob,
	fixedvar= mowestq1  mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
        		   mopaq0    mopaq1    mopaq2    mosmk2  mosmk3  
		 	moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex );      		  		 		 		 		 		 		 

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= mowestq1  mowestq2 mowestq3   mopaq0    mopaq1    mopaq2   mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moob ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mom,
	fixedvar= mocalq1  mocalq2  mocalq3  moage cohort chage white sex);
        		  		 		 		 		 		 		 
/**********************************************************************/
/**********************************************************************/
title ' in-uterine factors - adjusting for bpregob & agebirth';
proc genmod data = all descending;
 class id momid ;
   model chob = agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
                bpregob prev_preg1 prev_preg2 prev_preg3 &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covuter GEEEmpPEst = uter;
 run;
   
data betas; 
  set uter end=_end_ ;  
  _type_ = 'PARM';
	retain intercept agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
                bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex;
	
          if _n_ eq 1 then intercept = estimate;
    else if _n_ eq 2 then agebirth  = estimate;
    else if _n_ eq 3 then abwt1     = estimate;
    else if _n_ eq 4 then abwt3     = estimate;
    else if _n_ eq 5 then gweek1    = estimate;
    else if _n_ eq 6 then gweek3    = estimate;
    else if _n_ eq 7 then Delivery  = estimate;
	else if _n_ eq 8 then pregcomp2  = estimate;
	else if _n_ eq 9 then bpregob   = estimate;
	else if _n_ eq 10 then prev_preg1= estimate;
	else if _n_ eq 11 then prev_preg2  = estimate;
	else if _n_ eq 12 then prev_preg3  = estimate;
    else if _n_ eq 13 then cohort   = estimate;
    else if _n_ eq 14 then chage    = estimate;
    else if _n_ eq 15 then white    = estimate;
    else if _n_ eq 16 then sex      = estimate; 
    
    if _end_ then output;
run;

data covparms;  
	set covuter;  
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=agebirth   Prm3=abwt1      Prm4=abwt3         Prm5=gweek1  
			Prm6=gweek3      Prm7=Delivery   Prm8=pregcomp2   Prm9=bpregob    
			Prm10=prev_preg1    Prm11=prev_preg2    Prm12=prev_preg3 
			Prm13=cohort    Prm14=chage     Prm15=white        Prm16=sex   ;

	length _name_ $10;
	
		     if _n_ eq 1 then  _name_ = 'INTERCEPT';
		else if _n_ eq 2 then  _name_ = 'agebirth';
		else if _n_ eq 3 then  _name_ = 'abwt1';
		else if _n_ eq 4 then  _name_ = 'abwt3';
		else if _n_ eq 5 then  _name_ = 'gweek1';
		else if _n_ eq 6 then  _name_ = 'gweek3';
		else if _n_ eq 7 then  _name_ = 'Delivery';
		else if _n_ eq 8 then  _name_ = 'pregcomp2';
		else if _n_ eq 9 then  _name_ = 'bpregob';
		else if _n_ eq 10 then  _name_ = 'prev_preg1';
		else if _n_ eq 11 then  _name_ = 'prev_preg2';
		else if _n_ eq 12 then  _name_ = 'prev_preg3';
		else if _n_ eq 13 then  _name_ = 'cohort';
		else if _n_ eq 14 then  _name_ = 'chage';
		else if _n_ eq 15 then  _name_ = 'white';
		else if _n_ eq 16 then  _name_ = 'sex';
	
keep _type_ _name_ prm1-prm16 ;
run;

data betacov;  
	set betas covparms;  
	keep  _type_ _name_ 
			intercept agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex ;
run;

*frequency/prevalence dataset;
proc sort data=all;
	by  agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex ;
run;
proc means noprint data=all; 
	by  agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex  ;
	var momid;
	output out=freqs n=fq;
run;

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= abwt1 abwt3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= birthw,
	fixedvar= agebirth gweek1 gweek3 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex    );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= abwt1  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= birthw1,
	fixedvar= agebirth abwt3 gweek1 gweek3 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex    );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  abwt3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= birthw3,
	fixedvar= agebirth abwt1 gweek1 gweek3 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex    );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  gweek1 gweek3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= week,
	fixedvar= agebirth abwt1 abwt3 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex    );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  gweek1  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= week1,
	fixedvar= agebirth abwt1 abwt3 gweek3 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex    );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  gweek3 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= week3,
	fixedvar= agebirth abwt1 abwt3 gweek1 Delivery pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex    );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= Delivery ,
	missvarlist=NONE,
	partialpar= T,
	outdat= csec,
	fixedvar= agebirth abwt1 abwt3 gweek1 gweek3  pregcomp2
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex    );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= pregcomp2 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= comp,
	fixedvar= agebirth abwt1 abwt3 gweek1 gweek3 Delivery 
  				bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex    );

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob ,
	missvarlist=NONE,
	partialpar= T,
	outdat= uter,
	fixedvar= agebirth 
  				 prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex     );
  		 		 		 		 		 
/**********************************************************************/
title ' bpregob & agebirth - not adjusting for other in-uterine factors factors because they may be on the causal pathways';
proc genmod data = all descending;
 class id momid ;
   model chob = agebirth bpregob prev_preg1 prev_preg2 prev_preg3 &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covuter GEEEmpPEst = uter;
 run;
   
data betas; 
  set uter end=_end_ ;  
  _type_ = 'PARM';
	retain intercept agebirth  bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex;
	
         if _n_ eq 1 then intercept = estimate;
    else if _n_ eq 2 then agebirth  = estimate;
    else if _n_ eq 3 then bpregob   = estimate;
    else if _n_ eq 4 then prev_preg1  = estimate;
    else if _n_ eq 5 then prev_preg2  = estimate;
    else if _n_ eq 6 then prev_preg3  = estimate;
    else if _n_ eq 7 then cohort   = estimate;
    else if _n_ eq 8 then chage    = estimate;
    else if _n_ eq 9 then white    = estimate;
    else if _n_ eq 10 then sex     = estimate;
    
    if _end_ then output;
 
run;

data covparms;  
	set covuter;  
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=agebirth   Prm3=bpregob   Prm4=prev_preg1   Prm5=prev_preg2  
			Prm6=prev_preg3  Prm7=cohort     Prm8=chage     Prm9=white        Prm10=sex   ;

	length _name_ $10;
	
		     if _n_ eq 1 then  _name_ = 'INTERCEPT';
		else if _n_ eq 2 then  _name_ = 'agebirth';
		else if _n_ eq 3 then  _name_ = 'bpregob';
		else if _n_ eq 4 then  _name_ = 'prev_preg1';
		else if _n_ eq 5 then  _name_ = 'prev_preg2';
		else if _n_ eq 6 then  _name_ = 'prev_preg3';
		else if _n_ eq 7 then  _name_ = 'cohort';
		else if _n_ eq 8 then  _name_ = 'chage';
		else if _n_ eq 9 then  _name_ = 'white';
		else if _n_ eq 10 then _name_ = 'sex';
	
keep  _type_ _name_ prm1-prm10 ;
run;

data betacov;  
	set betas covparms;  
	keep  _type_ _name_ 
			intercept agebirth  bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex ;
run;

*frequency/prevalence dataset;
proc sort data=all;
	by agebirth  bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex;
run;
proc means noprint data=all; 
	by agebirth  bpregob prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex ;
	var momid;
	output out=freqs n=fq;
run;

%par( bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= bpregob ,
	missvarlist=NONE,
	partialpar= T,
	outdat= mob,
	fixedvar= agebirth prev_preg1 prev_preg2 prev_preg3 
  				cohort chage white sex     );

/**********************************************************************/
/**********************************************************************/
title ' all factors ';
proc genmod data = all descending;
 class id momid;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 moob &moshiftq_ 
  				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
  				&sesq_ heduc1 heduc2 fincome1 fincome2 fincome3
				&chwestq_ &chstq_ &chpaq_ &chcalq_ 
   				prev_preg1 prev_preg2 prev_preg3 region2 region3 region4
   				moage &covar1 chbmibase
      / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covcomp GEEEmpPEst = comp;
 run;
  
*positive coef:
  		mopaq0 mopaq1 mopaq2 mosmk2 moob moshiftq1 moshiftq2 moshiftq3
		abwt1 abwt3 gweek3 bpregob sesq0 sesq1 sesq2 heduc1 heduc2 fincome2
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 ;

data betas; 
  set comp end=_end_ ;  
  _type_ = 'PARM';
	retain intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
		mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3 
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		prev_preg1 prev_preg2 prev_preg3  region2 region3 region4
		moage cohort chage white sex chbmibase ;
	
    if _n_ eq 1 then intercept = estimate;        else if _n_ eq 2 then mowestq1  = estimate;    
    else if _n_ eq 3 then mowestq2  = estimate;   else if _n_ eq 4 then mowestq3  = estimate;   
    else if _n_ eq 5 then mocalq1   = estimate;   else if _n_ eq 6 then mocalq2   = estimate;
	else if _n_ eq 7 then mocalq3   = estimate;   else if _n_ eq 8 then mopaq0   = estimate;    
	else if _n_ eq 9 then mopaq1   = estimate;    else if _n_ eq 10 then mopaq2   = estimate;    
	else if _n_ eq 11 then mosmk2  = estimate;     else if _n_ eq 12 then mosmk3  = estimate;
	else if _n_ eq 13 then moob     = estimate;    else if _n_ eq 14 then moshiftq1= estimate;    
	else if _n_ eq 15 then moshiftq2= estimate;    else if _n_ eq 16 then moshiftq3= estimate;    
	else if _n_ eq 17 then abwt1     = estimate;   else if _n_ eq 18 then abwt3     = estimate;
    else if _n_ eq 19 then gweek1    = estimate;   else if _n_ eq 20 then gweek3    = estimate;   
    else if _n_ eq 21 then Delivery  = estimate;   else if _n_ eq 22 then pregcomp2  = estimate;  
    else if _n_ eq 23 then bpregob   = estimate;   else if _n_ eq 24 then sesq0     = estimate;   
    else if _n_ eq 25 then sesq1     = estimate;   else if _n_ eq 26 then sesq2     = estimate;   
    else if _n_ eq 27 then heduc1   = estimate;    else if _n_ eq 28 then heduc2   = estimate;
    else if _n_ eq 29 then fincome1  = estimate;   else if _n_ eq 30 then fincome2  = estimate;   
    else if _n_ eq 31 then fincome3   = estimate;  else if _n_ eq 32 then chwestq1  = estimate;   
    else if _n_ eq 33 then chwestq2  = estimate;   else if _n_ eq 34 then chwestq3  = estimate;
    else if _n_ eq 35 then chstq1    = estimate;   else if _n_ eq 36 then chstq2    = estimate;   
    else if _n_ eq 37 then chstq3    = estimate;   else if _n_ eq 38 then chpaq0    = estimate;   
    else if _n_ eq 39 then chpaq1    = estimate;   else if _n_ eq 40 then chpaq2   = estimate;
    else if _n_ eq 41 then chcalq1  = estimate;    else if _n_ eq 42 then chcalq2  = estimate;    
    else if _n_ eq 43 then chcalq3  = estimate;    else if _n_ eq 44 then prev_preg1= estimate;   
    else if _n_ eq 45 then prev_preg2  = estimate; else if _n_ eq 46 then prev_preg3  = estimate; 
    else if _n_ eq 47 then region2  = estimate;    else if _n_ eq 48 then region3  = estimate;
    else if _n_ eq 49 then region4  = estimate;    else if _n_ eq 50 then moage    = estimate;    
    else if _n_ eq 51 then cohort   = estimate;    else if _n_ eq 52 then chage    = estimate;    
    else if _n_ eq 53 then white    = estimate;    else if _n_ eq 54 then sex      = estimate;    
    else if _n_ eq 55 then chbmibase = estimate;
    
    if _end_ then output;
  
  * set negative beta to 0 to 1) avoid errors in PAR and 2) to prevent certain exposures were omitted from PAR calculation;
  if mowestq1 <0 then  mowestq1 =0;    if mowestq2 <0 then  mowestq2 =0;
  if mowestq3 <0 then  mowestq3 =0;    if mosmk3 <0 then mosmk3 =0;     
  if gweek1 <0 then  gweek1=0;         if fincome1 <0 then fincome1 =0; 
  if fincome3 <0 then fincome3 =0;     if Delivery <0 then  Delivery=0; 
  if pregcomp2 <0 then  pregcomp2=0; 
  
run;

data covparms;  
	set covcomp;  
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=mowestq1    Prm3=mowestq2    Prm4=mowestq3    Prm5=mocalq1  
			Prm6=mocalq2     Prm7=mocalq3     Prm8=mopaq0      Prm9=mopaq1     Prm10=mopaq2     
			Prm11=mosmk2     Prm12=mosmk3     Prm13=moob
			Prm14=moshiftq1  Prm15=moshiftq2  Prm16=moshiftq3  Prm17=abwt1      
			Prm18=abwt3      Prm19=gweek1     Prm20=gweek3     Prm21=Delivery   Prm22=pregcomp2   
			Prm23=bpregob    Prm24=sesq0      Prm25=sesq1      Prm26=sesq2      Prm27=heduc1     
			Prm28=heduc2     Prm29=fincome1   Prm30=fincome2   Prm31=fincome3          
			Prm32=chwestq1   Prm33=chwestq2   Prm34=chwestq3   Prm35=chstq1     Prm36=chstq2     
			Prm37=chstq3     Prm38=chpaq0     Prm39=chpaq1     Prm40=chpaq2     Prm41=chcalq1    
			Prm42=chcalq2    Prm43=chcalq3    Prm44=prev_preg1 Prm45=prev_preg2 
			Prm46=prev_preg3 Prm47=region2    Prm48=region3    Prm49=region4     Prm50=moage      
			Prm51=cohort     Prm52=chage      Prm53=white      Prm54=sex        Prm55=chbmibase   ;

	length _name_ $15;
	
	* Assign which row this is (the row "label" in the covariance matrix) ;
	  if _n_ eq 1 then _name_ = 'intercept';        else if _n_ eq 2 then _name_ = 'mowestq1';    
    else if _n_ eq 3 then _name_ = 'mowestq2';   else if _n_ eq 4 then _name_ = 'mowestq3';   
    else if _n_ eq 5 then _name_ = 'mocalq1';   else if _n_ eq 6 then _name_ = 'mocalq2';
	else if _n_ eq 7 then _name_ = 'mocalq3';   else if _n_ eq 8 then _name_ = 'mopaq0';    
	else if _n_ eq 9 then _name_ = 'mopaq1';    else if _n_ eq 10 then _name_ = 'mopaq2';    
	else if _n_ eq 11 then _name_ = 'mosmk2';     else if _n_ eq 12 then _name_ = 'mosmk3';
	else if _n_ eq 13 then _name_ = 'moob';    else if _n_ eq 14 then _name_ = 'moshiftq1';    
	else if _n_ eq 15 then _name_ = 'moshiftq2';    else if _n_ eq 16 then _name_ = 'moshiftq3';    
	else if _n_ eq 17 then _name_ = 'abwt1';   else if _n_ eq 18 then _name_ = 'abwt3';
    else if _n_ eq 19 then _name_ = 'gweek1';   else if _n_ eq 20 then _name_ = 'gweek3';   
    else if _n_ eq 21 then _name_ = 'Delivery';   else if _n_ eq 22 then _name_ = 'pregcomp2';  
    else if _n_ eq 23 then _name_ = 'bpregob';   else if _n_ eq 24 then _name_ = 'sesq0';   
    else if _n_ eq 25 then _name_ = 'sesq1';   else if _n_ eq 26 then _name_ = 'sesq2';   
    else if _n_ eq 27 then _name_ = 'heduc1';    else if _n_ eq 28 then _name_ = 'heduc2';
    else if _n_ eq 29 then _name_ = 'fincome1';   else if _n_ eq 30 then _name_ = 'fincome2';   
    else if _n_ eq 31 then _name_ = 'fincome3';  else if _n_ eq 32 then _name_ = 'chwestq1';   
    else if _n_ eq 33 then _name_ = 'chwestq2';   else if _n_ eq 34 then _name_ = 'chwestq3';
    else if _n_ eq 35 then _name_ = 'chstq1';   else if _n_ eq 36 then _name_ = 'chstq2';   
    else if _n_ eq 37 then _name_ = 'chstq3';   else if _n_ eq 38 then _name_ = 'chpaq0';   
    else if _n_ eq 39 then _name_ = 'chpaq1';   else if _n_ eq 40 then _name_ = 'chpaq2';
    else if _n_ eq 41 then _name_ = 'chcalq1';    else if _n_ eq 42 then _name_ = 'chcalq2';    
    else if _n_ eq 43 then _name_ = 'chcalq3';    else if _n_ eq 44 then _name_ = 'prev_preg1';   
    else if _n_ eq 45 then _name_ = 'prev_preg2'; else if _n_ eq 46 then _name_ = 'prev_preg3'; 
    else if _n_ eq 47 then _name_ = 'region2';    else if _n_ eq 48 then _name_ = 'region3';
    else if _n_ eq 49 then _name_ = 'region4';    else if _n_ eq 50 then _name_ = 'moage';    
    else if _n_ eq 51 then _name_ = 'cohort';    else if _n_ eq 52 then _name_ = 'chage';    
    else if _n_ eq 53 then _name_ = 'white';    else if _n_ eq 54 then _name_ = 'sex';    
    else if _n_ eq 55 then _name_ = 'chbmibase';
  
keep  _type_ _name_ prm1-prm55 ;

run;

data betacov;  
	set betas covparms;  
	keep _type_ _name_ 
			intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
		mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3 
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		prev_preg1 prev_preg2 prev_preg3  region2 region3 region4
		moage cohort chage white sex chbmibase;
run;

*frequency/prevalence dataset;
proc sort data=all;
	by  mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
		mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3 
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		prev_preg1 prev_preg2 prev_preg3  region2 region3 region4
		moage cohort chage white sex chbmibase ;
run;
proc means noprint data=all; 
	by  mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
		mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3 
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		prev_preg1 prev_preg2 prev_preg3  region2 region3 region4
		moage cohort chage white sex chbmibase ;
	var momid;
	output out=freqs n=fq;
run;

/****************** ALL **************************/
**********;		
%par(
	bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  mowestq1 mowestq2 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 
			 moob moshiftq1 moshiftq2 moshiftq3
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= comp,
	fixedvar=  mocalq1 mocalq2 mocalq3  chcalq1 chcalq2 chcalq3 
		      prev_preg1 prev_preg2 prev_preg3 
		      region2 region3 region4 moage chbmibase cohort chage white sex );

/**********************************************************************/
/**********************************************************************/
*********** gestational weight gain **********;

data all; set all end=_end_;
  if cohort=0; *only available in GUTS1;
run; 

title ' in-uterine factors - adjusting for bpregob & agebirth';
proc genmod data = all descending;
 class id momid ;
   model chob = gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covuter GEEEmpPEst = uter;
 run;
   
data betas; 
  set uter end=_end_ ;  
  _type_ = 'PARM';
	retain intercept gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
  				chage white sex;
	
    if _n_ eq 1 then intercept = estimate;
    else if _n_ eq 2 then gotweight  = estimate;
    else if _n_ eq 3 then agebirth  = estimate;
	else if _n_ eq 4 then bpregob   = estimate;
	else if _n_ eq 5 then prev_preg1= estimate;
	else if _n_ eq 6 then prev_preg2  = estimate;
	else if _n_ eq 7 then prev_preg3  = estimate;
    else if _n_ eq 8 then chage    = estimate;
    else if _n_ eq 9 then white    = estimate;
    else if _n_ eq 10 then sex      = estimate;
    
    if _end_ then output;

run;

data covparms;  
	set covuter;  
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=gotweight  Prm3=agebirth   Prm4=bpregob    Prm5=prev_preg1    Prm6=prev_preg2 
			Prm7=prev_preg3  Prm8=chage     Prm9=white        Prm10=sex   ;

	length _name_ $10;
	
		if _n_ eq 1 then  _name_ = 'INTERCEPT';
		else if _n_ eq 2 then  _name_ = 'gotweight';
		else if _n_ eq 3 then  _name_ = 'agebirth';
		else if _n_ eq 4 then  _name_ = 'bpregob';
		else if _n_ eq 5 then  _name_ = 'prev_preg1';
		else if _n_ eq 6 then  _name_ = 'prev_preg2';
		else if _n_ eq 7 then  _name_ = 'prev_preg3';
		else if _n_ eq 8 then  _name_ = 'chage';
		else if _n_ eq 9 then  _name_ = 'white';
		else if _n_ eq 10 then _name_ = 'sex';

keep  _type_ _name_ prm1-prm10 ;
run;

data betacov;  
	set betas covparms;  
	keep  _type_ _name_ 
			intercept  gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
  				chage white sex;
run;

*frequency/prevalence dataset;
proc sort data=all;
	by  gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
  				chage white sex ;
run;
proc means noprint data=all; 
	by  gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
  				chage white sex  ;
	var momid;
	output out=freqs n=fq;
run;

%par(
	bdata=betacov,
	pdata=freqs, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar=  gotweight ,
	missvarlist=NONE,
	partialpar= T,
	outdat= gwt,
	fixedvar=  agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
  				chage white sex  );
 



