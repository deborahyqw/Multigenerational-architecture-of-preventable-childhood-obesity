
/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/*******************************************************************************
Program name: /udd/nhywa/GUTSOB/secondary_windows/
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Bethsaida Cardona (n2bca)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: July 30, 2025
Purpose: Calculate RR and PAR within exposure window; socioeconomic exposures

*******************************************************************************/

/********************************************************************************
Set Up
********************************************************************************/

%include '/udd/nhywa/GUTSOB/secondary_windows/2.clean_data.sas';

/**********************************************************************/



data all;
  set exwindows end=_end_;
  cohort=cohort-1;
              
    %indic3(vbl=sesv_pregq, reflev=3, missing=., min=0, max=2, prefix=pregsesq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');

    %indic3(vbl=sesv_earlychq, reflev=3, missing=., min=0, max=2, prefix=earlychsesq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');

    %indic3(vbl=sesv_chq, reflev=3, missing=., min=0, max=2, prefix=chsesq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');

    %indic3(vbl=sesv_adolq, reflev=3, missing=., min=0, max=2, prefix=adolsesq, usemiss=0,
            label0='Q1',label1='Q2', label2='Q3');


	/*note that we only want to keep participants without missing exposure data for the earliest window
	okay if missing for later windows because they might have developed outcome*/

    if not missing(sesv_pregq); 
    *AND not missing(sesv_earlych) AND not missing(sesv_chq) AND not missing(sesv_adolq); 

run; 

proc sort data=all; by _imputation_; run;


/*MANUAL SPECIFICATION of variables*/
/*compare exposures and covariates in the stratified analyses*/
proc means data=all; 
    vars cohort  white sex heduc1 heduc2 fincome1 fincome2 fincome3
    midwest_preg south_preg west_preg chage_preg
    midwest_ch south_ch west_ch chage_ch   
    midwest_earlych south_earlych west_earlych chage_earlych   
    midwest_adol south_adol west_adol chage_adol   
 ; 
run; 

proc means data=all; 
  var sesv_adolm; 
  class sesv_adolq; 
run; 

/**********************************************************************
RUN THE RR, WITH METANALYSIS BY IMPUTATION - SIMULTANEOSLY ADJUSTING FOR
PRIOR EXPOSURE WINDOWS
**********************************************************************/

/**********************************************************************/

title "HEADER: nSES - PREGNANCY"; 
proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                pregsesq0 pregsesq1 pregsesq2
              midwest_preg south_preg west_preg chage_preg white sex  
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_preg;
run;

/*trend*/
proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                sesv_pregm
              midwest_preg south_preg west_preg chage_preg white sex  
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_preg_t;
run;
title ""; 


TITLE " HEADER: multiple imputation - PREGNANCY";
ods output ParameterEstimates=mi_nses_preg;
PROC MIANALYZE parms=nses_preg;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
                pregsesq0 pregsesq1 pregsesq2
              midwest_preg south_preg west_preg chage_preg white sex    ;
RUN;

ods output ParameterEstimates=mi_nses_preg_t;
PROC MIANALYZE parms=nses_preg_t;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
                sesv_pregm
              midwest_preg south_preg west_preg chage_preg white sex    ;
RUN;

title ""; 



/**********************************************************************/


title "HEADER: nSES - EARLY CHILDHOOD - ADJ"; 
proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    earlychsesq0 earlychsesq1 earlychsesq2
                  midwest_earlych south_earlych west_earlych chage_earlych white sex  
                  sesv_preg
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_earlych;
run;

proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    sesv_earlychm
                  midwest_earlych south_earlych west_earlych chage_earlych white sex  
                  sesv_preg
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_earlych_t;
run;
title ""; 

TITLE " HEADER: multiple imputation - EARLY CHILDHOOD - ADJ";
ods output ParameterEstimates=mi_nses_earlych;
PROC MIANALYZE parms=nses_earlych;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
                earlychsesq0 earlychsesq1 earlychsesq2
              midwest_earlych south_earlych west_earlych chage_earlych white sex   
              sesv_preg ;
RUN;

ods output ParameterEstimates=mi_nses_earlych_t;
PROC MIANALYZE parms=nses_earlych_t;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
              sesv_earlychm
              midwest_earlych south_earlych west_earlych chage_earlych white sex   
              sesv_preg ;
RUN;
title ""; 


/**********************************************************************/


title "HEADER: nSES - CHILDHOOD - ADJ"; 
proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    chsesq0 chsesq1 chsesq2
                  midwest_ch south_ch west_ch chage_ch white sex  
                  sesv_preg sesv_earlych
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_ch;
run;

proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    sesv_chm
                  midwest_ch south_ch west_ch chage_ch white sex  
                  sesv_preg sesv_earlych
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_ch_t;
run;

title ""; 

TITLE " HEADER: multiple imputation - EARLY CHILDHOOD - ADJ";
ods output ParameterEstimates=mi_nses_ch;
PROC MIANALYZE parms=nses_ch;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
              chsesq0 chsesq1 chsesq2
              midwest_ch south_ch west_ch chage_ch white sex   
              sesv_preg sesv_earlych;
RUN;

ods output ParameterEstimates=mi_nses_ch_t;
PROC MIANALYZE parms=nses_ch_t;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
              sesv_chm
              midwest_ch south_ch west_ch chage_ch white sex   
              sesv_preg sesv_earlych;
RUN;
title ""; 


/**********************************************************************/

title "HEADER: nSES - ADOLESCENCE - ADJ"; 
proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    adolsesq0 adolsesq1 adolsesq2
                  midwest_adol south_adol west_adol chage_adol white sex  
                  sesv_preg sesv_earlych sesv_ch
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_adol;
run;

proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                  sesv_adolm
                  midwest_adol south_adol west_adol chage_adol white sex  
                  sesv_preg sesv_earlych sesv_ch
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_adol_t;
run;

title ""; 



TITLE " HEADER: multiple imputation - ADOLESCENCE - ADJ";
ods output ParameterEstimates=mi_nses_adol;
PROC MIANALYZE parms=nses_adol;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
                adolsesq0 adolsesq1 adolsesq2
              midwest_adol south_adol west_adol chage_adol white sex   
              sesv_preg sesv_earlych sesv_ch;
RUN;

ods output ParameterEstimates=mi_nses_adol_t;
PROC MIANALYZE parms=nses_adol_t;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
              sesv_adolm
              midwest_adol south_adol west_adol chage_adol white sex   
              sesv_preg sesv_earlych sesv_ch;
RUN;

title ""; 

/**********************************************************************/
/*NOW COMBINE ALL DATASETS TOGETHER FOR EXPORT*/

/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat.socio_RR_adj;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;
    length analysis $ 40; 

		set mi_nses_preg(in=a) mi_nses_earlych(in=b) mi_nses_ch(in=c) mi_nses_adol(in=d) 
        mi_nses_preg_t(in=e) mi_nses_earlych_t(in=f) mi_nses_ch_t(in=g) mi_nses_adol_t(in=h) ;
		
		if a or e then mod="preg";
		if b or f then mod="earlych";
    if c or g then mod="ch";
		if d or h then mod="adol";

		if Parm in (

      "sesv_pregm", "sesv_earlychm", "sesv_chm", "sesv_adolm",

      "pregsesq0", "pregsesq1", "pregsesq2",
      "earlychsesq0", "earlychsesq1", "earlychsesq2",
      "chsesq0", "chsesq1", "chsesq2",
      "adolsesq0", "adolsesq1", "adolsesq2"
        ); *only keep main exposures when exporting;

		group="socio"; 
    analysis="adjusted";

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

proc print data=dat.socio_RR_adj; 
run; 

/*can add code to delete datasets*/

/**********************************************************************
RUN THE RR, WITH METANALYSIS BY IMPUTATION - NOT SIMULTANEOSLY ADJUSTING FOR
PRIOR EXPOSURE WINDOWS
**********************************************************************/


/**********************************************************************/

/*NOTE THAT WE DONT HAVE TO RERUN THE PREGNANCY PERIOD SINCE WE ALREADY WEREN'T 
ADJUSTING FOR PRIOR PERIODS*/


/**********************************************************************/

title "HEADER: nSES - EARLY CHILDHOOD"; 
proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    earlychsesq0 earlychsesq1 earlychsesq2
                  midwest_earlych south_earlych west_earlych chage_earlych white sex  
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_earlych;
run;

proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    sesv_earlychm
                  midwest_earlych south_earlych west_earlych chage_earlych white sex  
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_earlych_t;
run;
title ""; 


TITLE " HEADER: multiple imputation - EARLY CHILDHOOD";
ods output ParameterEstimates=mi_nses_earlych;
PROC MIANALYZE parms=nses_earlych;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
                earlychsesq0 earlychsesq1 earlychsesq2
              midwest_earlych south_earlych west_earlych chage_earlych white sex   
              ;
RUN;

ods output ParameterEstimates=mi_nses_earlych_t;
PROC MIANALYZE parms=nses_earlych_t;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
              sesv_earlychm
              midwest_earlych south_earlych west_earlych chage_earlych white sex   
              ;
RUN;
title ""; 


/**********************************************************************/


title "HEADER: nSES - CHILDHOOD"; 
proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    chsesq0 chsesq1 chsesq2
                  midwest_ch south_ch west_ch chage_ch white sex  
              
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_ch;
run;

proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                  sesv_chm
                  midwest_ch south_ch west_ch chage_ch white sex  
              
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_ch_t;
run;
title ""; 

TITLE " HEADER: multiple imputation - EARLY CHILDHOOD";
ods output ParameterEstimates=mi_nses_ch;
PROC MIANALYZE parms=nses_ch;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
                chsesq0 chsesq1 chsesq2
              midwest_ch south_ch west_ch chage_ch white sex   
              ;
RUN;

ods output ParameterEstimates=mi_nses_ch_t;
PROC MIANALYZE parms=nses_ch_t;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
              sesv_chm
              midwest_ch south_ch west_ch chage_ch white sex   
              ;
RUN;
title ""; 


/**********************************************************************/

title "HEADER: nSES - ADOLESCENCE"; 
proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    adolsesq0 adolsesq1 adolsesq2
                  midwest_adol south_adol west_adol chage_adol white sex  
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_adol;
run;

proc genmod data = all descending;
    by _imputation_ ;
    class id momid ;
    model chobv_adol = heduc1 heduc2 fincome1 fincome2 fincome3
                    sesv_adolm
                  midwest_adol south_adol west_adol chage_adol white sex  
    / dist = Poisson link = log;
    repeated subject=id(momid)/type=unstr PRINTMLE ecovb;
    ods output GEERCov=covnses GEEEmpPEst = nses_adol_t;
run;

title ""; 



TITLE " HEADER: multiple imputation - ADOLESCENCE";
ods output ParameterEstimates=mi_nses_adol;
PROC MIANALYZE parms=nses_adol;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
                adolsesq0 adolsesq1 adolsesq2
              midwest_adol south_adol west_adol chage_adol white sex   
              ;
RUN;

ods output ParameterEstimates=mi_nses_adol_t;
PROC MIANALYZE parms=nses_adol_t;
MODELEFFECTS INTERCEPT 
            heduc1 heduc2 fincome1 fincome2 fincome3
              sesv_adolm
              midwest_adol south_adol west_adol chage_adol white sex   
              ;
RUN;
title ""; 

/**********************************************************************/
/*NOW COMBINE ALL DATASETS TOGETHER FOR EXPORT*/

/*MANUAL SPECIFICATION OF DATASET NAME AND GROUP*/
	data dat.socio_RR;
		length Parm $ 15;
		length mod $ 40;
		length group $ 40;
    length analysis $ 40; 


		set mi_nses_preg(in=a) mi_nses_earlych(in=b) mi_nses_ch(in=c) mi_nses_adol(in=d) 
        mi_nses_preg_t(in=e) mi_nses_earlych_t(in=f) mi_nses_ch_t(in=g) mi_nses_adol_t(in=h) ;
		
		if a or e then mod="preg";
		if b or f then mod="earlych";
    if c or g then mod="ch";
		if d or h then mod="adol";

		if Parm in (

      "sesv_pregm", "sesv_earlychm", "sesv_chm", "sesv_adolm",
      "pregsesq0", "pregsesq1", "pregsesq2",
      "earlychsesq0", "earlychsesq1", "earlychsesq2",
      "chsesq0", "chsesq1", "chsesq2",
      "adolsesq0", "adolsesq1", "adolsesq2"
        ); *only keep main exposures when exporting;

		group="socio"; 
    analysis="unadjusted";

		RR=exp(Estimate); LCI=exp(LCLMean); UCI=exp(UCLMean);
	run; 

proc print data=dat.socio_RR; 
run; 
