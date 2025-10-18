/*******************************************************************************
Program name: gee_ob_par_MI_all.sas
Purpose: Calculate PAR for all exposures for obesity risk with multiple imputation
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
  
  /* if agebirth >=35 then oldbirth=1; else oldbirth=0; */
  
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
   /*  %indic3(vbl=nvdi270q, reflev=3, missing=., min=0, max=2, prefix=nvdi270q, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');
    %indic3(vbl=pm25q, reflev=0, missing=., min=1, max=3, prefix=pm25q, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=no2q, reflev=0, missing=., min=1, max=3, prefix=no2q, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=temsq, reflev=0, missing=., min=1, max=3, prefix=temsq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=temwq, reflev=0, missing=., min=1, max=3, prefix=temwq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=foodswampq , reflev=0, missing=., min=1, max=3, prefix=foodswampq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=physicianq, reflev=0, missing=., min=1, max=3, prefix=physicianq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=food_desertq, reflev=0, missing=., min=1, max=3, prefix=food_desertq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');   */

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
title ' all factors ';
proc genmod data = all descending;
	by _imputation_ ;
 class id momid ;
   model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 moob &moshiftq_ 
  				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
  				&sesq_ heduc1 heduc2 fincome1 fincome2 fincome3
				&chwestq_ &chstq_ &chpaq_ &chcalq_ 
   				prev_preg1 prev_preg2 prev_preg3 midwest south west 
   				moage &covar1 chbmibase
      / dist = Poisson link = log;
     repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
     ods output GEERCov=covcomp GEEEmpPEst = comp;
 run;
  
*positive coef:
	1.  mowestq1 mowestq2 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 moob moshiftq1 moshiftq2
		abwt1 abwt3 gweek3 Delivery pregcomp2 bpregob sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 
	2.  mowestq1 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 moob moshiftq1 moshiftq2
		abwt1 abwt3 gweek3 Delivery pregcomp2 bpregob sesq0 sesq1 sesq2 heduc1 heduc2 
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1
	3.  mowestq1 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2
		abwt1 abwt3 gweek3 Delivery pregcomp2 bpregob sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2
	4.  mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2
		abwt1 abwt3 gweek3 Delivery pregcomp2 bpregob sesq0 sesq1 sesq2 heduc1 heduc2 
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 
	5.  mowestq2 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob sesq0 sesq1 sesq2 heduc1 heduc2
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2  ;

*ever had negative coef:
	mowestq1 mowestq2 mowestq3 mosmk3 gweek1 fincome1 fincome2 fincome3 chpaq2
	;

data betas; 
  set comp ;  
  by _imputation_;
  _type_ = 'PARM';
	retain intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
		mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3 
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		prev_preg1 prev_preg2 prev_preg3  midwest south west 
		moage cohort chage white sex chbmibase ;
	
	* 'i' counts rows within each _imputation_ group ;
  	if first._imputation_ then i=1;  
  	else i+1;
	
	select (i);
    when (1) intercept = estimate;    when (2) mowestq1  = estimate;    when (3) mowestq2  = estimate;
    when (4) mowestq3  = estimate;    when (5) mocalq1   = estimate;    when (6) mocalq2   = estimate;
	when (7) mocalq3   = estimate;    when (8) mopaq0   = estimate;    when (9) mopaq1   = estimate;
	when (10) mopaq2   = estimate;    when (11) mosmk2  = estimate;    when (12) mosmk3  = estimate;
	when (13) moob     = estimate;    when (14) moshiftq1= estimate;    when (15) moshiftq2= estimate;    
	when (16) moshiftq3= estimate;    when (17) abwt1     = estimate;   when (18) abwt3     = estimate;
    when (19) gweek1    = estimate;   when (20) gweek3    = estimate;   when (21) Delivery  = estimate;
    when (22) pregcomp2  = estimate;  when (23) bpregob   = estimate;   when (24) sesq0     = estimate;   
    when (25) sesq1     = estimate;
    when (26) sesq2     = estimate;   when (27) heduc1   = estimate;    when (28) heduc2   = estimate;
    when (29) fincome1  = estimate;   when (30) fincome2  = estimate;   when (31) fincome3   = estimate;
    when (32) chwestq1  = estimate;   when (33) chwestq2  = estimate;   when (34) chwestq3  = estimate;
    when (35) chstq1    = estimate;   when (36) chstq2    = estimate;   when (37) chstq3    = estimate;
    when (38) chpaq0    = estimate;   when (39) chpaq1    = estimate;   when (40) chpaq2   = estimate;
    when (41) chcalq1  = estimate;    when (42) chcalq2  = estimate;    when (43) chcalq3  = estimate;
    when (44) prev_preg1= estimate;   when (45) prev_preg2  = estimate; when (46) prev_preg3  = estimate; 
    when (47) midwest  = estimate;    when (48) south    = estimate;    when (49) west     = estimate;    
    when (50) moage    = estimate;    when (51) cohort   = estimate;    when (52) chage    = estimate;    
    when (53) white    = estimate;    when (54) sex      = estimate;    when (55) chbmibase = estimate;
    otherwise;
  end;
	
  * Only OUTPUT once per _imputation_, after we've assigned all param columns ;
  if last._imputation_ then output;
  
  * set negative beta to 0 to 1) avoid errors in PAR and 2) to prevent certain exposures were omitted from PAR calculation;
  if mowestq1 <0 then  mowestq1 =0;    if mowestq2 <0 then  mowestq2 =0;
  if mowestq3 <0 then  mowestq3 =0;    if mosmk3 <0 then mosmk3 =0;     
  if gweek1 <0 then  gweek1=0;         if fincome1 <0 then fincome1 =0; 
  if fincome2 <0 then fincome2 =0;     if fincome3 <0 then fincome3 =0;   
  if chpaq2 <0 then chpaq2 =0;         if MOSHIFTQ3 <0 then MOSHIFTQ3=0;
  
