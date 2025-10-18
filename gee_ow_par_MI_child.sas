/*******************************************************************************
Program name: gee_ow_par_MI_child.sas
Purpose: Calculate PAR for personal exposures for overweight risk with multiple imputation
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
data all;
  set all end=_end_;
  cohort=cohort-1;
    
	%indic3(vbl=chwestq, reflev=0, missing=., min=1, max=3, prefix=chwestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chcalq, reflev=0, missing=., min=1, max=3, prefix=chcalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chstq, reflev=0, missing=., min=1, max=3, prefix=chstq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chpaq, reflev=3, missing=., min=0, max=2, prefix=chpaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');
    
run;

proc sort data=all; by _imputation_; run;

%LET covar1= cohort chage white sex ;

run;

/**********************************************************************/
title ' personal modifiable factors ';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = &chwestq_ &chstq_ &chpaq_ &chcalq_ chbmibase &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covchild GEEEmpPEst = child;
 run;
   
data betas; 
  set child ;  
  by _imputation_;
  _type_ = 'PARM';
	retain intercept chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		    chbmibase cohort chage white sex;
	
	* 'i' counts rows within each _imputation_ group ;
  	if first._imputation_ then i=1;  
  	else i+1;
	
	select (i);
    when (1) intercept = estimate;
    when (2) chwestq1  = estimate;
    when (3) chwestq2  = estimate;
    when (4) chwestq3  = estimate;
    when (5) chstq1   = estimate;
    when (6) chstq2   = estimate;
	when (7) chstq3   = estimate;
	when (8) chpaq0   = estimate;
	when (9) chpaq1   = estimate;
	when (10) chpaq2  = estimate;
	when (11) chcalq1   = estimate;
	when (12) chcalq2   = estimate;
	when (13) chcalq3   = estimate;
	when (14) chbmibase = estimate;
    when (15) cohort   = estimate;
    when (16) chage    = estimate;
    when (17) white    = estimate;
    when (18) sex      = estimate;
    otherwise;
  end;
	
  * Only OUTPUT once per _imputation_, after we've assigned all param columns ;
  if last._imputation_ then output;

	* set negative beta to 0 to avoid errors in PAR -- chpa2 <0 in imputations 1-2;
	if chpaq1 <0 then chpaq1=0;   if chpaq2 <0 then chpaq2=0;
run;
proc print data=betas; 

data covparms;  
	set covchild;  
	by _imputation_;
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=chwestq1   Prm3=chwestq2   Prm4=chwestq3   Prm5=chstq1  
			Prm6=chstq2      Prm7=chstq3     Prm8=chpaq0     Prm9=chpaq1     Prm10=chpaq2 
			Prm11=chcalq1    Prm12=chcalq2   Prm13=chcalq3   Prm14=chbmibase
			Prm15=cohort     Prm16=chage     Prm17=white     Prm18=sex   ;

	length _name_ $10;
	
	*i counts rows within each _imputation_;
	if first._imputation_ then i=1;
 		 else i+1;

	* Assign which row this is (the row "label" in the covariance matrix) ;
	select(i);
		when(1)  _name_ = 'INTERCEPT';
		when(2)  _name_ = 'chwestq1';
		when(3)  _name_ = 'chwestq2';
		when(4)  _name_ = 'chwestq3';
		when(5)  _name_ = 'chstq1';
		when(6)  _name_ = 'chstq2';
		when(7)  _name_ = 'chstq3';
		when(8)  _name_ = 'chpaq0';
		when(9)  _name_ = 'chpaq1';
		when(10)  _name_ = 'chpaq2';
		when(11)  _name_ = 'chcalq1';
		when(12)  _name_ = 'chcalq2';
		when(13)  _name_ = 'chcalq3';
		when(14)  _name_ = 'chbmibase';
		when(15)  _name_ = 'cohort';
		when(16)  _name_ = 'chage';
		when(17)  _name_ = 'white';
		when(18)  _name_ = 'sex';
		otherwise;
	end;
	
	* Output EVERY row;
  	output;

keep _imputation_ _type_ _name_ prm1-prm18 ;

run;
*proc print data=covparms; 

data betacov;  
	set betas covparms;  
	by _imputation_ ;
	keep _imputation_ _type_ _name_ 
			intercept chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex ;
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
	by _imputation_ chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex ;
run;
proc means noprint data=all; 
	by _imputation_ chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex  ;
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

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=west,
        modmod = chwestq1 chwestq2 chwestq3,
        fixfix = chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=west1,
        modmod = chwestq1 ,
        fixfix =  chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=west2,
        modmod = chwestq2 ,
        fixfix = chwestq1  chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=west3,
        modmod = chwestq3 ,
        fixfix = chwestq1 chwestq2  chstq1 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=sed,
        modmod = chstq1 chstq2 chstq3   ,
        fixfix = chwestq1 chwestq2 chwestq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=sed1,
        modmod = chstq1    ,
        fixfix = chwestq1 chwestq2 chwestq3 chstq2 chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=sed2,
        modmod = chstq2 ,
        fixfix = chwestq1 chwestq2 chwestq3 chstq1  chstq3 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=sed3,
        modmod = chstq3  ,
        fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 
			chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=pa,
        modmod = chpaq0 chpaq1 chpaq2 ,
        fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			 chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=pa0,
        modmod = chpaq0   ,
        fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=pa1,
        modmod = chpaq1 ,
        fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0  chpaq2 chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=pa2,
        modmod = chpaq2 ,
        fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
			chpaq0 chpaq1  chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=child,
        modmod = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
        		 chpaq0 chpaq1 chpaq2  ,
        fixfix =  chcalq1 chcalq2 chcalq3 
			 chbmibase cohort chage white sex);

		 		 
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
			
%MIPAR(dat1=west1,   dat2=west2,   dat3=west3,   dat4=west4,   dat5=west5 );
%MIPAR(dat1=west11,   dat2=west12,   dat3=west13,   dat4=west14,   dat5=west15 );
%MIPAR(dat1=west21,   dat2=west22,   dat3=west23,   dat4=west24,   dat5=west25 );
%MIPAR(dat1=west31,   dat2=west32,   dat3=west33,   dat4=west34,   dat5=west35 );

%MIPAR(dat1=sed1,    dat2=sed2,    dat3=sed3,    dat4=sed4,    dat5=sed5 );
%MIPAR(dat1=sed11,    dat2=sed12,    dat3=sed13,    dat4=sed14,    dat5=sed15 );
%MIPAR(dat1=sed21,    dat2=sed22,    dat3=sed23,    dat4=sed24,    dat5=sed25 );
%MIPAR(dat1=sed31,    dat2=sed32,    dat3=sed33,    dat4=sed34,    dat5=sed35 );

%MIPAR(dat1=pa1,     dat2=pa2,     dat3=pa3,     dat4=pa4,     dat5=pa5 );
%MIPAR(dat1=pa01,     dat2=pa02,     dat3=pa03,     dat4=pa04,     dat5=pa05 );
%MIPAR(dat1=pa11,     dat2=pa12,     dat3=pa13,     dat4=pa14,     dat5=pa15 );
%MIPAR(dat1=pa21,     dat2=pa22,     dat3=pa23,     dat4=pa24,     dat5=pa25 );

%MIPAR(dat1=child1,   dat2=child2,   dat3=child3,   dat4=child4,   dat5=child5 );







