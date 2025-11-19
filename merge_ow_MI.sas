/*******************************************************************************
program title: merge_ow_MI.sas
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Yiqing Wang (nhywa)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: 12/2024
1) Purpose: Combine multiple imputed datasets and transform wide to long - secondary outcome OWOB
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

/******************************************************************************
/******************************************************************************/
/******************************************************************************/
/* Have to transpose by GUTS 1 and 2 separately, because 04-13 data will be missing for GUTS1 and 96-01 data missing for GUTS2 */
/****************************** GUTS1 ********************************************/
data all1; 
	set here.all1_mi end=_end_;
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
	
  	%indic3(vbl=husbeduc, reflev=3, missing=., min=1, max=2, prefix=heduc, usemiss=0,
            label1='<college',label2='college');   
            
    if incom01 <=5 then income=1; /*<50000*/
    	else if incom01>5 & incom01<=7 then income=2; /*50000-99000*/
    	else if incom01=8 then income=3; /*100000-149+*/
    	else income=4; /*150+*/
    /*$label 1.less than 15,000; 2.15,000-19; 3.20,000-29; 4.30,000-39; 5.40,000-49;\
        6.50,000-74; 7.75,000-99; 8.100,000-149; 9.150,000+; ..pt */
    %indic3(vbl=income, reflev=4, missing=., min=1, max=3, prefix=fincome, usemiss=0,
            label1='<50k',label2='50-99k',label3='100-149k');   
       
	year96=1996; year97=1997; year98=1998; year99=1999; year00=2000;
	year01=2001; year03=2003; year05=2005;
	
	chbmibase=chbmi96;  
	
	*define missing chob chow based on the multiple imputed chbmipct;
	array age(8) chage96 chage97 chage98 chage99 chage00 chage01 chage03 chage05;
				*8-15,9-17,10-18,11-19,13-20,14-22,16-23,17-25;
	array owob(8) chow96 chow97 chow98 chow99 chow00 chow01 chow03 chow05;
        array bmi(8) chbmi96 chbmi97 chbmi98 chbmi99 chbmi00 chbmi01 chbmi03 chbmi05;
        
        do i=1 to 8;
                if owob{i}=. then do;
                        if age{i}>=8 & age{i}<8.5 & natal_sex=1 & bmi{i}>=18.44 then owob{i} = 1;
                        else if age{i}>=8 & age{i}<8.5 & natal_sex=2 & bmi{i}>=18.35 then owob{i} = 1;
                        else if age{i}>=8.5 & age{i}<9 & natal_sex=1 & bmi{i}>=18.76 then owob{i} = 1;
                        else if age{i}>=8.5 & age{i}<9 & natal_sex=2 & bmi{i}>=18.69 then owob{i} = 1;
                        else if age{i}>=9 & age{i}<9.5 & natal_sex=1 & bmi{i}>=19.10 then owob{i} = 1;
                        else if age{i}>=9 & age{i}<9.5 & natal_sex=2 & bmi{i}>=19.07 then owob{i} = 1;
                        else if age{i}>=9.5 & age{i}<10 & natal_sex=1 & bmi{i}>=19.46 then owob{i} = 1;
                        else if age{i}>=9.5 & age{i}<10 & natal_sex=2 & bmi{i}>=19.45 then owob{i} = 1;
                        else if age{i}>=10 & age{i}<10.5 & natal_sex=1 & bmi{i}>=19.84 then owob{i} = 1;
                        else if age{i}>=10 & age{i}<10.5 & natal_sex=2 & bmi{i}>=19.86 then owob{i} = 1;
                        else if age{i}>=10.5 & age{i}<11 & natal_sex=1 & bmi{i}>=20.2 then owob{i} = 1;
                        else if age{i}>=10.5 & age{i}<11 & natal_sex=2 & bmi{i}>=20.29 then owob{i} = 1;
                        else if age{i}>=11 & age{i}<11.5 & natal_sex=1 & bmi{i}>=20.55 then owob{i} = 1;
                        else if age{i}>=11 & age{i}<11.5 & natal_sex=2 & bmi{i}>=20.74 then owob{i} = 1;
                        else if age{i}>=11.5 & age{i}<12 & natal_sex=1 & bmi{i}>=20.89 then owob{i} = 1;
                        else if age{i}>=11.5 & age{i}<12 & natal_sex=2 & bmi{i}>=21.2 then owob{i} = 1;
                        else if age{i}>=12 & age{i}<12.5 & natal_sex=1 & bmi{i}>=21.22 then owob{i} = 1;
                        else if age{i}>=12 & age{i}<12.5 & natal_sex=2 & bmi{i}>=21.68 then owob{i} = 1;
                        else if age{i}>=12.5 & age{i}<13 & natal_sex=1 & bmi{i}>=21.56 then owob{i} = 1;
                        else if age{i}>=12.5 & age{i}<13 & natal_sex=2 & bmi{i}>=22.14 then owob{i} = 1;
                        else if age{i}>=13 & age{i}<13.5 & natal_sex=1 & bmi{i}>=21.91 then owob{i} = 1;
                        else if age{i}>=13 & age{i}<13.5 & natal_sex=2 & bmi{i}>=22.58 then owob{i} = 1;
                        else if age{i}>=13.5 & age{i}<14 & natal_sex=1 & bmi{i}>=22.27 then owob{i} = 1;
                        else if age{i}>=13.5 & age{i}<14 & natal_sex=2 & bmi{i}>=22.98 then owob{i} = 1;
                        else if age{i}>=14 & age{i}<14.5 & natal_sex=1 & bmi{i}>=22.62 then owob{i} = 1;
                        else if age{i}>=14 & age{i}<14.5 & natal_sex=2 & bmi{i}>=23.34 then owob{i} = 1;
                        else if age{i}>=14.5 & age{i}<15 & natal_sex=1 & bmi{i}>=22.96 then owob{i} = 1;
                        else if age{i}>=14.5 & age{i}<15 & natal_sex=2 & bmi{i}>=23.66 then owob{i} = 1;
                        else if age{i}>=15 & age{i}<15.5 & natal_sex=1 & bmi{i}>=23.29 then owob{i} = 1;
                        else if age{i}>=15 & age{i}<15.5 & natal_sex=2 & bmi{i}>=23.94 then owob{i} = 1;
                        else if age{i}>=15.5 & age{i}<16 & natal_sex=1 & bmi{i}>=23.6 then owob{i} = 1;
                        else if age{i}>=15.5 & age{i}<16 & natal_sex=2 & bmi{i}>=24.17 then owob{i} = 1;
                        else if age{i}>=16 & age{i}<16.5 & natal_sex=1 & bmi{i}>=23.9 then owob{i} = 1;
                        else if age{i}>=16 & age{i}<16.5 & natal_sex=2 & bmi{i}>=24.37 then owob{i} = 1;
                        else if age{i}>=16.5 & age{i}<17 & natal_sex=1 & bmi{i}>=24.19 then owob{i} = 1;
                        else if age{i}>=16.5 & age{i}<17 & natal_sex=2 & bmi{i}>=24.54 then owob{i} = 1;
                        else if age{i}>=17 & age{i}<17.5 & natal_sex=1 & bmi{i}>=24.46 then owob{i} = 1;
                        else if age{i}>=17 & age{i}<17.5 & natal_sex=2 & bmi{i}>=24.7 then owob{i} = 1;
                        else if age{i}>=17.5 & age{i}<18 & natal_sex=1 & bmi{i}>=24.73 then owob{i} = 1;
                        else if age{i}>=17.5 & age{i}<18 & natal_sex=2 & bmi{i}>=24.85 then owob{i} = 1;
                        else if age{i}>=18 & bmi{i}>=25 then owob{i} = 1;
                        else owob{i} = 0;
                end;
	end; drop i;
	   	  
	********** generate time variable indicating OB incident **********************
	********** for subsequent censoring of observations after OB ******************;
        if chow96=1 then owyear=1996;
        else if chow97=1 then owyear=1997; else if chow98=1 then owyear=1998; 
        else if chow99=1 then owyear=1999; else if chow00=1 then owyear=2000;
        else if chow01=1 then owyear=2001; else if chow03=1 then owyear=2003;
        else if chow05=1 then owyear=2005;	
					 
