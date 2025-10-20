
/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/*******************************************************************************
Program name: /udd/nhywa/GUTSOB/secondary_windows/
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Bethsaida Cardona (n2bca)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: July 29, 2025
Purpose: Calculate RR and PAR within exposure window; child exposures

*******************************************************************************/

/********************************************************************************
Set Up
********************************************************************************/

%include '/udd/nhywa/GUTSOB/secondary_windows/2.clean_data.sas';

/**********************************************************************/
data all;
  set exwindows end=_end_;
  cohort=cohort-1;
    
	%indic3(vbl=chwestv_chq, reflev=0, missing=., min=1, max=3, prefix=chchwestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chcalv_chq, reflev=0, missing=., min=1, max=3, prefix=chchcalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chstv_chq, reflev=0, missing=., min=1, max=3, prefix=chchstq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chpav_chq, reflev=3, missing=., min=0, max=2, prefix=chchpaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');

	%indic3(vbl=chwestv_adolq, reflev=0, missing=., min=1, max=3, prefix=adolchwestq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chcalv_adolq, reflev=0, missing=., min=1, max=3, prefix=adolchcalq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chstv_adolq, reflev=0, missing=., min=1, max=3, prefix=adolchstq, usemiss=0,
            label1='Q2',label2='Q3', label3='Q4');
    %indic3(vbl=chpav_adolq, reflev=3, missing=., min=0, max=2, prefix=adolchpaq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');

	/*note that we only want to keep participants without missing exposure data for both windows
	so that adjusted and unadjusted effect estimates are more comparable*/

	if not missing(chwestv_chq) AND not missing(chstv_chq) AND not missing(chpav_chq);
	*AND not missing(chwestv_adolq) AND not missing(chstv_adolq) AND not missing(chpav_adolq); 
	
run;

proc means data=all; 
	var chwestv_chq chcalv_chq chstv_chq chpav_chq cohort chage_ch white sex chbmi_ch
    chwestv_adolq chcalv_adolq chstv_adolq chpav_adolq cohort chage_adol white sex chbmi_adol; 
run;

proc sort data=all; by _imputation_; run;

*%LET covar1= cohort chage_ch white sex chbmi_ch; /*MANUAL SPECIFICATION OF VARIABLES*/


/**********************************************************************
RUN THE RR, WITH METANALYSIS BY IMPUTATION - SIMULTANEOSLY ADJUSTING FOR PRIOR 
EXPOSURE WINDOWS
**********************************************************************/

title "HEADER: personal modifiable factors - CHILDHOOD ";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = &chchwestq_ &chchstq_ &chchpaq_ &chchcalq_ 
            cohort chage_ch white sex chbmi_ch
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb; /*note that our data no longer has repeated subjects, it is one row/id so might not have to do this*/
	ods output GEERCov=covlife GEEEmpPEst = life_ch;
run;
title "";

/*run for trend*/ 
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = chwestv_chm chstv_chm chpav_chm  &chchcalq_ 
            cohort chage_ch white sex chbmi_ch
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb; /*note that our data no longer has repeated subjects, it is one row/id so might not have to do this*/
	ods output GEERCov=covlife GEEEmpPEst = life_ch_t;
run;
title "";


TITLE "HEADER: multiple imputation - personal modifiable factors - CHILDHOOD";
ods output ParameterEstimates=mi_life_ch;
PROC MIANALYZE parms=life_ch;
MODELEFFECTS INTERCEPT 
		chchwestq1 chchwestq2 chchwestq3 chchstq1 chchstq2 chchstq3 chchpaq0 chchpaq1 chchpaq2 
		chchcalq1 chchcalq2 chchcalq3 
        cohort chage_ch white sex chbmi_ch;
RUN;
title "";

ods output ParameterEstimates=mi_life_ch_t;
PROC MIANALYZE parms=life_ch_t;
MODELEFFECTS INTERCEPT 
		chwestv_chm chstv_chm chpav_chm
		chchcalq1 chchcalq2 chchcalq3 
        cohort chage_ch white sex chbmi_ch;
RUN;
title "";


/***************************************************************************************/

title "HEADER: personal modifiable factors - ADOLESCENCE ";
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = &adolchwestq_ &adolchstq_ &adolchpaq_ &adolchcalq_ 
            cohort chage_adol white sex chbmi_adol
            chwestv_ch chstv_ch chpav_ch
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb; /*note that our data no longer has repeated subjects, it is one row/id so might not have to do this*/
	ods output GEERCov=covlife GEEEmpPEst = life_adol;
run;
title "";

/*for trend*/
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = chwestv_adolm chstv_adolm chpav_adolm
			&adolchcalq_ 
            cohort chage_adol white sex chbmi_adol
            chwestv_ch chstv_ch chpav_ch
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb; /*note that our data no longer has repeated subjects, it is one row/id so might not have to do this*/
	ods output GEERCov=covlife GEEEmpPEst = life_adol_t;
run;
title "";


TITLE "HEADER: multiple imputation - personal modifiable factors - ADOLESCENCE";
ods output ParameterEstimates=mi_life_adol;
PROC MIANALYZE parms=life_adol;
MODELEFFECTS INTERCEPT 
		adolchwestq1 adolchwestq2 adolchwestq3 adolchstq1 adolchstq2 adolchstq3 adolchpaq0 adolchpaq1 adolchpaq2 
		adolchcalq1 adolchcalq2 adolchcalq3 
        cohort chage_adol white sex chbmi_adol
        chwestv_ch chstv_ch chpav_ch;

RUN;
title "";

ods output ParameterEstimates=mi_life_adol_t;
PROC MIANALYZE parms=life_adol_t;
MODELEFFECTS INTERCEPT 
		chwestv_adolm chstv_adolm chpav_adolm 
		adolchcalq1 adolchcalq2 adolchcalq3 
        cohort chage_adol white sex chbmi_adol
        chwestv_ch chstv_ch chpav_ch;

RUN;
title "";


/**********************************************************************/
/*NOW COMBINE ALL DATASETS TOGETHER FOR EXPORT*/

/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat.life_RR_adj;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;
    	length analysis $ 40; 


		set mi_life_ch(in=a) mi_life_ch_t(in=b) mi_life_adol(in=c) mi_life_adol_t(in=d) ;
		
		if a OR b then mod="ch";
		if c OR d then mod="adol";

		if Parm in (

        "chchwestq1", "chchwestq2", "chchwestq3", "chchstq1", "chchstq2", "chchstq3", 
		"chchpaq0", "chchpaq1", "chchpaq2", 
            
        "adolchwestq1", "adolchwestq2", "adolchwestq3", "adolchstq1", "adolchstq2", "adolchstq3", 
		"adolchpaq0", "adolchpaq1", "adolchpaq2",
		
		"chwestv_chm", "chstv_chm", "chpav_chm", 
		"chwestv_adolm", "chstv_adolm", "chpav_adolm" 
		
		); *only keep main exposures when exporting;

		group="life"; 
		analysis="adjusted";

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

proc print data=dat.life_RR_adj; 
run; 


/**********************************************************************
RUN THE RR, WITH METANALYSIS BY IMPUTATION - NOT SIMULTANEOSLY ADJUSTING FOR PRIOR 
EXPOSURE WINDOWS
**********************************************************************/

/*childhood exposures data will remain the same as before since 
it wasn't adjusted by prior windows*/

/***************************************************************************************/


title "HEADER: personal modifiable factors - ADOLESCENCE ";
proc genmod data = all descending;
	by _imputation_ ;
class id momid ;
model chobv_adol = &adolchwestq_ &adolchstq_ &adolchpaq_ &adolchcalq_ 
            cohort chage_adol white sex chbmi_adol
            
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb; /*note that our data no longer has repeated subjects, it is one row/id so might not have to do this*/
	ods output GEERCov=covlife GEEEmpPEst = life_adol;
run;
title "";

/*trend*/ 
proc genmod data = all descending;
	by _imputation_ ;
	class id momid ;
	model chobv_adol = chwestv_adolm chstv_adolm chpav_adolm
			&adolchcalq_ 
            cohort chage_adol white sex chbmi_adol
	/ dist = Poisson link = log;
	repeated subject=id(momid)/type=unstr PRINTMLE ecovb; /*note that our data no longer has repeated subjects, it is one row/id so might not have to do this*/
	ods output GEERCov=covlife GEEEmpPEst = life_adol_t;
run;
title "";


TITLE "HEADER: multiple imputation - personal modifiable factors - ADOLESCENCE";
ods output ParameterEstimates=mi_life_adol;
PROC MIANALYZE parms=life_adol;
MODELEFFECTS INTERCEPT 
		adolchwestq1 adolchwestq2 adolchwestq3 adolchstq1 adolchstq2 adolchstq3 adolchpaq0 adolchpaq1 adolchpaq2 
		adolchcalq1 adolchcalq2 adolchcalq3 
        cohort chage_adol white sex chbmi_adol
        ;

RUN;
title "";

ods output ParameterEstimates=mi_life_adol_t;
PROC MIANALYZE parms=life_adol_t;
MODELEFFECTS INTERCEPT 
		chwestv_adolm chstv_adolm chpav_adolm 
		adolchcalq1 adolchcalq2 adolchcalq3 
        cohort chage_adol white sex chbmi_adol
        ;

RUN;
title "";

/**********************************************************************/
/*NOW COMBINE ALL DATASETS TOGETHER FOR EXPORT*/

/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat.life_RR;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;
    	length analysis $ 40; 

		set mi_life_ch(in=a) mi_life_ch_t(in=b) mi_life_adol(in=c) mi_life_adol_t(in=d) ;
		
		if a OR b then mod="ch";
		if c OR d then mod="adol";

		if Parm in (
        "chchwestq1", "chchwestq2", "chchwestq3", "chchstq1", "chchstq2", "chchstq3", 
		"chchpaq0", "chchpaq1", "chchpaq2", 
            
        "adolchwestq1", "adolchwestq2", "adolchwestq3", "adolchstq1", "adolchstq2", "adolchstq3", 
		"adolchpaq0", "adolchpaq1", "adolchpaq2",
		
		"chwestv_chm", "chstv_chm", "chpav_chm", 
		"chwestv_adolm", "chstv_adolm", "chpav_adolm" 
		
		
		); *only keep main exposures when exporting;

		group="life"; 
		analysis="unadjusted";

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

proc print data=dat.life_RR; 
run; 