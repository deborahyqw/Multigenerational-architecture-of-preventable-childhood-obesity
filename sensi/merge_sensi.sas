/*******************************************************************************
program name: merge_sensi.sas
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Yiqing Wang (nhywa)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: 12/2024
1) Purpose: Combine GUTS1 and GUTS2 with NHS2 to conduct complete-case analysis
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
sbs -o memsize=8000M xx.sas
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
libname outhere '/udd/nhywa/GUTSOB/sensi/';

%include '/udd/nhywa/GUTSOB/guts1_vars.sas';
%include '/udd/nhywa/GUTSOB/guts2_vars.sas';
*Read in NHS2 data prepared by Bethsaida with adjustment by Yiqing;
%include '/udd/nhywa/GUTSOB/nhs2_vars.sas';

*sbs -o memsize=8000M mySASprogram.sas ;

/****************************** GUTS1 ********************************************/
*merge files 1 - many, if no observations for that year then blank;
/* Have to transpose by GUTS 1 and 2 separately, because 04-13 data will be missing for GUTS1 and 96-01 data missing for GUTS2 */
data gutsmoms1;
  merge nhs2_vars(in=a) guts1(in=b);
  by momid;
  if a and b;
proc sort data=gutsmoms1; by id; run;

data all1; 
	merge gutsmoms1 (in=master) grav09guts1 bmibpregdt end=_end_;
  	by id; exrec=1; 
  	if master; if cohort=1 ;
  	if chbmi96 >0 ; *keep only children without missing baseline BMI;
  	if first.id then exrec=0;
  	
  	if white=. then white=0; sex = natal_sex - 1 ; 
  	
  	*maternal age at birth - 1980-1987;
 	agebirth = age89 - (retmo89 /12 - (chyob-1900));
 		
	if chage97=. then chage97=chage96+1; if chage98=. then chage98=chage97+1;
	if chage99=. then chage99=chage98+1; if chage00=. then chage00=chage99+1;
	if chage01=. then chage01=chage00+1; if chage03=. then chage03=chage01+2; if chage05=. then chage05=chage03+2;
    
    moagebase=age95+1; if moagebase=. then moagebase=age89+7;
    if age97=. then age97=moagebase+1; if age98=. then age98=age97+1;
	if age99=. then age99=age98+1; if age00=. then age00=age99+1;
	if age01=. then age01=age00+1; if age03=. then age03=age01+2; if age05=. then age05=age03+2;
				
    if Comp_Gesdbg=1 or Comp_prghtng=1 or Comp_peclmpg=1 or Delivery=1 then pregcomp=1;
    	else pregcomp=0;       
                         
    if Comp_Gesdbg=1 or Comp_prghtng=1 or Comp_peclmpg=1 then pregcomp2=1;
    	else pregcomp2=0;  
    	
    if Delivery = . then Delivery=1;    
    
    if prev_preg =. then prev_preg=0;                
    %indic3(vbl=prev_preg, reflev=0, missing=., min=1, max=3, prefix=prev_preg, usemiss=0,
            label1='one prev preg', label2='two prev preg', label3='three prev preg');
	
  	%indic3(vbl=bwg, reflev=2, missing=., min=1, max=3, prefix=abwt, usemiss=0,
            label1='<=2.5kg',label3='>=4.5kg');
      
  	%indic3(vbl=gestweek, reflev=2, missing=., min=1, max=3, prefix=gweek, usemiss=0,
            label2='<37',label3='>=43');         
	
  	%indic3(vbl=husbeduc, reflev=3, missing=., min=1, max=2, prefix=heduc, usemiss=0,
            label1='<college',label2='college');   
    
    if incom01 =. then income=.;  * 11671;
    	else if incom01 <=5 then income=1; /*<50000*/
    	else if incom01>5 & incom01<=7 then income=2; /*50000-99000*/
    	else if incom01=8 then income=3; /*100000-149+*/
    	else income=4; /*150+*/
    /*$label 1.less than 15,000; 2.15,000-19; 3.20,000-29; 4.30,000-39; 5.40,000-49;\
        6.50,000-74; 7.75,000-99; 8.100,000-149; 9.150,000+; ..pt */
    %indic3(vbl=income, reflev=4, missing=., min=1, max=3, prefix=fincome, usemiss=0,
            label1='<50k',label2='50-99k',label3='100-149k');   
    
    if gotweight=. then  gotweight=0; *8537;
     
	*make primary physician and food desert missing to match with GUTSII;
	physician=. ; food_desert=.; 
 	
	year96=1996; year97=1997; year98=1998; year99=1999; year00=2000;
	year01=2001; year03=2003; year05=2005;
	
	chbmibase=chbmi96;  
			   	  
	********** generate time variable indicating OB incident **********************
	********** for subsequent censoring of observations after OB ******************;
	if chob96=1 then obyear=1996;
	else if chob97=1 then obyear=1997; else if chob98=1 then obyear=1998; 
	else if chob99=1 then obyear=1999; else if chob00=1 then obyear=2000;
	else if chob01=1 then obyear=2001; else if chob03=1 then obyear=2003;
	else if chob05=1 then obyear=2005;   	
					 
