/*******************************************************************************
program name: all1_vars_mi.sas
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Yiqing Wang (nhywa)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: 12/2024
1) Purpose: Combine GUTS1 with NHS2 and conduct multiple imputation
2) Study Population: 
				- NHSII 1995-2013 (for maternal exposures)
                - GUTS1 1996-2005 (all offsprings were >=18 by then)
                - GUTS2 2004-2013 (all offsprings were >=18 by then)
3) Inclusion:
	-participants who had exposure and outcome data
   Exclusion:
	-Being obese or having missing BMI at the baseline for personal factors
	-BMI measurements excluded if pregnancy/breastfeeding during the past year
4) Exposures:
	- Maternal obesity, diet quality, physical activity, smoking, drinking, age at birth, Gestational diabetes, C-section, Small or large for gestational age 
	- Offspring diet quality, physical activity, sedentary behavior, Smoking, Drinking, Abnormal sleep duration 
    - Maternal education, Maternal job stress (job strain, rotating night-shift work schedule, job insecurity), Neighborhood socioeconomic status,
		Number of primary care providers in the county, Food deserts/swamps, Greenspace, Air pollution (personal exposure), Summer and winter temperature 
	- Child abuse (both for the moms and children)
	- Yale food addiction scale (NHS2 and later in GUTS)
5) Covariates: 
	- Maternal age at baseline (years), race/ethnicity, maternal total energy intake, maternal chronic diseases (?)
	- Offspring age, sex, race/ethnicity, offspring energy intake (?), offspring other chronic diseases (?)
6) Statistical analyses: multivariable log-binomial regression models with generalized estimating equations and specified an exchangeable correlation structure
*******************************************************************************/
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

%include '/udd/nhywa/GUTSOB/guts1_vars.sas';
*Read in NHS2 data prepared by Bethsaida with adjustment by Yiqing;
%include '/udd/nhywa/GUTSOB/nhs2_vars.sas';

*sbs -o memsize=8000M mySASprogram.sas ;

/******************************************************************************
/*************************** Merge all **********************************/
/******************************************************************************/
*merge files 1 - many, if no observations for that year then blank;
/* Have to transpose by GUTS 1 and 2 separately, because 04-13 data will be missing for GUTS1 and 96-01 data missing for GUTS2 */
data gutsmoms1;
  merge nhs2_vars(in=a) guts1(in=b);
  by momid;
  if a and b;
proc sort data=gutsmoms1; by id; run;

/****************************** GUTS1 ********************************************/
data all1; 
	merge gutsmoms1 (in=master) grav09guts1 bmibpregdt end=_end_;
  	by id; exrec=1; 
  	if master; if cohort=1 ;
  	if chbmi96 >0 ; *keep only children without missing baseline BMI;
  	if first.id then exrec=0;
  	
  	if white=. then white=0;
  	
  	*maternal age at birth - 1980-1987;
 	agebirth = age89 - (retmo89 /12 - (chyob-1900));
 		
	if chage97=. then chage97=chage96+1; if chage98=. then chage98=chage97+1;
	if chage99=. then chage99=chage98+1; if chage00=. then chage00=chage99+1;
	if chage01=. then chage01=chage00+1; if chage03=. then chage03=chage01+2; if chage05=. then chage05=chage03+2;
    
    moagebase=age95+1; if moagebase=. then moagebase=age89+7;
    if age97=. then age97=moagebase+1; if age98=. then age98=age97+1;
	if age99=. then age99=age98+1; if age00=. then age00=age99+1;
	if age01=. then age01=age00+1; if age03=. then age03=age01+2; if age05=. then age05=age03+2;
				
	array region{6} region10_95 region10_97 region10_99 region10_01 region10_03 region10_05;
	array mid{6} midwest95 midwest97 midwest99 midwest01 midwest03 midwest05;
	array south{6} south95 south97 south99 south01 south03 south05;
	array west{6} west95 west97 west99 west01 west03 west05;
	
	do i = 1 to 6;
  	if missing(region{i}) then do;
   		 mid{i}   = .;
    	south{i} = .;
    	west{i}  = .;
  	end;
  	else do;
  	  mid{i}   = (region{i} = 2);  /* => 1 if region{i}=2, else 0 */
   	  south{i} = (region{i} = 3);  /* => 1 if region{i}=3, else 0 */
      west{i}  = (region{i} = 4);  /* => 1 if region{i}=4, else 0 */
  	end;
	end; drop i;
	
	keep  id momid cohort ch_birthday natal_sex birthday 
			retmo95 retmo97 retmo99 retmo01 retmo03 retmo05
			irt96   irt97   irt98   irt99   irt00 irt01    irt03  irt05
			agebirth moagebase age97 age98 age99 age00 age01 age03 age05
			bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v
			smk95 smk97 smk99 smk01 smk03 smk05  white  husbeduc
			ahei95v ahei99v  ahei03v   f295v  f299v  f203v
			alco95v alco99v  alco03v     calor95v calor99v calor03v
			act91v act97v act01v act05v    incom01 sleep99 sleep01
			shi9395v shi9597v shi9799v shi9901v shi0103v shi0305v 
			nSES_95v nSES_97v nSES_99v nSES_01v nSES_03v nSES_05v 
  			supermarket1500_1999v supermarket1500_2001v supermarket1500_2003v supermarket1500_2005v
  			restaurant1500_1999v  restaurant1500_2001v  restaurant1500_2003v  restaurant1500_2005v  
	        fastfood1500_1999v    fastfood1500_2001v    fastfood1500_2003v    fastfood1500_2005v    
	        convenience1500_1999v convenience1500_2001v convenience1500_2003v convenience1500_2005v 
        		midwest95 midwest97 midwest99 midwest01 midwest03 midwest05
	 		  	south95 south97 south99 south01 south03 south05
			  	west95 west97 west99 west01 west03 west05
			chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05
			chdiet96v chdiet97v chdiet98v chdiet01v   chwest96 chwest97 chwest98 chwest01  
			chcal96v chcal97v chcal98v chcal01v 
			chcig96 chcig97 chcig98 chcig99 chcig00 chcig01 chcig03 chcig05
			chst96v chst97v chst98v chst99v chst00v chst01v chst05v
			chpa96v chpa97v chpa98v chpa99v chpa00v chpa01v chpa05v
			chbmi96 chbmi97 chbmi98 chbmi99 chbmi00 chbmi01 chbmi03 chbmi05
			bmibpreg  gotweight prev_preg  bwg gestweek 
			Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
			fl_notmom96  fl_notmom97 fl_notmom98  fl_not_mom9698  			
			chob96 chob97 chob98 chob99 chob00 chob01 chob03 chob05
			chow96 chow97 chow98 chow99 chow00 chow01 chow03 chow05  
			chpreg01 chpreg03 chpreg05;
