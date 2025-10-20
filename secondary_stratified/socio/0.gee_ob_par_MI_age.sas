
/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/socio
Pogrammer: Bethsaida Cardona (n2bca)
Date started: 07/2025
Program Purpose: Calculate RRs and PARs for the association between socioeconomic factors and obesity
stratified by age
Exposures: 	&heduc_ [categorical]; &fincome_ [categorical]; sesq_ [quantiles]
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
  set dat_lb.all end=_end_;
  cohort=cohort-1;
              
    %indic3(vbl=sesq, reflev=3, missing=., min=0, max=2, prefix=sesq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');

  chage13=.; 
  if chage lt 13 then chage13=0; else if chage ge 13 then chage13=1; 
               
run; 

proc sort data=all; by _imputation_; run;


/*MANUAL SPECIFICATION of variables*/
/*compare exposures and covariates in the stratified analyses*/
proc means data=all; 
 vars midwest south west cohort chage white sex heduc1 heduc2 fincome1 fincome2 fincome3  ; 
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

%LET covar1= midwest south west cohort white sex; /*MANUAL SPECIFICATION OF VARIABLES*/


/**********************************************************************
	CREATE MACRO TO RUN OVER THE STRATIFIED DATASETS
**********************************************************************/


%macro ob_par_MI_strat (data=, group=);


	/**********************************************************************
	RUN THE RR, WITH METANALYSIS BY IMPUTATION
	**********************************************************************/

	title "HEADER: education & income for &group"; 
	proc genmod data = &data. descending;
		by _imputation_ ;
		class id momid ;
	model chob = heduc1 heduc2 fincome1 fincome2 fincome3
					&covar1
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covsoc GEEEmpPEst = soc;
	run;
	title ""; 

	proc genmod data = &data. descending;
		by _imputation_ ;
		class id momid ;
	model chob = husbeduc income
					&covar1
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEEEmpPEst =soc_t;
	run;


	TITLE " HEADER: multiple imputation - education & income for &group";
	ods output ParameterEstimates=mi_soc;
	PROC MIANALYZE parms=soc;
	MODELEFFECTS INTERCEPT 
			heduc1 heduc2 fincome1 fincome2 fincome3
				&covar1  ;
	RUN;
	title ""; 

	ods output ParameterEstimates=mi_soct;
	PROC MIANALYZE parms=soc_t;
	MODELEFFECTS INTERCEPT 
					husbeduc income  
					&covar1;
	RUN;


	/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat_lb.soc_&group._RR;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;

		set mi_soc(in=a) mi_soct(in=b) ;
		
		if a then mod="socio";
		if b then mod="socio trend";
		if Parm in ("heduc1", "heduc2", "fincome1", "fincome2", "fincome3"); *only keep main exposures when exporting;

		group="&group."; 

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

	title "HEADER: proc print for the first regression analysis for &group"; 
	proc print data=dat_lb.soc_&group._RR; run; 
	title ""; 

	/**********************************************************************
	PREPARE DATA FOR PAR
	**********************************************************************/
	title "HEADER: proc print for soc for &group"; 
	proc print data=soc; run; 

	data betas; 
	set soc ;  
	by _imputation_;
	_type_ = 'PARM';
		retain intercept  heduc1 heduc2 fincome1 fincome2 fincome3
				&covar1;
		
		* 'i' counts rows within each _imputation_ group ;
		if first._imputation_ then i=1;  
		else i+1;

		/*MANUAL SPECIFICATION OF VARIABLES*/
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
		when (11) white    = estimate;
		when (12) sex     = estimate;
		otherwise;
	end;
		
	* Only OUTPUT once per _imputation_, after we've assigned all param columns ;
	if last._imputation_ then output;
	
		/*set negative beta to 0 to avoid errors in PAR, only main exposures*/

		if heduc1 <0 then heduc1=0; 
		if heduc2 <0 then heduc2=0; 
		if fincome1 <0 then fincome1=0; 
		if fincome2 <0 then fincome2=0; 
		if fincome3 <0 then fincome3=0; 
	run;

	title "HEADER: proc print for first betas for &group"; 
	proc print data=betas; run;
	title ""; 

	/*MANUALLY SPECIFICATION OF PARAMS*/
	data covparms;  
		set covsoc;  
		by _imputation_;
		length _type_ $4; 
		_type_ = 'COV';

		rename  Prm1=intercept   Prm2=heduc1    Prm3=heduc2     
				Prm4=fincome1    Prm5=fincome2     Prm6=fincome3
				Prm7=midwest     Prm8=south     Prm9=west    
				Prm10=cohort     Prm11=white  Prm12=sex     ;

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
			when(11)  _name_ = 'white';
			when (12) _name_  = 'sex';

			otherwise;
		end;
		
		* Output EVERY row;
		output;

		keep _imputation_ _type_ _name_ prm1-prm12 ;  /*MANUAL SPECIFICATION OF PARAMETER RANGE*/
	run;

	title "HEADER: proc print for first covparms for &group"; 
	proc print data=covparms; run; 
	title ""; 

	data betacov;  
		set betas covparms;  
		by _imputation_ ;
		keep _imputation_ _type_ _name_ 
				intercept heduc1 heduc2
					fincome1 fincome2 fincome3
					&covar1  ;
	run;

	*title "HEADER: proc print for first betacov for &group"; 
	*proc print data=betacov; run; 

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
	proc sort data=&data.;
		by _imputation_ heduc1 heduc2
					fincome1 fincome2 fincome3
					&covar1 ;
	run;

	proc means noprint data=&data.; 
		by _imputation_ heduc1 heduc2
					fincome1 fincome2 fincome3
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

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=educ,
			modmod =  heduc1 heduc2 ,
			fixfix =  fincome1 fincome2 fincome3
					&covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=educ1,
			modmod =  heduc1  ,
			fixfix = heduc2
					fincome1 fincome2 fincome3
					&covar1);
											
	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=educ2,
			modmod =  heduc2 ,
			fixfix =  heduc1
					fincome1 fincome2 fincome3
					&covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=inc,
			modmod =  fincome1 fincome2 fincome3,
			fixfix =  heduc1 heduc2
						&covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=inc1,
			modmod =  fincome1 ,
			fixfix =  heduc1 heduc2 fincome2 fincome3
						&covar1);
						
	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=inc2,
			modmod =  fincome2 ,
			fixfix =  heduc1 heduc2 fincome1 fincome3
					&covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=inc3,
			modmod =  fincome3,
			fixfix =  heduc1 heduc2 fincome1 fincome2 
						&covar1);



	/**********************************************************************/
	/*RUN ANALYSES FOR NEIGHBORHOOD SOCIOECONOMIC STATUS*/
	/**********************************************************************/ 

	title "HEADER: nSES for &group"; 
	proc genmod data = &data. descending;
		by _imputation_ ;
	class id momid ;
	model chob = heduc1 heduc2 fincome1 fincome2 fincome3 &covar1  
					sesq0 sesq1 sesq2
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covnses GEEEmpPEst = nses;
	run;

	title ""; 
	
	proc genmod data = &data. descending;
		by _imputation_ ;
		class id momid ;
	model chob = husbeduc income &covar1
					ses_m 
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEEEmpPEst =nses_t;
	run;
	
	TITLE " HEADER: multiple imputation - nses for &group";
	ods output ParameterEstimates=mi_nses;
	PROC MIANALYZE parms=nses;
	MODELEFFECTS INTERCEPT 
				heduc1 heduc2 fincome1 fincome2 fincome3 &covar1  
				sesq0 sesq1 sesq2  ;
	RUN;

	title ""; 

	ods output ParameterEstimates=mi_nsest;
	PROC MIANALYZE parms=nses_t;
	MODELEFFECTS INTERCEPT 
				husbeduc income &covar1 
				ses_m ;
	RUN;

	/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat_lb.nses_&group._RR;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;

		set mi_nses(in=a) mi_nsest(in=b) ;

		if a then mod="socio";
		if b then mod="socio trend";
		if Parm in ("sesq0", "sesq1", "sesq2"); *only keep main exposures when exporting;

		group="&group."; 

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

	title "HEADER: proc print second regression results for &group"; 
	proc print data=dat_lb.nses_&group._RR; run; 
	title ""; 

	title "HEADER: proc print nses for &group"; 
	proc print data=nses; run;
	title ""; 

	/*MANUAL SPECIFICATION OF PARAMETERS*/
	data betas; 
	set nses ;  
	by _imputation_;
	_type_ = 'PARM';
		retain intercept heduc1 heduc2 fincome1 fincome2 fincome3
				&covar1
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
		when (11) white    = estimate;
		when (12) sex       = estimate;
		when (13) sesq0   = estimate;
		when (14) sesq1   = estimate;
		when (15) sesq2   = estimate;
		otherwise;
	end;
		
	* Only OUTPUT once per _imputation_, after we've assigned all param columns ;
	if last._imputation_ then output;
	
	run; 

	data betas; 
		set betas; 
		if sesq0 <0 then  sesq0 =0; 
		if sesq1 <0 then  sesq1 =0; 
		if sesq2 <0 then  sesq2 =0; 
		if heduc1 <0 then heduc1=0; 
		if heduc2 <0 then heduc2=0; 
		if fincome1 <0 then fincome1=0; 
		if fincome2 <0 then fincome2=0; 
		if fincome3 <0 then fincome3=0; 
	run; 

	title "HEADER: proc print second betas results for &group"; 
	proc print data=betas; run;
	title ""; 


	/*MANUAL SPECIFICATION OF PARAMETERS*/
	data covparms;  
		set covnses;  
		by _imputation_;
		length _type_ $4; 
		_type_ = 'COV';

		rename  Prm1=intercept   Prm2=heduc1    Prm3=heduc2     
				Prm4=fincome1    Prm5=fincome2     Prm6=fincome3
				Prm7=midwest     Prm8=south     Prm9=west    
				Prm10=cohort     Prm11=white     Prm12=sex 
				Prm13=sesq0      Prm14=sesq1     Prm15=sesq2;

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
			when(11)  _name_ = 'white';
			when(12)  _name_ = 'sex';
			when(13)  _name_ = 'sesq0';
			when(14)  _name_ = 'sesq1';
			when(15)  _name_ = 'sesq2';
			otherwise;
		end;
		
		* Output EVERY row;
		output;

		keep _imputation_ _type_ _name_ prm1-prm15 ; /*MANUAL SPECIFICATION OF PARAMETER RANGE*/
	run;

	title "HEADER: proc print second covparms for &group"; 
	proc print data=covparms; 
	title ""; 

	data betacov;  
		set betas covparms;  
		by _imputation_ ;
		keep _imputation_ _type_ _name_ 
				intercept heduc1 heduc2 fincome1 fincome2 fincome3
					&covar1 
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
	
	title "HEADER: proc print second betacov1 for &group"; 
	proc print data=betacov1; run;
	title ""; 

	*frequency/prevalence dataset;
	proc sort data=&data.;
		by _imputation_ heduc1 heduc2 fincome1 fincome2 fincome3
					&covar1
					sesq0 sesq1 sesq2;
	run;
	proc means noprint data=&data.; 
		by _imputation_ heduc1 heduc2 fincome1 fincome2 fincome3
					&covar1
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

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=ses,
			modmod =  sesq0 sesq1 sesq2  ,
			fixfix =  heduc1 heduc2 fincome1 fincome2 fincome3
						&covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=ses0,
			modmod =  sesq0   ,
			fixfix =  heduc1 heduc2 fincome1 fincome2 fincome3
						&covar1
						sesq1 sesq2);
											
	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=ses1,
			modmod =  sesq1   ,
			fixfix =  heduc1 heduc2 fincome1 fincome2 fincome3
						&covar1
						sesq0 sesq2);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=ses2,
			modmod =  sesq2  ,
			fixfix =  heduc1 heduc2 fincome1 fincome2 fincome3
						&covar1
						sesq0 sesq1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=soc,
			modmod =  sesq0 sesq1 sesq2 heduc1 heduc2
						fincome1 fincome2 fincome3,
			fixfix =   &covar1);
																		
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


	%MIPAR(dat1=educ1,   dat2=educ2,    dat3=educ3,    dat4=educ4,    dat5=educ5, 	exposure=heduc );
	%MIPAR(dat1=educ11,  dat2=educ12,   dat3=educ13,   dat4=educ14,   dat5=educ15, 	exposure=heduc1);
	%MIPAR(dat1=educ21,  dat2=educ22,   dat3=educ23,   dat4=educ24,   dat5=educ25, 	exposure=heduc2);

	%MIPAR(dat1=inc1,    dat2=inc2,     dat3=inc3,     dat4=inc4,     dat5=inc5, 	exposure=fincome );
	%MIPAR(dat1=inc11,   dat2=inc12,    dat3=inc13,    dat4=inc14,    dat5=inc15, 	exposure=fincome1 );
	%MIPAR(dat1=inc21,   dat2=inc22,    dat3=inc23,    dat4=inc24,    dat5=inc25, 	exposure=fincome2  );
	%MIPAR(dat1=inc31,   dat2=inc32,    dat3=inc33,    dat4=inc34,    dat5=inc35, 	exposure=fincome3 );

	%MIPAR(dat1=ses1,    dat2=ses2,     dat3=ses3,     dat4=ses4,     dat5=ses5,	exposure=ses  );
	%MIPAR(dat1=ses01,   dat2=ses02,    dat3=ses03,    dat4=ses04,    dat5=ses05, 	exposure=sesq0 );
	%MIPAR(dat1=ses11,   dat2=ses12,    dat3=ses13,    dat4=ses14,    dat5=ses15, 	exposure=sesq1 );
	%MIPAR(dat1=ses21,   dat2=ses22,    dat3=ses23,    dat4=ses24,    dat5=ses25, 	exposure=sesq2 );

	%MIPAR(dat1=soc1,    dat2=soc2,     dat3=soc3,     dat4=soc4,     dat5=soc5, 	exposure=soc );


	/*MANUAL SPECIFICATION OF DATA NAME*/
	data dat_lb.socio_&group._par; 
		set 
		heduc_PAR 	  heduc1_PAR     heduc2_PAR 
		fincome_PAR  fincome1_PAR  fincome2_PAR  fincome3_PAR
		ses_PAR     sesq0_PAR   	sesq1_PAR     sesq2_PAR 
		soc_PAR
		; 

		length group $ 40;
		group="&group.";
	run; 

	title "HEADER: final output for &group"; 
	proc print data=dat_lb.socio_&group._par; 
	run;
	title ""; 


%mend ob_par_MI_strat;

/**********************************************************************
	RUN MACRO OVER THE STRATIFIED DATASETS
**********************************************************************/


%ob_par_MI_strat(data=data_child, group=child); run; 
%ob_par_MI_strat(data=data_teen, group=teen); run; 