/****************************** Transpose wide to long ********************************************/
array irt(8) irt96 irt97 irt98 irt99 irt00 irt01 irt03 irt05;
array qyear(8) year96 year97 year98 year99 year00 year01 year03 year05;
array age(8) chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05; *8-15,9-17,10-18,11-19,13-20,14-22,16-23,17-25;
array ob(8) chob96 chob97 chob98 chob99 chob00 chob01 chob03 chob05;
array bmi(8) chbmi96 chbmi97 chbmi98 chbmi99 chbmi00 chbmi01 chbmi03 chbmi05;

array wdiet(8) chwest96 chwest97 chwest98 chwest98 chwest98 chwest01 chwest01 chwest01;
array kcal(8) chcal96v chcal97v chcal98v chcal98v chcal98v chcal01v chcal01v chcal01v;
array sed(8) chst96v chst97v chst98v chst99v chst00v chst01v chst01v chst05v;
array pa(8) chpa96v chpa97v chpa98v chpa99v chpa00v chpa01v chpa01v chpa05v;
array preg(8) XXX XXX XXX XXX XXX chpreg01 chpreg03 chpreg05;

array mage(8) moagebase age97 age98 age99 age00 age01 age03 age05;
array mwest(8) f295v f295v f295v f299v f299v f299v f203v f203v;
array mcal(8) calor95v calor95v calor95v calor99v calor99v calor99v calor03v calor03v;
array msmk(8) smk95 smk97 smk97 smk99 smk99 smk01 smk03 smk05;
array mpa(8) act91v act97v act97v act97v act97v act01v act01v act05v;
array mbmi(8) bmi95v bmi97v bmi97v bmi99v bmi99v bmi01v bmi03v bmi05v;
array mshift(8) shi9395v shi9597v shi9597v shi9799v shi9799v shi9901v shi0103v shi0305v;
array mses(8) nSES_95v nSES_97v nSES_97v nSES_99v nSES_99v nSES_01v nSES_03v nSES_05v;
array location{8} region10_95 region10_97 region10_97 region10_99 region10_99 region10_01 region10_03 region10_05;

/*** If lost to follow-up,     then lastq=last irt. 
 	 If not lost to follow up, then lastq=. ***/  
   do i=1 to dim(irt);
   	if irt{i} >0 then lastq=irt{i};
   end; drop i;
   if lastq=irt{8} then lastq=.;

