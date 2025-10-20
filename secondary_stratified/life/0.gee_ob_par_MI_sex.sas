/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/life
Pogrammer: Bethsaida Cardona (n2bca)
Date started: 07/2025
Program Purpose: Calculate RRs and PARs for the association between child personal factors and obesity
stratified by sex
Exposures: &chwestq_ [quantiles] &chstq_ [quantiles] &chpaq_ [quantiles]
Stratifiers: sex
Statistical Analyses: 
	1) proc genmod to calculate multivariable log-binomial model with generalized estimating equations (GEE), 
	a Poisson distribution, and an unstructured correlation structure, accounting for correlations across 
	time for the same child and between siblings born to the same mother
	2) population attributable fraction with %par macro

*/

/********************************************************************************
Set Up
********************************************************************************/


libname dat_lb '/udd/nhywa/GUTSOB/secondary_stratified/1.data';

/*call in sas file that has our study population data (includes multiple imputation, is specific to the obesity outcome)*/ 
*%include '/udd/nhywa/GUTSOB/merge_ob_MI.sas';

/*
data dat_lb.all; 
   set all;
run;  
*/

/*note that the multiple imputation occuring in the merge_ob_MI.sas file take a very long time, so I output the saved the output file 
to dat_lb*/

/* Show full log, try to find which step is the slowest */
options msglevel=i fullstimer;

filename nhstools '/proj/nhsass/nhsas00/nhstools/sasautos/'; 
filename channing '/usr/local/channing/sasautos/';
filename ehmac '/udd/stleh/ehmac/';
options  mautosource sasautos=(channing nhstools);
libname  nhsfmt   "/proj/nhsass/nhsas00/formats";
options fmtsearch=(nhsfmt);
* options  fmtsearch=(nhsfmt) nofmterr nocenter nonumber nodate formdlim=' ';

options  linesize=150 pagesize=110;
			   
%include '/udd/nhywa/macros/cumavg.macro.sas'; *macro for calculation of CV;


/**********************************************************************/
data all;
  set dat_lb.all end=_end_; 
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

*proc contents data=all; 
*run; 

/*MANUAL SPECIFICATION of variables*/
/*compare exposures and covariates in the stratified analyses*/
proc means data=all; 
 vars chwest chcal chst chpa chage white; 
 class sex; 
run; 


data data_male; 
	set all; 
	if sex=0; 
run; 


data data_female; 
	set all; 
	if sex=1; 
run; 


/*NOTE: Compared to calculating and running the RR and PAR on the whole dataset, for the 
analyses stratifying by sex, we don't adjust for sex*/

%LET covar1= chbmibase cohort chage white; /*MANUAL SPECIFICATION OF VARIABLES*/



/**********************************************************************
	CREATE MACRO TO RUN OVER THE STRATIFIED DATASETS
**********************************************************************/


