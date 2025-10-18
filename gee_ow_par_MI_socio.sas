/*******************************************************************************
Program name: gee_ow_par_MI_socio.sas
Purpose: Calculate PAR for socio-environmental exposures for obesity risk with multiple imputation
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
              
    %indic3(vbl=sesq, reflev=3, missing=., min=0, max=2, prefix=sesq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');
               
run; 

proc sort data=all; by _imputation_; run;

%LET covar1= cohort chage white sex ;

run;

/**********************************************************************/
title ' education & income '; 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = heduc1 heduc2 fincome1 fincome2 fincome3
			    midwest south west &covar1
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covsoc GEEEmpPEst = soc;
 run;
   
data betas; 
  set soc ;  
  by _imputation_;
  _type_ = 'PARM';
	retain intercept  heduc1 heduc2 fincome1 fincome2 fincome3
			midwest south west cohort chage white sex;
	
	* 'i' counts rows within each _imputation_ group ;
  	if first._imputation_ then i=1;  
  	else i+1;
	
	select (i);
    when (1) intercept = estimate;
 	when (2) heduc1   = estimate;
    when (3) heduc2   = estimate;
    when (4) fincome1   = estimate;
    when (5) fincome2   = estimate;
    when (6) fincome3   = estimate;
    when (7) midwest  = estimate;
    when (8) south    = estimate;
    when (9) west     = estimate;
    when (10) cohort   = estimate;
    when (11) chage    = estimate;
    when (12) white    = estimate;
    when (13) sex      = estimate;
    otherwise;
  end;
	
  * Only OUTPUT once per _imputation_, after we've assigned all param columns ;
  if last._imputation_ then output;
  
  if fincome3 <0 then  fincome3 =0; 

run;
*proc print data=betas; 

data covparms;  
	set covsoc;  
	by _imputation_;
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=heduc1    Prm3=heduc2     
			Prm4=fincome1    Prm5=fincome2     Prm6=fincome3
			Prm7=midwest     Prm8=south     Prm9=west    
			Prm10=cohort     Prm11=chage     Prm12=white    Prm13=sex   ;

	length _name_ $10;
	
	*i counts rows within each _imputation_;
	if first._imputation_ then i=1;
 		 else i+1;

	* Assign which row this is (the row "label" in the covariance matrix) ;
	select(i);
		when(1)  _name_ = 'INTERCEPT';
		when(2)  _name_ = 'heduc1';
		when(3)  _name_ = 'heduc2';
		when(4)  _name_ = 'fincome1';
		when(5)  _name_ = 'fincome2';
		when(6)  _name_ = 'fincome3';
		when(7)  _name_ = 'midwest';
		when(8)  _name_ = 'south';
		when(9)  _name_ = 'west';
		when(10)  _name_ = 'cohort';
		when(11)  _name_ = 'chage';
		when(12)  _name_ = 'white';
		when(13)  _name_ = 'sex';
		otherwise;
	end;
	
	* Output EVERY row;
  	output;

keep _imputation_ _type_ _name_ prm1-prm13 ;

run;
*proc print data=covparms; 

data betacov;  
	set betas covparms;  
	by _imputation_ ;
	keep _imputation_ _type_ _name_ 
			intercept heduc1 heduc2
				fincome1 fincome2 fincome3
				midwest south west
					cohort chage white sex ;
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
	by _imputation_ heduc1 heduc2
				fincome1 fincome2 fincome3
				 midwest south west
					cohort chage white sex ;
run;
proc means noprint data=all; 
	by _imputation_ heduc1 heduc2
				fincome1 fincome2 fincome3
				midwest south west
					cohort chage white sex  ;
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

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=educ,
        modmod =  heduc1 heduc2 ,
        fixfix =  fincome1 fincome2 fincome3
   				    midwest south west
					 cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=educ1,
        modmod =  heduc1  ,
        fixfix = heduc2
				fincome1 fincome2 fincome3
				midwest south west
					 cohort chage white sex);
					 					
%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=educ2,
        modmod =  heduc2 ,
        fixfix =  heduc1
				fincome1 fincome2 fincome3
   				    midwest south west
					 cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=inc,
        modmod =  fincome1 fincome2 fincome3,
        fixfix =  heduc1 heduc2
   				    midwest south west
					 cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=inc1,
        modmod =  fincome1 ,
        fixfix =  heduc1 heduc2 fincome2 fincome3
   				    midwest south west
					 cohort chage white sex);
					 
%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=inc2,
        modmod =  fincome2 ,
        fixfix =  heduc1 heduc2 fincome1 fincome3
   				    midwest south west
					 cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=inc3,
        modmod =  fincome3,
        fixfix =  heduc1 heduc2 fincome1 fincome2 
   				    midwest south west
					 cohort chage white sex);

/**********************************************************************/
/**********************************************************************/ 
title ' socio-environmental factors '; 
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chow = heduc1 heduc2 fincome1 fincome2 fincome3
			    midwest south west &covar1 sesq0 sesq1 sesq2 
     / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covsoc GEEEmpPEst = soc;
 run;
   
