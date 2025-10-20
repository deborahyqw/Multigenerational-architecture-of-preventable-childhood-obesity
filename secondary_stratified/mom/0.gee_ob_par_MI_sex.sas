

/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/mom
Pogrammer: Bethsaida Cardona (n2bca)
Date started: 07/2025
Program Purpose: Calculate RRs and PARs for the association between maternal factors and obesity
stratified by sex
Exposures: &mowestq_ [quantiles]; &mopaq_ [quantiles]; &mosmk_ [categorical]; &moshift_ [categorical]; 
	moob [binary]
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

/*MANUAL SPECIFICATION of variables*/
/*compare exposures and covariates in the stratified analyses*/
proc means data=all; 
 vars moage cohort chage white sex &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_ 
  			      ; 
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


%LET covar1= moage cohort white chage ; run; /*MANUAL SPECIFICATION OF VARIABLES*/


/**********************************************************************
	CREATE MACRO TO RUN OVER THE STRATIFIED DATASETS
**********************************************************************/


%macro ob_par_MI_strat (data=, group=);



	/**********************************************************************
	RUN THE RR, WITH METANALYSIS BY IMPUTATION
	**********************************************************************/

	title "HEADER: maternal modifiable factors, &group.";
	proc genmod data = &data descending;
		by _imputation_ ;
	class id momid ;
	model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_ 
					&covar1
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covmom GEEEmpPEst = mom;
	run;
	title ""; 

	proc genmod data = &data descending;
		by _imputation_ ;
	class id momid ;
	model chob = mowest_m mocal_m mopa_m mosmk2 mosmk3
					moshift_m 
					moage &covar1
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEEEmpPEst =mom_t;
	run;
	

	TITLE "HEADER: multiple imputation - maternal modifiable factors - no moob, &group";
	ods output ParameterEstimates=mi_mom;
	PROC MIANALYZE parms=mom;
	MODELEFFECTS INTERCEPT mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
			mopaq0 mopaq1 mopaq2 mosmk2 mosmk3
			moshiftq1 moshiftq2 moshiftq3 
			&covar1  ;
	RUN;
	title "";

	/*
	ods output ParameterEstimates=mi_momt;
	PROC MIANALYZE parms=mom_t;
	MODELEFFECTS INTERCEPT mowest_m mocal_m mopa_m mosmk2 mosmk3
			moshift_m 
			&covar1  ;
	RUN;
	*/


	/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat_lb.mom_&group._RR;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;

		set mi_mom(in=a) /*mi_momt(in=b)*/ ;
		
		if a then mod="mom";
		/*if b then mod="mom trend";*/
		if Parm in ("mowestq1", "mowestq2", "mowestq3", "mocalq1", "mocalq2", "mocalq3"    
						"mopaq0", "mopaq1", "mopaq2", "mosmk2" "mosmk3" "moshiftq1" "moshiftq2" "moshiftq3"); *only keep main exposures when exporting;

		group="&group"; 

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

	title "HEADER: proc print for the first regression analysis for &group"; 
	proc print data=dat_lb.mom_&group._RR; run; 
	title ""; 

	/**********************************************************************
	PREPARE DATA FOR PAR
	**********************************************************************/
	title "HEADER: proc print for mom for &group"; 
	proc print data=mom; run; 
	title "";


	/*MANUAL SPECIFICATION OF VARIABLES*/
	data betas; 
	set mom ;  
	by _imputation_;
	_type_ = 'PARM';
		retain intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
						mopaq0 mopaq1 mopaq2 mosmk2 mosmk3
						moshiftq1 moshiftq2 moshiftq3
						&covar1;
		
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
		when (18) white    = estimate;
		when (19) chage      = estimate;
		otherwise;
	end;
		
	* Only OUTPUT once per _imputation_, after we've assigned all param columns ;
	if last._imputation_ then output;

		/*set negative beta to 0 to avoid errors in PAR, only main exposures*/

		if mowestq1 <0 then mowestq1=0; 
		if mowestq2 <0 then mowestq2=0; 
		if mowestq3 <0 then mowestq3=0; 
		if mocalq1 <0 then mocalq1=0; 
		if mocalq2 <0 then mocalq2=0; 
		if mocalq3 <0 then mocalq3=0; 
		if mopaq0 <0 then mopaq0=0; 
		if mopaq1 <0 then mopaq1=0; 
		if mopaq2 <0 then mopaq2=0; 
		if moshiftq1 <0 then moshiftq1=0; 
		if mosmk2 <0 then mosmk2=0; 
		if mosmk3 <0 then mosmk3=0; 
		if moshiftq2 <0 then moshiftq2=0; 
		if moshiftq3 <0 then moshiftq3=0; 
	run;

	title "HEADER: proc print for first betas for &group"; 
	proc print data=betas; run;
	title ""; 

	/*MANUALLY SPECIFICATION OF PARAMS*/
	data covparms;  
		set covmom;  
		by _imputation_;
		length _type_ $4; 
		_type_ = 'COV';

		rename  Prm1=intercept   Prm2=mowestq1   Prm3=mowestq2   Prm4=mowestq3   Prm5=mocalq1  
				Prm6=mocalq2     Prm7=mocalq3    
				Prm8=mopaq0     Prm9=mopaq1    Prm10=mopaq2    Prm11=mosmk2   Prm12=mosmk3 
				Prm13=moshiftq1  Prm14=moshiftq2  Prm15=moshiftq3   Prm16=moage 
				Prm17=cohort     Prm18=white       Prm19=chage   ;

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
			when(18)  _name_ = 'white';
			when(19)  _name_ = 'chage';
			otherwise;
		end;
		
		* Output EVERY row;
		output;


		keep _imputation_ _type_ _name_ prm1-prm19 ;

	run;


	title "HEADER: proc print for first covparms for &group"; 
	proc print data=covparms; run; 
	title ""; 

	data betacov;  
		set betas covparms;  
		by _imputation_ ;
		keep _imputation_ _type_ _name_ 
				intercept mowestq1   mowestq2   mowestq3   mocalq1  
				mocalq2    mocalq3    mopaq0     mopaq1     mopaq2     
				mosmk2 mosmk3  moshiftq1  moshiftq2  moshiftq3  
				&covar1 ;
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
		by _imputation_ mowestq1   mowestq2   mowestq3   mocalq1  
				mocalq2    mocalq3   
				mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
				moshiftq2  moshiftq3  &covar1 ;
	run;
	proc means noprint data=&data; 
		by _imputation_ mowestq1   mowestq2   mowestq3   mocalq1  
			mocalq2    mocalq3    
			mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
			moshiftq2  moshiftq3  &covar1  ;
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

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mwest,
			modmod = mowestq1 mowestq2 mowestq3,
			fixfix = mocalq1  mocalq2  mocalq3    
					mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mwestq1,
			modmod = mowestq1 ,
			fixfix = mowestq2 mowestq3 mocalq1  mocalq2  mocalq3  
					mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mwestq2,
			modmod = mowestq2 ,
			fixfix = mowestq1 mowestq3 mocalq1  mocalq2  mocalq3  
					mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mwestq3,
			modmod = mowestq3 ,
			fixfix = mowestq1 mowestq2 mocalq1  mocalq2  mocalq3  
					mopaq0    mopaq1    mopaq2    mosmk2 mosmk3  
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mpa,
			modmod = mopaq0    mopaq1    mopaq2 ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3    
					mosmk2 mosmk3  
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mpaq0,
			modmod = mopaq0  ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1   mocalq2  mocalq3   
					mopaq1    mopaq2 mosmk2 mosmk3  
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mpaq1,
			modmod = mopaq1   ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3     
					mopaq0    mopaq2    mosmk2 mosmk3  
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mpaq2,
			modmod = mopaq2 ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3    
						mopaq0    mopaq1    mosmk2 mosmk3  
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=msmk,
			modmod = mosmk2 mosmk3 ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3     
						mopaq0    mopaq1    mopaq2   
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=msmk2,
			modmod = mosmk2  ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3     
						mopaq0    mopaq1    mopaq2   mosmk3
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=msmk3,
			modmod = mosmk3 ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3     
						mopaq0    mopaq1    mopaq2   mosmk2 
					moshiftq1 moshiftq2 moshiftq3 &covar1);


	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mshift,
			modmod = moshiftq1 moshiftq2 moshiftq3 ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3  
						mopaq0    mopaq1    mopaq2   
					mosmk2 mosmk3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mshiftq1,
			modmod = moshiftq1  ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1 mocalq2  mocalq3   
						mopaq0    mopaq1    mopaq2   
					mosmk2 mosmk3 moshiftq2 moshiftq3 &covar1);
					
	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mshiftq2,
			modmod = moshiftq2  ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3    
						mopaq0    mopaq1    mopaq2   
					mosmk2 mosmk3 moshiftq1 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mshiftq3,
			modmod = moshiftq3 ,
			fixfix = mowestq1  mowestq2  mowestq3  mocalq1  mocalq2  mocalq3    
						mopaq0    mopaq1    mopaq2   
					mosmk2 mosmk3 moshiftq1 moshiftq2 &covar1);


	/**********************************************************************/
	/*RUN ANALYSES THAT INCLUDE MATERNAL OBESITY AS AN EXPOSURE*/
	/**********************************************************************/ 

	title "maternal modifiable factors - moob, &group.";
	proc genmod data = &data descending;
		by _imputation_ ;
	class id momid ;
	model chob = &mowestq_ &mocalq_ &mopaq_ mosmk2 mosmk3 &moshiftq_ 
					&covar1 moob
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covmom GEEEmpPEst = mom;
	run;
	title "";

	
	TITLE " multiple imputation - moob, &group";
	ods output ParameterEstimates=mi_mom;
	PROC MIANALYZE parms=mom;
	MODELEFFECTS INTERCEPT mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
			mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 
			moshiftq1 moshiftq2 moshiftq3 
			&covar1 moob  ;
	RUN;
	title ""; 


	/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat_lb.obmom_&group._RR;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;

		set mi_mom(in=a) ;

		if a then mod="mom";
		if Parm in ("moob"); *only keep main exposures when exporting;

		group="&group."; 

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

	title "HEADER: proc print second regression results for &group"; 
	proc print data=dat_lb.obmom_&group._RR; run; 
	title ""; 


	/*MANUAL SPECIFICATION OF PARAMETERS*/
	data betas; 
	set mom ;  
	by _imputation_;
	_type_ = 'PARM';
		retain intercept mowestq1 mowestq2 mowestq3 mocalq1 mocalq2 mocalq3 
						mopaq0 mopaq1 mopaq2 mosmk2 mosmk3 
						moshiftq1 moshiftq2 moshiftq3
						&covar1 moob;
		
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
		when (18) white    = estimate;
		when (19) chage      = estimate;
		when (20) moob     = estimate;
		otherwise;
	end;
		
	* Only OUTPUT once per _imputation_, after we've assigned all param columns ;
	if last._imputation_ then output;
	
		/*set negative beta to 0 to avoid errors in PAR, only main exposures*/

		if mowestq1 <0 then mowestq1=0; 
		if mowestq2 <0 then mowestq2=0; 
		if mowestq3 <0 then mowestq3=0; 
		if mocalq1 <0 then mocalq1=0; 
		if mocalq2 <0 then mocalq2=0; 
		if mocalq3 <0 then mocalq3=0; 
		if mopaq0 <0 then mopaq0=0; 
		if mopaq1 <0 then mopaq1=0; 
		if mopaq2 <0 then mopaq2=0; 
		if moshiftq1 <0 then moshiftq1=0; 
		if mosmk2 <0 then mosmk2=0; 
		if mosmk3 <0 then mosmk3=0; 
		if moshiftq2 <0 then moshiftq2=0; 
		if moshiftq3 <0 then moshiftq3=0; 
		if moob <0 then moob=0; 


	run;

	title "HEADER: proc print second betas results for &group"; 
	proc print data=betas; run;
	title ""; 

	/*MANUAL SPECIFICATION OF PARAMETERS*/
	data covparms;  
		set covmom;  
		by _imputation_;
		length _type_ $4; 
		_type_ = 'COV';

		rename  Prm1=intercept   Prm2=mowestq1   Prm3=mowestq2   Prm4=mowestq3   Prm5=mocalq1  
				Prm6=mocalq2     Prm7=mocalq3    
				Prm8=mopaq0      Prm9=mopaq1     Prm10=mopaq2    Prm11=mosmk2  Prm12=mosmk3 
				Prm13=moshiftq1  Prm14=moshiftq2  Prm15=moshiftq3 Prm16=moage 
				Prm17=cohort     Prm18=white     Prm19=chage   Prm20=moob ;

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
			when(18)  _name_ = 'white';
			when(19)  _name_ = 'chage';
			when(20)  _name_ = 'moob';
			otherwise;
		end;
		
		* Output EVERY row;
		output;

	keep _imputation_ _type_ _name_ prm1-prm20 ;

	run;

	title "HEADER: proc print second covparms for &group"; 
	proc print data=covparms; 
	title ""; 

	data betacov;  
		set betas covparms;  
		by _imputation_ ;
		keep _imputation_ _type_ _name_ 
				intercept mowestq1   mowestq2   mowestq3   mocalq1  
				mocalq2    mocalq3    mopaq0     mopaq1     mopaq2     
				mosmk2  mosmk3  moshiftq1 moshiftq2  moshiftq3  
				&covar1  moob ;
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
	proc sort data=&data;
		by _imputation_ mowestq1   mowestq2   mowestq3   mocalq1  
				mocalq2    mocalq3    
				mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
				moshiftq2  moshiftq3  &covar1 moob;
	run;
	proc means noprint data=&data; 
		by _imputation_ mowestq1   mowestq2   mowestq3   mocalq1  
			mocalq2    mocalq3    
			mopaq0     mopaq1     mopaq2     mosmk2 mosmk3  moshiftq1
			moshiftq2  moshiftq3  &covar1 moob ;
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

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mob,
			modmod = moob,
			fixfix = mowestq1  mowestq2 mowestq3 mocalq1  mocalq2  mocalq3    
					mopaq0    mopaq1    mopaq2    mosmk2  mosmk3  
					moshiftq1 moshiftq2 moshiftq3 &covar1);

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=mom,
			modmod = mowestq1  mowestq2 mowestq3   mopaq0    mopaq1    mopaq2   mosmk2 mosmk3  
					moshiftq1 moshiftq2 moshiftq3 moob,
			fixfix = mocalq1  mocalq2  mocalq3  &covar1);

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

	%MIPAR(dat1=mwest1,     dat2=mwest2,    dat3=mwest3,    dat4=mwest4,    dat5=mwest5,    exposure=mowest);
	%MIPAR(dat1=mwestq11,   dat2=mwestq12,  dat3=mwestq13,  dat4=mwestq14,  dat5=mwestq15,  exposure=mowestq1); 
	%MIPAR(dat1=mwestq21,   dat2=mwestq22,  dat3=mwestq23,  dat4=mwestq24,  dat5=mwestq25,  exposure=mowestq2); 
	%MIPAR(dat1=mwestq31,   dat2=mwestq32,  dat3=mwestq33,  dat4=mwestq34,  dat5=mwestq35,  exposure=mowestq3); 
	%MIPAR(dat1=mpa1,       dat2=mpa2,      dat3=mpa3,      dat4=mpa4,      dat5=mpa5,      exposure=mopa); 
	%MIPAR(dat1=mpaq01,     dat2=mpaq02,    dat3=mpaq03,    dat4=mpaq04,    dat5=mpaq05,    exposure=mopaq0); 
	%MIPAR(dat1=mpaq11,     dat2=mpaq12,    dat3=mpaq13,    dat4=mpaq14,    dat5=mpaq15,    exposure=mopaq1); 
	%MIPAR(dat1=mpaq21,     dat2=mpaq22,    dat3=mpaq23,    dat4=mpaq24,    dat5=mpaq25,    exposure=mopaq2); 
	%MIPAR(dat1=msmk1,      dat2=msmk2,     dat3=msmk3,     dat4=msmk4,     dat5=msmk5,     exposure=mosmk);
	%MIPAR(dat1=msmk21,     dat2=msmk22,    dat3=msmk23,    dat4=msmk24,    dat5=msmk25,    exposure=mosmk2);
	%MIPAR(dat1=msmk31,     dat2=msmk32,    dat3=msmk33,    dat4=msmk34,    dat5=msmk35,    exposure=mosmk3);
	%MIPAR(dat1=mshift1,    dat2=mshift2,   dat3=mshift3,   dat4=mshift4,   dat5=mshift5,   exposure=moshift);
	%MIPAR(dat1=mshiftq11,  dat2=mshiftq12, dat3=mshiftq13, dat4=mshiftq14, dat5=mshiftq15, exposure=moshiftq1);
	%MIPAR(dat1=mshiftq21,  dat2=mshiftq22, dat3=mshiftq23, dat4=mshiftq24, dat5=mshiftq25, exposure=moshiftq2);
	%MIPAR(dat1=mshiftq31,  dat2=mshiftq32, dat3=mshiftq33, dat4=mshiftq34, dat5=mshiftq35, exposure=moshiftq3);
	%MIPAR(dat1=mob1,     	dat2=mob2,     	dat3=mob3,     	dat4=mob4,     	dat5=mob5,		exposure=moob);
	%MIPAR(dat1=mom1,       dat2=mom2,      dat3=mom3,      dat4=mom4,      dat5=mom5,      exposure=mom);




	/*MANUAL SPECIFICATION OF DATA NAME*/
	data dat_lb.mom_&group._par; 
		set 
		mowest_PAR 	  mowestq1_PAR      mowestq2_PAR      mowestq3_PAR
		mopa_PAR       mopaq0_PAR        mopaq1_PAR        mopaq2_PAR
		mosmk_PAR      mosmk2_PAR   	   mosmk3_PAR     
		moshift_PAR 	  moshiftq1_PAR     moshiftq2_PAR     moshiftq3_PAR
		moob_PAR
		mom_PAR
		; 

		length group $ 40;
		group="&group";
	run; 

	title "HEADER: final output for &group"; 
	proc print data=dat_lb.mom_&group._par; 
	run;
	title ""; 


%mend ob_par_MI_strat;

/**********************************************************************
	RUN MACRO OVER THE STRATIFIED DATASETS
**********************************************************************/



%ob_par_MI_strat(data=data_male, group=male); 
%ob_par_MI_strat(data=data_female, group=female); 