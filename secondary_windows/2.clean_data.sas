

/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 

program name: /udd/nhywa/GUTSOB/secondary_windows/
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Bethsaida Cardona (n2bca) 
Preparation date: 07/2025
Purpose: Combines the long GUTS1 and GUTS2 datasets output from /udd/nhywa/GUTSOB/secondary_windows/1.merge_ob_MI.sas 
and prepares data to run the exposure window analyses
*/


/***************************************************************************/
/*SET UP*/

%include '/udd/nhywa/GUTSOB/secondary_windows/1.merge_ob_MI.sas';


/***************************************************************************
MERGE GUTS1 AND GUTS2 ; ADJUST DATASET FURTHER
****************************************************************************/

data all; 
	set all1_tidy all2_tidy;

	if mobmi >= 30 then moob=1; else moob=0; 
	if bmibpreg >= 30 then bpregob=1; else bpregob=0;
	
	/*create indicators for age*/
	length age_ind $ 20; 
	if chage >=-1 and chage <1 then age_ind="preg"; 
	if chage >=1 and chage <5 then age_ind="earlych"; 
	if chage >=5 and chage <11 then age_ind="ch"; 
	if chage >=11 and chage <= 18 then age_ind="adol"; 

  /*change smoking to ever/never from past/current/never*/
  if mosmk=1 then mosmk=0; 
    else if mosmk in (2,3) then mosmk=1; 

  /*for now will change region from indicator variables into one variable*/
  region=.; 
  if midwest=0 AND south=0 and west=0 then region=1; 
  if midwest=1 AND south=0 and west=0 then region=2; 
  if midwest=0 AND south=1 and west=0 then region=3; 
  if midwest=0 AND south=0 and west=1 then region=4; 

  /*only keep if age_ind isn't missing: should only be missing if age is < -1*/
  if not missing(age_ind);

run;



proc export data=all
	outfile='/udd/nhywa/GUTSOB/secondary_windows/1.data/all.csv'
	dbms=csv replace;
run; 



/***************************************************************************
Calculate exposure averages
****************************************************************************/

/* within each age indicator, take the average of all the exposure windows
personal: chwest chst chpa chcal / chbmibase 
mom: mowest mocal mopa moshift moob (measured with mombmi) [mosmk - this is categorical]
social: ses
*/



proc means data=all noprint;
  class cohort _imputation_ id momid age_ind; /*group by variables that aren't changing and we want to keep*/
  var chwest chst chpa chcal mowest mocal mopa moshift mosmk ses; /*variables we want to take the average or sum of*/
  output out=summarized_means 
    mean(chwest)=chwestv 
    mean(chst)=chstv 
    mean(chpa)=chpav 
    mean(chcal)=chcalv 
    mean(mowest)=mowestv 
    mean(mocal)=mocalv 
    mean(mopa)=mopav 
    mean(moshift)=moshiftv 
    mean(mobmi)=mobmiv
    mean(mosmk)=mosmkv
    mean(ses)=sesv 
    sum(chob)=chobv
    ;
run;


/* Remove _TYPE_ and _FREQ_ */
data summarized_means;
  set summarized_means;
  if not missing(cohort) AND 
  not missing(age_ind) AND
  not missing(_imputation_) AND 
  not missing (id) AND 
  not missing(momid); /* Keeps grouped results, exclude overall summaries*/
  drop _TYPE_ _FREQ_;
run;

proc print data=summarized_means (obs=50); run; 

proc sort data=summarized_means; by cohort _imputation_ id momid; run; 


proc export data=summarized_means
	outfile='/udd/nhywa/GUTSOB/secondary_windows/1.data/summarized_means.csv'
	dbms=csv replace;
run; 



/*transpose the means based on the age indicators*/

%let exposure_list = chwestv chstv chpav chcalv mowestv mocalv mopav moshiftv mobmiv mosmkv sesv chobv; /*list of exposures to run through*/