run;
*proc print data=betas; 

data covparms;  
	set covcomp;  
	by _imputation_;
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
			Prm46=prev_preg3 Prm47=midwest    Prm48=south      Prm49=west       Prm50=moage      
			Prm51=cohort     Prm52=chage      Prm53=white      Prm54=sex        Prm55=chbmibase   ;

	length _name_ $15;
	
	*i counts rows within each _imputation_;
	if first._imputation_ then i=1;
 		 else i+1;

	* Assign which row this is (the row "label" in the covariance matrix) ;
	select(i);
		when(1)  _name_ = 'INTERCEPT';   when(2)  _name_ = 'mowestq1';   when(3)  _name_ = 'mowestq2';
		when(4)  _name_ = 'mowestq3';    when(5)  _name_ = 'mocalq1';    when(6)  _name_ = 'mocalq2';
		when(7)  _name_ = 'mocalq3';     when(8)  _name_ = 'mopaq0';     when(9)  _name_ = 'mopaq1';
		when(10)  _name_ = 'mopaq2';     when(11)  _name_ = 'mosmk2';    when(12)  _name_ = 'mosmk3';
		when(13)  _name_ = 'moob';
		when(14)  _name_ = 'moshiftq1';  when(15)  _name_ = 'moshiftq2'; when(16)  _name_ = 'moshiftq3'; 
		when(17)  _name_ = 'abwt1';      when(18)  _name_ = 'abwt3';     when(19)  _name_ = 'gweek1';     
		when(20)  _name_ = 'gweek3';     when(21)  _name_ = 'Delivery';  when(22)  _name_ = 'pregcomp2';
        when(23)  _name_ = 'bpregob';    when(24)  _name_ = 'sesq0';     when(25)  _name_ = 'sesq1';
        when(26)  _name_ = 'sesq2';      when(27)  _name_ = 'heduc1';    when(28)  _name_ = 'heduc2';
        when(29)  _name_ = 'fincome1';   when(30)  _name_ = 'fincome2';  when(31)  _name_ = 'fincome3';    
        when(32)  _name_ = 'chwestq1';   when(33)  _name_ = 'chwestq2';  when(34)  _name_ = 'chwestq3';
        when(35)  _name_ = 'chstq1';     when(36)  _name_ = 'chstq2';    when(37)  _name_ = 'chstq3';
        when(38)  _name_ = 'chpaq0';     when(39)  _name_ = 'chpaq1';    when(40)  _name_ = 'chpaq2';
        when(41)  _name_ = 'chcalq1';    when(42)  _name_ = 'chcalq2';   when(43)  _name_ = 'chcalq3';
        when(44)  _name_ = 'prev_preg1'; when(45)  _name_ = 'prev_preg2';
        when(46)  _name_ = 'prev_preg3'; when(47)  _name_ = 'midwest';   when(48)  _name_ = 'south';
        when(49)  _name_ = 'west';       when(50)  _name_ = 'moage';     when(51)  _name_ = 'cohort';     
        when(52)  _name_ = 'chage';      when(53)  _name_ = 'white';     when(54)  _name_ = 'sex';        
        when(55)  _name_ = 'chbmibase';
		otherwise;
	end;
	
	* Output EVERY row;
  	output;

