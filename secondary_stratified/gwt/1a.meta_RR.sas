/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/gwt
Pogrammer: Bethsaida Cardona (n2bca)
Date started: 07/2025
Program Purpose: Metanalyze RRs within stratified groups (male and female, maternal obesity and none, child 
and teen) to obtain the Q for heterogeneity
Statistical Analyses: %metaanal for metanalysis 
*/


/**********************************************************************
 Read-in macros, data formats, and libraries
**********************************************************************/

/*path to library with datasets, MANUAL SPECIFICATION*/ 
libname dat_lb '/udd/nhywa/GUTSOB/secondary_stratified/1.data';

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

/**********************************************************************
 Call in the RR data from each of the stratified groups, and combine 
 the data from the respective group
**********************************************************************/


/**SEX************************************/


data meta_RR_sex;
   set dat_lb.gwt_female_RR  dat_lb.gwt_male_RR ;
   	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep Parm mod group beta SE HRCI2; 

run;

proc print data=meta_RR_sex; run;

/**AGE************************************/

data meta_RR_age;
   set dat_lb.gwt_child_RR  dat_lb.gwt_teen_RR;
   	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep Parm mod group beta SE HRCI2; 

run;

proc print data=meta_RR_age; run;

/**MATERNAL BMI************************************/

data meta_RR_mob;
   set dat_lb.gwt_moob_RR  dat_lb.gwt_nomoob_RR; 
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep Parm mod group beta SE HRCI2; 

run;

proc print data=meta_RR_mob; run;
 


/**********************************************************************
CREATE MACRO TO METANALYZE ALL OF THE EXPOSURES FOR EACH GROUP
**********************************************************************/


/*have to metaanalyze each exposure separately, will create macro that can be used to run through each of the stratification groups (sex/age/materinal BMI)*/

%macro metaanal_allexp (data=, group=);

	/* gotweight exposure */
	data gotweight_&group.; set &data; if Parm = 'gotweight'; run;
	%metaanal(data=gotweight_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=gotweight, outcomelabel=ob, 
		outdat= "RR_gwt_gotweight_&group");

	
%mend metaanal_allexp;


/**********************************************************************
RUN MACRO
**********************************************************************/

%let newpath = /udd/nhywa/GUTSOB/secondary_stratified/1.data;
x "cd &newpath";


%metaanal_allexp(data=meta_RR_sex, group=sex);

%metaanal_allexp(data=meta_RR_age, group=age);

%metaanal_allexp(data=meta_RR_mob, group=mob);









