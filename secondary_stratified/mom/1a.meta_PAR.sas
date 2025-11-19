/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 
Program name: /udd/nhywa/GUTSOB/secondary_stratified/mom
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
   set dat_lb.mom_female_PAR dat_lb.mom_male_PAR; 
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep beta SE group exposure HRCI2; 
run;

proc print data=meta_PAR_sex; run;


/**AGE************************************/

data meta_PAR_age;
   set dat_lb.mom_child_PAR dat_lb.mom_teen_PAR; 
	length  HRCI2 $ 18; 
	HRCI2=.;
	SE=StdErr*1;
    beta=Estimate*1;
	keep beta SE group exposure HRCI2; 
run;

proc print data=meta_PAR_age; run;

/**MATERNAL BMI************************************/


data meta_PAR_mob;
   set dat_lb.mom_moob_PAR dat_lb.mom_nomoob_PAR; 
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

	/* mowest exposure */
	data mowest_&group.; set &data; if exposure = 'mowest'; run;
	%metaanal(data=mowest_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mowest, outcomelabel=ob, 
			outdat= "PAR_mom_mowest_&group");

	/* mowestq1 exposure */
	data mowestq1_&group.; set &data; if exposure = 'mowestq1'; run;
	%metaanal(data=mowestq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mowestq1, outcomelabel=ob, 
			outdat= "PAR_mom_mowestq1_&group");

	/* mowestq2 exposure */
	data mowestq2_&group.; set &data; if exposure = 'mowestq2'; run;
	%metaanal(data=mowestq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mowestq2, outcomelabel=ob, 
		outdat= "PAR_mom_mowestq2_&group");

	/* mowestq3 exposure */
	data mowestq3_&group.; set &data; if exposure = 'mowestq3'; run;
	%metaanal(data=mowestq3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mowestq3, outcomelabel=ob, 
		outdat= "PAR_mom_mowestq3_&group");


	/* mopa exposure */
	data mopa_&group.; set &data; if exposure = 'mopa'; run;
	%metaanal(data=mopa_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mopa, outcomelabel=ob, 
		outdat= "PAR_mom_mopa_&group");

	/* mopaq0 exposure */
	data mopaq0_&group.; set &data; if exposure = 'mopaq0'; run;
	%metaanal(data=mopaq0_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mopaq0, outcomelabel=ob, 
		outdat= "PAR_mom_mopaq0_&group");

	/* mopaq1 exposure */
	data mopaq1_&group.; set &data; if exposure = 'mopaq1'; run;
	%metaanal(data=mopaq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mopaq1, outcomelabel=ob, 
		outdat= "PAR_mom_mopaq1_&group");

	/* mopaq2 exposure */
	data mopaq2_&group.; set &data; if exposure = 'mopaq2'; run;
	%metaanal(data=mopaq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mopaq2, outcomelabel=ob, 
		outdat= "PAR_mom_mopaq2_&group");	

	/* mosmk exposure */
	data mosmk_&group.; set &data; if exposure = 'mosmk'; run;
	%metaanal(data=mosmk_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mosmk, outcomelabel=ob, 
		outdat= "PAR_mom_mosmk_&group");		

	/* mosmk2 exposure */
	data mosmk2_&group.; set &data; if exposure = 'mosmk2'; run;
	%metaanal(data=mosmk2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mosmk2, outcomelabel=ob, 
		outdat= "PAR_mom_mosmk2_&group");

	/* mosmk3 exposure */
	data mosmk3_&group.; set &data; if exposure = 'mosmk3'; run;
	%metaanal(data=mosmk3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mosmk3, outcomelabel=ob, 
		outdat= "PAR_mom_mosmk3_&group");

	/* moshift exposure */
	data moshift_&group.; set &data; if exposure = 'moshift'; run;
	%metaanal(data=moshift_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=moshift, outcomelabel=ob, 
			outdat= "PAR_mom_moshift_&group");

	/* moshiftq1 exposure */
	data moshiftq1_&group.; set &data; if exposure = 'moshiftq1'; run;
	%metaanal(data=moshiftq1_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=moshiftq1, outcomelabel=ob, 
			outdat= "PAR_mom_moshiftq1_&group");

	/* moshiftq2 exposure */
	data moshiftq2_&group.; set &data; if exposure = 'moshiftq2'; run;
	%metaanal(data=moshiftq2_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=moshiftq2, outcomelabel=ob, 
		outdat= "PAR_mom_moshiftq2_&group");

	/* moshiftq3 exposure */
	data moshiftq3_&group.; set &data; if exposure = 'moshiftq3'; run;
	%metaanal(data=moshiftq3_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=moshiftq3, outcomelabel=ob, 
		outdat= "PAR_mom_moshiftq3_&group"); run; 

    %if "&data" ne "meta_PAR_mob" %then %do; 

    /* moob exposure */
	data moob_&group.; set &data; if exposure = 'moob'; run;
	%metaanal(data=moob_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=moob, outcomelabel=ob, 
		outdat= "PAR_mom_moob_&group"); run;

    %end;


	/* mom exposure */
	data mom_&group.; set &data; if exposure = 'mom'; run;
	%metaanal(data=mom_&group., beta=beta, se_or_var=s, se=SE, studylab=group, loglinear=F,
		explabel=mom, outcomelabel=ob, 
		outdat= "PAR_mom_mom_&group"); run;


%mend metaanal_allexp;


/**********************************************************************
RUN MACRO
**********************************************************************/

%let newpath = /udd/nhywa/GUTSOB/secondary_stratified/1.data;
x "cd &newpath";


%metaanal_allexp(data=meta_PAR_sex, group=sex);
%metaanal_allexp(data=meta_PAR_age, group=age);
%metaanal_allexp(data=meta_PAR_mob, group=mob);