*replace missing with prior values;
	do i=2 to 8;
		if wdiet(i) = . then  wdiet(i) =  wdiet(i-1); 
		if kcal(i) = .  then  kcal(i)  =  kcal(i-1); 
		if sed(i) = .   then  sed(i) =  sed(i-1); 
		if pa(i) = . then  pa(i) =  pa(i-1); 
		if mwest(i) = . then  mwest(i) =  mwest(i-1); 
		if mcal(i) = . then  mcal(i) =  mcal(i-1); 
		if msmk(i) = . then  msmk(i) =  msmk(i-1); 
		if mpa(i) = . then  mpa(i) =  mpa(i-1); 
		if mshift(i) = . then  mshift(i) =  mshift(i-1); 
		if mses(i) = . then  mses(i) =  mses(i-1); 
		if location(i) = . then  location(i) =  location(i-1); 		
	end;

*DO-LOOP OVER TIME PERIODS;
	%beginex();
	
do time=1 to 8;	
	
 	year=qyear(time); 	        chage =age(time);     	    chob  =ob(time);
	chbmi =bmi(time);           chwest =wdiet(time);     
	chcal =kcal(time);          chst =sed(time);            chpa  =pa(time);          
	chpreg  =preg(time);	   
	moage =mage(time);	        mowest =mwest(time);        mocal  =mcal(time);       
	mosmk  =msmk(time);
	mopa   =mpa(time);          mobmi  =mbmi(time);         moshift  =mshift(time);
	ses  =mses(time);           region = location(time);    chirt = irt{time};   
      
    %indic3 (vbl=mosmk, prefix=mosmk, min=2, max=3, reflev=1, missing=., usemiss=0,
      label2='mom past smoking', label3='mom current smoking');   

/******************************************************************
  ***************          EXCLUSIONS          *******************
********************************************************************/
*baseline;
if time=1 then do;	
	*%exclude(id ne ., nodelete=t); *16611;
	%exclude(momid ne ., nodelete=t); 
    %exclude(exrec eq 1); *exclude those not in GUTS1 -1 ;
    %exclude(chob eq 1); *baseline ob n=741;
	%exclude(chbmi eq .); * baseline bmi missing - should be 0, already excluded; 
	%exclude(bwg eq . or  gestweek eq . or husbeduc eq . or incom01 eq . or bmibpreg eq . or
			 chwest eq . or chcal eq . or chst eq . or chpa eq . or
    		 mowest eq . or mocal eq . or mopa eq . or mobmi eq . or moshift eq . or ses eq . ); *exclude missing exposures 7464;
    %exclude(lastq eq irt{1});  /*only returned baseline 1996Q n=142*/
    *%exclude(id ne ., nodelete=t);
    %exclude(momid ne ., nodelete=t); *8263;
  %output();
  end;

*Follow-up;
  else if time>1 then do;
  	%exclude(irt{time} eq .); * observations if not returning questionnaires 3942;
  	%exclude(0 lt lastq lt irt{time}); 	 *censor lost to follow up ;
  	%exclude(0 lt obyear lt qyear{time} );  *censor observations after becoming OB 291  ;
  	%exclude(bmi{time} eq .); 	   *censor missing bmi 532;
  	%exclude(age{time} gt 18); 	   *censor age>18 3103;
	%exclude(preg{time} eq 1 , skip=T); * skip observations if pregnant 31;
	*%exclude(id ne ., nodelete=t); 
	%exclude(momid ne ., nodelete=t); *28979;
  %output();
  end;
end; *37242;

%endex();

keep id momid cohort white sex ch_birthday birthday  
		bmibpreg gotweight &abwt_ &gweek_ &prev_preg_ 
		&fincome_ incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc &heduc_
		&mosmk_ region agebirth moagebase chpreg
		year chage  chob  chbmi  chbmibase 
		chwest chcal chst chpa  
		moage   mowest  mocal  mopa    mobmi    moshift  ses   
 		fl_notmom96  fl_notmom97 fl_notmom98  fl_not_mom9698 obyear lastq chirt;
run;
proc means data=all1 nolabels n nmiss mean std min median max; run;
proc freq data=all1; table region; run;

/****************************** GUTS 2 ********************************************/
*merge files 1 - many, if no observations for that year then blank;
/* Have to transpose by GUTS 1 and 2 separately, because 04-13 data will be missing for GUTS1 and 96-01 data missing for GUTS2 */
data gutsmoms2;
  merge nhs2_vars(in=a) guts2(in=b);
  by momid;
  if a and b;