%macro run_all_exposures;
  %let n = 1;
  %let this_exposure = %scan(&exposure_list, &n);
  
  %do %while(%length(&this_exposure));
  
    proc transpose data=summarized_means out=wide_&this_exposure. prefix=&this_exposure._;
      by cohort _imputation_ id momid;
      id age_ind;
      var &this_exposure;
    run;

    %let n = %eval(&n + 1);
    %let this_exposure = %scan(&exposure_list, &n);
  %end;

%mend run_all_exposures;
 

%run_all_exposures;



/***************************************************************************
FOR COVARIATES THAT VARY WITHIN EXPOSURE WINDOWS, 
WILL TAKE THE FIRST VALUE THAT APPEARS WITHIN THE EXPOSURE WINDOW
****************************************************************************/

/*
personal: chbmibase cohort white sex chage
mom:  moage cohort white sex
socio: midwest south west heduc1 heduc2 fincome1 fincome2 fincome3
*/


/* Step 1: Sort the data by grouping variables and year */
proc sort data=all;
    by cohort _imputation_ id momid age_ind year;
run;


data earliest;
    set all;
    by cohort _imputation_ id momid age_ind;

    retain chage_keep chbmi_keep moage_keep region_keep
            chage_year chbmi_year moage_year region_year
           ;

    /* Initialize retained vars at start of each group */
    if first.age_ind then do;
        call missing(chage_keep, chbmi_keep, moage_keep, region_keep,
                    chage_year, chbmi_year, moage_year, region_year);
    end;

    /* Keep first non-missing value (from earliest year) */
    if missing(chage_keep) and not missing(chage) then do;
        chage_keep = chage;
        chage_year = year;
    end;

    if missing(chbmi_keep) and not missing(chbmi) then do;
        chbmi_keep = chbmi;
        chbmi_year = year;
    end;

    if missing(moage_keep) and not missing(moage) then do;
        moage_keep = moage;
        moage_year = year;
    end;
  
    if missing(region_keep) and not missing(region) then do;
        region_keep = region;
        region_year = year;
    end;

    /* Output once per group, at the last obs */
    if last.age_ind then do;
        output;
    end;

    keep cohort _imputation_ id momid age_ind
         chage_keep chage_year
         chbmi_keep chbmi_year
         moage_keep moage_year
         region_keep region_year; 
run;

proc print data=earliest(obs=50); 

/*
proc export data=earliest
	outfile='/udd/nhywa/GUTSOB/secondary_windows/1.data/earliest.csv'
	dbms=csv replace;
run; 
*/

data earliest; 
  set earliest; 
  rename chage_keep=chage chbmi_keep=chbmi moage_keep=moage region_keep=region; 
  drop chage_year chbmi_year moage_year region_year; 
run; 



proc print data=earliest(obs=50); 


/*transpose from long to wide*/


/*transpose the means based on the age indicators*/

%let covariate_list = chage chbmi moage region; /*list of covariates to run through*/

%macro run_all_covariates;
  %let n = 1;
  %let this_covariate = %scan(&covariate_list, &n);
  
  %do %while(%length(&this_covariate));
  
    proc transpose data=earliest out=wide_&this_covariate. prefix=&this_covariate._;
      by cohort _imputation_ id momid;
      id age_ind;
      var &this_covariate;
    run;

    %let n = %eval(&n + 1);
    %let this_covariate = %scan(&covariate_list, &n);
  %end;

%mend run_all_covariates;
 

%run_all_covariates;

/*
proc print data=wide_chage(obs=20); 
proc print data=wide_chbmi(obs=20); 
proc print data=wide_moage(obs=20); 
proc print data=wide_region(obs=20); 
*/


/***************************************************************************
FOR NON-TIMEVARYING COVARIATES WILL ALSO DO SOMETHING SIMILAR AS ABOVE
TO RETAIN IN DATASET, OTHERWISE WONT BE RETAINED
****************************************************************************/

