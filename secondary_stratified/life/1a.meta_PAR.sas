/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/life
Pogrammer: Bethsaida Cardona (n2bca)
Date started: 07/2025
Program Purpose: Metanalyze PARs within stratified groups (male and female, maternal obesity and none, child 
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
 Call in the PAR data from each of the stratified groups, and combine 
 the data from the respective group
**********************************************************************/

/**SEX************************************/
data meta_PAR_sex; 
	set dat_lb.life_female_PAR dat_lb.life_male_PAR; 
	length  HRCI2 $ 18; 
	SE=StdErr*1;
    beta=Estimate*1;
	HRCI2=.;
	keep beta SE group exposure HRCI2; 
run; 

proc print data=meta_PAR_sex; 

/**AGE************************************/

/*Note that the between imputation variance for chstq1-3 among children was 0; maybe because the RR was negative for all imputations
and I had to change them to 0 in order to calculate the PAR*/

data meta_PAR_age; 
	set dat_lb.life_child_PAR dat_lb.life_teen_PAR; 
	length  HRCI2 $ 18; 
	SE=StdErr*1;
    beta=Estimate*1;
	HRCI2=.;
	keep beta SE group exposure HRCI2; 
run; 

proc print data=meta_PAR_age; 


/**MATERNAL BMI************************************/

/*for moob, the RR for chwestq1 was negative across all imputations so the between-imputation variance was zero when calculating the PAR*/

data meta_PAR_mob; 
	set dat_lb.life_moob_PAR dat_lb.life_nomoob_PAR; 
	length  HRCI2 $ 18; 
	SE=StdErr*1;
    beta=Estimate*1;
	HRCI2=.;
	keep beta SE group exposure HRCI2; 
run; 

proc print data=meta_PAR_mob; 

/**********************************************************************
CREATE MACRO TO METANALYZE ALL OF THE EXPOSURES FOR EACH GROUP
**********************************************************************/

/*have to metaanalyze each exposure separately, will create macro that can be used to run through each of the stratification groups (sex/age/materinal BMI)*/


%macro metaanal_allexp (data=, group=);


	/* chwest exposure */
	data chwest_&group.; set &data; if exposure = 'chwest'; run;
	%metaanal(data=chwest_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chwest, outcomelabel=ob, 
			outdat= "PAR_life_chwest_&group");

	/* chwestq1 exposure */
	data chwestq1_&group.; set &data; if exposure = 'chwestq1'; run;
	%metaanal(data=chwestq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chwestq1, outcomelabel=ob, 
			outdat= "PAR_life_chwestq1_&group");

	/* chwestq2 exposure */
	data chwestq2_&group.; set &data; if exposure = 'chwestq2'; run;
	%metaanal(data=chwestq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chwestq2, outcomelabel=ob, 
		outdat= "PAR_life_chwestq2_&group");

	/* chwestq3 exposure */
	data chwestq3_&group.; set &data; if exposure = 'chwestq3'; run;
	%metaanal(data=chwestq3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chwestq3, outcomelabel=ob, 
		outdat= "PAR_life_chwestq3_&group");

	/* chst exposure */
	data chst_&group.; set &data; if exposure = 'chst'; run;
	%metaanal(data=chst_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chst, outcomelabel=ob, 
		outdat= "PAR_life_chst_&group");

	/* chstq1 exposure */
	data chstq1_&group.; set &data; if exposure = 'chstq1'; run;
	%metaanal(data=chstq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chstq1, outcomelabel=ob, 
		outdat= "PAR_life_chstq1_&group");

	/* chstq2 exposure */
	data chstq2_&group.; set &data; if exposure = 'chstq2'; run;
	%metaanal(data=chstq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chstq2, outcomelabel=ob, 
		outdat= "PAR_life_chstq2_&group");

	/* chstq3 exposure */
	data chstq3_&group.; set &data; if exposure = 'chstq3'; run;
	%metaanal(data=chstq3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chstq3, outcomelabel=ob, 
		outdat= "PAR_life_chstq3_&group");		

	/* chpa exposure */
	data chpa_&group.; set &data; if exposure = 'chpa'; run;
	%metaanal(data=chpa_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chpa, outcomelabel=ob, 
		outdat= "PAR_life_chpa_&group");

	/* chpaq0 exposure */
	data chpaq0_&group.; set &data; if exposure = 'chpaq0'; run;
	%metaanal(data=chpaq0_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chpaq0, outcomelabel=ob, 
		outdat= "PAR_life_chpaq0_&group");

	/* chpaq1 exposure */
	data chpaq1_&group.; set &data; if exposure = 'chpaq1'; run;
	%metaanal(data=chpaq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chpaq1, outcomelabel=ob, 
		outdat= "PAR_life_chpaq1_&group");

	/* chpaq2 exposure */
	data chpaq2_&group.; set &data; if exposure = 'chpaq2'; run;
	%metaanal(data=chpaq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=chpaq2, outcomelabel=ob, 
		outdat= "PAR_life_chpaq2_&group");


	/* life exposure */
	data life_&group.; set &data; if exposure = 'life'; run;
	%metaanal(data=life_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=life, outcomelabel=ob, 
		outdat= "PAR_life_life_&group");

%mend metaanal_allexp;


/**********************************************************************
RUN MACRO
**********************************************************************/

%let newpath = /udd/nhywa/GUTSOB/secondary_stratified/1.data;
x "cd &newpath";


%metaanal_allexp(data=meta_PAR_sex, group=sex);

%metaanal_allexp(data=meta_PAR_age, group=age);

%metaanal_allexp(data=meta_PAR_mob, group=mob);






