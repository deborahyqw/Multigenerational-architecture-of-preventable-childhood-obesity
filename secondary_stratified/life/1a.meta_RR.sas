/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/life
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
   set dat_lb.life_female_rr  dat_lb.life_male_rr;;
   length  HRCI2 $ 18; 
   HRCI2=.;
   SE=StdErr*1;
   beta=Estimate*1;
   if mod="life";
   keep Parm mod group beta SE HRCI2; 
run;

proc print data=meta_RR_sex; 
run;

/**AGE************************************/

data meta_RR_age;
   set dat_lb.life_child_rr  dat_lb.life_teen_rr;;
   length  HRCI2 $ 18; 
   HRCI2=.;
   SE=StdErr*1;
   beta=Estimate*1;
   if mod="life";
   keep Parm mod group beta SE HRCI2; 
run;

proc print data=meta_RR_age; 
run;

/**MATERNAL BMI************************************/


data meta_RR_mob;
   set dat_lb.life_moob_rr  dat_lb.life_nomoob_rr;;
   length  HRCI2 $ 18; 
   HRCI2=.;
   SE=StdErr*1;
   beta=Estimate*1;
   if mod="life";
   keep Parm mod group beta SE HRCI2; 
run;

proc print data=meta_RR_mob; 
run;

/**********************************************************************
CREATE MACRO TO METANALYZE ALL OF THE EXPOSURES FOR EACH GROUP
**********************************************************************/

/*have to metaanalyze each exposure separately, will create macro that can be used to run through each of the stratification groups (sex/age/materinal BMI)*/


%macro metaanal_allexp (data=, group=);

	/* chwestq1 exposure */
	data chwestq1_&group.; set &data; if Parm = 'chwestq1'; run;
	%metaanal(data=chwestq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=chwestq1, outcomelabel=ob, 
			outdat= "RR_life_chwestq1_&group");

	/* chwestq2 exposure */
	data chwestq2_&group.; set &data; if Parm = 'chwestq2'; run;
	%metaanal(data=chwestq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=chwestq2, outcomelabel=ob, 
		outdat= "RR_life_chwestq2_&group");

	/* chwestq3 exposure */
	data chwestq3_&group.; set &data; if Parm = 'chwestq3'; run;
	%metaanal(data=chwestq3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=chwestq3, outcomelabel=ob, 
		outdat= "RR_life_chwestq3_&group");

	/* chstq1 exposure */
	data chstq1_&group.; set &data; if Parm = 'chstq1'; run;
	%metaanal(data=chstq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=chstq1, outcomelabel=ob, 
		outdat= "RR_life_chstq1_&group");

	/* chstq2 exposure */
	data chstq2_&group.; set &data; if Parm = 'chstq2'; run;
	%metaanal(data=chstq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=chstq2, outcomelabel=ob, 
		outdat= "RR_life_chstq2_&group");

	/* chstq3 exposure */
	data chstq3_&group.; set &data; if Parm = 'chstq3'; run;
	%metaanal(data=chstq3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=chstq3, outcomelabel=ob, 
		outdat= "RR_life_chstq3_&group");		

	/* chpaq0 exposure */
	data chpaq0_&group.; set &data; if Parm = 'chpaq0'; run;
	%metaanal(data=chpaq0_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=chpaq0, outcomelabel=ob, 
		outdat= "RR_life_chpaq0_&group");

	/* chpaq1 exposure */
	data chpaq1_&group.; set &data; if Parm = 'chpaq1'; run;
	%metaanal(data=chpaq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=chpaq1, outcomelabel=ob, 
		outdat= "RR_life_chpaq1_&group");

	/* chpaq2 exposure */
	data chpaq2_&group.; set &data; if Parm = 'chpaq2'; run;
	%metaanal(data=chpaq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=chpaq2, outcomelabel=ob, 
		outdat= "RR_life_chpaq2_&group");

%mend metaanal_allexp;


/**********************************************************************
RUN MACRO
**********************************************************************/

%let newpath = /udd/nhywa/GUTSOB/secondary_stratified/1.data;
x "cd &newpath";


%metaanal_allexp(data=meta_RR_sex, group=sex);

%metaanal_allexp(data=meta_RR_age, group=age);

%metaanal_allexp(data=meta_RR_mob, group=mob);