proc sort data=gutsmoms2; by id; run;

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
  	
  	if bmibpreg=. then bmibpreg=21.93; *total 5077 not baseline;
  		                        	
 	*maternal age at birth ;
 	agebirth = age89 - (retmo89 /12 - (chyob-1900));
 	
 	moagebase=age03+1; if moagebase=. then moagebase=age89+15;
	age06=age05+1; age08=age07+1;
 		
	if chage06=. then chage06=chage04+2; if chage08=. then chage08=chage06+2;
	if chage11=. then chage11=chage08+3; if chage13=. then chage13=chage11+2;
    if age06=. then age06=moagebase+2; if age08=. then age08=age06+2;
	if age11=. then age11=age08+3; if age13=. then age13=age11+2;
				  	
	gotweight =.; /*  create a variable for gestational weight category which we need for merge because we dont have data for GUTS2 */
	
	sex = natal_sex - 1 ; 
            
    if Comp_Gesdbg=1 or Comp_prghtng=1 or Comp_peclmpg=1 or Delivery=1 then pregcomp=1;
    	else pregcomp=0;  
    if Comp_Gesdbg=1 or Comp_prghtng=1 or Comp_peclmpg=1 then pregcomp2=1;
    	else pregcomp2=0;  
    	
     if Delivery = . then Delivery=1;    
    
    if prev_preg =. then prev_preg=0;                
    %indic3(vbl=prev_preg, reflev=0, missing=., min=1, max=3, prefix=prev_preg, usemiss=0,
            label1='one prev preg', label2='two prev preg', label3='three prev preg');
	
  	%indic3(vbl=bwg, reflev=2, missing=., min=1, max=3, prefix=abwt, usemiss=0,
            label1='<=2.5kg',label3='>=4.5kg');
               
  	%indic3(vbl=gestweek, reflev=2, missing=., min=1, max=3, prefix=gweek, usemiss=0,
            label2='<37',label3='>=43');         
	
  	%indic3(vbl=husbeduc, reflev=3, missing=., min=1, max=2, prefix=heduc, usemiss=0,
            label1='<college',label2='college');   
    
    if incom01 =. then income=.;  *replace missing with median is 7 1748;
    	else if incom01 <=5 then income=1; /*<50000*/
    	else if incom01>5 & incom01<=7 then income=2; /*50000-99000*/
    	else if incom01=8 then income=3; /*100000-149+*/
    	else income=4; /*150+*/
    /*$label 1.less than 15,000; 2.15,000-19; 3.20,000-29; 4.30,000-39; 5.40,000-49;\
        6.50,000-74; 7.75,000-99; 8.100,000-149; 9.150,000+; ..pt */
    %indic3(vbl=income, reflev=4, missing=., min=1, max=3, prefix=fincome, usemiss=0,
            label1='<50k',label2='50-99k',label3='100-149k');   
                	              	
	year04=2004; year06=2006; year08=2008; year11=2011; year13=2013;
	
	chbmibase=chbmi04; 
		
	********** generate time variable indicating OB incident **********************
	********** for subsequent censoring of observations after OB ******************;
	if chob04=1 then obyear=2004; else if chob06=1 then obyear=2006; 
	else if chob08=1 then obyear=2008; else if chob11=1 then obyear=2011;
	else if chob13=1 then obyear=2013;  
					 
/****************************** Transpose wide to long ********************************************/
array irt(5) irt04 irt06 irt08 irt11 irt13;
array ob(5) chob04 chob06 chob08 chob11 chob13;
array bmi(5) chbmi04 chbmi06 chbmi08 chbmi11 chbmi13;
array age(5) chage04 chage06 chage08 chage11 chage13;
array qyear(5) year04 year06 year08 year11 year13;
array wdiet(5) chwest04 chwest06 chwest08 chwest11 chwest11;
array kcal(5) chcal04v chcal06v chcal08v chcal11v chcal11v;
array sed(5) chst04v chst06v chst08v chst11v chst11v;
array pa(5) chpa04v chpa06v chpa08v chpa11v chpa11v;
array preg(5) XXX XXX XXX XXX chpreg13;