proc sort data=all;
    by cohort _imputation_ id momid;
run;

data nonvarying;
    set all;
    by cohort _imputation_ id momid;
    if first.momid; 
    /*keep only variables of interest*/
    keep cohort _imputation_ id momid chbmibase white sex husbeduc income bpregob; 
run;

/*
proc print data=nonvarying(obs=50); 
run; 
*/

/***************************************************************************
CREATE INDICATOR FOR OVERALL OUTCOME
****************************************************************************/

/*create indicator for overall outcome, will not be grouped by the age indicator*/
proc means data=all noprint;
  class cohort _imputation_ id momid; 
  var chob; /*variables we want to take sum of*/
  output out=summarized_outcome 
    sum(chob)=chobv;
run;


data summarized_outcome;
  set summarized_outcome;
  if not missing(cohort) and not missing(_imputation_) 
  and not missing (id) and not missing(momid); /* Keeps grouped results, exclude overall summaries*/
  drop _TYPE_ _FREQ_;
run;


proc sort data=summarized_outcome; by cohort _imputation_ id momid; run; 
proc print data=summarized_outcome (obs=50); run; 



/***************************************************************************
FINALLY MERGE ALL DATASETS AND ADJUST FURTHER FOR ANALYSIS
****************************************************************************/

data exwindows;
  merge 
    nonvarying summarized_outcome 
    wide_chwestv wide_chstv wide_chpav wide_chcalv wide_mowestv wide_mocalv 
    wide_mopav wide_moshiftv wide_mobmiv wide_mosmkv wide_sesv wide_chobv
    wide_chage wide_chbmi wide_moage wide_region
    
  end=_end_;
  
  by cohort _imputation_ id momid;

  /*note maternal smoking is 0 (never) or 1 (ever/never) when we took the average within exposure periods, a average that is not 0 will indicate a change 
  between status*/ 
  if mosmkv_preg = 0 then mosmkv_preg = 0; else if mosmkv_preg > 0 then mosmkv_preg =1; 
  if mosmkv_earlych = 0 then mosmkv_earlych = 0; else if mosmkv_earlych > 0 then mosmkv_earlych =1; 
  if mosmkv_ch = 0 then mosmkv_ch = 0; else if mosmkv_ch > 0 then mosmkv_ch =1; 
  if mosmkv_adol = 0 then mosmkv_adol = 0; else if mosmkv_adol > 0 then mosmkv_adol =1; 

  /*recode mombmi to binary obese/not obese variable. will be using the average of each exposure window*/
  *#PPP# I worry that mom obesity during peri-pregnancy is susceptible for misclassification. 
  	BMI during the 3 trimester can fall under the obesity category even among mothers who are normal weight before pregnancy.
    I think we can focus on the pre-pregnancy obesity for this reason. ;  	
  /*BC: good point! So for the "the peri-pregnancy period", I will use the pre-pregnancy bmi instead, we will have to make a note of
  this in the methods or somewhere in the figure description*/
  
  if bpregob = 1 then moob_preg=1; else if bpregob = 0 then moob_preg=0; 
  if mobmiv_earlych >= 30 then moob_earlych=1; else if not missing(mobmiv_earlych) AND mobmiv_earlych<30 then moob_earlych=0; 
  if mobmiv_ch >= 30 then moob_ch=1; else if not missing(mobmiv_ch) AND mobmiv_ch<30 then moob_ch=0; 
  if mobmiv_adol >= 30 then moob_adol=1; else if not missing(mobmiv_adol) AND mobmiv_adol<30 then moob_adol=0; 

  
  /*will redefine shiftwork to be binary, some shiftwork versus no shiftwork, so that regressions can converge (funky distributions otherwise)*/
    if moshiftv_preg > 0 then moshiftb_preg=1; else if not missing(moshiftv_preg) AND moshiftv_preg<=0 then moshiftb_preg=0; 
    if moshiftv_earlych > 0 then moshiftb_earlych=1; else if not missing(moshiftv_earlych) AND moshiftv_earlych<=0 then moshiftb_earlych=0; 
    if moshiftv_ch > 0 then moshiftb_ch=1; else if not missing(moshiftv_ch) AND moshiftv_ch<=0 then moshiftb_ch=0; 
    if moshiftv_adol > 0 then moshiftb_adol=1; else if not missing(moshiftv_adol) AND moshiftv_adol<=0 then moshiftb_adol=0; 

  /*refine region to dummy variables*/
  midwest_preg = .; south_preg = .;  west_preg = .;
  if region_preg = 1 then do; midwest_preg = 0; south_preg  = 0; west_preg   = 0; end;
    else if region_preg = 2 then do; midwest_preg = 1; south_preg  = 0; west_preg   = 0; end;
    else if region_preg = 3 then do; midwest_preg = 0; south_preg  = 1; west_preg   = 0; end;
    else if region_preg = 4 then do; midwest_preg = 0; south_preg  = 0; west_preg   = 1; end;

  midwest_earlych=.; south_earlych=.; west_earlych=.;
  if region_earlych = 1 then do; midwest_earlych = 0; south_earlych  = 0; west_earlych   = 0; end;
    else if region_earlych = 2 then do; midwest_earlych = 1; south_earlych  = 0; west_earlych   = 0; end;
    else if region_earlych = 3 then do; midwest_earlych = 0; south_earlych  = 1; west_earlych   = 0; end;
    else if region_earlych = 4 then do; midwest_earlych = 0; south_earlych  = 0; west_earlych   = 1; end;

  midwest_ch=.; south_ch=.; west_ch=.;
  if region_ch = 1 then do; midwest_ch = 0; south_ch  = 0; west_ch   = 0; end;
    else if region_ch = 2 then do; midwest_ch = 1; south_ch  = 0; west_ch   = 0; end;
    else if region_ch = 3 then do; midwest_ch = 0; south_ch  = 1; west_ch   = 0; end;
    else if region_ch = 4 then do; midwest_ch = 0; south_ch  = 0; west_ch   = 1; end;

  midwest_adol=.; south_adol=.; west_adol=.;
  if region_adol = 1 then do; midwest_adol = 0; south_adol  = 0; west_adol   = 0; end;
    else if region_adol = 2 then do; midwest_adol = 1; south_adol  = 0; west_adol   = 0; end;
    else if region_adol = 3 then do; midwest_adol = 0; south_adol  = 1; west_adol   = 0; end;
    else if region_adol = 4 then do; midwest_adol = 0; south_adol  = 0; west_adol   = 1; end;

  %indic3(vbl=husbeduc, reflev=3, missing=., min=1, max=2, prefix=heduc, usemiss=0,
          label1='<college',label2='college');
  %indic3(vbl=income, reflev=4, missing=., min=1, max=3, prefix=fincome, usemiss=0,
          label1='<50k',label2='50-99k',label3='100-149k');   

