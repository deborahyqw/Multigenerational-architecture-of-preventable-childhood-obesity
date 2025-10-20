


/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/*******************************************************************************
Program name: /udd/nhywa/GUTSOB/secondary_windows/
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Bethsaida Cardona (n2bca)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: July 30, 2025
Purpose: Calculate RR and PAR within exposure window; maternal exposures
*******************************************************************************/

/********************************************************************************
Set Up
********************************************************************************/

%include '/udd/nhywa/GUTSOB/secondary_windows/2.clean_data.sas';

/**********************************************************************/

/*
will NOT be adjusting data by cohort because there shouldn't be any participants from GUTSI with data from 
pregnancy. regression is also not running when I do this, not also that there are no repeated subjects..
*/ 


data all;
  set exwindows end=_end_; 
  cohort=cohort-1;
    
	%indic3(vbl=mowestv_pregq, reflev=0, missing=., min=1, max=3, prefix=pregmowestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mocalv_pregq, reflev=0, missing=., min=1, max=3, prefix=pregmocalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mopav_pregq, reflev=3, missing=., min=0, max=2, prefix=pregmopaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');        


	%indic3(vbl=mowestv_earlychq, reflev=0, missing=., min=1, max=3, prefix=earlychmowestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mocalv_earlychq, reflev=0, missing=., min=1, max=3, prefix=earlychmocalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mopav_earlychq, reflev=3, missing=., min=0, max=2, prefix=earlychmopaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');        

	%indic3(vbl=mowestv_chq, reflev=0, missing=., min=1, max=3, prefix=chmowestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mocalv_chq, reflev=0, missing=., min=1, max=3, prefix=chmocalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mopav_chq, reflev=3, missing=., min=0, max=2, prefix=chmopaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');        

	%indic3(vbl=mowestv_adolq, reflev=0, missing=., min=1, max=3, prefix=adolmowestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mocalv_adolq, reflev=0, missing=., min=1, max=3, prefix=adolmocalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
     %indic3(vbl=mopav_adolq, reflev=3, missing=., min=0, max=2, prefix=adolmopaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3'); 

	/*note that we only want to keep participants without missing exposure data for the earliest window
	okay if missing for later windows because they might have developed outcome*/

	if not missing(moob_preg) AND not missing(mowestv_pregq) AND not missing(mocalv_pregq) AND not missing(mopav_pregq);
	    *AND not missing(moob_earlych) AND not missing(mowestv_earlychq) AND not missing(mocalv_earlychq) AND not missing(mopav_earlychq) AND
		not missing(moob_ch) AND not missing(mowestv_chq) AND not missing(mocalv_chq) AND not missing(mopav_chq) AND
		not missing(moob_adol) AND not missing(mowestv_adolq) AND not missing(mocalv_adolq) AND not missing(mopav_adolq);
run;

proc sort data=all; by _imputation_; run;

/*MANUAL SPECIFICATION of variables*/
/*compare exposures and covariates in the stratified analyses*/
proc means data=all; 
 vars cohort white sex
 moage_preg  chage_preg   &pregmowestq_ &pregmocalq_ &pregmopaq_ mosmkv_preg moshiftb_preg
 moage_earlych chage_earlych  &earlychmowestq_ &earlychmocalq_ &earlychmopaq_ mosmkv_earlych moshiftb_earlych
 moage_ch  chage_ch &chmowestq_ &chmocalq_ &chmopaq_ mosmkv_ch moshiftb_ch
 moage_adol chage_adol &adolmowestq_ &adolmocalq_ &adolmopaq_ mosmkv_adol moshiftb_adol
  			      ; 
run; 


%LET covar1= moage_preg chage_preg white sex ; run; /*MANUAL SPECIFICATION OF VARIABLES, NOT ADJUSTING FOR COHORT*/


/**********************************************************************
RUN THE RR, WITH METANALYSIS BY IMPUTATION - SIMULTANEOSLY ADJUSTING FOR PRIOR 
EXPOSURE WINDOWS
**********************************************************************/

/*note that I cannot seem to adjust by maternal smoking in previous exposure windows, might be due to the high correlation
between windows*/

title "HEADER: maternal modifiable factors subject adjustment - Pregnancy";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = &pregmowestq_ &pregmopaq_ mosmkv_preg moshiftb_preg
				&pregmocalq_ moage_preg chage_preg white sex
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_preg;
run;

/*trend*/
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = mowestv_pregm mopav_pregm mosmkv_preg moshiftb_preg
				&pregmocalq_ moage_preg chage_preg white sex
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_preg_t;
run;
title ""; 

TITLE "HEADER: multiple imputation - maternal modifiable factors - PREGNANCY";
ods output ParameterEstimates=mi_mom_preg;
PROC MIANALYZE parms=mom_preg;
MODELEFFECTS INTERCEPT pregmowestq1 pregmowestq2 pregmowestq3 
		pregmopaq0 pregmopaq1 pregmopaq2 mosmkv_preg moshiftb_preg
		pregmocalq1 pregmocalq2 pregmocalq3 
		moage_preg chage_preg white sex  ;
RUN;


ods output ParameterEstimates=mi_mom_preg_t;
PROC MIANALYZE parms=mom_preg_t;
MODELEFFECTS INTERCEPT mowestv_pregm mopav_pregm mosmkv_preg moshiftb_preg
		pregmocalq1 pregmocalq2 pregmocalq3 
		mosmkv_preg moshiftb_preg
		moage_preg chage_preg white sex  ;
RUN;
title "";

/*********** MOOB *****************/

title "maternal modifiable factors - Pregnancy moob, .";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv = &pregmowestq_ &pregmocalq_ &pregmopaq_ mosmkv_preg moshiftb_preg
				moage_preg chage_preg white sex
				moob_preg
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_preg_mob;
run;


TITLE "HEADER: multiple imputation - maternal modifiable factors moob - PREGNANCY";
ods output ParameterEstimates=mi_mom_preg_mob;
PROC MIANALYZE parms=mom_preg_mob;
	MODELEFFECTS INTERCEPT pregmowestq1 pregmowestq2 pregmowestq3 pregmocalq1 pregmocalq2 pregmocalq3 
			pregmopaq0 pregmopaq1 pregmopaq2 mosmkv_preg moshiftb_preg
			moage_preg chage_preg white sex  moob_preg ;
RUN;
title "";


/***************************************************************************************/

title "HEADER: maternal modifiable factors subject adjustment - EARLY CHILDHOOD";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = &earlychmowestq_ &earlychmopaq_ mosmkv_earlych moshiftb_earlych
					&earlychmocalq_ moage_earlych chage_earlych white sex 
				mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_earlych;
run;

/*trend*/
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = mowestv_earlychm mopav_earlychm mosmkv_earlych moshiftb_earlych
					&earlychmocalq_ moage_earlych chage_earlych white sex 
				mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_earlych_t;
run;
title ""; 


TITLE "HEADER: multiple imputation - maternal modifiable factors - EARLY CHILDHOOD";
ods output ParameterEstimates=mi_mom_earlych;
PROC MIANALYZE parms=mom_earlych;
MODELEFFECTS INTERCEPT earlychmowestq1 earlychmowestq2 earlychmowestq3 
		earlychmopaq0 earlychmopaq1 earlychmopaq2 mosmkv_earlych moshiftb_earlych
		earlychmocalq1 earlychmocalq2 earlychmocalq3 
		moage_earlych chage_earlych white sex  
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg ;
RUN;
title "";

ods output ParameterEstimates=mi_mom_earlych_t;
PROC MIANALYZE parms=mom_earlych_t;
MODELEFFECTS INTERCEPT mowestv_earlychm mopav_earlychm mosmkv_earlych moshiftb_earlych
		earlychmocalq1 earlychmocalq2 earlychmocalq3 
		moage_earlych chage_earlych white sex  
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg ;
RUN;
title "";

/************** MOOB ********************/

title "HEADER: maternal modifiable factors subject adjustment moob - EARLY CHILDHOOD";
proc genmod data = all descending;
	by _imputation_ ;
class id momid ;
model chobv_adol = &earlychmowestq_ &earlychmocalq_ &earlychmopaq_ mosmkv_earlych moshiftb_earlych
				moage_earlych chage_earlych white sex 
				moob_earlych
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg moob_preg

	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_earlych_mob;
run;
title ""; 

TITLE "HEADER: multiple imputation - maternal modifiable factors moob - EARLY CHILDHOOD";
ods output ParameterEstimates=mi_mom_earlych_mob;
PROC MIANALYZE parms=mom_earlych_mob;
MODELEFFECTS INTERCEPT earlychmowestq1 earlychmowestq2 earlychmowestq3 earlychmocalq1 earlychmocalq2 earlychmocalq3 
		earlychmopaq0 earlychmopaq1 earlychmopaq2 mosmkv_earlych moshiftb_earlych
		moage_earlych chage_earlych white sex  
		moob_earlych
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg moob_preg;
RUN;
title "";

/***************************************************************************************/

title "HEADER: maternal modifiable factors subject adjustment - CHILDHOOD";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = &chmowestq_  &chmopaq_ mosmkv_ch moshiftb_ch
				&chmocalq_ moage_ch chage_ch white sex
				mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg
				mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_ch;
run;

/*trend*/
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = mowestv_chm mopav_chm mosmkv_ch moshiftb_ch
				&chmocalq_ moage_ch chage_ch white sex
				mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg
				mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_ch_t;
run;
title ""; 

TITLE "HEADER: multiple imputation - maternal modifiable factors - CHILDHOOD";
ods output ParameterEstimates=mi_mom_ch;
PROC MIANALYZE parms=mom_ch;
	MODELEFFECTS INTERCEPT chmowestq1 chmowestq2 chmowestq3 
		chmopaq0 chmopaq1 chmopaq2 mosmkv_ch moshiftb_ch 
		chmocalq1 chmocalq2 chmocalq3 
		moage_ch chage_ch white sex  
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg 
              mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych;
RUN;

ods output ParameterEstimates=mi_mom_ch_t;
PROC MIANALYZE parms=mom_ch_t;
	MODELEFFECTS INTERCEPT mowestv_chm mopav_chm mosmkv_ch moshiftb_ch 
		chmocalq1 chmocalq2 chmocalq3 
		moage_ch chage_ch white sex  
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg 
              mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych;
RUN;
title "";

/************** MOOB *********************/


title "HEADER: maternal modifiable factors subject adjustment moob - CHILDHOOD";
proc genmod data = all descending;
	by _imputation_ ;
class id momid ;
model chobv_adol = &chmowestq_ &chmocalq_ &chmopaq_ mosmkv_ch moshiftb_ch
				moage_ch chage_ch white sex
				moob_ch
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg moob_preg
              mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych moob_earlych

	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_ch_mob;
run;
title ""; 

TITLE "HEADER: multiple imputation - maternal modifiable factors moob - CHILDHOOD";
ods output ParameterEstimates=mi_mom_ch_mob;
PROC MIANALYZE parms=mom_ch_mob;
MODELEFFECTS INTERCEPT chmowestq1 chmowestq2 chmowestq3 chmocalq1 chmocalq2 chmocalq3 
		chmopaq0 chmopaq1 chmopaq2 mosmkv_ch moshiftb_ch 
		moage_ch chage_ch white sex  
		moob_ch
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg moob_preg
              mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych moob_earlych;
RUN;
title "";

/***************************************************************************************/

title "HEADER: maternal modifiable factors subject adjustment - ADOLESCENCE";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = &adolmowestq_ &adolmopaq_ mosmkv_adol moshiftb_adol
					&adolmocalq_ moage_adol chage_adol white sex
				mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg
				mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych
				mowestv_ch mopav_ch /*mosmkv_ch*/ moshiftb_ch

	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_adol;
run;

/*trend*/
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = mowestv_adolm mopav_adolm mosmkv_adol moshiftb_adol
					&adolmocalq_ moage_adol chage_adol white sex
				mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg
				mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych
				mowestv_ch mopav_ch /*mosmkv_ch*/ moshiftb_ch

	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_adol_t;
run;

title ""; 


TITLE "HEADER: multiple imputation - maternal modifiable factors - ADOLESCENCE";
ods output ParameterEstimates=mi_mom_adol;
PROC MIANALYZE parms=mom_adol;
	MODELEFFECTS INTERCEPT adolmowestq1 adolmowestq2 adolmowestq3 
			adolmopaq0 adolmopaq1 adolmopaq2 mosmkv_adol moshiftb_adol 
			adolmocalq1 adolmocalq2 adolmocalq3  moage_adol chage_adol white sex  
				mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg 
				mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych
				mowestv_ch mopav_ch /*mosmkv_ch*/ moshiftb_ch;
RUN;

ods output ParameterEstimates=mi_mom_adol_t;
PROC MIANALYZE parms=mom_adol_t;
	MODELEFFECTS INTERCEPT mowestv_adolm mopav_adolm mosmkv_adol moshiftb_adol 
			adolmocalq1 adolmocalq2 adolmocalq3  moage_adol chage_adol white sex  
				mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg 
				mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych
				mowestv_ch mopav_ch /*mosmkv_ch*/ moshiftb_ch;
RUN;
title "";

/*************** MOOB ********************/

title "HEADER: maternal modifiable factors subject adjustment moob - ADOLESCENCE";
proc genmod data = all descending;
	by _imputation_ ;
class id momid ;
model chobv_adol = &adolmowestq_ &adolmocalq_ &adolmopaq_ mosmkv_adol moshiftb_adol
				moage_adol chage_adol white sex
				moob_adol
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg moob_preg
              mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych moob_earlych
              mowestv_ch mopav_ch /*mosmkv_ch*/ moshiftb_ch moob_ch

	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_adol_mob;
run;
title ""; 


TITLE "HEADER: multiple imputation - maternal modifiable factors moob - ADOLESCENCE";
ods output ParameterEstimates=mi_mom_adol_mob;
PROC MIANALYZE parms=mom_adol_mob;
MODELEFFECTS INTERCEPT adolmowestq1 adolmowestq2 adolmowestq3 adolmocalq1 adolmocalq2 adolmocalq3 
		adolmopaq0 adolmopaq1 adolmopaq2 mosmkv_adol moshiftb_adol 
		moage_adol chage_adol white sex  
		moob_adol
              mowestv_preg mopav_preg /*mosmkv_preg*/ moshiftb_preg moob_preg
              mowestv_earlych mopav_earlych /*mosmkv_earlych*/ moshiftb_earlych moob_earlych
              mowestv_ch mopav_ch /*mosmkv_ch*/ moshiftb_ch moob_ch;
RUN;
title "";





/**********************************************************************/
/*NOW COMBINE ALL DATASETS TOGETHER FOR EXPORT*/

/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat.mom_RR_adj;
		length Parm $ 20;
		length mod $ 40;
		length group $ 40;
		length analysis $ 40; 


		set mi_mom_preg(in=a) mi_mom_earlych(in=b) mi_mom_ch(in=c) mi_mom_adol(in=d) 
			mi_mom_preg_t(in=e) mi_mom_earlych_t(in=f) mi_mom_ch_t(in=g) mi_mom_adol_t(in=h)
		
		;
		
		if a or e then mod="preg";
		if b or f then mod="earlych";
        if c or g then mod="ch";
		if d or h then mod="adol";

		if Parm in (
			"mowestv_pregm", "mopav_pregm",
			"mowestv_earlychm", "mopav_earlychm",
			"mowestv_chm", "mopav_chm",
			"mowestv_adolm", "mopav_adolm") 

		OR ((a or b or c or d) AND Parm in ("pregmowestq1", "pregmowestq2", "pregmowestq3",  
		"pregmopaq0", "pregmopaq1", "pregmopaq2", "mosmkv_preg",  

        "earlychmowestq1", "earlychmowestq2", "earlychmowestq3", 
		"earlychmopaq0", "earlychmopaq1", "earlychmopaq2", "mosmkv_earlych",
        "chmowestq1", "chmowestq2", "chmowestq3",  
		"chmopaq0", "chmopaq1", "chmopaq2", "mosmkv_ch",  

        "adolmowestq1", "adolmowestq2", "adolmowestq3", 
		"adolmopaq0", "adolmopaq1", "adolmopaq2", "mosmkv_adol"))

        OR (a and Parm="moshiftb_preg")
        OR (b and Parm="moshiftb_earlych") 
        OR (c and Parm="moshiftb_ch") 
        OR (d and Parm="moshiftb_adol") 

        ; *only keep main exposures when exporting;

              
		group="mom"; 
		analysis="adjusted";

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

proc print data=dat.mom_RR_adj; 
run; 

	data dat.mom_mob_RR_adj;
		length Parm $ 20;
		length mod $ 40;
		length group $ 40;
		length analysis $ 40; 

		set mi_mom_preg_mob(in=a) mi_mom_earlych_mob(in=b) mi_mom_ch_mob(in=c) mi_mom_adol_mob(in=d) ;
		
		if a then mod="preg";
		if b then mod="earlych";
        if c then mod="ch";
		if d then mod="adol";

		if (mod = "preg" and Parm="moob_preg")
              OR (mod = "earlych" and Parm="moob_earlych") 
              OR (mod = "ch" and Parm="moob_ch") 
              OR (mod = "adol" and Parm="moob_adol") 

              ; *only keep main exposures when exporting;

              
		group="mom"; 
		analysis="adjusted";


		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

proc print data=dat.mom_mob_RR_adj; 
run; 

/*can add code deleting prior datasets*/

/**********************************************************************
RUN THE RR, WITH METANALYSIS BY IMPUTATION - NOT SIMULTANEOSLY ADJUSTING FOR PRIOR 
EXPOSURE WINDOWS
**********************************************************************/


/*DONT HAVE TO RERUN FOR PREGNANCY PERIOD BECAUSE IT ALREADY WASN'T 
ADJUSTED FOR PRIOR WINDOWS*/


/***************************************************************************************/

title "HEADER: maternal modifiable factors subject adjustment - EARLY CHILDHOOD";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = &earlychmowestq_  &earlychmopaq_ mosmkv_earlych moshiftb_earlych
					&earlychmocalq_ moage_earlych chage_earlych white sex 
    
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_earlych;
run;

/*TREND*/
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = mowestv_earlychm mopav_earlychm mosmkv_earlych moshiftb_earlych
					&earlychmocalq_ moage_earlych chage_earlych white sex 
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_earlych_t;
run;
title ""; 

TITLE "HEADER: multiple imputation - maternal modifiable factors - EARLY CHILDHOOD";
ods output ParameterEstimates=mi_mom_earlych;
PROC MIANALYZE parms=mom_earlych;
	MODELEFFECTS INTERCEPT earlychmowestq1 earlychmowestq2 earlychmowestq3 
			earlychmopaq0 earlychmopaq1 earlychmopaq2 mosmkv_earlych moshiftb_earlych
			earlychmocalq1 earlychmocalq2 earlychmocalq3 
			moage_earlych chage_earlych white sex  
				;
RUN;

ods output ParameterEstimates=mi_mom_earlych_t;
PROC MIANALYZE parms=mom_earlych_t;
	MODELEFFECTS INTERCEPT mowestv_earlychm mopav_earlychm mosmkv_earlych moshiftb_earlych
			earlychmocalq1 earlychmocalq2 earlychmocalq3 
			moage_earlych chage_earlych white sex  
				;
RUN;
title "";

/************* MOOB **********************/

title "HEADER: maternal modifiable factors subject adjustment moob - EARLY CHILDHOOD";
proc genmod data = all descending;
	by _imputation_ ;
class id momid ;
model chobv_adol = &earlychmowestq_ &earlychmocalq_ &earlychmopaq_ mosmkv_earlych moshiftb_earlych
				moage_earlych chage_earlych white sex 
				moob_earlych
              

	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_earlych_mob;
run;
title ""; 

TITLE "HEADER: multiple imputation - maternal modifiable factors moob - EARLY CHILDHOOD";
ods output ParameterEstimates=mi_mom_earlych_mob;
PROC MIANALYZE parms=mom_earlych_mob;
MODELEFFECTS INTERCEPT earlychmowestq1 earlychmowestq2 earlychmowestq3 earlychmocalq1 earlychmocalq2 earlychmocalq3 
		earlychmopaq0 earlychmopaq1 earlychmopaq2 mosmkv_earlych moshiftb_earlych
		moage_earlych chage_earlych white sex  
		moob_earlych
              ;
RUN;
title "";

/***************************************************************************************/

title "HEADER: maternal modifiable factors subject adjustment - CHILDHOOD";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = &chmowestq_ &chmopaq_ mosmkv_ch moshiftb_ch
					&chmocalq_ moage_ch chage_ch white sex
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_ch;
run;

/*TREND*/
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = mowestv_chm mopav_chm mosmkv_ch moshiftb_ch
					&chmocalq_ moage_ch chage_ch white sex
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_ch_t;
run;
title ""; 

TITLE "HEADER: multiple imputation - maternal modifiable factors - CHILDHOOD";
ods output ParameterEstimates=mi_mom_ch;
	PROC MIANALYZE parms=mom_ch;
	MODELEFFECTS INTERCEPT chmowestq1 chmowestq2 chmowestq3
			chmopaq0 chmopaq1 chmopaq2 mosmkv_ch moshiftb_ch 
			chmocalq1 chmocalq2 chmocalq3 
			moage_ch chage_ch white sex  
			;
RUN;

ods output ParameterEstimates=mi_mom_ch_t;
	PROC MIANALYZE parms=mom_ch_t;
	MODELEFFECTS INTERCEPT mowestv_chm mopav_chm mosmkv_ch moshiftb_ch 
			chmocalq1 chmocalq2 chmocalq3 
			moage_ch chage_ch white sex  
			;
RUN;
title "";

/********* MOOB ***********************/


title "HEADER: maternal modifiable factors subject adjustment moob - CHILDHOOD";
proc genmod data = all descending;
	by _imputation_ ;
class id momid ;
model chobv_adol = &chmowestq_ &chmocalq_ &chmopaq_ mosmkv_ch moshiftb_ch
				moage_ch chage_ch white sex
				moob_ch

	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_ch_mob;
run;
title ""; 

TITLE "HEADER: multiple imputation - maternal modifiable factors moob - CHILDHOOD";
ods output ParameterEstimates=mi_mom_ch_mob;
PROC MIANALYZE parms=mom_ch_mob;
MODELEFFECTS INTERCEPT chmowestq1 chmowestq2 chmowestq3 chmocalq1 chmocalq2 chmocalq3 
		chmopaq0 chmopaq1 chmopaq2 mosmkv_ch moshiftb_ch 
		moage_ch chage_ch white sex  
		moob_ch
              ;
RUN;
title "";

/***************************************************************************************/

title "HEADER: maternal modifiable factors subject adjustment - ADOLESCENCE";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = &adolmowestq_ &adolmopaq_ mosmkv_adol moshiftb_adol
					&adolmocalq_ moage_adol chage_adol white sex
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covmom GEEEmpPEst = mom_adol;
run;

proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = mowestv_adolm mopav_adolm mosmkv_adol moshiftb_adol
					&adolmocalq_ moage_adol chage_adol white sex
		/ dist = Poisson link = log;
		repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
		ods output GEERCov=covmom GEEEmpPEst = mom_adol_t;
run;
title ""; 


TITLE "HEADER: multiple imputation - maternal modifiable factors - ADOLESCENCE";
ods output ParameterEstimates=mi_mom_adol;
PROC MIANALYZE parms=mom_adol;
MODELEFFECTS INTERCEPT adolmowestq1 adolmowestq2 adolmowestq3 
		adolmopaq0 adolmopaq1 adolmopaq2 mosmkv_adol moshiftb_adol 
		adolmocalq1 adolmocalq2 adolmocalq3 
		moage_adol chage_adol white sex  
			;
RUN;

ods output ParameterEstimates=mi_mom_adol_t;
PROC MIANALYZE parms=mom_adol_t;
MODELEFFECTS INTERCEPT mowestv_adolm mopav_adolm mosmkv_adol moshiftb_adol 
		adolmocalq1 adolmocalq2 adolmocalq3 
		moage_adol chage_adol white sex  
			;
RUN;
title "";

/********* MOOB **********************************/

title "HEADER: maternal modifiable factors subject adjustment moob - ADOLESCENCE";
proc genmod data = all descending;
	by _imputation_ ;
class id momid ;
model chobv_adol = &adolmowestq_ &adolmocalq_ &adolmopaq_ mosmkv_adol moshiftb_adol
				moage_adol chage_adol white sex
				moob_adol

	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
	ods output GEERCov=covmom GEEEmpPEst = mom_adol_mob;
run;
title ""; 


TITLE "HEADER: multiple imputation - maternal modifiable factors moob - ADOLESCENCE";
ods output ParameterEstimates=mi_mom_adol_mob;
PROC MIANALYZE parms=mom_adol_mob;
MODELEFFECTS INTERCEPT adolmowestq1 adolmowestq2 adolmowestq3 adolmocalq1 adolmocalq2 adolmocalq3 
		adolmopaq0 adolmopaq1 adolmopaq2 mosmkv_adol moshiftb_adol 
		moage_adol chage_adol white sex  
		moob_adol
			;
RUN;
title "";





/**********************************************************************/
/*NOW COMBINE ALL DATASETS TOGETHER FOR EXPORT*/

/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat.mom_RR;
		length Parm $ 20;
		length mod $ 40;
		length group $ 40;
		length analysis $ 40; 

		set mi_mom_preg(in=a) mi_mom_earlych(in=b) mi_mom_ch(in=c) mi_mom_adol(in=d) 
			mi_mom_preg_t(in=e) mi_mom_earlych_t(in=f) mi_mom_ch_t(in=g) mi_mom_adol_t(in=h)
		
		;
		
		if a or e then mod="preg";
		if b or f then mod="earlych";
        if c or g then mod="ch";
		if d or h then mod="adol";

		if Parm in (
			"mowestv_pregm", "mopav_pregm",
			"mowestv_earlychm", "mopav_earlychm",
			"mowestv_chm", "mopav_chm",
			"mowestv_adolm", "mopav_adolm") 

		OR ((a or b or c or d) AND Parm in ("pregmowestq1", "pregmowestq2", "pregmowestq3",  
		"pregmopaq0", "pregmopaq1", "pregmopaq2", "mosmkv_preg",  

        "earlychmowestq1", "earlychmowestq2", "earlychmowestq3", 
		"earlychmopaq0", "earlychmopaq1", "earlychmopaq2", "mosmkv_earlych",
        "chmowestq1", "chmowestq2", "chmowestq3",  
		"chmopaq0", "chmopaq1", "chmopaq2", "mosmkv_ch",  

        "adolmowestq1", "adolmowestq2", "adolmowestq3", 
		"adolmopaq0", "adolmopaq1", "adolmopaq2", "mosmkv_adol"))

        OR (a and Parm="moshiftb_preg")
        OR (b and Parm="moshiftb_earlych") 
        OR (c and Parm="moshiftb_ch") 
        OR (d and Parm="moshiftb_adol") 

        ; *only keep main exposures when exporting;

            
		group="mom"; 
		analysis="unadjusted";

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

proc print data=dat.mom_RR; 
run; 

	data dat.mom_mob_RR;
		length Parm $ 20;
		length mod $ 40;
		length group $ 40;

		set mi_mom_preg_mob(in=a) mi_mom_earlych_mob(in=b) mi_mom_ch_mob(in=c) mi_mom_adol_mob(in=d) ;
		
		if a then mod="preg";
		if b then mod="earlych";
        if c then mod="ch";
		if d then mod="adol";

		if (mod = "preg" and Parm="moob_preg")
              OR (mod = "earlych" and Parm="moob_earlych") 
              OR (mod = "ch" and Parm="moob_ch") 
              OR (mod = "adol" and Parm="moob_adol") 

              ; *only keep main exposures when exporting;

              
		group="mom"; 
		analysis="unadjusted";

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

proc print data=dat.mom_mob_RR; 
run; 