%macro ob_par_MI_strat (data=, group=);


	/**********************************************************************
	RUN THE RR, WITH METANALYSIS BY IMPUTATION
	**********************************************************************/

	/*MANUAL SPECIFICATION OF DATASET NAME*/

	title "HEADER: personal modifiable factors, &group.";
	proc genmod data = &data. descending;
		by _imputation_ ;
	class id momid ;
	model chob = &chwestq_ &chstq_ &chpaq_ &chcalq_ &covar1
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covlife GEEEmpPEst = life;
	run;
	title "";
	
	proc genmod data = &data. descending;
		by _imputation_ ;
		class id momid ;
		model chob = chwest_m chst_m chpa_m chcal_m &covar1
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEEEmpPEst =life_t;
	run;

	TITLE "HEADER: multiple imputation - personal modifiable factors, &group.";
	ods output ParameterEstimates=mi_life;
	PROC MIANALYZE parms=life;
	MODELEFFECTS INTERCEPT 
			chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 chpaq0 chpaq1 chpaq2 
			chcalq1 chcalq2 chcalq3 &covar1;
	RUN;
	title "";

	ods output ParameterEstimates=mi_lifet;
	PROC MIANALYZE parms=life_t;
	MODELEFFECTS INTERCEPT  
			chwest_m chst_m chpa_m chcal_m &covar1  ;
	RUN;	



	/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat_lb.life_&group._RR;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;

		set mi_life(in=a) mi_lifet(in=b) ;
		
		if a then mod="life";
		if b then mod="life trend";

		if Parm in ("chwestq1", "chwestq2", "chwestq3", "chstq1", "chstq2", "chstq3", "chpaq0", 
				"chpaq1", "chpaq2", "chcalq1", "chcalq2", "chcalq3"); *only keep main exposures when exporting;

		group="&group."; 

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

	title "HEADER: proc print regression results for &group"; 
	proc print data=dat_lb.life_&group._RR; run; 
	title ""; 


	/**********************************************************************
	PREPARE DATA FOR PAR
	**********************************************************************/

	title "HEADER: proc print life for &group"; 
	proc print data=life; run; 
	title ""; 


	/*transposing the dataset so that each row corresponds to an imputation and each variable has its effect estimate*/

	data betas; 
	set life ;  
	by _imputation_;
	_type_ = 'PARM';
		retain intercept chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1;
		
		* 'i' counts rows within each _imputation_ group ;
		if first._imputation_ then i=1;  
		else i+1;

		/*MANUAL SPECIFICATION OF VARIABLES*/
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

		otherwise;
	end;
		
	/*Only OUTPUT once per _imputation_, after we've assigned all param columns*/
	if last._imputation_ then output;

		/*set negative beta to 0 to avoid errors in PAR, only main exposures*/

		if chwestq1 <0 then chwestq1=0; 
		if chwestq2 <0 then chwestq2=0; 
		if chwestq3 <0 then chwestq3=0; 
		if chstq1 <0 then chstq1=0; 
		if chstq2 <0 then chstq2=0; 
		if chstq3 <0 then chstq3=0; 
		if chpaq0 <0 then chpaq0=0; 
		if chpaq1 <0 then chpaq1=0; 
		if chpaq2 <0 then chpaq2=0; 

	run;

	title "HEADER: proc print betas for &group"; 
	proc print data=betas; run; 
	title ""; 


	/*specify which PRM corresponds with which variable
	MANUALLY SPECIFICATION OF PARAMS*/
	data covparms;  
		set covlife;  
		by _imputation_;
		length _type_ $4; 
		_type_ = 'COV';

		rename  Prm1=intercept   Prm2=chwestq1   Prm3=chwestq2   Prm4=chwestq3   Prm5=chstq1  
				Prm6=chstq2      Prm7=chstq3     Prm8=chpaq0     Prm9=chpaq1     Prm10=chpaq2 
				Prm11=chcalq1    Prm12=chcalq2   Prm13=chcalq3   Prm14=chbmibase
				Prm15=cohort     Prm16=chage     Prm17=white     ;

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

			otherwise;
		end;
		
		* Output EVERY row;
		output;

	keep _imputation_ _type_ _name_ prm1-prm17 ; /*MANUAL SPECIFICATION OF PARAMETER RANGE*/
	run;

	title "HEADER: proc print covparms for &group"; 
	proc print data=covparms; run; 
	title ""; 

	data betacov;  
		set betas covparms;  
		by _imputation_ ;
		keep _imputation_ _type_ _name_ 
				intercept chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1 ;
	run;

	*proc print data=betacov; 


	/*output each imputation beta/covariance into its own dataset*/
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

	title "HEADER: proc print betacov1 for &group"; 
	proc print data=betacov1; run;
	title ""; 


	*frequency/prevalence dataset from original dataset must use the complete list of variables in the analysis;
	proc sort data=&data.;
		by _imputation_ chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1 ;
	run;

	proc means noprint data=&data.; 
		by _imputation_ chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1  ;
		var momid; /*this variable should be any numeric variable that is non-missing for all observations used in the analysis*/
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
	*proc print data=freqs1 (obs=10); 



	/*run the par macro over each of the imputated datasets*/
	%macro runPAR(prefixBeta=, prefixFreq=, outpref=, modmod=, fixfix=);
		%local i;
		%do i=1 %to 5;
			%par(
				bdata=&prefixBeta.&i, /*name of dataset containing coefficients and their variance-covariance matrix*/
				pdata=&prefixFreq.&i, /*name of dataset condtaining variable combinations and their frequences*/
				n_or_p=N, 			  /*whether the pdata dataset contains counts (N) or prevalences (P)*/
				n_or_pname=FQ, 		  /*the name of the variable in Pdata that is the count or the prevalence for the stratum*/
				modvar= &modmod,	  /*the list of modifiable variables*/ 
				missvarlist=NONE,     /*list of missing indicators in original model*/ 
				partialpar= T,
				outdat= &outpref.&i,
				fixedvar= &fixfix  	  /*the list of variables to be held fixed in computing a partial PAR*/
				);
		%end;
	%mend runPAR;


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=west,
			modmod = chwestq1 chwestq2 chwestq3,
			fixfix = chstq1 chstq2 chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=west1,
			modmod = chwestq1 ,
			fixfix =  chwestq2 chwestq3 chstq1 chstq2 chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=west2,
			modmod = chwestq2 ,
			fixfix = chwestq1  chwestq3 chstq1 chstq2 chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=west3,
			modmod = chwestq3 ,
			fixfix = chwestq1 chwestq2  chstq1 chstq2 chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=sed,
			modmod = chstq1 chstq2 chstq3   ,
			fixfix = chwestq1 chwestq2 chwestq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=sed1,
			modmod = chstq1    ,
			fixfix = chwestq1 chwestq2 chwestq3 chstq2 chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=sed2,
			modmod = chstq2 ,
			fixfix = chwestq1 chwestq2 chwestq3 chstq1  chstq3 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=sed3,
			modmod = chstq3  ,
			fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 
				chpaq0 chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=pa,
			modmod = chpaq0 chpaq1 chpaq2 ,
			fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
				chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=pa0,
			modmod = chpaq0   ,
			fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
				chpaq1 chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=pa1,
			modmod = chpaq1 ,
			fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
				chpaq0  chpaq2 chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=pa2,
			modmod = chpaq2 ,
			fixfix = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
				chpaq0 chpaq1  chcalq1 chcalq2 chcalq3 
				&covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=life,
			modmod = chwestq1 chwestq2 chwestq3 chstq1 chstq2 chstq3 
					chpaq0 chpaq1 chpaq2  ,
			fixfix =  chcalq1 chcalq2 chcalq3 
				&covar1);

					
	/*************************************************************************************/
	/**************** combine using mianalyze ********************************************/

	/*combine the PAR and errors from each of the imputations*/

	%macro MIPAR(dat1=, dat2=, dat3=, dat4=, dat5=, exposure=);

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

		ods output ParameterEstimates=&exposure._PAR;
		proc mianalyze data=temp;
			modeleffects Estimate;  
			stderr StdErr;
		run;

		data &exposure._PAR; 
			set &exposure._PAR; 
			length exposure $ 15;
			exposure="&exposure."; 
		run; 
			

	%mend MIPAR;


	%MIPAR(dat1=west1,    dat2=west2,    dat3=west3,    dat4=west4,    dat5=west5,  exposure=chwest);
	%MIPAR(dat1=west11,   dat2=west12,   dat3=west13,   dat4=west14,   dat5=west15, exposure=chwestq1);
	%MIPAR(dat1=west21,   dat2=west22,   dat3=west23,   dat4=west24,   dat5=west25, exposure=chwestq2);
	%MIPAR(dat1=west31,   dat2=west32,   dat3=west33,   dat4=west34,   dat5=west35, exposure=chwestq3);

	%MIPAR(dat1=sed1,     dat2=sed2,     dat3=sed3,     dat4=sed4,     dat5=sed5,  	exposure=chst);
	%MIPAR(dat1=sed11,    dat2=sed12,    dat3=sed13,    dat4=sed14,    dat5=sed15, 	exposure=chstq1);
	%MIPAR(dat1=sed21,    dat2=sed22,    dat3=sed23,    dat4=sed24,    dat5=sed25, 	exposure=chstq2);
	%MIPAR(dat1=sed31,    dat2=sed32,    dat3=sed33,    dat4=sed34,    dat5=sed35, 	exposure=chstq3);

	%MIPAR(dat1=pa1,      dat2=pa2,      dat3=pa3,      dat4=pa4,      dat5=pa5,  	exposure=chpa);
	%MIPAR(dat1=pa01,     dat2=pa02,     dat3=pa03,     dat4=pa04,     dat5=pa05, 	exposure=chpaq0 );
	%MIPAR(dat1=pa11,     dat2=pa12,     dat3=pa13,     dat4=pa14,     dat5=pa15, 	exposure=chpaq1 );
	%MIPAR(dat1=pa21,     dat2=pa22,     dat3=pa23,     dat4=pa24,     dat5=pa25, 	exposure=chpaq2 );

	%MIPAR(dat1=life1,    dat2=life2,    dat3=life3,    dat4=life4,    dat5=life5,  exposure=life );


	/*MANUAL SPECIFICATION OF DATA NAME*/
	data dat_lb.life_&group._par; 
		set 
		chwest_PAR chwestq1_PAR chwestq2_PAR chwestq3_PAR
		chst_PAR   chstq1_PAR   chstq2_PAR   chstq3_PAR
		chpa_PAR   chpaq0_PAR   chpaq1_PAR   chpaq2_PAR 
		life_PAR
		; 

		length group $ 40;
		group="&group.";

	run; 



	title "HEADER: final output for &group"; 
	proc print data=dat_lb.life_&group._par; 
	run;
	title "";

%mend ob_par_MI_strat;

/**********************************************************************
	RUN MACRO OVER THE STRATIFIED DATASETS
**********************************************************************/


%ob_par_MI_strat(data=data_male, group=male); 
%ob_par_MI_strat(data=data_female, group=female); 





