

/********************************************************************************
CODE DOCUMENTATION
********************************************************************************/
/* 

program name: /udd/nhywa/GUTSOB/secondary_windows/
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Template: /udd/nhywa/GUTSOB/all1_vars_mi.sas
Programmer: Bethsaida Cardona (n2bca) added additional variables needed for exposure windows
			Yiqing Wang (nhywa)
Preparation date: 07/2025
1) Purpose: Combine GUTS1 with NHS2 and conduct multiple imputation, 
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
				
	/*exposure window update, array needs to cover data from 1989*/
	array region{9} region10_89 region10_91 region10_93 region10_95 region10_97 region10_99 region10_01 region10_03 region10_05;
	array mid{9} midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05;
	array south{9} south89 south91 south93 south95 south97 south99 south01 south03 south05;
	array west{9} west89 west91 west93 west95 west97 west99 west01 west03 west05;
	
	do i = 1 to 9;
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
			bmi89    bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 /*exposure window addition*/
			/*bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v*/
			smk89    smk91   smk93 smk95 smk97 smk99 smk01 smk03 smk05  white  husbeduc 	/*exposure window addition; added in 1989, 1991 and 1993*/
			/*ahei95v ahei99v  ahei03v*/   
			f291 f295  f299  f203 /*exposure window addition*/
			/*f295v  f299v  f203v*/
			/*alco95v alco99v  alco03v*/     
			calor91n calor95n calor99n calor03n /*exposure window addition*/
			/*calor95v calor99v calor03v*/
			act89m act91m act97m act01m act05m /*exposure window addition*/
			/*act91v act97v act01v act05v*/    
			incom01 
			/*sleep99 sleep01*/
			shi89_con shi8991_con shi9193_con shi9395_con shi9597_con shi9799_con shi9901_con shi0103_con shi0305_con /*exposure window addition*/
			/*shi9395v shi9597v shi9799v shi9901v shi0103v shi0305v*/ 
			nSES_89 nSES_91 nSES_93 nSES_95 nSES_97 nSES_99 nSES_01 nSES_03 nSES_05 /*exposure window addition*/ 
			/*nSES_95v nSES_97v nSES_99v nSES_01v nSES_03v nSES_05v*/ 
  			/*supermarket1500_1999v supermarket1500_2001v supermarket1500_2003v supermarket1500_2005v
  			restaurant1500_1999v  restaurant1500_2001v  restaurant1500_2003v  restaurant1500_2005v  
	        fastfood1500_1999v    fastfood1500_2001v    fastfood1500_2003v    fastfood1500_2005v    
	        convenience1500_1999v convenience1500_2001v convenience1500_2003v convenience1500_2005v*/ 
        	midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 /*exposure window addition; added in 1989, 1991 and 1993*/ 
	 		south89 south91 south93 south95 south97 south99 south01 south03 south05
			west89 west91 west93 west95 west97 west99 west01 west03 west05
			chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05
			/*chdiet96v chdiet97v chdiet98v chdiet01v*/   
			chwest_96 chwest_97 chwest_98 chwest_01 /*exposure window addition*/
			/*chwest96 chwest97 chwest98 chwest01*/  
			chcal96 chcal97 chcal98 chcal01 /*exposure window addition*/
			/*chcal96v chcal97v chcal98v chcal01v*/ 
			/*chcig96 chcig97 chcig98 chcig99 chcig00 chcig01 chcig03 chcig05*/
			chst96 chst97 chst98 chst99 chst00 chst01 chst05 /*exposure window addition*/
			chst96v chst97v chst98v chst99v chst00v chst01v chst05v
			chpa96 chpa97 chpa98 chpa99 chpa00 chpa01 chpa05 /*change for exposure windows*/ 
			/*chpa96v chpa97v chpa98v chpa99v chpa00v chpa01v chpa05v*/
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
class 	white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
		midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 /*exposure window addition; added in 1989, 1991 and 1993*/ 
	 	south89 south91 south93 south95 south97 south99 south01 south03 south05
		west89 west91 west93 west95 west97 west99 west01 west03 west05
		gotweight prev_preg  bwg gestweek husbeduc incom01 
		/*sleep99 sleep01*/
		;
	    
var chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05
	chwest_96 chwest_97 chwest_98 chwest_01 /*exposure window addition*/
	/*chwest96 chwest97 chwest98 chwest01*/
	chcal96 chcal97 chcal98 chcal01 /*exposure window addition*/
	/*chcal96v chcal97v chcal98v chcal01v*/ 
	chst96 chst97 chst98 chst99 chst00 chst01 chst05 /*exposure window addition*/
	/*chst96v chst97v chst98v chst99v chst00v chst01v chst05v*/
	chpa96 chpa97 chpa98 chpa99 chpa00 chpa01 chpa05 /*change for exposure windows*/ 
	/*chpa96v chpa97v chpa98v chpa99v chpa00v chpa01v chpa05v*/

	agebirth moagebase age97 age98 age99 age00 age01 age03 age05
	f291 f295  f299  f203 /*exposure window addition*/
	/*f295v  f299v  f203v*/              
	calor91n calor95n calor99n calor03n /*exposure window addition*/
	/*calor95v calor99v calor03v*/
	act89m act91m act97m act01m act05m /*exposure window addition*/
	/*act91v act97v act01v act05v*/      
	bmi89    bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 /*exposure window addition*/
	/*bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v*/
	shi89_con shi8991_con shi9193_con shi9395_con shi9597_con shi9799_con shi9901_con shi0103_con shi0305_con /*exposure window addition*/
	/*shi9395v shi9597v shi9799v shi9901v shi0103v shi0305v*/

	nSES_89 nSES_91 nSES_93 nSES_95 nSES_97 nSES_99 nSES_01 nSES_03 nSES_05  /*exposure window addition*/
    /*nSES_95v nSES_97v nSES_99v nSES_01v nSES_03v nSES_05v*/ 
    /*supermarket1500_1999v supermarket1500_2001v supermarket1500_2003v supermarket1500_2005v
  	restaurant1500_1999v  restaurant1500_2001v  restaurant1500_2003v  restaurant1500_2005v  
	fastfood1500_1999v    fastfood1500_2001v    fastfood1500_2003v    fastfood1500_2005v    
	convenience1500_1999v convenience1500_2001v convenience1500_2003v convenience1500_2005v*/ 
    chbmi96 chbmi97 chbmi98 chbmi99 chbmi00 chbmi01 chbmi03 chbmi05
	bmibpreg
	
	white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
	midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 /*exposure window addition; added in 1989, 1991 and 1993*/ 
	south89 south91 south93 south95 south97 south99 south01 south03 south05
	west89 west91 west93 west95 west97 west99 west01 west03 west05
	gotweight prev_preg  bwg gestweek husbeduc incom01 
	/*sleep99 sleep01*/;
	
fcs reg(chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05
		chwest_96 chwest_97 chwest_98 chwest_01 /*exposure window addition*/
		/*chwest96 chwest97 chwest98 chwest01*/
		chcal96 chcal97 chcal98 chcal01 /*exposure window addition*/
		/*chcal96v chcal97v chcal98v chcal01v*/ 
		chst96 chst97 chst98 chst99 chst00 chst01 chst05 /*exposure window addition*/
		/*chst96v chst97v chst98v chst99v chst00v chst01v chst05v*/
		chpa96 chpa97 chpa98 chpa99 chpa00 chpa01 chpa05 /*exposure window addition*/
		/*chpa96v chpa97v chpa98v chpa99v chpa00v chpa01v chpa05v*/

		agebirth moagebase age97 age98 age99 age00 age01 age03 age05
		f291 f295  f299  f203 /*exposure window addition*/
		/*f295v  f299v  f203v*/              
		calor91n calor95n calor99n calor03n /*exposure window addition*/
		/*calor95v calor99v calor03v*/
		act89m act91m act97m act01m act05m /*exposure window addition*/
		/*act91v act97v act01v act05v*/      
		bmi89    bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 /*exposure window addition*/
		/*bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v*/
		shi89_con shi8991_con shi9193_con shi9395_con shi9597_con shi9799_con shi9901_con shi0103_con shi0305_con /*exposure window addition*/
		/*shi9395v shi9597v shi9799v shi9901v shi0103v shi0305v*/

		/*change for exposure windows*/
		nSES_89 nSES_91 nSES_93 nSES_95 nSES_97 nSES_99 nSES_01 nSES_03 nSES_05 
   		/*nSES_95v nSES_97v nSES_99v nSES_01v nSES_03v nSES_05v*/ 
    	/*supermarket1500_1999v supermarket1500_2001v supermarket1500_2003v supermarket1500_2005v
  		restaurant1500_1999v  restaurant1500_2001v  restaurant1500_2003v  restaurant1500_2005v  
		fastfood1500_1999v    fastfood1500_2001v    fastfood1500_2003v    fastfood1500_2005v    
	    convenience1500_1999v convenience1500_2001v convenience1500_2003v convenience1500_2005v*/ 
        chbmi96 chbmi97 chbmi98 chbmi99 chbmi00 chbmi01 chbmi03 chbmi05
		bmibpreg) 

    logistic(white natal_sex Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery
    		midwest89 midwest91 midwest93 midwest95 midwest97 midwest99 midwest01 midwest03 midwest05 /*exposure window addition; added in 1989, 1991 and 1993*/ 
	 		south89 south91 south93 south95 south97 south99 south01 south03 south05
			west89 west91 west93 west95 west97 west99 west01 west03 west05
			gotweight prev_preg  bwg gestweek husbeduc incom01 /*sleep99 sleep01*/ / likelihood=augment) 
     
	 nbiter =10 ; 
run;

proc sort data=all1nomiss out=heredat.all1_mi; by _imputation_ id; run; 

proc means data=all1nomiss n nmiss mean std min median max nolabels ;
 where _Imputation_ = 1 ;
run;