run;




**********   need to make all exposures to categorical for PAR    ********;


/*exposure list is same as defined previously*/

%macro run_quartiles;
  %let n = 1;
  %let this_exposure = %scan(&exposure_list, &n);
  
  %do %while(%length(&this_exposure));
  
    proc rank data=exwindows group=4 out=exwindows; by cohort _imputation_;
      var &this_exposure._preg &this_exposure._earlych &this_exposure._ch &this_exposure._adol
      ;
      ranks &this_exposure._pregq &this_exposure._earlychq &this_exposure._chq &this_exposure._adolq
      ;
    run;

    %let n = %eval(&n + 1);
    %let this_exposure = %scan(&exposure_list, &n);
  %end;

%mend run_quartiles;
 

%run_quartiles;

proc sort data=exwindows; by _imputation_; 
run; 

/* not sure what the following is doing...
%macro run_quartiles;
  %let n = 1;
  %let this_exposure = %scan(&exposure_list, &n);
  
  %do %while(%length(&this_exposure));
  
    proc rank data=exwindows group=4 out=exwindows; by _imputation_;
      var &this_exposure._preg &this_exposure._earlych &this_exposure._ch &this_exposure._adol
      ;
      by _imputation_;
      ranks &this_exposure._pregq2 &this_exposure._earlychq2 &this_exposure._chq2 &this_exposure._adolq2
      ;
    run;

    %let n = %eval(&n + 1);
    %let this_exposure = %scan(&exposure_list, &n);
  %end;

%mend run_quartiles;
 
%run_quartiles;
*/

