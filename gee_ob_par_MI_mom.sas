/*******************************************************************************
Program name: gee_ob_par_MI_mom.sas
Purpose: Calculate PAR for maternal exposures for obesity risk with multiple imputation
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

%include '/udd/nhywa/GUTSOB/merge_ob_MI.sas';

/**********************************************************************/
data all;
  set all end=_end_;
  cohort=cohort-1;
    
	%indic3(vbl=mowestq, reflev=0, missing=., min=1, max=3, prefix=mowestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mocalq, reflev=0, missing=., min=1, max=3, prefix=mocalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mopaq, reflev=3, missing=., min=0, max=2, prefix=mopaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');        
     %indic3(vbl=moshiftq, reflev=0, missing=., min=1, max=3, prefix=moshiftq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
          
run;

proc sort data=all; by _imputation_; run;

%LET covar1= cohort chage white sex ;

run;

/**********************************************************************/
title ' maternal modifiable factors - not adjusting for moob because it may be on the causal pathways ';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_ 
  			    moage &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covmom GEEEmpPEst = mom;
 run;
   
data betas; 
  set mom ;  
  by _imputation_;
  _type_ = 'PARM';
	retain intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
					 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3
					moshiftq1 moshiftq2 moshiftq3
					moage cohort chage white sex;
	
	* 'i' counts rows within each _imputation_ group ;
  	if first._imputation_ then i=1;  
  	else i+1;
	
	select (i);
    when (1) intercept = estimate;
    when (2) mowestq1  = estimate;
    when (3) mowestq2  = estimate;
    when (4) mowestq3  = estimate;
    when (5) mocalq1   = estimate;
    when (6) mocalq2   = estimate;
	when (7) mocalq3   = estimate;
	when (8) mopaq0   = estimate;
	when (9) mopaq1   = estimate;
	when (10) mopaq2   = estimate;
	when (11) mosmk2  = estimate;
	when (12) mosmk3  = estimate;
	when (13) moshiftq1= estimate;
	when (14) moshiftq2= estimate;
	when (15) moshiftq3= estimate;
    when (16) moage    = estimate;
    when (17) cohort   = estimate;
    when (18) chage    = estimate;
    when (19) white    = estimate;
    when (20) sex      = estimate;
    otherwise;
  end;
	
  * Only OUTPUT once per _imputation_, after we've assigned all param columns ;
  if last._imputation_ then output;

run;
*proc print data=betas; 

data covparms;  
	set covmom;  
	by _imputation_;
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=mowestq1   Prm3=mowestq2   Prm4=mowestq3   Prm5=mocalq1  
			Prm6=mocalq2     Prm7=mocalq3    
			Prm8=mopaq0     Prm9=mopaq1    Prm10=mopaq2    Prm11=mosmk2   Prm12=mosmk3 
			Prm13=moshiftq1  Prm14=moshiftq2  Prm15=moshiftq3   Prm16=moage 
			Prm17=cohort     Prm18=chage      Prm19=white       Prm20=sex   ;

	length _name_ $10;
	
	*i counts rows within each _imputation_;
	if first._imputation_ then i=1;
 		 else i+1;

	* Assign which row this is (the row "label" in the covariance matrix) ;
	select(i);
		when(1)  _name_ = 'INTERCEPT';
		when(2)  _name_ = 'mowestq1';
		when(3)  _name_ = 'mowestq2';
		when(4)  _name_ = 'mowestq3';
		when(5)  _name_ = 'mocalq1';
		when(6)  _name_ = 'mocalq2';
		when(7)  _name_ = 'mocalq3';
		when(8)  _name_ = 'mopaq0';
		when(9)  _name_ = 'mopaq1';
		when(10)  _name_ = 'mopaq2';
		when(11)  _name_ = 'mosmk2';
		when(12)  _name_ = 'mosmk3';
		when(13)  _name_ = 'moshiftq1';
		when(14)  _name_ = 'moshiftq2';
		when(15)  _name_ = 'moshiftq3';
		when(16)  _name_ = 'moage';
		when(17)  _name_ = 'cohort';
		when(18)  _name_ = 'chage';
		when(19)  _name_ = 'white';
		when(20)  _name_ = 'sex';
		otherwise;
	end;
	
	* Output EVERY row;
  	output;

keep _imputation_ _type_ _name_ prm1-prm20 ;

run;
*proc print data=covparms; 

data betacov;  
	set betas covparms;  
	by _imputation_ ;
	keep _imputation_ _type_ _name_ 
			intercept mowestq1   mowestq2   mowestq3   mocalq1  
			  mocalq2    mocalq3    mopaq0     mopaq1     mopaq2     
			  mosmk2 mosmk3  moshiftq1  moshiftq2  moshiftq3  
			  moage      cohort     chage    white   sex ;
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
	by _imputation_ mowestq1   mowestq2   mowestq3   mocalq1  
			  mocalq2    mocalq3   
			  mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
			  moshiftq2  moshiftq3  moage      cohort     chage    white   sex ;
run;
proc means noprint data=all; 
	by _imputation_ mowestq1   mowestq2   mowestq3   mocalq1  
		 mocalq2    mocalq3    
		 mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
		 moshiftq2  moshiftq3  moage      cohort     chage    white   sex  ;
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

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mwest,
        modmod = mowestq1 mowestq2 mowestq3,
        fixfix = mocalq1  mocalq2  mocalq3    
		 		 mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mwestq1,
        modmod = mowestq1 ,
        fixfix = mowestq2 mowestq3 mocalq1  mocalq2  mocalq3  
		 		 mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mwestq2,
        modmod = mowestq2 ,
        fixfix = mowestq1 mowestq3 mocalq1  mocalq2  mocalq3  
		 		 mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mwestq3,
        modmod = mowestq3 ,
        fixfix = mowestq1 mowestq2 mocalq1  mocalq2  mocalq3  
		 		 mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mpa,
        modmod = mopaq0    mopaq1    mopaq2 ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3    
		 		   mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mpaq0,
        modmod = mopaq0  ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1   mocalq2  mocalq3   
		 		 mopaq1    mopaq2 mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mpaq1,
        modmod = mopaq1   ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3     
		 		 mopaq0    mopaq2    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mpaq2,
        modmod = mopaq2 ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3    
		 		    mopaq0    mopaq1    mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=msmk,
        modmod = mosmk2 mosmk3 ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3     
		 		    mopaq0    mopaq1    mopaq2   
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=msmk2,
        modmod = mosmk2  ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3     
		 		    mopaq0    mopaq1    mopaq2   mosmk3
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=msmk3,
        modmod = mosmk3 ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3     
		 		    mopaq0    mopaq1    mopaq2   mosmk2 
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);


%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mshift,
        modmod = moshiftq1 moshiftq2 moshiftq3 ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3  
		 		    mopaq0    mopaq1    mopaq2   
		 		 mosmk2 mosmk3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mshiftq1,
        modmod = moshiftq1  ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3   
		 		    mopaq0    mopaq1    mopaq2   
		 		 mosmk2 mosmk3 moshiftq2 moshiftq3 moage cohort chage white sex);
		 		 