array mage(5) moagebase age06 age08 age11 age13;
array mwest(5) f203v f203v f207v f211v f211v;
array mcal(5) calor03n calor03n calor07n calor11n calor11n;
array msmk(5) smk03 smk05 smk07 smk11 smk13;
array mpa(5) act01v act05v act05v act09v act13v;
array mbmi(5) bmi03v bmi05v bmi07v bmi11v bmi13v;
array mshift(5) shi0103v shi0305v shi0305v shi11v shi13v;
array mses(5) nSES_03v nSES_05v nSES_07v nSES_11v nSES_13v;
array location{5} region10_03 region10_05 region10_07 region10_11 region10_13;

/*** If lost to follow-up,     then lastq=last irt. 
 	 If not lost to follow up, then lastq=. ***/  
   do i=1 to dim(irt);
   	if irt{i} >0 then lastq=irt{i};
   end; drop i;
   if lastq=irt{5} then lastq=.;

*replace missing with prior values;
	do i=2 to 5;
		if wdiet(i) = . then  wdiet(i) =  wdiet(i-1); 
		if kcal(i) = .  then  kcal(i)  =  kcal(i-1); 
		if sed(i) = .   then  sed(i) =  sed(i-1); 
		if pa(i) = . then  pa(i) =  pa(i-1); 
		if mwest(i) = . then  mwest(i) =  mwest(i-1); 
		if mcal(i) = . then  mcal(i) =  mcal(i-1); 
		if msmk(i) = . then  msmk(i) =  msmk(i-1); 
		if mpa(i) = . then  mpa(i) =  mpa(i-1); 
		if mshift(i) = . then  mshift(i) =  mshift(i-1); 
		if mses(i) = . then  mses(i) =  mses(i-1); 
		if location(i) = . then  location(i) =  location(i-1); 		
	end;

*DO-LOOP OVER TIME PERIODS;
	%beginex();
	
do time=1 to 5;	
	year=qyear(time); 	       chage =age(time);     	 chob  =ob(time);
	chbmi =bmi(time);          chwest =wdiet(time);     
	chcal =kcal(time);         chst =sed(time);          chpa  =pa(time);          
	chpreg  =preg(time);	   moage =mage(time);	        mowest =mwest(time);
	mocal  =mcal(time);       mosmk  =msmk(time);
	mopa   =mpa(time);         mobmi  =mbmi(time);       moshift  =mshift(time);
	ses  =mses(time);         region = location(time);      chirt = irt{time};
      
    %indic3 (vbl=mosmk, prefix=mosmk, min=2, max=3, reflev=1, missing=., usemiss=0,
      label2='mom past smoking', label3='mom current smoking');

/******************************************************************
  ***************          EXCLUSIONS         *******************
********************************************************************/
*baseline;
if time=1 then do;	
	*%exclude(id ne ., nodelete=t); *10289;
	%exclude(momid ne ., nodelete=t);
    %exclude(exrec eq 1); *exclude those not in GUTS2;
    %exclude(chob eq 1); *baseline ob 510;
	%exclude(chbmi eq .); * baseline bmi missing - should be 0, already excluded; 
	%exclude(bwg eq . or  gestweek eq . or husbeduc eq . or incom01 eq . or bmibpreg eq . or
			 chwest eq . or chcal eq . or chst eq . or chpa eq . or
    		 mowest eq . or mocal eq . or mopa eq . or mobmi eq . or moshift eq . or ses eq . ); *exclude missing exposures 2926;
    %exclude(lastq eq irt{1});  /*only returned baseline 2004Q 651 */
    *%exclude(id ne ., nodelete=t);
    %exclude(momid ne ., nodelete=t); *6202; 
  %output();
  end;

