
/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 

program name: /udd/nhywa/GUTSOB/secondary_windows/
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Template: /udd/nhywa/GUTSOB/all2_vars_mi.sas
Programmer: Bethsaida Cardona (n2bca) added additional variables needed for exposure windows
			Yiqing Wang (nhywa)
Preparation date: 07/2025
1) Purpose: Combine GUTS2 with NHS2 and conduct multiple imputation, 
similar to main analysis but imputted variables are only those used in the exposure windows analysis

*/

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
libname heredat '/udd/nhywa/GUTSOB/secondary_windows/1.data';

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

	/*exposure window update, array needs to cover data from 1989*/
	array region{12} region10_89 region10_91 region10_93 region10_95 region10_97 region10_99 region10_01 region10_03 region10_05 region10_07 region10_11 region10_13;
	array mid{12} midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 midwest07 midwest11 midwest13 ;
	array south{12} south89 south91 south93 south95 south97 south99 south01 south03 south05 south07 south11 south13 ;
	array west{12} west89 west91 west93 west95 west97 west99 west01 west03 west05 west07 west11 west13 ;
	
	do i = 1 to 12;
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
			bmi89    bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 bmi07 bmi11 bmi13 /*exposure window addition*/
			/*bmi03v bmi05v bmi07v bmi11v bmi13v*/
			smk89    smk91   smk93 smk95 smk97 smk99 smk01 smk03 smk05 smk07 smk11 smk13 white  husbeduc 	/*exposure window addition; added in additional years*/
			/*ahei03v ahei07v ahei11v*/      
			f291  f295  f299 f203  f207 f211 /*exposure window addition*/
			/*f203v  f207v  f211v*/
			/*alco03v alco07v alco11v*/      
			calor91n calor95n calor99n calor03n calor07n calor11n /*exposure window addition*/
			/*calor03v calor07v calor11v*/
			act89m act91m act97m act01m act05m act09m act13m /*exposure window addition*/
			/*act01v act05v act09v act13v*/       
			shi89_con shi8991_con shi9193_con shi9395_con shi9597_con shi9799_con shi9901_con shi0103_con shi0305_con shi07_con shi11_con shi13_con /*exposure window addition*/
			/*shi0103v shi0305v shi11v shi13v*/   
			incom01 
			/*sleep06 sleep08 sleep11*/
			nSES_89 nSES_91 nSES_93 nSES_95 nSES_97 nSES_99 nSES_01 nSES_03 nSES_05 nSES_07 nSES_09 nSES_11 nSES_13 /*exposure window addition*/
			/*nSES_03v nSES_05v nSES_07v nSES_09v nSES_11v nSES_13v*/ 
    		/*supermarket1500_2003v supermarket1500_2005v supermarket1500_2007v supermarket1500_2009v supermarket1500_2011v supermarket1500_2013v  
			restaurant1500_2003v  restaurant1500_2005v  restaurant1500_2007v  restaurant1500_2009v  restaurant1500_2011v  restaurant1500_2013v   
			fastfood1500_2003v    fastfood1500_2005v    fastfood1500_2007v    fastfood1500_2009v    fastfood1500_2011v    fastfood1500_2013v   
			convenience1500_2003v convenience1500_2005v convenience1500_2007v convenience1500_2009v convenience1500_2011v convenience1500_2013v */ 	
			midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 midwest07 midwest11 midwest13 /*exposure window addition; added in additional years*/
			south89 south91 south93 south95 south97 south99 south01 south03 south05 south07 south11 south13 
			west89 west91 west93 west95 west97 west99 west01 west03 west05 west07 west11 west13 
			chage04 chage06 chage08 chage11 chage13
			/*chdiet04v chdiet06v chdiet08v chdiet11v*/  
			chwest_04 chwest_06 chwest_08 chwest_11  /*exposure window addition*/
			/*chwest04 chwest06 chwest08 chwest11*/  
			chcal04 chcal06 chcal08 chcal11 	/*exposure window addition*/
			/*chcal04v chcal06v chcal08v chcal11v*/
			/*chcig06 chcig08 chcig11 chcig13*/
			chst04 chst06 chst08 chst11 /*exposure window addition*/
			/*chst04v chst06v chst08v chst11v*/ 
			chpa04 chpa06 chpa08 chpa11 /*exposure window addition*/
			/*chpa04v chpa06v chpa08v chpa11v*/ /*exposure window addition*/
			chbmi04 chbmi06 chbmi08 chbmi11 chbmi13
			bmibpreg  Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery prev_preg  bwg gestweek 
			/*physician_ratio10v food_desert10v physician_ratio12v food_desert12v physician_ratio13v food_desert13v*/ 			
			chob04 chob06 chob08 chob11 chob13 
			chow04 chow06 chow08 chow11 chow13 
			chpreg13;