/****************************** Transpose wide to long ********************************************/
array irt(8) irt96 irt97 irt98 irt99 irt00 irt01 irt03 irt05;
array qyear(8) year96 year97 year98 year99 year00 year01 year03 year05;
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
array mid(8) midwest95 midwest97 midwest97 midwest99 midwest99 midwest01 midwest03 midwest05;
array sth(8) south95 south97 south97 south99 south99 south01 south03 south05;
array wst(8) west95 west97 west97 west99 west99 west01 west03 west05;

/*** If lost to follow-up,     then lastq=last irt. 
 	 If not lost to follow up, then lastq=. ***/  
   do i=1 to dim(irt);
   	if irt{i} >0 then lastq=irt{i};
   end; drop i;
   if lastq=irt{8} then lastq=.;

*DO-LOOP OVER TIME PERIODS;
	%beginex();
	
do time=1 to 8;

 	year=qyear(time); 	       chage =age(time);     	 chow  =owob(time);
	chbmi =bmi(time);          chwest =wdiet(time);      chpreg  =preg(time);
	chcal =kcal(time);         chst =sed(time);          chpa  =pa(time);  
	
	moage =mage(time);	       mowest =mwest(time);      mocal  =mcal(time);       
	mosmk  =msmk(time);        mopa   =mpa(time);        mobmi  =mbmi(time);       
	moshift  =mshift(time);
	
	ses  =mses(time);          midwest = mid(time);      south = sth(time);
	west = wst(time);          chirt = irt{time};        
     
       
    %indic3 (vbl=mosmk, prefix=mosmk, min=2, max=3, reflev=1, missing=., usemiss=0,
      label2='mom past smoking', label3='mom current smoking');   

