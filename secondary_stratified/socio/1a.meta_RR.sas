/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/socio
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

/* note that for each group we are calling in two datsets, one with the income/education and 
the other with the nses */

/**SEX************************************/


data meta_RR_sex;
   set dat_lb.soc_female_RR  dat_lb.soc_male_RR 
        dat_lb.nses_female_RR dat_lb.nses_male_RR;
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep Parm mod group beta SE HRCI2; 

run;

proc print data=meta_RR_sex; run;

/**AGE************************************/

data meta_RR_age;
   set dat_lb.soc_child_RR  dat_lb.soc_teen_RR 
        dat_lb.nses_child_RR dat_lb.nses_teen_RR;
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep Parm mod group beta SE HRCI2; 

run;

proc print data=meta_RR_age; run;

/**MATERNAL BMI************************************/

data meta_RR_mob;
   set dat_lb.soc_moob_RR  dat_lb.soc_nomoob_RR 
        dat_lb.nses_moob_RR dat_lb.nses_nomoob_RR;
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

	/* sesq0 exposure */
	data sesq0_&group.; set &data; if Parm = 'sesq0'; run;
	%metaanal(data=sesq0_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=sesq0, outcomelabel=ob, 
			outdat= "RR_socio_sesq0_&group");

	/* sesq1 exposure */
	data sesq1_&group.; set &data; if Parm = 'sesq1'; run;
	%metaanal(data=sesq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=sesq1, outcomelabel=ob, 
		outdat= "RR_socio_sesq1_&group");

	/* sesq2 exposure */
	data sesq2_&group.; set &data; if Parm = 'sesq2'; run;
	%metaanal(data=sesq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=sesq2, outcomelabel=ob, 
		outdat= "RR_socio_sesq2_&group");

	/* heduc1 exposure */
	data heduc1_&group.; set &data; if Parm = 'heduc1'; run;
	%metaanal(data=heduc1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=heduc1, outcomelabel=ob, 
		outdat= "RR_socio_heduc1_&group");

	/* heduc2 exposure */
	data heduc2_&group.; set &data; if Parm = 'heduc2'; run;
	%metaanal(data=heduc2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=heduc2, outcomelabel=ob, 
		outdat= "RR_socio_heduc2_&group");

	/* fincome1 exposure */
	data fincome1_&group.; set &data; if Parm = 'fincome1'; run;
	%metaanal(data=fincome1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=fincome1, outcomelabel=ob, 
		outdat= "RR_socio_fincome1_&group");		

	/* fincome2 exposure */
	data fincome2_&group.; set &data; if Parm = 'fincome2'; run;
	%metaanal(data=fincome2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=fincome2, outcomelabel=ob, 
		outdat= "RR_socio_fincome2_&group");

	/* fincome3 exposure */
	data fincome3_&group.; set &data; if Parm = 'fincome3'; run;
	%metaanal(data=fincome3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=fincome3, outcomelabel=ob, 
		outdat= "RR_socio_fincome3_&group");


%mend metaanal_allexp;


/**********************************************************************
RUN MACRO
**********************************************************************/

%let newpath = /udd/nhywa/GUTSOB/secondary_stratified/1.data;
x "cd &newpath";


%metaanal_allexp(data=meta_RR_sex, group=sex);

%metaanal_allexp(data=meta_RR_age, group=age);

%metaanal_allexp(data=meta_RR_mob, group=mob);









