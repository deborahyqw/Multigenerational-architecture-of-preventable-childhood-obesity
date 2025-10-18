/*******************************************************************************
Program name: gee_ob_par_MI_gwt.sas
Purpose: Calculate PAR for gestational weight gain for obesity risk with multiple imputation
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

%include '/udd/nhywa/GUTSOB/merge_ow_MI.sas';

/**********************************************************************/
proc sort data=all; by _imputation_ id; run;
data all; set all end=_end_;
  by _imputation_ id;
  
  if cohort=1; *only available in GUTS1;

run; 

proc sort data=all; by _imputation_; run;

run;

/**********************************************************************/
title ' in-uterine factors - adjusting for bpregow & agebirth';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = gotweight agebirth bpregow prev_preg1 prev_preg2 prev_preg3 chage white sex 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covuter GEEEmpPEst = uter;
 run;
   
data betas; 
  set uter ;  
  by _imputation_;
  _type_ = 'PARM';
	retain intercept gotweight agebirth bpregow prev_preg1 prev_preg2 prev_preg3 
  				chage white sex;
	
	* 'i' counts rows within each _imputation_ group ;
  	if first._imputation_ then i=1;  
  	else i+1;
	
	select (i);
    when (1) intercept = estimate;
    when (2) gotweight  = estimate;
    when (3) agebirth  = estimate;
	when (4) bpregow   = estimate;
	when (5) prev_preg1= estimate;
	when (6) prev_preg2  = estimate;
	when (7) prev_preg3  = estimate;
    when (8) chage    = estimate;
    when (9) white    = estimate;
    when (10) sex      = estimate;
    otherwise;
  end;
	
  * Only OUTPUT once per _imputation_, after we've assigned all param columns ;
  if last._imputation_ then output;

run;
*proc print data=betas; 

data covparms;  
	set covuter;  
	by _imputation_;
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=gotweight  Prm3=agebirth   Prm4=bpregow    Prm5=prev_preg1    Prm6=prev_preg2 
			Prm7=prev_preg3  Prm8=chage     Prm9=white        Prm10=sex   ;

	length _name_ $10;
	
	*i counts rows within each _imputation_;
	if first._imputation_ then i=1;
 		 else i+1;

	* Assign which row this is (the row "label" in the covariance matrix) ;
	select(i);
		when(1)  _name_ = 'INTERCEPT';
		when(2)  _name_ = 'gotweight';
		when(3)  _name_ = 'agebirth';
		when(4)  _name_ = 'bpregow';
		when(5)  _name_ = 'prev_preg1';
		when(6)  _name_ = 'prev_preg2';
		when(7)  _name_ = 'prev_preg3';
		when(8)  _name_ = 'chage';
		when(9)  _name_ = 'white';
		when(10)  _name_ = 'sex';
		otherwise;
	end;
	
	* Output EVERY row;
  	output;

keep _imputation_ _type_ _name_ prm1-prm10 ;

run;
*proc print data=covparms; 

data betacov;  
	set betas covparms;  
	by _imputation_ ;
	keep _imputation_ _type_ _name_ 
			intercept  gotweight agebirth bpregow prev_preg1 prev_preg2 prev_preg3 
  				chage white sex;
run;

data betacov1(drop=_imputation_) 
		betacov2(drop=_imputation_) 
		betacov3(drop=_imputation_)
		betacov4(drop=_imputation_) 
		betacov5(drop=_imputation_);
  set betacov;
  select (_imputation_);
    when (1) output betacov1;
    when (2) output betacov2;
    when (3) output betacov3;
    when (4) output betacov4;
    when (5) output betacov5;
    otherwise;
  end;
run;
proc print data=betacov1; run;

*frequency/prevalence dataset;
proc sort data=all;
	by _imputation_  gotweight agebirth bpregow prev_preg1 prev_preg2 prev_preg3 
  				chage white sex ;
run;
proc means noprint data=all; 
	by _imputation_  gotweight agebirth bpregow prev_preg1 prev_preg2 prev_preg3 
  				chage white sex  ;
	var momid;
	output out=freqs n=fq;
run;
data freqs1(drop=_imputation_)
     freqs2(drop=_imputation_)
     freqs3(drop=_imputation_)
     freqs4(drop=_imputation_)
     freqs5(drop=_imputation_);
  set freqs;
  select (_imputation_);
    when (1) output freqs1;
    when (2) output freqs2;
    when (3) output freqs3;
    when (4) output freqs4;
    when (5) output freqs5;
    otherwise;
  end;
run;
proc print data=freqs1 (obs=10); run;

%macro runPAR(prefixBeta=, prefixFreq=, outpref=, modmod=, fixfix=);
	%local i;
  	%do i=1 %to 5;
%par(
	bdata=&prefixBeta.&i,
	pdata=&prefixFreq.&i, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= &modmod  ,
	missvarlist=NONE,
	partialpar= T,
	outdat= &outpref.&i,
	fixedvar= &fixfix );
	%end;
%mend runPAR;

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=gwt,
        modmod = gotweight,
        fixfix = agebirth bpregow prev_preg1 prev_preg2 prev_preg3 
  				chage white sex                   );
 
/*************************************************************************************/
/**************** combine using mianalyze ********************************************/

%macro MIPAR(dat1=, dat2=, dat3=, dat4=, dat5=);

data temp; 
	length _Imputation_ 3;
	set &dat1(in=a) &dat2(in=b) &dat3(in=c) &dat4(in=d) &dat5(in=e);
	if a then _Imputation_=1;
  		else if b then _Imputation_=2;
 		else if c then _Imputation_=3;
  		else if d then _Imputation_=4;
  		else if e then _Imputation_=5;
  		  	
  	/* approximate standard error from the half-width of the CI */
  	StdErr = (uclpartialx - lclpartialx) / (2 * 1.96);
  	Estimate = partlparx;
  	Parameter = 'PartialPAR'; 
  	
  	keep _Imputation_ Estimate StdErr Parameter;
run;

proc mianalyze data=temp;
   modeleffects Estimate;  
   stderr StdErr;
run;

%mend MIPAR;

%MIPAR(dat1=gwt1,   dat2=gwt2,   dat3=gwt3,   dat4=gwt4,   dat5=gwt5 );