/******************************************************************
  ***************          EXCLUSIONS         *******************
********************************************************************/
*baseline;
if time=1 then do;      *83055;
    %exclude(momid ne ., nodelete=t); *83055;
    %exclude(exrec eq 1); *exclude those not in GUTS1 5;
    %exclude(chow eq 1); *baseline ow 16905;
    %exclude(chbmi eq .); * baseline bmi missing - should be 0, already excluded; 
    *%exclude(lastq eq irt{1});  /*only returned baseline 1996Q 3605*/
    %exclude(momid ne ., nodelete=t); *62540;
  %output();
  end;

*Follow-up;
  else if time>1 then do;
        *%exclude(irt{time} eq .); * no need to censor observations if not returning questionnaires because of imputation x42278;
        *%exclude(0 lt lastq lt irt{time});       *censor lost to follow up ;
        %exclude(0 lt owyear lt qyear{time} );  *censor observations after becoming Ow 14037 ;
        %exclude(bmi{time} eq .);          *censor missing bmi - should be 0;
        %exclude(age{time} gt 18);         *censor age>18 42916;
        %exclude(momid ne ., nodelete=t); *292718;
        %exclude(preg{time} eq 1 , skip=T); * skip observations if pregnant 264;

  %output();
  end;
end; *458005;

%endex();

keep id momid cohort white sex ch_birthday birthday  _imputation_
		bmibpreg gotweight &abwt_ &gweek_ &prev_preg_ 
		&fincome_ incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc &heduc_
		&mosmk_ midwest south west agebirth moagebase chpreg
		year chage  chow  chbmi  chbmibase 
		chwest chcal chst chpa  
		moage   mowest  mocal  mopa    mobmi    moshift  ses   
 		fl_notmom96  fl_notmom97 fl_notmom98  fl_not_mom9698 owyear lastq chirt ;
run;
proc means data=all1 nolabels n nmiss mean std min median max; run;