run;
proc means data=all2 n nmiss mean std min median max nolabels ;
run;


/* impute missings */
proc mi data=all2 out=all2nomiss seed=222222 nimpute=5 noprint ;
class white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
		midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 midwest07 midwest11 midwest13 /*exposure window addition; added in additional years*/
		south89 south91 south93 south95 south97 south99 south01 south03 south05 south07 south11 south13 
		west89 west91 west93 west95 west97 west99 west01 west03 west05 west07 west11 west13 
		prev_preg  bwg gestweek husbeduc incom01 
		/*sleep06 sleep08 sleep11*/
		;
	    
var chage04 chage06 chage08 chage11 chage13
	chwest_04 chwest_06 chwest_08 chwest_11  /*exposure window addition*/
	/*chwest04 chwest06 chwest08 chwest11*/  
	chcal04 chcal06 chcal08 chcal11 	/*exposure window addition*/
	/*chcal04v chcal06v chcal08v chcal11v*/
	chst04 chst06 chst08 chst11 /*exposure window addition*/
	/*chst04v chst06v chst08v chst11v*/ 
	chpa04 chpa06 chpa08 chpa11 /*exposure window addition*/
	/*chpa04v chpa06v chpa08v chpa11v*/ 

	agebirth moagebase age06 age08 age11 age13
	f291  f295  f299 f203  f207 f211 /*exposure window addition*/
	/*f203v  f207v  f211v*/           
	calor91n calor95n calor99n calor03n calor07n calor11n /*exposure window addition*/
	/*calor03v calor07v calor11v*/
	act89m act91m act97m act01m act05m act09m act13m /*exposure window addition*/
	/*act01v act05v act09v act13v*/    
	bmi89    bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 bmi07 bmi11 bmi13 /*exposure window addition*/
	/*bmi03v bmi05v bmi07v bmi11v bmi13v*/
	shi89_con shi8991_con shi9193_con shi9395_con shi9597_con shi9799_con shi9901_con shi0103_con shi0305_con shi07_con shi11_con shi13_con /*exposure window addition*/
	/*shi0103v shi0305v shi11v shi13v*/

	nSES_89 nSES_91 nSES_93 nSES_95 nSES_97 nSES_99 nSES_01 nSES_03 nSES_05 nSES_07 nSES_09 nSES_11 nSES_13 /*exposure window addition*/
    /*nSES_03v nSES_05v nSES_07v nSES_09v nSES_11v nSES_13v*/ 
   	/*supermarket1500_2003v supermarket1500_2005v supermarket1500_2007v supermarket1500_2009v supermarket1500_2011v supermarket1500_2013v  
	restaurant1500_2003v  restaurant1500_2005v  restaurant1500_2007v  restaurant1500_2009v  restaurant1500_2011v  restaurant1500_2013v   
	fastfood1500_2003v    fastfood1500_2005v    fastfood1500_2007v    fastfood1500_2009v    fastfood1500_2011v    fastfood1500_2013v   
	convenience1500_2003v convenience1500_2005v convenience1500_2007v convenience1500_2009v convenience1500_2011v convenience1500_2013v*/  	
    chbmi04 chbmi06 chbmi08 chbmi11 chbmi13
 	bmibpreg
	
	/*physician_ratio10v food_desert10v physician_ratio12v food_desert12v physician_ratio13v food_desert13v*/
	
	white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
	midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 midwest07 midwest11 midwest13 /*exposure window addition; added in additional years*/
	south89 south91 south93 south95 south97 south99 south01 south03 south05 south07 south11 south13 
	west89 west91 west93 west95 west97 west99 west01 west03 west05 west07 west11 west13 
	prev_preg  bwg gestweek husbeduc 
	incom01 
	/*sleep06 sleep08 sleep11*/;
	