*Follow-up;
  else if time>1 then do;
  	%exclude(irt{time} eq .); * cesnor observations if not returning questionnaires 6272;
  	%exclude(0 lt lastq lt irt{time}); 	 *censor lost to follow up ;
  	%exclude(0 lt obyear lt qyear{time} );  *censor observations after becoming OB  120;
  	%exclude(bmi{time} eq .); 	   *censor missing bmi 1068;
  	%exclude(age{time} gt 18); 	   *censor age>18 2342;
	%exclude(preg{time} eq 1 , skip=T); * skip observations if pregnant  0;
	*%exclude(id ne ., nodelete=t);
	%exclude(momid ne ., nodelete=t); *8584;
  %output();
  end;
end; *14786;

%endex();
 
fl_notmom96=.;  fl_notmom97=.; fl_notmom98=.;   fl_not_mom9698=.;
 
keep id momid cohort white sex ch_birthday birthday  
		bmibpreg gotweight &abwt_ &gweek_ &prev_preg_ 
		&fincome_ incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc &heduc_
		&mosmk_ region agebirth moagebase chpreg
		year chage  chob chbmi  chbmibase 
		chwest chcal chst chpa  
		moage  mowest   mocal  mopa    mobmi    moshift  ses  
 		fl_notmom96  fl_notmom97 fl_notmom98  fl_not_mom9698 obyear lastq chirt;		
run;  
proc means data=all2 nolabels n nmiss mean std min median max; run;
proc freq data=all2; table region; run;

data all; set all1 all2;

	moob=.; if mobmi >= 30 then moob=1; else if mobmi>0 & mobmi<30 then moob=0; 
	bpregob=.; if bmibpreg >= 30 then bpregob=1; else if bmibpreg>0 & bmibpreg<30 then bpregob=0;

run;

proc datasets nolist;
delete nhs2_vars guts1 guts2 gutsmoms1 gutsmoms2 grav09guts1 grav09guts2 bmibpregdt all1 all2;
run;

**********   need to make all exposures to categorical for PAR    ********;
proc rank data=all group=4 out=all; by cohort ;
	var chwest chcal chst chpa mowest mocal mopa moshift ses  ;
	ranks chwestq chcalq chstq chpaq mowestq mocalq mopaq moshiftq sesq  ;
run;

%macro quant_med (data, var, quantvar, quantcont);
proc means data=&data n nmiss median p25 p75;
var &var;
class cohort &quantvar;
output out=stat MEDIAN=&quantcont;
run;
proc sort data=&data; by cohort  &quantvar; run;
proc sort data=stat; by cohort  &quantvar; run;

data &data;
merge &data stat;
by cohort  &quantvar;
if momid = . then delete;
if &var=. then &quantcont=.;
run;
%mend quant_med;

%quant_med (data=all, var=chwest, quantvar=chwestq, quantcont=chwest_m);
%quant_med (data=all, var=chcal, quantvar=chcalq, quantcont=chcal_m);
%quant_med (data=all, var=chst, quantvar=chstq, quantcont=chst_m);
%quant_med (data=all, var=chpa, quantvar=chpaq, quantcont=chpa_m);
%quant_med (data=all, var=mowest, quantvar=mowestq, quantcont=mowest_m);
%quant_med (data=all, var=mocal, quantvar=mocalq, quantcont=mocal_m);
%quant_med (data=all, var=mopa, quantvar=mopaq, quantcont=mopa_m);
%quant_med (data=all, var=moshift, quantvar=moshiftq, quantcont=moshift_m);
%quant_med (data=all, var=ses, quantvar=sesq, quantcont=ses_m);

proc means data=all nolabels n nmiss median std mean min max; run;

proc freq data=all; 
	table gotweight &abwt_ &gweek_ &prev_preg_ &fincome_ incom01 income
		  Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		  husbeduc &mosmk_ chob moob bpregob region;
run;

proc sort data=all out=outhere.allvar_sensi; by id year; run;