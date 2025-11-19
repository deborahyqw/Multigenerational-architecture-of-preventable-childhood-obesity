/*******************************************************************************
program name: all2_vars_mi.sas
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

%include '/udd/nhywa/GUTSOB/guts2_vars.sas';
*Read in NHS2 data prepared by Bethsaida with adjustment by Yiqing;
%include '/udd/nhywa/GUTSOB/nhs2_vars.sas';

/******************************************************************************
/*************************** Merge all **********************************/
/******************************************************************************/
*merge files 1 - many, if no observations for that year then blank;
/* Have to transpose by GUTS 1 and 2 separately, because 04-13 data will be missing for GUTS1 and 96-01 data missing for GUTS2 */
data gutsmoms2;
  merge nhs2_vars(in=a) guts2(in=b);
  by momid;
  if a and b;
proc sort data=gutsmoms2; by id; run;


/****************************** GUTS 2 ********************************************/
data all2;
  merge gutsmoms2 (in=master) grav09guts2 bmibpregdt end=_end_;
  	by id; exrec=1; 
  	if master; if cohort=2 ;
  	if chbmi04 >0 ; *keep only children without missing baseline BMI;
  	if first.id then exrec=0;
  	
  	if white=. then white=0;
  	
  	if chyob < 1990 then bmibpreg = .; *chyob 1987-1996;
  		else if chyob >= 1990 & chyob < 1992 then bmibpreg = bmi89v; 
  		else if chyob >= 1992 & chyob < 1994 then bmibpreg = bmi91v; 
  		else if chyob >= 1994 & chyob < 1996 then bmibpreg = bmi93v; 
  		else bmibpreg = bmi95v; 
  		                        	
 	*maternal age at birth ;
 	agebirth = age89 - (retmo89 /12 - (chyob-1900));
 	
 	moagebase=age03+1; if moagebase=. then moagebase=age89+15;
	age06=age05+1; age08=age07+1;
 		
	if chage06=. then chage06=chage04+2; if chage08=. then chage08=chage06+2;
	if chage11=. then chage11=chage08+3; if chage13=. then chage13=chage11+2;
    if age06=. then age06=moagebase+2; if age08=. then age08=age06+2;
	if age11=. then age11=age08+3; if age13=. then age13=age11+2;
				
	array region{5} region10_03 region10_05 region10_07 region10_11 region10_13;
	array mid{5} midwest03 midwest05 midwest07 midwest11 midwest13 ;
	array south{5} south03 south05 south07 south11 south13 ;
	array west{5} west03 west05 west07 west11 west13 ;
	
	do i = 1 to 5;
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
			retmo03 retmo05 retmo07 retmo09 retmo11 retmo13 
			irt04 irt06 irt08 irt11 irt13 
			agebirth moagebase age06 age08 age11 age13
			bmi03v bmi05v bmi07v bmi11v bmi13v
			smk03 smk05 smk07 smk11 smk13  white  husbeduc
			/* ahei03v ahei07v ahei11v */     f203v  f207v  f211v
			/* alco03v alco07v alco11v */     calor03v calor07v calor11v 
			act01v act05v act09v act13v       
			shi0103v shi0305v shi07v shi11v shi13v   incom01 /* sleep06 sleep08 sleep11 */
			nSES_03v nSES_05v nSES_07v nSES_09v nSES_11v nSES_13v 
    /* supermarket1500_2003v supermarket1500_2005v supermarket1500_2007v supermarket1500_2009v supermarket1500_2011v supermarket1500_2013v  
	restaurant1500_2003v  restaurant1500_2005v  restaurant1500_2007v  restaurant1500_2009v  restaurant1500_2011v  restaurant1500_2013v   
	fastfood1500_2003v    fastfood1500_2005v    fastfood1500_2007v    fastfood1500_2009v    fastfood1500_2011v    fastfood1500_2013v   
	convenience1500_2003v convenience1500_2005v convenience1500_2007v convenience1500_2009v convenience1500_2011v convenience1500_2013v  */	
        		midwest03 midwest05 midwest07 midwest11 midwest13 
				south03 south05 south07 south11 south13 
				west03 west05 west07 west11 west13 
			chage04 chage06 chage08 chage11 chage13
			/* chdiet04v chdiet06v chdiet08v chdiet11v */  chwest04 chwest06 chwest08 chwest11  
			chcal04v chcal06v chcal08v chcal11v
			/* chcig06 chcig08 chcig11 chcig13 */
			chst04v chst06v chst08v chst11v 
			chpa04v chpa06v chpa08v chpa11v 
			chbmi04 chbmi06 chbmi08 chbmi11 chbmi13
			bmibpreg  Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery prev_preg  bwg gestweek 
			/* physician_ratio10v food_desert10v physician_ratio12v food_desert12v physician_ratio13v food_desert13v 	*/		
			chob04 chob06 chob08 chob11 chob13 
			chow04 chow06 chow08 chow11 chow13 chpreg13;
run;
proc means data=all2 n nmiss mean std min median max nolabels ;
run;

/* impute missings */
proc mi data=all2 out=all2nomiss seed=222222 nimpute=5 noprint ;
class white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
    		  midwest03 midwest05 midwest07 midwest11 midwest13 
				south03 south05 south07 south11 south13 
				west03 west05 west07 west11 west13 
			    prev_preg  bwg gestweek husbeduc incom01 ;
	    
var chage04 chage06 chage08 chage11 chage13
			chwest04 chwest06 chwest08 chwest11  
			chcal04v chcal06v chcal08v chcal11v
			chst04v chst06v chst08v chst11v 
			chpa04v chpa06v chpa08v chpa11v 

	agebirth moagebase age06 age08 age11 age13
			f203v  f207v  f211v           calor03v calor07v calor11v 
			act01v act05v act09v act13v    bmi03v bmi05v bmi07v bmi11v bmi13v
	shi0103v shi0305v shi07v shi11v shi13v

    nSES_03v nSES_05v nSES_07v nSES_09v nSES_11v nSES_13v 
      chbmi04 chbmi06 chbmi08 chbmi11 chbmi13
 	bmibpreg
		
	white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
    		  midwest03 midwest05 midwest07 midwest11 midwest13 
				south03 south05 south07 south11 south13 
				west03 west05 west07 west11 west13 
				 prev_preg  bwg gestweek husbeduc incom01 ;
	
fcs reg( chage04 chage06 chage08 chage11 chage13
			 chwest04 chwest06 chwest08 chwest11  
			chcal04v chcal06v chcal08v chcal11v
			chst04v chst06v chst08v chst11v 
			chpa04v chpa06v chpa08v chpa11v 

	agebirth moagebase age06 age08 age11 age13
			 f203v  f207v  f211v          calor03v calor07v calor11v 
			act01v act05v act09v act13v    bmi03v bmi05v bmi07v bmi11v bmi13v
	shi0103v shi0305v shi07v shi11v shi13v

	 nSES_03v nSES_05v nSES_07v nSES_09v nSES_11v nSES_13v 
      chbmi04 chbmi06 chbmi08 chbmi11 chbmi13
 	bmibpreg )

    logistic( white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
    		  midwest03 midwest05 midwest07 midwest11 midwest13 
				south03 south05 south07 south11 south13 
				west03 west05 west07 west11 west13 
			  prev_preg  bwg gestweek husbeduc incom01 / likelihood=augment) 
     nbiter =10 ; 
run;

proc sort data=all2nomiss out=here.all2_mi; by _imputation_ id; run;

proc means data=all2nomiss n nmiss mean std min median max nolabels ;
 where _Imputation_ = 1 ;
run;