%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mshiftq2,
        modmod = moshiftq2  ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3    
		 		    mopaq0    mopaq1    mopaq2   
		 		 mosmk2 mosmk3 moshiftq1 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mshiftq3,
        modmod = moshiftq3 ,
        fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3    
		 		    mopaq0    mopaq1    mopaq2   
		 		 mosmk2 mosmk3 moshiftq1 moshiftq2 moage cohort chage white sex);
        		  		 		 		 		 		 		 
/**********************************************************************/
title ' maternal modifiable factors - moob ';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_ 
  			    moage &covar1 moob
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covmom GEEEmpPEst = mom;
 run;
   
data betas; 
  set mom ;  
  by _imputation_;
  _type_ = 'PARM';
	retain intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
					 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 
					moshiftq1 moshiftq2 moshiftq3
					moage cohort chage white sex moob;
	
	* 'i' counts rows within each _imputation_ group ;
  	if first._imputation_ then i=1;  
  	else i+1;
	
	select (i);
    when (1) intercept = estimate;
    when (2) mowestq1  = estimate;
    when (3) mowestq2  = estimate;
    when (4) mowestq3  = estimate;
    when (5) mocalq1   = estimate;
    when (6) mocalq2   = estimate;
	when (7) mocalq3   = estimate;
	when (8) mopaq0   = estimate;
	when (9) mopaq1   = estimate;
	when (10) mopaq2   = estimate;
	when (11) mosmk2  = estimate;
	when (12) mosmk3  = estimate;
	when (13) moshiftq1= estimate;
	when (14) moshiftq2= estimate;
	when (15) moshiftq3= estimate;
    when (16) moage    = estimate;
    when (17) cohort   = estimate;
    when (18) chage    = estimate;
    when (19) white    = estimate;
    when (20) sex      = estimate;
    when (21) moob     = estimate;
    otherwise;
  end;
	
  * Only OUTPUT once per _imputation_, after we've assigned all param columns ;
  if last._imputation_ then output;
  
  if mowestq1 <0 then  mowestq1 =0;    if mowestq2 <0 then  mowestq2 =0;

run;
*proc print data=betas; 

