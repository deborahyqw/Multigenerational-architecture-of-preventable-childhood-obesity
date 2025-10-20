
/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/gwt
Pogrammer: Bethsaida Cardona (n2bca)
Date started: 07/2025
Program Purpose: Calculate RRs and PARs for the association between gestational weight gain and obesity
stratified by age
Exposures: GOTWEIGHT [binary]
Stratifiers: age (child <13 or child >=13)
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
  set dat_lb.all;
run; 


data all; 
  set all end=_end_;
  if cohort=1; *only available in GUTS1;

  chage13=.; 
  if chage lt 13 then chage13=0; else if chage ge 13 then chage13=1; 
run; 

proc sort data=all; by _imputation_; run;


/*compare exposures and covariates in the stratified analyses*/
proc means data=all; 
 vars gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 chage white sex; 
 class chage13; 
run; 



data data_child; 
	set all; 
	if chage13=0; 
run; 


data data_teen; 
	set all; 
	if chage13=1; 
run; 

%LET covar1=  white sex; /*MANUAL SPECIFICATION OF VARIABLES*/



/**********************************************************************
	CREATE MACRO TO RUN OVER THE STRATIFIED DATASETS
**********************************************************************/


%macro ob_par_MI_strat (data=, group=);


	/**********************************************************************
	RUN THE RR, WITH METANALYSIS BY IMPUTATION
	**********************************************************************/

	title "HEADING: gotweight regression, &group.";
	proc genmod data = &data descending;
		by _imputation_ ;
	class id momid ;
	model chob = gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 &covar1
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covuter GEEEmpPEst = uter;
	run;

	TITLE "HEADER: multiple imputation - gotweight, &group.";
	ods output ParameterEstimates=mi_gweight;
	PROC MIANALYZE parms=uter;
	MODELEFFECTS INTERCEPT 
				gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 &covar1 ;
	RUN;
	title ""; 


	/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
		data dat_lb.gwt_&group._RR;
			length Parm $ 15;
			length mod $ 40;
			length group $ 40;

			set mi_gweight(in=a)  ;
			
			if a then mod="gwt";
			if Parm in ("gotweight"); *only keep main exposures when exporting;

			group="&group."; 

			RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
		run; 

		title "HEADER: proc print for the first regression analysis for &group"; 
		proc print data=dat_lb.gwt_&group._RR; run; 
		title ""; 


	/**********************************************************************
	PREPARE DATA FOR PAR
	**********************************************************************/

	title "HEADER: proc print for uter for &group"; 
	proc print data=uter; run; 
	title "";


	data betas; 
	set uter ;  
	by _imputation_;
	_type_ = 'PARM';
		retain intercept gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1;
		
		* 'i' counts rows within each _imputation_ group ;
		if first._imputation_ then i=1;  
		else i+1;
		
		/*MANUAL SPECIFICATION OF VARIABLES*/
		select (i);
		when (1) intercept = estimate;
		when (2) gotweight  = estimate;
		when (3) agebirth  = estimate;
		when (4) bpregob   = estimate;
		when (5) prev_preg1= estimate;
		when (6) prev_preg2  = estimate;
		when (7) prev_preg3  = estimate;
		when (8) white    = estimate;
		when (9) sex      = estimate;
		otherwise;
	end;
		
	/*Only OUTPUT once per _imputation_, after we've assigned all param columns*/
	if last._imputation_ then output;

	run;

	title "HEADER: proc print for betas for &group"; 
	proc print data=betas; run;
	title ""; 

	/*MANUALLY SPECIFICATION OF PARAMS*/
	data covparms;  
		set covuter;  
		by _imputation_;
		length _type_ $4; 
		_type_ = 'COV';

		rename  Prm1=intercept   Prm2=gotweight  Prm3=agebirth   Prm4=bpregob    Prm5=prev_preg1    Prm6=prev_preg2 
				Prm7=prev_preg3  Prm8=white        Prm9=sex   ;

		length _name_ $10;
		
		*i counts rows within each _imputation_;
		if first._imputation_ then i=1;
			else i+1;

		* Assign which row this is (the row "label" in the covariance matrix) ;
		select(i);
			when(1)  _name_ = 'INTERCEPT';
			when(2)  _name_ = 'gotweight';
			when(3)  _name_ = 'agebirth';
			when(4)  _name_ = 'bpregob';
			when(5)  _name_ = 'prev_preg1';
			when(6)  _name_ = 'prev_preg2';
			when(7)  _name_ = 'prev_preg3';
			when(8)  _name_ = 'white';
			when(9)  _name_ = 'sex';
			otherwise;
		end;
		
		* Output EVERY row;
		output;

	keep _imputation_ _type_ _name_ prm1-prm9 ;  /*MANUAL SPECIFICATION OF PARAMETER RANGE*/

	run;

	title "HEADER: proc print for covparms for &group"; 
	proc print data=covparms; run; 
	title ""; 

	data betacov;  
		set betas covparms;  
		by _imputation_ ;
		keep _imputation_ _type_ _name_ 
				intercept  gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1;
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

	title "HEADER: proc print for first betacov1 for &group"; 
	proc print data=betacov1; run;
	title ""; 	

	*frequency/prevalence dataset;
	proc sort data=&data;
		by _imputation_  gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1 ;
	run;
	proc means noprint data=&data; 
		by _imputation_  gotweight agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1  ;
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
	*proc print data=freqs1 (obs=10); run;

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
			fixfix = agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1                   );

	;
	
	/*************************************************************************************/
	/**************** combine using mianalyze ********************************************/


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



	%MIPAR(dat1=gwt1,   dat2=gwt2,   dat3=gwt3,   dat4=gwt4,   dat5=gwt5, exposure=gotweight );




	/*MANUAL SPECIFICATION OF DATA NAME*/
	data dat_lb.gwt_&group._par; 
		set 
		gotweight_PAR
		; 

		length group $ 40;
		group="&group.";
	run; 

	title "HEADER: final output for &group"; 
	proc print data=dat_lb.gwt_&group._par; 
	run;
	title ""; 


%mend ob_par_MI_strat;

/**********************************************************************
	RUN MACRO OVER THE STRATIFIED DATASETS
**********************************************************************/


%ob_par_MI_strat(data=data_child, group=child); run; 
%ob_par_MI_strat(data=data_teen, group=teen); run; 