run;
proc means data=all1 n nmiss mean std min median max nolabels ;
run;

/* impute missings -- remove variables without missingness to speed up */
proc mi data=all1 out=all1nomiss seed=222222 nimpute=5 noprint ;
class white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
    		  midwest95 midwest97 midwest99 midwest01 midwest03 midwest05
	 		  south95 south97 south99 south01 south03 south05
			  west95 west97 west99 west01 west03 west05
				gotweight prev_preg  bwg gestweek husbeduc incom01 sleep99 sleep01;
	    
var chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05
	chwest96 chwest97 chwest98 chwest01
	chcal96v chcal97v chcal98v chcal01v 
	chst96v chst97v chst98v chst99v chst00v chst01v chst05v
	chpa96v chpa97v chpa98v chpa99v chpa00v chpa01v chpa05v

	agebirth moagebase age97 age98 age99 age00 age01 age03 age05
	f295v  f299v  f203v              calor95v calor99v calor03v
	act91v act97v act01v act05v      bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v
	shi9395v shi9597v shi9799v shi9901v shi0103v shi0305v

    nSES_95v nSES_97v nSES_99v nSES_01v nSES_03v nSES_05v 
    supermarket1500_1999v supermarket1500_2001v supermarket1500_2003v supermarket1500_2005v
  			restaurant1500_1999v  restaurant1500_2001v  restaurant1500_2003v  restaurant1500_2005v  
	        fastfood1500_1999v    fastfood1500_2001v    fastfood1500_2003v    fastfood1500_2005v    
	        convenience1500_1999v convenience1500_2001v convenience1500_2003v convenience1500_2005v 
        chbmi96 chbmi97 chbmi98 chbmi99 chbmi00 chbmi01 chbmi03 chbmi05
	bmibpreg
	
	white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
    		  midwest95 midwest97 midwest99 midwest01 midwest03 midwest05
	 		  south95 south97 south99 south01 south03 south05
			  west95 west97 west99 west01 west03 west05
				gotweight prev_preg  bwg gestweek husbeduc incom01 sleep99 sleep01;
	
fcs reg( chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05
	 chwest96 chwest97 chwest98 chwest01
	chcal96v chcal97v chcal98v chcal01v 
	chst96v chst97v chst98v chst99v chst00v chst01v chst05v
	chpa96v chpa97v chpa98v chpa99v chpa00v chpa01v chpa05v

	agebirth moagebase age97 age98 age99 age00 age01 age03 age05
	f295v  f299v  f203v              calor95v calor99v calor03v
	act91v act97v act01v act05v      bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v
	shi9395v shi9597v shi9799v shi9901v shi0103v shi0305v

    nSES_95v nSES_97v nSES_99v nSES_01v nSES_03v nSES_05v 
    supermarket1500_1999v supermarket1500_2001v supermarket1500_2003v supermarket1500_2005v
  			restaurant1500_1999v  restaurant1500_2001v  restaurant1500_2003v  restaurant1500_2005v  
	        fastfood1500_1999v    fastfood1500_2001v    fastfood1500_2003v    fastfood1500_2005v    
	        convenience1500_1999v convenience1500_2001v convenience1500_2003v convenience1500_2005v 
        chbmi96 chbmi97 chbmi98 chbmi99 chbmi00 chbmi01 chbmi03 chbmi05
	bmibpreg) 

    logistic( white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
    		  midwest95 midwest97 midwest99 midwest01 midwest03 midwest05
	 		  south95 south97 south99 south01 south03 south05
			  west95 west97 west99 west01 west03 west05
				gotweight prev_preg  bwg gestweek husbeduc incom01 sleep99 sleep01/ likelihood=augment) 
				
     nbiter =10 ; 
run;

proc sort data=all1nomiss out=here.all1_mi; by _imputation_ id; run;

proc means data=all1nomiss n nmiss mean std min median max nolabels ;
 where _Imputation_ = 1 ;
run;
