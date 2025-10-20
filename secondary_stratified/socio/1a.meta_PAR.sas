/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/socio
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
 Call in the RR data from each of the stratified groups, and combine 
 the data from the respective group
**********************************************************************/



/**SEX************************************/

data meta_PAR_sex;
   set dat_lb.socio_female_PAR dat_lb.socio_male_PAR; 
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep beta SE group exposure HRCI2; 
run;

proc print data=meta_PAR_sex; run;


/**AGE************************************/

data meta_PAR_age;
   set dat_lb.socio_child_PAR dat_lb.socio_teen_PAR; 
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep beta SE group exposure HRCI2; 
run;

proc print data=meta_PAR_age; run;

/**MATERNAL BMI************************************/

data meta_PAR_mob;
   set dat_lb.socio_moob_PAR dat_lb.socio_nomoob_PAR; 
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep beta SE group exposure HRCI2; 
run;

proc print data=meta_PAR_mob; run;


/**********************************************************************
CREATE MACRO TO METANALYZE ALL OF THE EXPOSURES FOR EACH GROUP
**********************************************************************/


/*have to metaanalyze each exposure separately, will create macro that can be used to run through each of the stratification groups (sex/age/materinal BMI)*/


%macro metaanal_allexp (data=, group=);

	/* ses exposure */
	data ses_&group.; set &data; if exposure = 'ses'; run;
	%metaanal(data=ses_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=ses, outcomelabel=ob, 
			outdat= "PAR_socio_ses_&group");

	/* sesq0 exposure */
	data sesq0_&group.; set &data; if exposure = 'sesq0'; run;
	%metaanal(data=sesq0_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=sesq0, outcomelabel=ob, 
			outdat= "PAR_socio_sesq0_&group");

	/* sesq1 exposure */
	data sesq1_&group.; set &data; if exposure = 'sesq1'; run;
	%metaanal(data=sesq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=sesq1, outcomelabel=ob, 
		outdat= "PAR_socio_sesq1_&group");

	/* sesq2 exposure */
	data sesq2_&group.; set &data; if exposure = 'sesq2'; run;
	%metaanal(data=sesq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=sesq2, outcomelabel=ob, 
		outdat= "PAR_socio_sesq2_&group");


	/* heduc exposure */
	data heduc_&group.; set &data; if exposure = 'heduc'; run;
	%metaanal(data=heduc_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=heduc, outcomelabel=ob, 
		outdat= "PAR_socio_heduc_&group");

	/* heduc1 exposure */
	data heduc1_&group.; set &data; if exposure = 'heduc1'; run;
	%metaanal(data=heduc1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=heduc1, outcomelabel=ob, 
		outdat= "PAR_socio_heduc1_&group");

	/* heduc2 exposure */
	data heduc2_&group.; set &data; if exposure = 'heduc2'; run;
	%metaanal(data=heduc2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=heduc2, outcomelabel=ob, 
		outdat= "PAR_socio_heduc2_&group");

	/* fincome exposure */
	data fincome_&group.; set &data; if exposure = 'fincome'; run;
	%metaanal(data=fincome_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=fincome, outcomelabel=ob, 
		outdat= "PAR_socio_fincome_&group");	

	/* fincome1 exposure */
	data fincome1_&group.; set &data; if exposure = 'fincome1'; run;
	%metaanal(data=fincome1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=fincome1, outcomelabel=ob, 
		outdat= "PAR_socio_fincome1_&group");		

	/* fincome2 exposure */
	data fincome2_&group.; set &data; if exposure = 'fincome2'; run;
	%metaanal(data=fincome2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=fincome2, outcomelabel=ob, 
		outdat= "PAR_socio_fincome2_&group");

	/* fincome3 exposure */
	data fincome3_&group.; set &data; if exposure = 'fincome3'; run;
	%metaanal(data=fincome3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=fincome3, outcomelabel=ob, 
		outdat= "PAR_socio_fincome3_&group");

	/* soc exposure */
	data soc_&group.; set &data; if exposure = 'soc'; run;
	%metaanal(data=soc_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=soc, outcomelabel=ob, 
		outdat= "PAR_socio_soc_&group");


%mend metaanal_allexp;


/**********************************************************************
RUN MACRO
**********************************************************************/

%let newpath = /udd/nhywa/GUTSOB/secondary_stratified/1.data;
x "cd &newpath";


%metaanal_allexp(data=meta_PAR_sex, group=sex);
%metaanal_allexp(data=meta_PAR_age, group=age);
%metaanal_allexp(data=meta_PAR_mob, group=mob);








