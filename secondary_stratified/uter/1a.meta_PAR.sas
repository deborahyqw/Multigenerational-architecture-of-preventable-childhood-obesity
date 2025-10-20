/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/uter
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
   set dat_lb.uter_female_PAR dat_lb.uter_male_PAR; 
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep beta SE group exposure HRCI2; 
run;

proc print data=meta_PAR_sex; run;


/**AGE************************************/

data meta_PAR_age;
   set dat_lb.uter_child_PAR dat_lb.uter_teen_PAR; 
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep beta SE group exposure HRCI2; 
run;

proc print data=meta_PAR_age; run;

/**MATERNAL BMI************************************/

data meta_PAR_mob;
   set dat_lb.uter_moob_PAR dat_lb.uter_nomoob_PAR; 
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

	/* abwt exposure */
	data abwt_&group.; set &data; if exposure = 'abwt'; run;
	%metaanal(data=abwt_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=abwt, outcomelabel=ob, 
			outdat= "PAR_uter_abwt_&group");

	/* abwt1 exposure */
	data abwt1_&group.; set &data; if exposure = 'abwt1'; run;
	%metaanal(data=abwt1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=abwt1, outcomelabel=ob, 
			outdat= "PAR_uter_abwt1_&group");

	/* abwt3 exposure */
	data abwt3_&group.; set &data; if exposure = 'abwt3'; run;
	%metaanal(data=abwt3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=abwt3, outcomelabel=ob, 
		outdat= "PAR_uter_abwt3_&group");

	/* gweek exposure */
	data gweek_&group.; set &data; if exposure = 'gweek'; run;
	%metaanal(data=gweek_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=gweek, outcomelabel=ob, 
		outdat= "PAR_uter_gweek_&group");


	/* gweek1 exposure */
	data gweek1_&group.; set &data; if exposure = 'gweek1'; run;
	%metaanal(data=gweek1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=gweek1, outcomelabel=ob, 
		outdat= "PAR_uter_gweek1_&group");

	/* gweek3 exposure */
	data gweek3_&group.; set &data; if exposure = 'gweek3'; run;
	%metaanal(data=gweek3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=gweek3, outcomelabel=ob, 
		outdat= "PAR_uter_gweek3_&group");

	/* Delivery exposure */
	data Delivery_&group.; set &data; if exposure = 'Delivery'; run;
	%metaanal(data=Delivery_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=Delivery, outcomelabel=ob, 
		outdat= "PAR_uter_Delivery_&group");

	/* pregcomp2 exposure */
	data pregcomp2_&group.; set &data; if exposure = 'pregcomp2'; run;
	%metaanal(data=pregcomp2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=pregcomp2, outcomelabel=ob, 
		outdat= "PAR_uter_pregcomp2_&group");	

	/* bpregob exposure */
	data bpregob_&group.; set &data; if exposure = 'bpregob'; run;
	%metaanal(data=bpregob_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=bpregob, outcomelabel=ob, 
		outdat= "PAR_uter_bpregob_&group");		

	/* uter exposure */
	data uter_&group.; set &data; if exposure = 'uter'; run;
	%metaanal(data=uter_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=uter, outcomelabel=ob, 
		outdat= "PAR_uter_uter_&group");


%mend metaanal_allexp;


/**********************************************************************
RUN MACRO
**********************************************************************/

%let newpath = /udd/nhywa/GUTSOB/secondary_stratified/1.data;
x "cd &newpath";


%metaanal_allexp(data=meta_PAR_sex, group=sex);
%metaanal_allexp(data=meta_PAR_age, group=age);
%metaanal_allexp(data=meta_PAR_mob, group=mob);