/****************************** GUTS 2 ********************************************/
data all2; 
	set here.all2_mi end=_end_;
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
	
  %indic3(vbl=husbeduc, reflev=3, missing=., min=1, max=2, prefix=heduc, usemiss=0,
            label1='<college',label2='college');
                        
      if incom01 <=5 then income=1; /*<50000*/
    	else if incom01>5 & incom01<=7 then income=2; /*50000-99000*/
    	else if incom01=8 then income=3; /*100000-149+*/
    	else income=4; /*150+*/
    /*$label 1.less than 15,000; 2.15,000-19; 3.20,000-29; 4.30,000-39; 5.40,000-49;\
        6.50,000-74; 7.75,000-99; 8.100,000-149; 9.150,000+; ..pt */
    %indic3(vbl=income, reflev=4, missing=., min=1, max=3, prefix=fincome, usemiss=0,
            label1='<50k',label2='50-99k',label3='100-149k');   
         	              	
	year04=2004; year06=2006; year08=2008; year11=2011; year13=2013;
	
	chbmibase=chbmi04; 
	
	*define missing chob chow based on the multiple imputed chbmipct;
        array owob(5) chow04 chow06 chow08 chow11 chow13;
        array bmi(5) chbmi04 chbmi06 chbmi08 chbmi11 chbmi13;
        array age(5) chage04 chage06 chage08 chage11 chage13;
	
	do i=1 to 5;
                if owob{i}=. then do;
                        if age{i}>=8 & age{i}<8.5 & natal_sex=1 & bmi{i}>=18.44 then owob{i} = 1;
                        else if age{i}>=8 & age{i}<8.5 & natal_sex=2 & bmi{i}>=18.35 then owob{i} = 1;
                        else if age{i}>=8.5 & age{i}<9 & natal_sex=1 & bmi{i}>=18.76 then owob{i} = 1;
                        else if age{i}>=8.5 & age{i}<9 & natal_sex=2 & bmi{i}>=18.69 then owob{i} = 1;
                        else if age{i}>=9 & age{i}<9.5 & natal_sex=1 & bmi{i}>=19.10 then owob{i} = 1;
                        else if age{i}>=9 & age{i}<9.5 & natal_sex=2 & bmi{i}>=19.07 then owob{i} = 1;
                        else if age{i}>=9.5 & age{i}<10 & natal_sex=1 & bmi{i}>=19.46 then owob{i} = 1;
                        else if age{i}>=9.5 & age{i}<10 & natal_sex=2 & bmi{i}>=19.45 then owob{i} = 1;
                        else if age{i}>=10 & age{i}<10.5 & natal_sex=1 & bmi{i}>=19.84 then owob{i} = 1;
                        else if age{i}>=10 & age{i}<10.5 & natal_sex=2 & bmi{i}>=19.86 then owob{i} = 1;
                        else if age{i}>=10.5 & age{i}<11 & natal_sex=1 & bmi{i}>=20.2 then owob{i} = 1;
                        else if age{i}>=10.5 & age{i}<11 & natal_sex=2 & bmi{i}>=20.29 then owob{i} = 1;
                        else if age{i}>=11 & age{i}<11.5 & natal_sex=1 & bmi{i}>=20.55 then owob{i} = 1;
                        else if age{i}>=11 & age{i}<11.5 & natal_sex=2 & bmi{i}>=20.74 then owob{i} = 1;
                        else if age{i}>=11.5 & age{i}<12 & natal_sex=1 & bmi{i}>=20.89 then owob{i} = 1;
                        else if age{i}>=11.5 & age{i}<12 & natal_sex=2 & bmi{i}>=21.2 then owob{i} = 1;
                        else if age{i}>=12 & age{i}<12.5 & natal_sex=1 & bmi{i}>=21.22 then owob{i} = 1;
                        else if age{i}>=12 & age{i}<12.5 & natal_sex=2 & bmi{i}>=21.68 then owob{i} = 1;
                        else if age{i}>=12.5 & age{i}<13 & natal_sex=1 & bmi{i}>=21.56 then owob{i} = 1;
                        else if age{i}>=12.5 & age{i}<13 & natal_sex=2 & bmi{i}>=22.14 then owob{i} = 1;
                        else if age{i}>=13 & age{i}<13.5 & natal_sex=1 & bmi{i}>=21.91 then owob{i} = 1;
                        else if age{i}>=13 & age{i}<13.5 & natal_sex=2 & bmi{i}>=22.58 then owob{i} = 1;
                        else if age{i}>=13.5 & age{i}<14 & natal_sex=1 & bmi{i}>=22.27 then owob{i} = 1;
                        else if age{i}>=13.5 & age{i}<14 & natal_sex=2 & bmi{i}>=22.98 then owob{i} = 1;
                        else if age{i}>=14 & age{i}<14.5 & natal_sex=1 & bmi{i}>=22.62 then owob{i} = 1;
                        else if age{i}>=14 & age{i}<14.5 & natal_sex=2 & bmi{i}>=23.34 then owob{i} = 1;
                        else if age{i}>=14.5 & age{i}<15 & natal_sex=1 & bmi{i}>=22.96 then owob{i} = 1;
                        else if age{i}>=14.5 & age{i}<15 & natal_sex=2 & bmi{i}>=23.66 then owob{i} = 1;
                        else if age{i}>=15 & age{i}<15.5 & natal_sex=1 & bmi{i}>=23.29 then owob{i} = 1;
                        else if age{i}>=15 & age{i}<15.5 & natal_sex=2 & bmi{i}>=23.94 then owob{i} = 1;
                        else if age{i}>=15.5 & age{i}<16 & natal_sex=1 & bmi{i}>=23.6 then owob{i} = 1;
                        else if age{i}>=15.5 & age{i}<16 & natal_sex=2 & bmi{i}>=24.17 then owob{i} = 1;
                        else if age{i}>=16 & age{i}<16.5 & natal_sex=1 & bmi{i}>=23.9 then owob{i} = 1;
                        else if age{i}>=16 & age{i}<16.5 & natal_sex=2 & bmi{i}>=24.37 then owob{i} = 1;
                        else if age{i}>=16.5 & age{i}<17 & natal_sex=1 & bmi{i}>=24.19 then owob{i} = 1;
                        else if age{i}>=16.5 & age{i}<17 & natal_sex=2 & bmi{i}>=24.54 then owob{i} = 1;
                        else if age{i}>=17 & age{i}<17.5 & natal_sex=1 & bmi{i}>=24.46 then owob{i} = 1;
                        else if age{i}>=17 & age{i}<17.5 & natal_sex=2 & bmi{i}>=24.7 then owob{i} = 1;
                        else if age{i}>=17.5 & age{i}<18 & natal_sex=1 & bmi{i}>=24.73 then owob{i} = 1;
                        else if age{i}>=17.5 & age{i}<18 & natal_sex=2 & bmi{i}>=24.85 then owob{i} = 1;
                        else if age{i}>=18 & bmi{i}>=25 then owob{i} = 1;
                        else owob{i} = 0;
                end;
        end; drop i;
	
	********** generate time variable indicating OB incident **********************
	********** for subsequent censoring of observations after OB ******************;
	if chow04=1 then owyear=2004; else if chow06=1 then owyear=2006; 
        else if chow08=1 then owyear=2008; else if chow11=1 then owyear=2011;
        else if chow13=1 then owyear=2013;  
					 
