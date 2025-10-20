
/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/uter
Pogrammer: Bethsaida Cardona (n2bca)
Date started: 07/2025
Program Purpose: Calculate RRs and PARs for the association between intrauternin factors and obesity
stratified by sex
Exposures: 	&abwt_ [categorical]; &gweek_ [categorical]; Delivery [binary]; pregcomp2 [binary]; bpregob [binary]
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
    		
run;

proc sort data=all; by _imputation_; run;


/*MANUAL SPECIFICATION of variables*/
/*compare exposures and covariates in the stratified analyses*/
proc means data=all; 
 vars agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
                bpregob prev_preg1 prev_preg2 prev_preg3 cohort chage white sex ; 
 class sex; 
run; 


data data_female; 
	set all; 
	if sex=1; 
run; 


data data_male; 
	set all; 
	if sex=0; 
run; 


%LET covar1= cohort chage white ; run; /*MANUAL SPECIFICATION OF VARIABLES*/


/**********************************************************************
	CREATE MACRO TO RUN OVER THE STRATIFIED DATASETS
**********************************************************************/


%macro ob_par_MI_strat (data=, group=);

	/**********************************************************************
	RUN THE RR, WITH METANALYSIS BY IMPUTATION
	**********************************************************************/

	title "HEADER: in-uterine factors - adjusting for bpregob & agebirth, &group";
	proc genmod data = &data descending;
		by _imputation_ ;
	class id momid ;
	model chob = agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 &covar1
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covuter GEEEmpPEst = uter;
	run;
	title ""; 


	TITLE "HEADER: multiple imputation - in-uterine factors, &group";
	ods output ParameterEstimates=mi_uter;
	PROC MIANALYZE parms=uter;
	MODELEFFECTS INTERCEPT 
			agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1  ;
	RUN;
	title "";


	/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat_lb.uter_&group._RR;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;

		set mi_uter(in=a) ;
		
		if a then mod="uter";

		if Parm in ("abwt1", "abwt3", "gweek1", "gweek3", "Delivery", "pregcomp2"); *only keep main exposures when exporting;

		group="&group."; 

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

	title "HEADER: proc print first regression results for &group"; 
	proc print data=dat_lb.uter_&group._RR; run; 
	title "";
	

	/**********************************************************************
	PREPARE DATA FOR PAR
	**********************************************************************/
	
	title "HEADER: proc print uter for &group"; 
	proc print data=uter; run;
	title ""; 

	data betas; 
	set uter ;  
	by _imputation_;
	_type_ = 'PARM';
		retain intercept agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1;
		
		* 'i' counts rows within each _imputation_ group ;
		if first._imputation_ then i=1;  
		else i+1;
		
		/*MANUAL SPECIFICATION OF VARIABLES*/
		select (i);
		when (1) intercept = estimate;
		when (2) agebirth  = estimate;
		when (3) abwt1     = estimate;
		when (4) abwt3     = estimate;
		when (5) gweek1    = estimate;
		when (6) gweek3    = estimate;
		when (7) Delivery  = estimate;
		when (8) pregcomp2  = estimate;
		when (9) bpregob   = estimate;
		when (10) prev_preg1= estimate;
		when (11) prev_preg2  = estimate;
		when (12) prev_preg3  = estimate;
		when (13) cohort   = estimate;
		when (14) chage    = estimate;
		when (15) white    = estimate;
		otherwise;
	end;
		
	* Only OUTPUT once per _imputation_, after we've assigned all param columns ;
	if last._imputation_ then output;
	
		/*set negative beta to 0 to avoid errors in PAR, only main exposures*/

		if abwt1 <0 then abwt1=0; 
		if abwt3 <0 then abwt3=0; 
		if gweek1 <0 then gweek1=0; 
		if gweek3 <0 then gweek3=0; 
		if Delivery <0 then Delivery=0; 
		if pregcomp2 <0 then pregcomp2=0; 
		if bpregob <0 then bpregob=0; 

	run;

	title "HEADER: proc print first betas for &group"; 
	proc print data=betas; 
	title ""; 


	/*MANUALLY SPECIFICATION OF PARAMS*/
	data covparms;  
		set covuter;  
		by _imputation_;
		length _type_ $4; 
		_type_ = 'COV';

		rename  Prm1=intercept   Prm2=agebirth   Prm3=abwt1      Prm4=abwt3         Prm5=gweek1  
				Prm6=gweek3      Prm7=Delivery   Prm8=pregcomp2   Prm9=bpregob    
				Prm10=prev_preg1    Prm11=prev_preg2    Prm12=prev_preg3 
				Prm13=cohort    Prm14=chage     Prm15=white        ;

		length _name_ $10;
		
		*i counts rows within each _imputation_;
		if first._imputation_ then i=1;
			else i+1;

		* Assign which row this is (the row "label" in the covariance matrix) ;
		select(i);
			when(1)  _name_ = 'INTERCEPT';
			when(2)  _name_ = 'agebirth';
			when(3)  _name_ = 'abwt1';
			when(4)  _name_ = 'abwt3';
			when(5)  _name_ = 'gweek1';
			when(6)  _name_ = 'gweek3';
			when(7)  _name_ = 'Delivery';
			when(8)  _name_ = 'pregcomp2';
			when(9)  _name_ = 'bpregob';
			when(10)  _name_ = 'prev_preg1';
			when(11)  _name_ = 'prev_preg2';
			when(12)  _name_ = 'prev_preg3';
			when(13)  _name_ = 'cohort';
			when(14)  _name_ = 'chage';
			when(15)  _name_ = 'white';
			otherwise;
		end;
		
		* Output EVERY row;
		output;

		keep _imputation_ _type_ _name_ prm1-prm15 ; /*MANUAL SPECIFICATION OF PARAMETER RANGE*/
	run;

	title "HEADER: proc print first covparms for &group"; 
	proc print data=covparms; 
	title ""; 

	data betacov;  
		set betas covparms;  
		by _imputation_ ;
		keep _imputation_ _type_ _name_ 
				intercept agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
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

	title "HEADER: proc print first betacov1 for &group"; 
	proc print data=betacov1; run;
	title ""; 

	*frequency/prevalence dataset;
	proc sort data=&data;
		by _imputation_ agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1 ;
	run;
	proc means noprint data=&data; 
		by _imputation_ agebirth abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
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

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=birthw,
			modmod = abwt1 abwt3,
			fixfix = agebirth gweek1 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1                   );
	
	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=birthw1,
			modmod = abwt1 ,
			fixfix = agebirth abwt3 gweek1 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1                   );

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=birthw3,
			modmod = abwt3,
			fixfix = agebirth abwt1 gweek1 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1                   );

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=week,
			modmod = gweek1 gweek3,
			fixfix = agebirth abwt1 abwt3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1                   );

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=week1,
			modmod = gweek1,
			fixfix = agebirth abwt1 abwt3 gweek3 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1            );
					
	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=week3,
			modmod = gweek3,
			fixfix = agebirth abwt1 abwt3 gweek1 Delivery pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1            );
					
	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=csec,
			modmod = Delivery  ,
			fixfix = agebirth abwt1 abwt3 gweek1 gweek3 pregcomp2
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1                   );

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=comp,
			modmod = pregcomp2 ,
			fixfix = agebirth abwt1 abwt3 gweek1 gweek3 Delivery
					bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1                   );

	%runPAR(prefixBeta=betacov, prefixFreq=freqs, outpref=uter,
			modmod = abwt1 abwt3 gweek1 gweek3 Delivery pregcomp2 bpregob,
			fixfix = agebirth 
					prev_preg1 prev_preg2 prev_preg3 
					&covar1                   );
											
	/**********************************************************************/
	/*RUN ANALYSES FOR BPREGOB*/
	/**********************************************************************/ 

	title "bpregob & agebirth - not adjusting for other in-uterine factors factors because they may be on the causal pathways, &group.";
	proc genmod data = &data descending;
		by _imputation_ ;
	class id momid ;
	model chob = agebirth bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covuter GEEEmpPEst = uter;
	run;

	title ""; 

	TITLE " multiple imputation - in-uterine factors";
	ods output ParameterEstimates=mi_uter;
	PROC MIANALYZE parms=uter;
	MODELEFFECTS INTERCEPT 
					agebirth  bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1  ;
	RUN;


	/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat_lb.uter2_&group._RR;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;

		set mi_uter(in=a) ;
		
		if a then mod="uter";

		if Parm in ("bpregob"); *only keep main exposures when exporting;

		group="&group."; 

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

	title "HEADER: proc print second regression results for &group"; 
	proc print data=dat_lb.uter2_&group._RR; run; 
	title ""; 

	/*MANUAL SPECIFICATION OF PARAMETERS*/
	data betas; 
	set uter ;  
	by _imputation_;
	_type_ = 'PARM';
		retain intercept agebirth  bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1;
		
		* 'i' counts rows within each _imputation_ group ;
		if first._imputation_ then i=1;  
		else i+1;
		
		select (i);
		when (1) intercept = estimate;
		when (2) agebirth  = estimate;
		when (3) bpregob   = estimate;
		when (4) prev_preg1  = estimate;
		when (5) prev_preg2  = estimate;
		when (6) prev_preg3  = estimate;
		when (7) cohort   = estimate;
		when (8) chage    = estimate;
		when (9) white    = estimate;
		otherwise;
	end;
		
	* Only OUTPUT once per _imputation_, after we've assigned all param columns ;
	if last._imputation_ then output;

	if bpregob<0 then bpregob=0;

	run;

	title "HEADER: proc print second betas for &group"; 
	proc print data=betas; 
	title ""; 

	/*MANUAL SPECIFICATION OF PARAMETERS*/
	data covparms;  
		set covuter;  
		by _imputation_;
		length _type_ $4; 
		_type_ = 'COV';

		rename  Prm1=intercept   Prm2=agebirth   Prm3=bpregob   Prm4=prev_preg1   Prm5=prev_preg2  
				Prm6=prev_preg3  Prm7=cohort     Prm8=chage     Prm9=white        ;

		length _name_ $10;
		
		*i counts rows within each _imputation_;
		if first._imputation_ then i=1;
			else i+1;

		* Assign which row this is (the row "label" in the covariance matrix) ;
		select(i);
			when(1)  _name_ = 'INTERCEPT';
			when(2)  _name_ = 'agebirth';
			when(3)  _name_ = 'bpregob';
			when(4)  _name_ = 'prev_preg1';
			when(5)  _name_ = 'prev_preg2';
			when(6)  _name_ = 'prev_preg3';
			when(7)  _name_ = 'cohort';
			when(8)  _name_ = 'chage';
			when(9)  _name_ = 'white';
			otherwise;
		end;
		
		* Output EVERY row;
		output;

		keep _imputation_ _type_ _name_ prm1-prm9 ; /*MANUAL SPECIFICATION OF PARAMETER RANGE*/
	run;

	title "HEADER: proc print second covparms for &group"; 
	proc print data=covparms; 
	title ""; 

	data betacov;  
		set betas covparms;  
		by _imputation_ ;
		keep _imputation_ _type_ _name_ 
				intercept agebirth  bpregob prev_preg1 prev_preg2 prev_preg3 
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

	title "HEADER: proc print second betacov1 for &group"; 
	proc print data=betacov1; run;
	title ""; 

	*frequency/prevalence dataset;
	proc sort data=&data;
		by _imputation_ agebirth  bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1;
	run;
	proc means noprint data=&data; 
		by _imputation_ agebirth  bpregob prev_preg1 prev_preg2 prev_preg3 
					&covar1 ;
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
			modmod = bpregob,
			fixfix = agebirth  prev_preg1 prev_preg2 prev_preg3 
					&covar1   );

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

	%MIPAR(dat1=birthw1,    dat2=birthw2,       dat3=birthw3,       dat4=birthw4,       dat5=birthw5,       exposure=abwt);
	%MIPAR(dat1=birthw11,   dat2=birthw12,      dat3=birthw13,      dat4=birthw14,      dat5=birthw15,      exposure=abwt1);
	%MIPAR(dat1=birthw31,   dat2=birthw32,      dat3=birthw33,      dat4=birthw34,      dat5=birthw35,      exposure=abwt3);
	%MIPAR(dat1=week1,      dat2=week2,         dat3=week3,         dat4=week4,         dat5=week5,         exposure=gweek); 
	%MIPAR(dat1=week11,     dat2=week12,        dat3=week13,        dat4=week14,        dat5=week15,        exposure=gweek1); 
	%MIPAR(dat1=week31,     dat2=week32,        dat3=week33,        dat4=week34,        dat5=week35,        exposure=gweek3); 
	%MIPAR(dat1=csec1,      dat2=csec2,         dat3=csec3,         dat4=csec4,         dat5=csec5,         exposure=Delivery); 
	%MIPAR(dat1=comp1,      dat2=comp2,         dat3=comp3,         dat4=comp4,         dat5=comp5,         exposure=pregcomp2); 
	%MIPAR(dat1=uter1,      dat2=uter2,         dat3=uter3,         dat4=uter4,         dat5=uter5,         exposure=uter); 
	%MIPAR(dat1=mob1,       dat2=mob2,          dat3=mob3,          dat4=mob4,          dat5=mob5,          exposure=bpregob); 



	/*MANUAL SPECIFICATION OF DATA NAME*/
	data dat_lb.uter_&group._par; 
		set 
		abwt_PAR abwt1_PAR abwt3_PAR 
		gweek_PAR gweek1_PAR gweek3_PAR 
		Delivery_PAR 
		pregcomp2_PAR 
		bpregob_PAR
		uter_PAR
		; 

		length group $ 40;
		group="&group.";
	run; 

	title "HEADER: final output for &group"; 
	proc print data=dat_lb.uter_&group._par; 
	run;
	title "";

%mend ob_par_MI_strat;

/**********************************************************************
	RUN MACRO OVER THE STRATIFIED DATASETS
**********************************************************************/


%ob_par_MI_strat(data=data_male, group=male); run; 
%ob_par_MI_strat(data=data_female, group=female); run; 