data covparms;  
	set covmom;  
	by _imputation_;
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=mowestq1   Prm3=mowestq2   Prm4=mowestq3   Prm5=mocalq1  
			Prm6=mocalq2     Prm7=mocalq3    
			Prm8=mopaq0      Prm9=mopaq1     Prm10=mopaq2    Prm11=mosmk2  Prm12=mosmk3 
			Prm13=moshiftq1  Prm14=moshiftq2  Prm15=moshiftq3 Prm16=moage 
			Prm17=cohort     Prm18=chage     Prm19=white     Prm20=sex   Prm21=moob ;

	length _name_ $10;
	
	*i counts rows within each _imputation_;
	if first._imputation_ then i=1;
 		 else i+1;

	* Assign which row this is (the row "label" in the covariance matrix) ;
	select(i);
		when(1)  _name_ = 'INTERCEPT';
		when(2)  _name_ = 'mowestq1';
		when(3)  _name_ = 'mowestq2';
		when(4)  _name_ = 'mowestq3';
		when(5)  _name_ = 'mocalq1';
		when(6)  _name_ = 'mocalq2';
		when(7)  _name_ = 'mocalq3';
		when(8)  _name_ = 'mopaq0';
		when(9)  _name_ = 'mopaq1';
		when(10)  _name_ = 'mopaq2';
		when(11)  _name_ = 'mosmk2';
		when(12)  _name_ = 'mosmk3';
		when(13)  _name_ = 'moshiftq1';
		when(14)  _name_ = 'moshiftq2';
		when(15)  _name_ = 'moshiftq3';
		when(16)  _name_ = 'moage';
		when(17)  _name_ = 'cohort';
		when(18)  _name_ = 'chage';
		when(19)  _name_ = 'white';
		when(20)  _name_ = 'sex';
		when(21)  _name_ = 'moob';
		otherwise;
	end;
	
	* Output EVERY row;
  	output;

keep _imputation_ _type_ _name_ prm1-prm21 ;

run;
*proc print data=covparms; 

data betacov;  
	set betas covparms;  
	by _imputation_ ;
	keep _imputation_ _type_ _name_ 
			intercept mowestq1   mowestq2   mowestq3   mocalq1  
			  mocalq2    mocalq3    mopaq0     mopaq1     mopaq2     
			  mosmk2  mosmk3  moshiftq1 moshiftq2  moshiftq3  
			  moage      cohort     chage    white   sex moob ;
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
	by _imputation_ mowestq1   mowestq2   mowestq3   mocalq1  
			  mocalq2    mocalq3    
			  mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
			  moshiftq2  moshiftq3  moage      cohort     chage    white   sex moob;
run;
proc means noprint data=all; 
	by _imputation_ mowestq1   mowestq2   mowestq3   mocalq1  
		 mocalq2    mocalq3    
		 mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
		 moshiftq2  moshiftq3  moage      cohort     chage    white   sex moob ;
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

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mob,
        modmod = moob,
        fixfix = mowestq1  mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
        		   mopaq0    mopaq1    mopaq2    mosmk2  mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moage cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mom,
        modmod = mowestq1  mowestq2 mowestq3   mopaq0    mopaq1    mopaq2   mosmk2 mosmk3  
		 		 moshiftq1 moshiftq2 moshiftq3 moob,
        fixfix = mocalq1  mocalq2  mocalq3  moage cohort chage white sex);

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

%MIPAR(dat1=mwest1,   dat2=mwest2,   dat3=mwest3,   dat4=mwest4,   dat5=mwest5 );
%MIPAR(dat1=mwestq11, dat2=mwestq12, dat3=mwestq13, dat4=mwestq14, dat5=mwestq15 );
%MIPAR(dat1=mwestq21, dat2=mwestq22, dat3=mwestq23, dat4=mwestq24, dat5=mwestq25 );
%MIPAR(dat1=mwestq31, dat2=mwestq32, dat3=mwestq33, dat4=mwestq34, dat5=mwestq35 );
%MIPAR(dat1=mpa1,     dat2=mpa2,     dat3=mpa3,     dat4=mpa4,     dat5=mpa5 );
%MIPAR(dat1=mpaq01,   dat2=mpaq02,   dat3=mpaq03,   dat4=mpaq04,   dat5=mpaq05 );
%MIPAR(dat1=mpaq11,   dat2=mpaq12,   dat3=mpaq13,   dat4=mpaq14,   dat5=mpaq15 );
%MIPAR(dat1=mpaq21,   dat2=mpaq22,   dat3=mpaq23,   dat4=mpaq24,   dat5=mpaq25 );
%MIPAR(dat1=msmk1,    dat2=msmk2,    dat3=msmk3,    dat4=msmk4,    dat5=msmk5 );
%MIPAR(dat1=msmk21,    dat2=msmk22,    dat3=msmk23,    dat4=msmk24,    dat5=msmk25 );
%MIPAR(dat1=msmk31,    dat2=msmk32,    dat3=msmk33,    dat4=msmk34,    dat5=msmk35 );
%MIPAR(dat1=mshift1,  dat2=mshift2,  dat3=mshift3,  dat4=mshift4,  dat5=mshift5 );
%MIPAR(dat1=mshiftq11,dat2=mshiftq12,dat3=mshiftq13,dat4=mshiftq14,dat5=mshiftq15 );
%MIPAR(dat1=mshiftq21,dat2=mshiftq22,dat3=mshiftq23,dat4=mshiftq24,dat5=mshiftq25 );
%MIPAR(dat1=mshiftq31,dat2=mshiftq32,dat3=mshiftq33,dat4=mshiftq34,dat5=mshiftq35 );
%MIPAR(dat1=mob1,     dat2=mob2,     dat3=mob3,     dat4=mob4,     dat5=mob5 );
%MIPAR(dat1=mom1,     dat2=mom2,     dat3=mom3,     dat4=mom4,     dat5=mom5 );