data betas; 
  set soc ;  
  by _imputation_;
  _type_ = 'PARM';
	retain intercept heduc1 heduc2 fincome1 fincome2 fincome3
			midwest south west cohort chage white sex 
			sesq0 sesq1 sesq2 ;
	
	* 'i' counts rows within each _imputation_ group ;
  	if first._imputation_ then i=1;  
  	else i+1;
	
	select (i);
    when (1) intercept = estimate;
 	when (2) heduc1   = estimate;
    when (3) heduc2   = estimate;
    when (4) fincome1   = estimate;
    when (5) fincome2   = estimate;
    when (6) fincome3   = estimate;
    when (7) midwest  = estimate;
    when (8) south    = estimate;
    when (9) west     = estimate;
    when (10) cohort   = estimate;
    when (11) chage    = estimate;
    when (12) white    = estimate;
    when (13) sex      = estimate;
    when (14) sesq0   = estimate;
    when (15) sesq1   = estimate;
    when (16) sesq2   = estimate;
    otherwise;
  end;
	
  * Only OUTPUT once per _imputation_, after we've assigned all param columns ;
  if last._imputation_ then output;
  
  if fincome2 <0 then  fincome2 =0;  if fincome3 <0 then  fincome3 =0; 

run;
*proc print data=betas; 

data covparms;  
	set covsoc;  
	by _imputation_;
	length _type_ $4; 
	 _type_ = 'COV';

	rename  Prm1=intercept   Prm2=heduc1    Prm3=heduc2     
			Prm4=fincome1    Prm5=fincome2     Prm6=fincome3
			Prm7=midwest     Prm8=south     Prm9=west    
			Prm10=cohort     Prm11=chage     Prm12=white    Prm13=sex   
			Prm14=sesq0      Prm15=sesq1     Prm16=sesq2;

	length _name_ $10;
	
	*i counts rows within each _imputation_;
	if first._imputation_ then i=1;
 		 else i+1;

	* Assign which row this is (the row "label" in the covariance matrix) ;
	select(i);
		when(1)  _name_ = 'INTERCEPT';
		when(2)  _name_ = 'heduc1';
		when(3)  _name_ = 'heduc2';
		when(4)  _name_ = 'fincome1';
		when(5)  _name_ = 'fincome2';
		when(6)  _name_ = 'fincome3';
		when(7)  _name_ = 'midwest';
		when(8)  _name_ = 'south';
		when(9)  _name_ = 'west';
		when(10)  _name_ = 'cohort';
		when(11)  _name_ = 'chage';
		when(12)  _name_ = 'white';
		when(13)  _name_ = 'sex';
		when(14)  _name_ = 'sesq0';
		when(15)  _name_ = 'sesq1';
		when(16)  _name_ = 'sesq2';
		otherwise;
	end;
	
	* Output EVERY row;
  	output;

keep _imputation_ _type_ _name_ prm1-prm16 ;

run;
*proc print data=covparms; 

data betacov;  
	set betas covparms;  
	by _imputation_ ;
	keep _imputation_ _type_ _name_ 
			intercept heduc1 heduc2 fincome1 fincome2 fincome3
				midwest south west cohort chage white sex 
					sesq0 sesq1 sesq2;
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
	by _imputation_ heduc1 heduc2 fincome1 fincome2 fincome3
				 midwest south west cohort chage white sex 
				 sesq0 sesq1 sesq2;
run;
proc means noprint data=all; 
	by _imputation_ heduc1 heduc2 fincome1 fincome2 fincome3
				midwest south west cohort chage white sex 
				sesq0 sesq1 sesq2 ;
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

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=ses,
        modmod =  sesq0 sesq1 sesq2  ,
        fixfix =  heduc1 heduc2 fincome1 fincome2 fincome3
   				    midwest south west
					 cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=ses0,
        modmod =  sesq0   ,
        fixfix =  heduc1 heduc2 fincome1 fincome2 fincome3
   				    midwest south west
					 cohort chage white sex sesq1 sesq2);
					 					
%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=ses1,
        modmod =  sesq1   ,
        fixfix =  heduc1 heduc2 fincome1 fincome2 fincome3
   				    midwest south west
					 cohort chage white sex sesq0 sesq2);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=ses2,
        modmod =  sesq2  ,
        fixfix =  heduc1 heduc2 fincome1 fincome2 fincome3
   				    midwest south west
					 cohort chage white sex sesq0 sesq1);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=soc,
        modmod =  sesq0 sesq1 sesq2 heduc1 heduc2
        			fincome1 fincome2 fincome3,
        fixfix =  midwest south west
					 cohort chage white sex);
					 		 		 		 		 		 		 
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

%MIPAR(dat1=educ1,     dat2=educ2,     dat3=educ3,     dat4=educ4,     dat5=educ5 );
%MIPAR(dat1=educ11,     dat2=educ12,     dat3=educ13,     dat4=educ14,     dat5=educ15 );
%MIPAR(dat1=educ21,     dat2=educ22,     dat3=educ23,     dat4=educ24,     dat5=educ25 );

%MIPAR(dat1=inc1,     dat2=inc2,     dat3=inc3,     dat4=inc4,     dat5=inc5 );
%MIPAR(dat1=inc11,     dat2=inc12,     dat3=inc13,     dat4=inc14,     dat5=inc15 );
%MIPAR(dat1=inc21,     dat2=inc22,     dat3=inc23,     dat4=inc24,     dat5=inc25 );
%MIPAR(dat1=inc31,     dat2=inc32,     dat3=inc33,     dat4=inc34,     dat5=inc35 );

%MIPAR(dat1=ses1,   dat2=ses2,   dat3=ses3,   dat4=ses4,   dat5=ses5 );
%MIPAR(dat1=ses01,   dat2=ses02,   dat3=ses03,   dat4=ses04,   dat5=ses05 );
%MIPAR(dat1=ses11,   dat2=ses12,   dat3=ses13,   dat4=ses14,   dat5=ses15 );
%MIPAR(dat1=ses21,   dat2=ses22,   dat3=ses23,   dat4=ses24,   dat5=ses25 );

%MIPAR(dat1=soc1,     dat2=soc2,     dat3=soc3,     dat4=soc4,     dat5=soc5 );