fcs reg(chage04 chage06 chage08 chage11 chage13
		chwest_04 chwest_06 chwest_08 chwest_11  /*exposure window addition*/
		/*chwest04 chwest06 chwest08 chwest11*/  
		chcal04 chcal06 chcal08 chcal11 	/*exposure window addition*/
		/*chcal04v chcal06v chcal08v chcal11v*/
		chst04 chst06 chst08 chst11 /*exposure window addition*/
		/*chst04v chst06v chst08v chst11v*/ 
		chpa04 chpa06 chpa08 chpa11 /*exposure window addition*/
		/*chpa04v chpa06v chpa08v chpa11v*/ 

		agebirth moagebase age06 age08 age11 age13
		f291  f295  f299 f203  f207 f211 /*exposure window addition*/
		/*f203v  f207v  f211v*/          
		calor91n calor95n calor99n calor03n calor07n calor11n /*exposure window addition*/
		/*calor03v calor07v calor11v*/
		act89m act91m act97m act01m act05m act09m act13m /*exposure window addition*/
		/*act01v act05v act09v act13v*/    
		bmi89    bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 bmi07 bmi11 bmi13 /*exposure window addition*/
		/*bmi03v bmi05v bmi07v bmi11v bmi13v*/
		shi89_con shi8991_con shi9193_con shi9395_con shi9597_con shi9799_con shi9901_con shi0103_con shi0305_con shi07_con shi11_con shi13_con /*exposure window addition*/
		/*shi0103v shi0305v shi11v shi13v*/

		nSES_89 nSES_91 nSES_93 nSES_95 nSES_97 nSES_99 nSES_01 nSES_03 nSES_05 nSES_07 nSES_09 nSES_11 nSES_13 /*exposure window addition*/
	 	/*nSES_03v nSES_05v nSES_07v nSES_09v nSES_11v nSES_13v*/ 
   		/*supermarket1500_2003v supermarket1500_2005v supermarket1500_2007v supermarket1500_2009v supermarket1500_2011v supermarket1500_2013v  
		restaurant1500_2003v  restaurant1500_2005v  restaurant1500_2007v  restaurant1500_2009v  restaurant1500_2011v  restaurant1500_2013v   
		fastfood1500_2003v    fastfood1500_2005v    fastfood1500_2007v    fastfood1500_2009v    fastfood1500_2011v    fastfood1500_2013v   
		convenience1500_2003v convenience1500_2005v convenience1500_2007v convenience1500_2009v convenience1500_2011v convenience1500_2013v*/  	
    	chbmi04 chbmi06 chbmi08 chbmi11 chbmi13
 		bmibpreg
		/*physician_ratio10v food_desert10v physician_ratio12v food_desert12v physician_ratio13v food_desert13v*/
		) 

    logistic(white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
				midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 midwest07 midwest11 midwest13 /*exposure window addition; added in additional years*/
				south89 south91 south93 south95 south97 south99 south01 south03 south05 south07 south11 south13 
				west89 west91 west93 west95 west97 west99 west01 west03 west05 west07 west11 west13 
			  	prev_preg  bwg gestweek husbeduc incom01 /*sleep06 sleep08 sleep11*/ / likelihood=augment) 
     
	 nbiter =10 ; 
run;

proc sort data=all2nomiss out=heredat.all2_mi; by _imputation_ id; run; /*BCAR CHANGED THE OUTPUT LOCATION FROM HERE TO THE FOLDER SCRIPT IS IN*/

proc means data=all2nomiss n nmiss mean std min median max nolabels ;
 where _Imputation_ = 1 ;
run;