keep _imputation_ _type_ _name_ prm1-prm55 ;

run;
*proc print data=covparms; 

data betacov;  
	set betas covparms;  
	by _imputation_ ;
	keep _imputation_ _type_ _name_ 
			intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
		mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3 
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		prev_preg1 prev_preg2 prev_preg3  midwest south west 
		moage cohort chage white sex chbmibase;
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
	by _imputation_ mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
		mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3 
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		prev_preg1 prev_preg2 prev_preg3  midwest south west 
		moage cohort chage white sex chbmibase ;
run;
proc means noprint data=all; 
	by _imputation_ mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
		mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3 
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
		prev_preg1 prev_preg2 prev_preg3  midwest south west 
		moage cohort chage white sex chbmibase ;
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

/****************** ALL **************************/
**********;		
%par(
	bdata=betacov1,
	pdata=freqs1, 
	n_or_p=N,
	n_or_pname=FQ,
	modvar= mowestq1 mowestq2 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 moob moshiftq1 moshiftq2
		abwt1 abwt3 gweek3 Delivery pregcomp2 bpregob sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 ,
	missvarlist=NONE,
	partialpar= T,
	outdat= comp1,
	fixedvar=  mocalq1 mocalq2 mocalq3 mosmk3 moshiftq3
		      gweek1  fincome3   chcalq1 chcalq2 chcalq3 chpaq2
		      prev_preg1 prev_preg2 prev_preg3 midwest south west moage chbmibase cohort chage white sex );

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

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=comp,
        modmod = mowestq1 mowestq2 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3
		abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
		chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2,
        fixfix = mocalq1 mocalq2 mocalq3  
		        chcalq1 chcalq2 chcalq3 
		      prev_preg1 prev_preg2 prev_preg3 midwest south west moage chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mom,
        modmod = mowestq1 mowestq2 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3,
        fixfix = abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
				sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
				chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2
				mocalq1 mocalq2 mocalq3  
		        chcalq1 chcalq2 chcalq3 
		      prev_preg1 prev_preg2 prev_preg3 midwest south west moage chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=uter,
        modmod =  abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob ,
        fixfix = mowestq1 mowestq2 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3
        		sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
				chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2
				mocalq1 mocalq2 mocalq3  
		        chcalq1 chcalq2 chcalq3 
		      prev_preg1 prev_preg2 prev_preg3 midwest south west moage chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=soc,
        modmod = sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3,
        fixfix = mowestq1 mowestq2 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3
				abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
				chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2
				mocalq1 mocalq2 mocalq3  
		        chcalq1 chcalq2 chcalq3 
		      prev_preg1 prev_preg2 prev_preg3 midwest south west moage chbmibase cohort chage white sex);

%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=child,
        modmod =  chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2,
        fixfix = mowestq1 mowestq2 mowestq3 mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 moob moshiftq1 moshiftq2 moshiftq3
				 abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob 
				 sesq0 sesq1 sesq2 heduc1 heduc2 fincome1 fincome2 fincome3
				 mocalq1 mocalq2 mocalq3  
		         chcalq1 chcalq2 chcalq3 
		      prev_preg1 prev_preg2 prev_preg3 midwest south west moage chbmibase cohort chage white sex);
		       		  		 		 		 		 		 		 			       		  		 		 		 		 		 		 
*************************************************************************************
**************** combine using mianalyze ********************************************;

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

%MIPAR(dat1=comp1,   dat2=comp2,   dat3=comp3,   dat4=comp4,   dat5=comp5 );
%MIPAR(dat1=mom1,   dat2=mom2,   dat3=mom3,   dat4=mom4,   dat5=mom5 );
%MIPAR(dat1=uter1,   dat2=uter2,   dat3=uter3,   dat4=uter4,   dat5=uter5 );
%MIPAR(dat1=soc1,   dat2=soc2,   dat3=soc3,   dat4=soc4,   dat5=soc5 );
%MIPAR(dat1=child1,   dat2=child2,   dat3=child3,   dat4=child4,   dat5=child5 );


