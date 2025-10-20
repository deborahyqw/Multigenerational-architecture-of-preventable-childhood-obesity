
/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 

program name: /udd/nhywa/GUTSOB/secondary_windows/
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Template: /udd/nhywa/GUTSOB/merge_ob_MI.sas
Programmer: Bethsaida Cardona (n2bca) 
Preparation date: 07/2025
1) Purpose: Combine multiple imputed datasets and transform wide to long, separately for GUTS 1 AND GUTS 2

*/
/*******************************************************************************/

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

*path to data;
libname here '/udd/nhywa/GUTSOB/';
libname herelb '/udd/nhywa/GUTSOB/secondary_windows/';
libname dat '/udd/nhywa/GUTSOB/secondary_windows/1.data/';


/******************************************************************************
/******************************************************************************/
/******************************************************************************/
/* Have to transpose by GUTS 1 and 2 separately, because 04-13 data will be missing for GUTS1 and 96-01 data missing for GUTS2 */
/****************************** GUTS1 ********************************************/
data all1; 
	set dat.all1_mi end=_end_; /*BCAR CHANGED THE OUTPUT FROM HERE TO FOLDER WHERE SCRIPT IS LOCATED*/
	by _imputation_ id; 
	 exrec=1; 
  	 if first.id then exrec=0;
  	
	sex = natal_sex - 1 ; 
    
    if Comp_Gesdbg=1 or Comp_prghtng=1 or Comp_peclmpg=1 or Delivery=1 then pregcomp=1;
    	else pregcomp=0;       
                         
    if Comp_Gesdbg=1 or Comp_prghtng=1 or Comp_peclmpg=1 then pregcomp2=1;
    	else pregcomp2=0;       
                           
    %indic3(vbl=prev_preg, reflev=0, missing=., min=1, max=3, prefix=prev_preg, usemiss=0,
            label1='one prev preg', label2='two prev preg', label3='three prev preg');

  	%indic3(vbl=bwg, reflev=2, missing=., min=1, max=3, prefix=abwt, usemiss=0,
            label1='<=2.5kg',label3='>=4.5kg');
             
  	%indic3(vbl=gestweek, reflev=2, missing=., min=1, max=3, prefix=gweek, usemiss=0,
            label2='<37',label3='>=43');         
	
  	*%indic3(vbl=husbeduc, reflev=3, missing=., min=1, max=2, prefix=heduc, usemiss=0,
            label1='<college',label2='college');   
            
    if incom01 <=5 then income=1; /*<50000*/
    	else if incom01>5 & incom01<=7 then income=2; /*50000-99000*/
    	else if incom01=8 then income=3; /*100000-149+*/
    	else income=4; /*150+*/
    /*$label 1.less than 15,000; 2.15,000-19; 3.20,000-29; 4.30,000-39; 5.40,000-49;\
        6.50,000-74; 7.75,000-99; 8.100,000-149; 9.150,000+; ..pt */
    *%indic3(vbl=income, reflev=4, missing=., min=1, max=3, prefix=fincome, usemiss=0,
            label1='<50k',label2='50-99k',label3='100-149k');   
       
 	 if sleep99<6 then chsleep99=1; *4-5;
     	else if sleep99=6 or sleep99=7 then chsleep99=2; *6-7;
     	else if sleep99=8 or sleep99=9 then chsleep99=3; *8-9;
     	else chsleep99=4; *10-11;
     if sleep01<6 then chsleep01=1; *4-5;
     	else if sleep01=6 or sleep01=7 then chsleep01=2; *6-7;
     	else if sleep01=8 or sleep01=9 then chsleep01=3; *8-9;
     	else chsleep01=4; *10-11;
 
	*make primary physician and food desert missing to match with GUTSII;
	physician=. ; food_desert=.; 
 	
	/*changes for exposure windows, added in years 1989-1995*/
	year89=1989; year90=1990; year91=1991; year92=1992; 
	year93=1993; year94=1994; year95=1995; year96=1996; 
	year97=1997; year98=1998; year99=1999; year00=2000;
	year01=2001; year03=2003; year05=2005;
	
	chbmibase=chbmi96;  
	
	/*changes for exposure windows, added in age in 1989 to 1995, both mom and child
	estimated using their age in 1996*/
	chage95=chage96-1; 
	chage94=chage96-2; 
	chage93=chage96-3; 
	chage92=chage96-4; 
	chage91=chage96-5; 
	chage90=chage96-6; 
	chage89=chage96-7; 

	/*NOTE can do this in the imputation file instead*/
	age95=moagebase-1;
	age94=moagebase-2;
	age93=moagebase-3;
	age92=moagebase-4;
	age91=moagebase-5;
	age90=moagebase-6;
	age89=moagebase-7;


	/*want to create an empty variable to act as placeholder when we don't have real variables in our array*/
	XXX1 = .;


	/*changes for exposure windows, added in years 1989-1995 to arrays*/
	*define missing chob chow based on the multiple imputed chbmipct;
	array age(15) chage89 chage90 chage91 chage92 chage93 chage94 chage95 chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05;
				*8-15,9-17,10-18,11-19,13-20,14-22,16-23,17-25;
	array ob(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chob96 chob97 chob98 chob99 chob00 chob01 chob03 chob05;
	array bmi(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chbmi96 chbmi97 chbmi98 chbmi99 chbmi00 chbmi01 chbmi03 chbmi05;
	
	/*changes for exposure windows, changed the array range*/
	do i=8 to 15;
		if ob{i}=. then do;
			if age{i}>=8 & age{i}<8.5 & natal_sex=1 & bmi{i}>=21.6 then ob{i} = 1;
			else if age{i}>=8 & age{i}<8.5 & natal_sex=2 & bmi{i}>=21.57 then ob{i} = 1;
			else if age{i}>=8.5 & age{i}<9 & natal_sex=1 & bmi{i}>=22.17 then ob{i} = 1;
			else if age{i}>=8.5 & age{i}<9 & natal_sex=2 & bmi{i}>=22.18 then ob{i} = 1;
			else if age{i}>=9 & age{i}<9.5 & natal_sex=1 & bmi{i}>=22.77 then ob{i} = 1;
			else if age{i}>=9 & age{i}<9.5 & natal_sex=2 & bmi{i}>=22.81 then ob{i} = 1;
			else if age{i}>=9.5 & age{i}<10 & natal_sex=1 & bmi{i}>=23.39 then ob{i} = 1;
			else if age{i}>=9.5 & age{i}<10 & natal_sex=2 & bmi{i}>=23.46 then ob{i} = 1;
			else if age{i}>=10 & age{i}<10.5 & natal_sex=1 & bmi{i}>=24 then ob{i} = 1;
			else if age{i}>=10 & age{i}<10.5 & natal_sex=2 & bmi{i}>=24.11 then ob{i} = 1;
			else if age{i}>=10.5 & age{i}<11 & natal_sex=1 & bmi{i}>=24.57 then ob{i} = 1;
			else if age{i}>=10.5 & age{i}<11 & natal_sex=2 & bmi{i}>=24.77 then ob{i} = 1;
			else if age{i}>=11 & age{i}<11.5 & natal_sex=1 & bmi{i}>=25.1 then ob{i} = 1;
			else if age{i}>=11 & age{i}<11.5 & natal_sex=2 & bmi{i}>=25.42 then ob{i} = 1;
			else if age{i}>=11.5 & age{i}<12 & natal_sex=1 & bmi{i}>=25.58 then ob{i} = 1;
			else if age{i}>=11.5 & age{i}<12 & natal_sex=2 & bmi{i}>=26.05 then ob{i} = 1;
			else if age{i}>=12 & age{i}<12.5 & natal_sex=1 & bmi{i}>=26.02 then ob{i} = 1;
			else if age{i}>=12 & age{i}<12.5 & natal_sex=2 & bmi{i}>=26.67 then ob{i} = 1;
			else if age{i}>=12.5 & age{i}<13 & natal_sex=1 & bmi{i}>=26.43 then ob{i} = 1;
			else if age{i}>=12.5 & age{i}<13 & natal_sex=2 & bmi{i}>=27.24 then ob{i} = 1;
			else if age{i}>=13 & age{i}<13.5 & natal_sex=1 & bmi{i}>=26.84 then ob{i} = 1;
			else if age{i}>=13 & age{i}<13.5 & natal_sex=2 & bmi{i}>=27.76 then ob{i} = 1;
			else if age{i}>=13.5 & age{i}<14 & natal_sex=1 & bmi{i}>=27.25 then ob{i} = 1;
			else if age{i}>=13.5 & age{i}<14 & natal_sex=2 & bmi{i}>=28.20 then ob{i} = 1;
			else if age{i}>=14 & age{i}<14.5 & natal_sex=1 & bmi{i}>=27.63 then ob{i} = 1;
			else if age{i}>=14 & age{i}<14.5 & natal_sex=2 & bmi{i}>=28.57 then ob{i} = 1;
			else if age{i}>=14.5 & age{i}<15 & natal_sex=1 & bmi{i}>=27.98 then ob{i} = 1;
			else if age{i}>=14.5 & age{i}<15 & natal_sex=2 & bmi{i}>=28.87 then ob{i} = 1;
			else if age{i}>=15 & age{i}<15.5 & natal_sex=1 & bmi{i}>=28.30 then ob{i} = 1;
			else if age{i}>=15 & age{i}<15.5 & natal_sex=2 & bmi{i}>=29.11 then ob{i} = 1;
			else if age{i}>=15.5 & age{i}<16 & natal_sex=1 & bmi{i}>=28.60 then ob{i} = 1;
			else if age{i}>=15.5 & age{i}<16 & natal_sex=2 & bmi{i}>=29.29 then ob{i} = 1;
			else if age{i}>=16 & age{i}<16.5 & natal_sex=1 & bmi{i}>=28.88 then ob{i} = 1;
			else if age{i}>=16 & age{i}<16.5 & natal_sex=2 & bmi{i}>=29.43 then ob{i} = 1;
			else if age{i}>=16.5 & age{i}<17 & natal_sex=1 & bmi{i}>=29.14 then ob{i} = 1;
			else if age{i}>=16.5 & age{i}<17 & natal_sex=2 & bmi{i}>=29.56 then ob{i} = 1;
			else if age{i}>=17 & age{i}<17.5 & natal_sex=1 & bmi{i}>=29.41 then ob{i} = 1;
			else if age{i}>=17 & age{i}<17.5 & natal_sex=2 & bmi{i}>=29.69 then ob{i} = 1;
			else if age{i}>=17.5 & age{i}<18 & natal_sex=1 & bmi{i}>=29.7 then ob{i} = 1;
			else if age{i}>=17.5 & age{i}<18 & natal_sex=2 & bmi{i}>=29.84 then ob{i} = 1;
			else if age{i}>=18 & bmi{i}>=30 then ob{i} = 1;
			else ob{i} = 0;
		end;
	end; drop i;
	
/*change for exposure windows: dropped all data on supermarkets/foodswampts etc, not needed*/
   	  
	********** generate time variable indicating OB incident **********************
	********** for subsequent censoring of observations after OB ******************;
	if chob96=1 then obyear=1996;
	else if chob97=1 then obyear=1997; else if chob98=1 then obyear=1998; 
	else if chob99=1 then obyear=1999; else if chob00=1 then obyear=2000;
	else if chob01=1 then obyear=2001; else if chob03=1 then obyear=2003;
	else if chob05=1 then obyear=2005;   	


					 
/****************************** Transpose wide to long ********************************************/

/*change for exposure windows - changed the start of irt to 1989
Note that compared to the original code, will only be keeping time-varying values (not cumulative) and the exposures 
that made it to the final manuscript
only two of the outcomes are from non-consecutive years, year03 year05, so the majority of array values will represent one year
*/

array irt(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 irt96 irt97 irt98 irt99 irt00 irt01 irt03 irt05; 
array qyear(15) year89 year90 year91 year92 year93 year94 year95 year96 year97 year98 year99 year00 year01 year03 year05; 
array wdiet(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chwest_96 chwest_97 chwest_98 chwest_98 chwest_98 chwest_01 chwest_01 chwest_01; 
array kcal(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chcal96 chcal97 chcal98 chcal98 chcal98 chcal01 chcal01 chcal01;
array sed(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chst96 chst97 chst98 chst99 chst00 chst01 chst01 chst05;
array pa(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chpa96 chpa97 chpa98 chpa99 chpa00 chpa01 chpa01 chpa05;
array sleep(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chsleep99 chsleep99 chsleep01 chsleep01 chsleep01;
array sleepc(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 sleep99 sleep99 sleep01 sleep01 sleep01;
array preg(15) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chpreg01 chpreg03 chpreg05;

array mage(15) age89 age90 age91 age92 age93 age94 age95 moagebase age97 age98 age99 age00 age01 age03 age05;
array mwest(15) XXX1 XXX1 f291 f291 f291 f291 f295 f295 f295 f295 f299 f299 f299 f203 f203;
array mcal(15) XXX1 XXX1 calor91n calor91n calor91n calor91n calor95n calor95n calor95n calor95n calor99n calor99n calor99n calor03n calor03n;
array msmk(15) smk89 smk89 smk91 smk91 smk93 smk93 smk95 smk95 smk97 smk97 smk99 smk99 smk01 smk03 smk05;
array mpa(15) act89m act89m act91m act91m act91m act91m act91m act91m act97m act97m act97m act97m act01m act01m act05m;
array mbmi(15) bmi89 bmi89 bmi91 bmi91 bmi93 bmi93 bmi95 bmi95 bmi97 bmi97 bmi99 bmi99 bmi01 bmi03 bmi05;
array mshift(15) shi89_con shi89_con shi8991_con shi8991_con shi9193_con shi9193_con shi9395_con shi9395_con shi9597_con shi9597_con shi9799_con shi9799_con shi9901_con shi0103_con shi0305_con;
array mses(15) nSES_89 nSES_89 nSES_91 nSES_91 nSES_93  nSES_93 nSES_95 nSES_95 nSES_97 nSES_97 nSES_99 nSES_99 nSES_01 nSES_03 nSES_05; 

array mid(15) midwest89 midwest89 midwest91 midwest91 midwest93 midwest93 midwest95 midwest95 midwest97 midwest97 midwest99 midwest99 midwest01 midwest03 midwest05;
array sth(15) south89 south89 south91 south91 south93 south93 south95 south95 south97 south97 south99 south99 south01 south03 south05;
array wst(15) west89 west89 west91 west91 west93 west93 west95 west95 west97 west97 west99 west99 west01 west03 west05;


/*** If lost to follow-up,     then lastq=last irt. 
 	 If not lost to follow up, then lastq=. ***/  
   do i=1 to dim(irt);
   	if irt{i} >0 then lastq=irt{i};
   end; drop i;
   if lastq=irt{15} then lastq=.; /*change for exposure windows: updated lastq irt*/

*DO-LOOP OVER TIME PERIODS;
	%beginex();
	
do time=1 to 15; /*change for exposure windows: updated array range*/

 	year=qyear(time); 	       chage =age(time);     	 chob  =ob(time);
	chbmi =bmi(time);          chwest =wdiet(time);     
	chcal =kcal(time);         chst =sed(time);          chpa  =pa(time);          
	chpreg  =preg(time);	   chsleep =sleep(time);     chsleepc =sleepc(time);
	moage =mage(time);	       mowest =mwest(time);      
	mocal  =mcal(time);        mosmk  =msmk(time);
	mopa   =mpa(time);         mobmi  =mbmi(time);       moshift  =mshift(time);
	ses  =mses(time);          midwest = mid(time);      south = sth(time);
	west = wst(time);         
	chirt = irt{time};
    
    *%indic3(vbl=chsleep, reflev=3, missing=., min=1, max=4, prefix=sleep, usemiss=0,
            label1='45',label2='67',label4='10-11');     
      
    *%indic3 (vbl=mosmk, prefix=mosmk, min=2, max=3, reflev=1, missing=., usemiss=0,
      label2='mom past smoking', label3='mom current smoking');   



/******************************************************************
  ***************          EXCLUSIONS         *******************
********************************************************************/

/*changes for exposure windows, keeping baseline the same -- 1996 -- so 
time=1 changes to time =8 

will also be exporting all the data for 1989-1996 and deleting afterwards*/


if time>=1 and time<8 then do; 
	  %output();
end;

*baseline;
if time=8 then do;	*83055;
	*%exclude(id ne ., nodelete=t);
	%exclude(momid ne ., nodelete=t); *83055;
    %exclude(exrec eq 1); *exclude those not in GUTS1 5;
    %exclude(chob eq 1); *baseline ob 3705;
	%exclude(chbmi eq .); * baseline bmi missing - should be 0, already excluded; 
    %exclude(lastq eq irt{1});  /*only returned baseline 1996Q 4370*/
    *%exclude(id ne ., nodelete=t);
    %exclude(momid ne ., nodelete=t); *74975;
  %output();
  atbaseline=1; /*changes for exposure windows; adding an indicator for whether participants made it to study*/
end;

*Follow-up;
  else if time>8 then do;
  	*%exclude(irt{time} eq .); * no need to censor observations if not returning questionnaires because of imputation x42278;
  	%exclude(0 lt lastq lt irt{time}); 	 *censor lost to follow up ;
  	%exclude(0 lt obyear lt qyear{time} );  *censor observations after becoming OB 5003 ;
  	%exclude(bmi{time} eq .); 	   *censor missing bmi - should be 0;
  	%exclude(age{time} gt 18); 	   *censor age>18 61582;
	*%exclude(id ne ., nodelete=t); 
	%exclude(momid ne ., nodelete=t); *382716;
	%exclude(preg{time} eq 1 , skip=T); * skip observations if pregnant 373;

  %output();
  end;
end; *457691;

%endex();

run;

/*
proc export data=all1
	outfile='/udd/nhywa/GUTSOB/secondary_windows/1.data/all1_long.csv'
	dbms=csv replace;
run; 
*/

proc means data=all1 nolabels n nmiss mean std min median max; run;

/*SAS does not give an error message for empty variables in arrays, running a proc means to ensure no unexpected 
empty variables*/

proc means data=all1; 
	vars
	chage89 chage90 chage91 chage92 chage93 chage94 chage95 chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05
	chob96 chob97 chob98 chob99 chob00 chob01 chob03 chob05
	chbmi96 chbmi97 chbmi98 chbmi99 chbmi00 chbmi01 chbmi03 chbmi05

	irt96 irt97 irt98 irt99 irt00 irt01 irt03 irt05 
	year89 year90 year91 year92 year93 year94 year95 year96 year97 year98 year99 year00 year01 year03 year05 
	chwest_96 chwest_97 chwest_98 chwest_98 chwest_98 chwest_01 chwest_01 chwest_01 
	chcal96 chcal97 chcal98 chcal98 chcal98 chcal01 chcal01 chcal01
	chst96 chst97 chst98 chst99 chst00 chst01 chst01 chst05
	chpa96 chpa97 chpa98 chpa99 chpa00 chpa01 chpa01 chpa05
	chsleep99 chsleep99 chsleep01 chsleep01 chsleep01
	sleep99 sleep99 sleep01 sleep01 sleep01
	chpreg01 chpreg03 chpreg05

	age89 age90 age91 age92 age93 age94 age95 moagebase age97 age98 age99 age00 age01 age03 age05
	f291 f291 f291 f291 f295 f295 f295 f295 f299 f299 f299 f203 f203
	calor91n calor91n calor91n calor91n calor95n calor95n calor95n calor95n calor99n calor99n calor99n calor03n calor03n
	smk89 smk89 smk91 smk91 smk93 smk93 smk95 smk95 smk97 smk97 smk99 smk99 smk01 smk03 smk05
	act89m act89m act91m act91m act91m act91m act91m act91m act97m act97m act97m act97m act01m act01m act05m
	bmi89 bmi89 bmi91 bmi91 bmi93 bmi93 bmi95 bmi95 bmi97 bmi97 bmi99 bmi99 bmi01 bmi03 bmi05
	shi89_con shi89_con shi8991_con shi8991_con shi9193_con shi9193_con shi9395_con shi9395_con shi9597_con shi9597_con shi9799_con shi9799_con shi9901_con shi0103_con shi0305_con
	nSES_89 nSES_89 nSES_91 nSES_91 nSES_93  nSES_93 nSES_95 nSES_95 nSES_97 nSES_97 nSES_99 nSES_99 nSES_01 nSES_03 nSES_05 


	midwest89 midwest89 midwest91 midwest91 midwest93 midwest93 midwest95 midwest95 midwest97 midwest97 midwest99 midwest99 midwest01 midwest03 midwest05
	south89 south89 south91 south91 south93 south93 south95 south95 south97 south97 south99 south99 south01 south03 south05
	west89 west89 west91 west91 west93 west93 west95 west95 west97 west97 west99 west99 west01 west03 west05
	;
run; 


/*tidy dataset:
only keeping participants who made it to study baseline
keep only variables of interest
*/ 

data all1_baseline; 
	set all1; 
	if atbaseline=1; 
	keep id atbaseline;
run; 

proc sort data=all1; by id; run; 
/*proc sort data=all1_baseline; by id; run; */
proc sort data=all1_baseline nodupkey; by id; run; /*BCAR not really sure why there are duplicate values..*/


data all1_tidy; 
	merge all1 (drop=atbaseline) all1_baseline (in=a); 
	by id;
	if a; /*keep only id is present at baseline*/
	
	keep id momid cohort white sex ch_birthday birthday  _imputation_
		bmibpreg gotweight &abwt_ &gweek_ &prev_preg_ 
		chsleep chsleepc incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc
		midwest south west agebirth moagebase chpreg
		year chage  chob  chbmi  chbmibase 
		chwest chcal chst chpa  
		moage   mowest  mocal  mopa    mobmi  mosmk  moshift  ses   
 		/*fl_notmom96  fl_notmom97 fl_notmom98  fl_not_mom9698*/ obyear lastq chirt;
run;

/*
proc export data=all1_tidy
	outfile='/udd/nhywa/GUTSOB/secondary_windows/1.data/all1_tidy.csv'
	dbms=csv replace;
run; 
*/


/****************************** GUTS 2 ********************************************/
data all2; 
	set dat.all2_mi end=_end_; /*BCAR CHANGED THE OUTPUT FROM HERE TO FOLDER WHERE SCRIPT IS LOCATED*/
	by _imputation_ id; 
		 exrec=1; 
  	 if first.id then exrec=0;
  	
	gotweight =.; /*  create a variable for gestational weight category which we need for merge because we dont have data for GUTS2 */
	
	sex = natal_sex - 1 ; 
            
    if Comp_Gesdbg=1 or Comp_prghtng=1 or Comp_peclmpg=1 or Delivery=1 then pregcomp=1;
    	else pregcomp=0;  
    if Comp_Gesdbg=1 or Comp_prghtng=1 or Comp_peclmpg=1 then pregcomp2=1;
    	else pregcomp2=0;       
                        
    %indic3(vbl=prev_preg, reflev=0, missing=., min=1, max=3, prefix=prev_preg, usemiss=0,
            label1='one prev preg', label2='two prev preg', label3='three prev preg');

 	 %indic3(vbl=bwg, reflev=2, missing=., min=1, max=3, prefix=abwt, usemiss=0,
            label1='<=2.5kg',label3='>=4.5kg');
             
  	%indic3(vbl=gestweek, reflev=2, missing=., min=1, max=3, prefix=gweek, usemiss=0,
            label2='<37',label3='>=43');      
	
  	*%indic3(vbl=husbeduc, reflev=3, missing=., min=1, max=2, prefix=heduc, usemiss=0,
            label1='<college',label2='college');
                        
      if incom01 <=5 then income=1; /*<50000*/
    	else if incom01>5 & incom01<=7 then income=2; /*50000-99000*/
    	else if incom01=8 then income=3; /*100000-149+*/
    	else income=4; /*150+*/
    /*$label 1.less than 15,000; 2.15,000-19; 3.20,000-29; 4.30,000-39; 5.40,000-49;\
        6.50,000-74; 7.75,000-99; 8.100,000-149; 9.150,000+; ..pt */
    *%indic3(vbl=income, reflev=4, missing=., min=1, max=3, prefix=fincome, usemiss=0,
            label1='<50k',label2='50-99k',label3='100-149k');   
       
     if sleep06<6 then chsleep06=1; *4-5;
     	else if sleep06=6 or sleep06=7 then chsleep06=2; *6-7;
     	else if sleep06=8 or sleep06=9 then chsleep06=3; *8-9;
     	else chsleep06=4; *10-11;
	 if sleep08<6 then chsleep08=1; *4-5;
     	else if sleep08=6 or sleep08=7 then chsleep08=2; *6-7;
     	else if sleep08=8 or sleep08=9 then chsleep08=3; *8-9;
     	else chsleep08=4; *10-11;
	 if sleep11<6 then chsleep11=1; *4-5;
     	else if sleep11=6 or sleep11=7 then chsleep11=2; *6-7;
     	else if sleep11=8 or sleep11=9 then chsleep11=3; *8-9;
     	else chsleep11=4; *10-11;

	chbmibase=chbmi04; 

	/*changes for exposure windows, added in years 1989-2003*/
	year89=1989; year90=1990; year91=1991; year92=1992; 
	year93=1993; year94=1994; year95=1995; year96=1996; 
	year97=1997; year98=1998; year99=1999; year00=2000;
    year01=2001; year02=2002; year03=2003;
	year04=2004; year06=2006; year08=2008; year11=2011; year13=2013;
	
	/*changes for exposure windows, added in age in 1989 to 1995, both mom and child*/
	chage02=chage04-2; 
	chage00=chage04-4; 
	chage98=chage04-6; 
	chage96=chage04-8; 
	chage94=chage04-10; 
	chage92=chage04-12; 
	chage90=chage04-14; 

	/*NOTE can do this in the imputation file instead*/
	age02=moagebase-2;
	age00=moagebase-4;
	age98=moagebase-6;
	age96=moagebase-8;
	age94=moagebase-10;
	age92=moagebase-12;
	age90=moagebase-14;

	/*want to create an empty variable to act as placeholder when we don't have real variables in our array*/
	XXX1 = .;
	
	/*changes for exposure windows, added in years 1989-1995 to arrays*/
	*define missing chob chow based on the multiple imputed chbmipct;
	array ob(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chob04 chob06 chob08 chob11 chob13;
	array bmi(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chbmi04 chbmi06 chbmi08 chbmi11 chbmi13;
	array age(12) chage90 chage92 chage94 chage96 chage98 chage00 chage02 chage04 chage06 chage08 chage11 chage13;
	
	do i=8 to 12;
		if ob{i}=. then do;
			if age{i}>=8 & age{i}<8.5 & natal_sex=1 & bmi{i}>=21.6 then ob{i} = 1;
			else if age{i}>=8 & age{i}<8.5 & natal_sex=2 & bmi{i}>=21.57 then ob{i} = 1;
			else if age{i}>=8.5 & age{i}<9 & natal_sex=1 & bmi{i}>=22.17 then ob{i} = 1;
			else if age{i}>=8.5 & age{i}<9 & natal_sex=2 & bmi{i}>=22.18 then ob{i} = 1;
			else if age{i}>=9 & age{i}<9.5 & natal_sex=1 & bmi{i}>=22.77 then ob{i} = 1;
			else if age{i}>=9 & age{i}<9.5 & natal_sex=2 & bmi{i}>=22.81 then ob{i} = 1;
			else if age{i}>=9.5 & age{i}<10 & natal_sex=1 & bmi{i}>=23.39 then ob{i} = 1;
			else if age{i}>=9.5 & age{i}<10 & natal_sex=2 & bmi{i}>=23.46 then ob{i} = 1;
			else if age{i}>=10 & age{i}<10.5 & natal_sex=1 & bmi{i}>=24 then ob{i} = 1;
			else if age{i}>=10 & age{i}<10.5 & natal_sex=2 & bmi{i}>=24.11 then ob{i} = 1;
			else if age{i}>=10.5 & age{i}<11 & natal_sex=1 & bmi{i}>=24.57 then ob{i} = 1;
			else if age{i}>=10.5 & age{i}<11 & natal_sex=2 & bmi{i}>=24.77 then ob{i} = 1;
			else if age{i}>=11 & age{i}<11.5 & natal_sex=1 & bmi{i}>=25.1 then ob{i} = 1;
			else if age{i}>=11 & age{i}<11.5 & natal_sex=2 & bmi{i}>=25.42 then ob{i} = 1;
			else if age{i}>=11.5 & age{i}<12 & natal_sex=1 & bmi{i}>=25.58 then ob{i} = 1;
			else if age{i}>=11.5 & age{i}<12 & natal_sex=2 & bmi{i}>=26.05 then ob{i} = 1;
			else if age{i}>=12 & age{i}<12.5 & natal_sex=1 & bmi{i}>=26.02 then ob{i} = 1;
			else if age{i}>=12 & age{i}<12.5 & natal_sex=2 & bmi{i}>=26.67 then ob{i} = 1;
			else if age{i}>=12.5 & age{i}<13 & natal_sex=1 & bmi{i}>=26.43 then ob{i} = 1;
			else if age{i}>=12.5 & age{i}<13 & natal_sex=2 & bmi{i}>=27.24 then ob{i} = 1;
			else if age{i}>=13 & age{i}<13.5 & natal_sex=1 & bmi{i}>=26.84 then ob{i} = 1;
			else if age{i}>=13 & age{i}<13.5 & natal_sex=2 & bmi{i}>=27.76 then ob{i} = 1;
			else if age{i}>=13.5 & age{i}<14 & natal_sex=1 & bmi{i}>=27.25 then ob{i} = 1;
			else if age{i}>=13.5 & age{i}<14 & natal_sex=2 & bmi{i}>=28.20 then ob{i} = 1;
			else if age{i}>=14 & age{i}<14.5 & natal_sex=1 & bmi{i}>=27.63 then ob{i} = 1;
			else if age{i}>=14 & age{i}<14.5 & natal_sex=2 & bmi{i}>=28.57 then ob{i} = 1;
			else if age{i}>=14.5 & age{i}<15 & natal_sex=1 & bmi{i}>=27.98 then ob{i} = 1;
			else if age{i}>=14.5 & age{i}<15 & natal_sex=2 & bmi{i}>=28.87 then ob{i} = 1;
			else if age{i}>=15 & age{i}<15.5 & natal_sex=1 & bmi{i}>=28.30 then ob{i} = 1;
			else if age{i}>=15 & age{i}<15.5 & natal_sex=2 & bmi{i}>=29.11 then ob{i} = 1;
			else if age{i}>=15.5 & age{i}<16 & natal_sex=1 & bmi{i}>=28.60 then ob{i} = 1;
			else if age{i}>=15.5 & age{i}<16 & natal_sex=2 & bmi{i}>=29.29 then ob{i} = 1;
			else if age{i}>=16 & age{i}<16.5 & natal_sex=1 & bmi{i}>=28.88 then ob{i} = 1;
			else if age{i}>=16 & age{i}<16.5 & natal_sex=2 & bmi{i}>=29.43 then ob{i} = 1;
			else if age{i}>=16.5 & age{i}<17 & natal_sex=1 & bmi{i}>=29.14 then ob{i} = 1;
			else if age{i}>=16.5 & age{i}<17 & natal_sex=2 & bmi{i}>=29.56 then ob{i} = 1;
			else if age{i}>=17 & age{i}<17.5 & natal_sex=1 & bmi{i}>=29.41 then ob{i} = 1;
			else if age{i}>=17 & age{i}<17.5 & natal_sex=2 & bmi{i}>=29.69 then ob{i} = 1;
			else if age{i}>=17.5 & age{i}<18 & natal_sex=1 & bmi{i}>=29.7 then ob{i} = 1;
			else if age{i}>=17.5 & age{i}<18 & natal_sex=2 & bmi{i}>=29.84 then ob{i} = 1;
			else if age{i}>=18 & bmi{i}>=30 then ob{i} = 1;
			else ob{i} = 0;
		end;
	end; drop i;
	
	/*change for exposure windows: dropped all data on supermarkets/foodswampts etc, not needed*/

	
	********** generate time variable indicating OB incident **********************
	********** for subsequent censoring of observations after OB ******************;
	if chob04=1 then obyear=2004; else if chob06=1 then obyear=2006; 
	else if chob08=1 then obyear=2008; else if chob11=1 then obyear=2011;
	else if chob13=1 then obyear=2013;  
					 
/****************************** Transpose wide to long ********************************************/

/*change for exposure windows - changed the start of irt to 1990
Note that compared to the original code, will only be keeping time-varying values (not cumulative) and the exposures 
that made it to the final manuscript
most of the outcomes are from every other year, so the majority of array values will represent every other year
*/

array irt(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 irt04 irt06 irt08 irt11 irt13;
array qyear(12) year90 year92 year94 year96 year98 year00 year02 year04 year06 year08 year11 year13;
array wdiet(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chwest_04 chwest_06 chwest_08 chwest_11 chwest_11;
array kcal(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chcal04 chcal06 chcal08 chcal11 chcal11;
array sed(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chst04 chst06 chst08 chst11 chst11;
array pa(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chpa04 chpa06 chpa08 chpa11 chpa11;
array sleep(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chsleep06 chsleep08 chsleep11 chsleep11;
array sleepc(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 sleep06 sleep08 sleep11 sleep11;
array preg(12) XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 XXX1 chpreg13;

array mage(12) age90 age92 age94 age96 age98 age00 age02 moagebase age06 age08 age11 age13;
array mwest(12) XXX1 f291 f291 f295 f295 f295 f295 f203 f203 f207 f211 f211;
array mcal(12) XXX1 calor91n calor91n calor95n calor95n calor95n calor95n calor03n calor03n calor07n calor11n calor11n;
array msmk(12) smk89 smk91 smk93 smk95 smk97 smk99 smk01 smk03 smk05 smk07 smk11 smk13;
array mpa(12) act89m act91m act91m act91m act97m act97m act01m act01m act05m act05m act09m act13m;
array mbmi(12) bmi89 bmi91 bmi93 bmi95 bmi97 bmi99 bmi01 bmi03 bmi05 bmi07 bmi11 bmi13;
array mshift(12) shi89_con shi8991_con shi9193_con shi9395_con shi9597_con shi9799_con shi9901_con shi0103_con shi0305_con shi0305_con shi11_con shi13_con;

array mses(12) nSES_89 nSES_91 nSES_93 nSES_95 nSES_97 nSES_99 nSES_01 nSES_03 nSES_05 nSES_07 nSES_11 nSES_13;


array mid(12) midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 midwest07 midwest11 midwest13;
array sth(12) south89 south91 south93 south95 south97 south99 south01 south03 south05 south07 south11 south13;
array wst(12) west89 west91 west93 west95 west97 west99 west01 west03 west05 west07 west11 west13;

/*** If lost to follow-up,     then lastq=last irt. 
 	 If not lost to follow up, then lastq=. ***/  
   do i=1 to dim(irt);
   	if irt{i} >0 then lastq=irt{i};
   end; drop i;
   if lastq=irt{12} then lastq=.;  /*change for exposure windows: updated lastq irt*/

*DO-LOOP OVER TIME PERIODS;
	%beginex();
	
do time=1 to 12;	 /*change for exposure windows: updated array range*/

	year=qyear(time); 	       chage =age(time);     	 chob  =ob(time);
	chbmi =bmi(time);          chwest =wdiet(time);     
	chcal =kcal(time);         chst =sed(time);          chpa  =pa(time);          
	chpreg  =preg(time);	   chsleep  =sleep(time);    chsleepc = sleepc(time);
	moage =mage(time);	       mowest =mwest(time);
	mocal  =mcal(time);        mosmk  =msmk(time);
	mopa   =mpa(time);         mobmi  =mbmi(time);       moshift  =mshift(time);
	ses  =mses(time);          midwest = mid(time);       south = sth(time);        
	west = wst(time);          
	chirt = irt{time};

     *%indic3(vbl=chsleep, reflev=3, missing=., min=1, max=4, prefix=sleep, usemiss=0,
            label1='45',label2='67',label4='10-11');   
      
    *%indic3 (vbl=mosmk, prefix=mosmk, min=2, max=3, reflev=1, missing=., usemiss=0,
      label2='mom past smoking', label3='mom current smoking');
       
/******************************************************************
  ***************          EXCLUSIONS         *******************
********************************************************************/

/*changes for exposure windows, keeping baseline the same -- 1996 -- so 
time=1 changes to time =8 

will also be exporting all the data for 1989-1996 and deleting afterwards*/


if time>=1 and time<8 then do; 
	  %output();
end;


*baseline;
if time=8 then do;	
	*%exclude(id ne ., nodelete=t); *51445;
	%exclude(momid ne ., nodelete=t);
    %exclude(exrec eq 1); *exclude those not in GUTS2;
    %exclude(chob eq 1); *baseline ob 2550;
	%exclude(chbmi eq .); * baseline bmi missing - should be 0, already excluded; 
    %exclude(lastq eq irt{1});  /*only returned baseline 2004Q 5070 */
    *%exclude(id ne ., nodelete=t);
    %exclude(momid ne ., nodelete=t); *43825;
  %output();
  atbaseline=1; /*changes for exposure windows; adding an indicator for whether participants made it to study*/
end;

*Follow-up;
  else if time>8 then do;
  	*%exclude(irt{time} eq .); * cesnor observations if not returning questionnaires;
  	%exclude(0 lt lastq lt irt{time}); 	 *censor lost to follow up ;
  	%exclude(0 lt obyear lt qyear{time} );  *censor observations after becoming OB 1578 ;
  	%exclude(bmi{time} eq .); 	   *censor missing bmi - should be 0;
  	%exclude(age{time} gt 18); 	   *censor age>18 40165;
	*%exclude(id ne ., nodelete=t);
	%exclude(momid ne ., nodelete=t); *86157;
	%exclude(preg{time} eq 1 , skip=T); * skip observations if pregnant 0 ;

  %output();
  end;
end; *129982 ;

%endex();
 
fl_notmom96=.;  fl_notmom97=.; fl_notmom98=.;   fl_not_mom9698=.;
 
*keep id momid cohort white sex ch_birthday birthday  _imputation_
		bmibpreg gotweight &abwt_ &gweek_ &prev_preg_ 
		&sleep_ chsleep chsleepc &fincome_ incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc &heduc_
		&mosmk_ midwest south west agebirth moagebase chpreg
		year chage  chob chbmi  chbmibase 
		chwest chcal chst chpa  
		moage  mowest   mocal  mopa    mobmi    moshift  ses  
		supermarket restaurant fastfood convenience foodswamp 
		supermarketz restaurantz fastfoodz conveniencez foodswampz
		supermarketa restauranta fastfooda conveniencea foodswampa
 		physician food_desert 
 		fl_notmom96  fl_notmom97 fl_notmom98  fl_not_mom9698 obyear lastq chirt;		
run;  

/*
proc export data=all2
	outfile='/udd/nhywa/GUTSOB/secondary_windows/1.data/all2_long.csv'
	dbms=csv replace;
run; 
*/

proc means data=all2 nolabels n nmiss mean std min median max; run;

/*SAS does not give an error message for empty variables in arrays, running a proc means to ensure no unexpected 
empty variables*/

proc means data=all2; 
	vars
	chob04 chob06 chob08 chob11 chob13
	chbmi04 chbmi06 chbmi08 chbmi11 chbmi13
	chage04 chage06 chage08 chage11 chage13

	irt04 irt06 irt08 irt11 irt13
	year90 year92 year94 year96 year98 year00 year02 year04 year06 year08 year11 year13
	chwest_04 chwest_06 chwest_08 chwest_11 chwest_11
	chcal04 chcal06 chcal08 chcal11 chcal11
	chst04 chst06 chst08 chst11 chst11
	chpa04 chpa06 chpa08 chpa11 chpa11
	chsleep06 chsleep08 chsleep11 chsleep11
	sleep06 sleep08 sleep11 sleep11
	chpreg13

	age90 age92 age94 age96 age98 age00 age02 moagebase age06 age08 age11 age13
	f291 f291 f295 f295 f295 f295 f203 f203 f207 f211 f211
	calor91n calor91n calor95n calor95n calor95n calor95n calor03n calor03n calor07n calor11n calor11n
	smk89 smk91 smk93 smk95 smk97 smk99 smk01 smk03 smk05 smk07 smk11 smk13
	act89m act91m act91m act91m act97m act97m act01m act01m act05m act05m act09m act13m
	bmi89 bmi91 bmi93 bmi95 bmi97 bmi99 bmi01 bmi03 bmi05 bmi07 bmi11 bmi13
	shi89_con shi8991_con shi9193_con shi9395_con shi9597_con shi9799_con shi9901_con shi0103_con shi0305_con shi0305_con shi11_con shi13_con

	nSES_89 nSES_91 nSES_93 nSES_95 nSES_97 nSES_99 nSES_01 nSES_03 nSES_05 nSES_07 nSES_11 nSES_13


	midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 midwest07 midwest11 midwest13
	south89 south91 south93 south95 south97 south99 south01 south03 south05 south07 south11 south13
	west89 west91 west93 west95 west97 west99 west01 west03 west05 west07 west11 west13
	;
run; 


/*tidy dataset:
only keeping participants who made it to study baseline
keep only variables of interest
*/ 

data all2_baseline; 
	set all2; 
	if atbaseline=1; 
	keep id atbaseline;
run; 

proc sort data=all2; by id; run; 
proc sort data=all2_baseline nodupkey; by id; run; /*BCAR not really sure why there are duplicate values..*/


data all2_tidy; 
	merge all2 all2_baseline (in=a); 
	by id;
	if a; /*keep only id is present at baseline*/
	
	keep id momid cohort white sex ch_birthday birthday  _imputation_
		bmibpreg gotweight &abwt_ &gweek_ &prev_preg_ 
		chsleep chsleepc incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc
		midwest south west agebirth moagebase chpreg
		year chage  chob  chbmi  chbmibase 
		chwest chcal chst chpa  
		moage   mowest  mocal  mopa    mobmi  mosmk  moshift  ses   
 		/*fl_notmom96  fl_notmom97 fl_notmom98  fl_not_mom9698*/ obyear lastq chirt;
run;

/*
proc export data=all2_tidy
	outfile='/udd/nhywa/GUTSOB/secondary_windows/1.data/all2_tidy.csv'
	dbms=csv replace;
run; 
*/