/*calculate the median value of each quartile to then apply regression models to obtain
the p for trend */

%macro quant_med (data, var, quantvar, quantcont);
  proc means data=&data n nmiss median p25 p75;
    var &var;
    class cohort _imputation_ &quantvar;
    output out=stat MEDIAN=&quantcont;
  run;
  proc sort data=&data; by cohort  _imputation_ &quantvar; run;
  proc sort data=stat; by cohort  _imputation_ &quantvar; run;

  data &data;
    merge &data stat;
    by cohort  _imputation_ &quantvar;
    if momid = . then delete;
    if &var=. then &quantcont=.;
  run;

%mend quant_med;


%let exposure_m_list = chwestv chstv chpav mowestv mopav moshiftv mobmiv sesv; /*list of exposures to run through*/


%macro run_medians(data, var, quantvar, quantcont);
  %let n = 1;
  %let this_exposure = %scan(&exposure_m_list, &n);
  
  %do %while(%length(&this_exposure));

    %quant_med (data=exwindows, var=&this_exposure._preg, quantvar=&this_exposure._pregq, quantcont=&this_exposure._pregm);
    %quant_med (data=exwindows, var=&this_exposure._earlych, quantvar=&this_exposure._earlychq, quantcont=&this_exposure._earlychm);
    %quant_med (data=exwindows, var=&this_exposure._ch, quantvar=&this_exposure._chq, quantcont=&this_exposure._chm);
    %quant_med (data=exwindows, var=&this_exposure._adol, quantvar=&this_exposure._adolq, quantcont=&this_exposure._adolm);
    
    %let n = %eval(&n + 1);
    %let this_exposure = %scan(&exposure_m_list, &n);
  %end;

%mend run_medians;

%run_medians;



proc export data=exwindows
	outfile='/udd/nhywa/GUTSOB/secondary_windows/1.data/exwindows.csv'
	dbms=csv replace;
run; 



proc datasets nolist;
delete all1 all2 all1_baseline all2_baseline all1_tidy all2_tidy
  all earliest
  nonvarying summarized_outcome 
    wide_chwestv wide_chstv wide_chpav wide_chcalv wide_mowestv wide_mocalv 
    wide_mopav wide_moshiftv wide_mosmkv wide_sesv wide_chobv
    wide_chage wide_chbmi wide_moage wide_region
;
run;


*#PPP# I may have misunderstood the code -
	Is the outcome CHOB coded as ever/never in each exposure window?
	How it is handled for participants who became obese in the middle of the window?
	Would then then exposure in the latter half of the window happen after the outcome occur, causing reverse-causation?
	I think we have discussed this before but don't remember exactly how we are going to do abou this.
	Are you going to run model like this: chob_adol ~ exposure_preg + exposure_earlych + exposure_ch ?
	Sorry for this silly question! ; 
  /*BC:  Yes the outcome chob is coded as ever/never in each exposure window. 
  When I was making the data from wide to long, I coded it so that when a participant became obese that time period and future time periods would  be excluded.
  Thus when I took the avg exposure for a particular window it didn't include any of the exposures from when a child became obese
  Does that make sense? 
  And now that Andy suggested not adjusting for previous time periods, I am just running 
  chob_adol ~ exposure_preg + covariates_preg 
  chob_adol ~ exposure_earlych + covariates_earlych
  */