/****************************** Transpose wide to long ********************************************/
array irt(5) irt04 irt06 irt08 irt11 irt13;
array qyear(5) year04 year06 year08 year11 year13;
array wdiet(5) chwest04 chwest06 chwest08 chwest11 chwest11;
array kcal(5) chcal04v chcal06v chcal08v chcal11v chcal11v;
array sed(5) chst04v chst06v chst08v chst11v chst11v;
array pa(5) chpa04v chpa06v chpa08v chpa11v chpa11v;
array preg(5) XXX XXX XXX XXX chpreg13;

array mage(5) moagebase age06 age08 age11 age13;
array mwest(5) f203v f203v f207v f211v f211v;
array mcal(5) calor03v calor03v calor07v calor11v calor11v;
array msmk(5) smk03 smk05 smk07 smk11 smk13;
array mpa(5) act01v act05v act05v act09v act13v;
array mbmi(5) bmi03v bmi05v bmi07v bmi11v bmi13v;
array mshift(5) shi0103v shi0305v shi07v shi11v shi13v;

array mses(5) nSES_03v nSES_05v nSES_07v nSES_11v nSES_13v;
array regionx(5) region10_03 region10_05 region10_07 region10_11 region10_13;
array mid(5) midwest03 midwest05 midwest07 midwest11 midwest13;
array sth(5) south03 south05 south07 south11 south13;
array wst(5) west03 west05 west07 west11 west13;

/*** If lost to follow-up,     then lastq=last irt. 
 	 If not lost to follow up, then lastq=. ***/  
   do i=1 to dim(irt);
   	if irt{i} >0 then lastq=irt{i};
   end; drop i;
   if lastq=irt{5} then lastq=.;

*DO-LOOP OVER TIME PERIODS;
	%beginex();
	
