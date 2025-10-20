/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/uter
Pogrammer: Bethsaida Cardona (n2bca)
Date started: 07/2025
Program Purpose: Metanalyze RRs within stratified groups (male and female, maternal obesity and none, child 
and teen) to obtain the Q for heterogeneity
Statistical Analyses: %metaanal for metanalysis 
*/

/**********************************************************************
 Read-in macros, data formats, and libraries
**********************************************************************/

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

/* note that for we are calling in two datsets, one that calls in all variables except bpregob and 
the other that calls in bpregob */

/**SEX************************************/

data meta_RR_sex;
   set dat_lb.uter_female_RR  dat_lb.uter_male_RR 
   		dat_lb.uter2_female_RR  dat_lb.uter2_male_RR;
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep Parm mod group beta SE HRCI2; 

run;

proc print data=meta_RR_sex; run;

/**AGE************************************/

data meta_RR_age;
   set dat_lb.uter_child_RR  dat_lb.uter_teen_RR 
   		dat_lb.uter2_child_RR  dat_lb.uter2_teen_RR; 
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep Parm mod group beta SE HRCI2; 

run;

proc print data=meta_RR_age; run;

/**MATERNAL BMI************************************/

data meta_RR_mob;
   set dat_lb.uter_moob_RR  dat_lb.uter_nomoob_RR 
   		dat_lb.uter2_moob_RR  dat_lb.uter2_nomoob_RR; 
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

	/* abwt1 exposure */
	data abwt1_&group.; set &data; if Parm = 'abwt1'; run;
	%metaanal(data=abwt1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=abwt1, outcomelabel=ob, 
			outdat= "RR_uter_abwt1_&group");

	/* abwt3 exposure */
	data abwt3_&group.; set &data; if Parm = 'abwt3'; run;
	%metaanal(data=abwt3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=abwt3, outcomelabel=ob, 
		outdat= "RR_uter_abwt3_&group");

	
	/* gweek1 exposure */
	data gweek1_&group.; set &data; if Parm = 'gweek1'; run;
	%metaanal(data=gweek1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=gweek1, outcomelabel=ob, 
		outdat= "RR_uter_gweek1_&group");

	/* gweek3 exposure */
	data gweek3_&group.; set &data; if Parm = 'gweek3'; run;
	%metaanal(data=gweek3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=gweek3, outcomelabel=ob, 
		outdat= "RR_uter_gweek3_&group");

	/* Delivery exposure */
	data Delivery_&group.; set &data; if Parm = 'Delivery'; run;
	%metaanal(data=Delivery_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=Delivery, outcomelabel=ob, 
		outdat= "RR_uter_Delivery_&group");

	/* pregcomp2 exposure */
	data pregcomp2_&group.; set &data; if Parm = 'pregcomp2'; run;
	%metaanal(data=pregcomp2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=pregcomp2, outcomelabel=ob, 
		outdat= "RR_uter_pregcomp2_&group");	

	/* bpregob exposure */
	data bpregob_&group.; set &data; if Parm = 'bpregob'; run;
	%metaanal(data=bpregob_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=T,
		explabel=bpregob, outcomelabel=ob, 
		outdat= "RR_uter_bpregob_&group");		


%mend metaanal_allexp;





/**********************************************************************
RUN MACRO
**********************************************************************/

%let newpath = /udd/nhywa/GUTSOB/secondary_stratified/1.data;
x "cd &newpath";


%metaanal_allexp(data=meta_RR_sex, group=sex);

%metaanal_allexp(data=meta_RR_age, group=age);

%metaanal_allexp(data=meta_RR_mob, group=mob);