do time=1 to 5;	

	year=qyear(time); 	       chage =age(time);     	 chow  =owob(time);
	chbmi =bmi(time);          chwest =wdiet(time);      chpreg  =preg(time);
	chcal =kcal(time);         chst =sed(time);          chpa  =pa(time);  
	
	moage =mage(time);	       mowest =mwest(time);      mocal  =mcal(time);       
	mosmk  =msmk(time);        mopa   =mpa(time);        mobmi  =mbmi(time);       
	moshift  =mshift(time);
	
	ses  =mses(time);          midwest = mid(time);      south = sth(time);
	west = wst(time);          chirt = irt{time};       
	
    %indic3 (vbl=mosmk, prefix=mosmk, min=2, max=3, reflev=1, missing=., usemiss=0,
      label2='mom past smoking', label3='mom current smoking');
       
/******************************************************************
  ***************          EXCLUSIONS         *******************
********************************************************************/
*baseline;
if time=1 then do;      
    %exclude(momid ne ., nodelete=t);
    %exclude(exrec eq 1); *exclude those not in GUTS2;
    %exclude(chow eq 1); *baseline ow 11155;
    %exclude(chbmi eq .); * baseline bmi missing - should be 0, already excluded; 
    *%exclude(lastq eq irt{1});  /*only returned baseline 2004Q 4175 */
    %exclude(momid ne ., nodelete=t); *36115;
  %output();
  end;

*Follow-up;
  else if time>1 then do;
        *%exclude(irt{time} eq .); * cesnor observations if not returning questionnaires;
        *%exclude(0 lt lastq lt irt{time});       *censor lost to follow up ;
        %exclude(0 lt owyear lt qyear{time} );  *censor observations after becoming OW 4894 ;
        %exclude(bmi{time} eq .);          *censor missing bmi - should be 0;
        %exclude(age{time} gt 18);         *censor age>18 29815;
        %exclude(momid ne ., nodelete=t); *67926;
        %exclude(preg{time} eq 1 , skip=T); * skip observations if pregnant 0;

  %output();
  end;
end; *129971 ;

%endex();
 
fl_notmom96=.;  fl_notmom97=.; fl_notmom98=.;   fl_not_mom9698=.;
 
keep id momid cohort white sex ch_birthday birthday  _imputation_
		bmibpreg gotweight &abwt_ &gweek_ &prev_preg_ 
		&fincome_ incom01 income
		Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		husbeduc &heduc_
		&mosmk_ midwest south west agebirth moagebase chpreg
		year chage  chow  chbmi  chbmibase 
		chwest chcal chst chpa  
		moage   mowest  mocal  mopa    mobmi    moshift  ses   
 		fl_notmom96  fl_notmom97 fl_notmom98  fl_not_mom9698 owyear lastq chirt;		
run;  
proc means data=all2 nolabels n nmiss mean std min median max; run;

data all; 
	set all1 all2;

	if mobmi >= 25 then moow=1; else moow=0; 
    if bmibpreg >= 25 then bpregow=1; else bpregow=0;
	
run;
proc sql;
   select count(distinct momid) as n_unique_ids
   from all1; 
quit;
proc sql;
   select count(distinct momid) as n_unique_ids
   from all2; 
quit;
proc datasets nolist;
delete all1 all2;
run;

**********   need to make all exposures to categorical for PAR    ********;
proc rank data=all group=4 out=all; by cohort _imputation_;
var chwest chcal chst chpa mowest mocal mopa moshift ses  ;
ranks chwestq chcalq chstq chpaq mowestq mocalq mopaq moshiftq sesq  ;
run;

%macro quant_med (data, var, quantvar, quantcont);
proc means data=&data n nmiss median p25 p75;
var &var;
class cohort _imputation_ &quantvar;
output out=stat MEDIAN=&quantcont;
run;
proc sort data=&data; by cohort  _imputation_ &quantvar; run;
proc sort data=stat; by cohort  _imputation_ &quantvar; run;

data &data;
merge &data stat;
by cohort  _imputation_ &quantvar;
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
/*
proc freq data=all; 
	table gotweight &abwt_ &gweek_ &prev_preg_ &fincome_ incom01 income
		  Comp_Gesdbg Comp_prghtng Comp_peclmpg Delivery pregcomp pregcomp2
		  husbeduc &mosmk_ chow moow bpregow;
run;
*/