/*******************************************************************************
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Yiqing Wang (nhywa)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: 12/2024
1) Purpose: Prepare GUTS1 dataset for analysis
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

*path to physical activity and diet;
libname gpadat '/udd/nhywa/MaternalUPF/data/prepare/pa/';
libname aheiguts '/udd/nhywa/MaternalUPF/data/prepare/diet/';

*Read geographic data prepared by Bethsaida;
*proc import datafile="/udd/n2bca/childhood_obesity/nhs2.spatial.vars.csv"
        out=geo
        dbms=csv
        replace;
*run;
*proc means data=geo; run;

*Read in NHS2 data prepared by Bethsaida;
*%include '/udd/n2bca/childhood_obesity/nhs2_vars.sas';
*proc means data=nhs2_vars; run;

/******************************************************************************
                                GUTS 1
******************************************************************************/

/* Read in variables: ************************************************************************
      ***** bmi id momid birthday and gender *************************************
 */
%gutsder9623 (keep= id momid cohort birthday natal_sex
irt96 irt97 irt98 irt99 irt00 irt01 irt03 irt05 irt07 irt10 irt13 irt14 irt15 irt16 irt19
age96 age97 age98 age99 age00 age01 age03 age05 age07 age10 age13 age14 age15 age16 age19
bmi96 bmi97 bmi98 bmi99 bmi00 bmi01 bmi03 bmi05 bmi07 bmi10 bmi13 bmi14 bmi15 bmi16 bmi19 
ob96 ob97 ob98 ob99 ob00 ob01 ob03 ob05 ob07 ob10 ob13 ob14 ob15 ob16 ob19
bmipct96 bmipct97 bmipct98 bmipct99 bmipct00 bmipct01 bmipct03 bmipct05 bmipct07 bmipct10 bmipct13 bmipct14 bmipct15 bmipct16 bmipct19
bmiz96 bmiz97 bmiz98 bmiz99 bmiz00 bmiz01 bmiz03 bmiz05 bmiz07 bmiz10 bmiz13 bmiz14 bmiz15 bmiz16 bmiz19
ow_ob96 ow_ob97 ow_ob98 ow_ob99 ow_ob00 ow_ob01 ow_ob03 ow_ob05 ow_ob07 ow_ob10 ow_ob13 ow_ob14 ow_ob15 ow_ob16 ow_ob19
);
    if cohort=1 then output;
run;
proc means; 
	var age96 age97 age98 age99 age00 age01 age03 age05 age07
		bmi96 bmi97 bmi98 bmi99 bmi00 bmi01 bmi03 bmi05 bmi07 
		bmipct96 bmipct97 bmipct98 bmipct99 bmipct00 bmipct01 bmipct03 bmipct05 bmipct07 
		bmiz96 bmiz97 bmiz98 bmiz99 bmiz00 bmiz01 bmiz03 bmiz05 bmiz07 ;
run;
proc freq; 
	tables cohort natal_sex ob96 ob97 ob98 ob99 ob00 ob01 ob03 ob05 ob07
			ow_ob96 ow_ob97 ow_ob98 ow_ob99 ow_ob00 ow_ob01 ow_ob03 ow_ob05 ow_ob07;
run;

data gutsder9623;
  set gutsder9623(rename=(birthday=ch_birthday
  age96 = chage96 age97 = chage97 age98 = chage98 age99 = chage99
  age00 = chage00 age01 = chage01 age03 = chage03 age05 = chage05
  age07 = chage07 age10 = chage10 age13 = chage13 age14 = chage14
  age15 = chage15 age16 = chage16 age19 = chage19

  bmi96 = chbmi96 bmi97 = chbmi97 bmi98 = chbmi98 bmi99 = chbmi99
  bmi00 = chbmi00 bmi01 = chbmi01 bmi03 = chbmi03 bmi05 = chbmi05
  bmi07 = chbmi07 bmi10 = chbmi10 bmi13 = chbmi13 bmi14 = chbmi14
  bmi15 = chbmi15 bmi16 = chbmi16 bmi19 = chbmi19

  bmipct96 = chbmipct96 bmipct97 = chbmipct97 bmipct98 = chbmipct98 bmipct99 = chbmipct99
  bmipct00 = chbmipct00 bmipct01 = chbmipct01 bmipct03 = chbmipct03 bmipct05 = chbmipct05
  bmipct07 = chbmipct07 bmipct10 = chbmipct10 bmipct13 = chbmipct13 bmipct14 = chbmipct14
  bmipct15 = chbmipct15 bmipct16 = chbmipct16 bmipct19 = chbmipct19

  bmiz96 = chbmiz96 bmiz97 = chbmiz97 bmiz98 = chbmiz98 bmiz99 = chbmiz99
  bmiz00 = chbmiz00 bmiz01 = chbmiz01 bmiz03 = chbmiz03 bmiz05 = chbmiz05
  bmiz07 = chbmiz07 bmiz10 = chbmiz10 bmiz13 = chbmiz13 bmiz14 = chbmiz14
  bmiz15 = chbmiz15 bmiz16 = chbmiz16 bmiz19 = chbmiz19

  ob96 = chob96 ob97 = chob97 ob98 = chob98 ob99 = chob99
  ob00 = chob00 ob01 = chob01 ob03 = chob03 ob05 = chob05
  ob07 = chob07 ob10 = chob10 ob13 = chob13 ob14 = chob14
  ob15 = chob15 ob16 = chob16 ob19 = chob19

  ow_ob96 = chow96 ow_ob97 = chow97 ow_ob98 = chow98 ow_ob99 = chow99
  ow_ob00 = chow00 ow_ob01 = chow01 ow_ob03 = chow03 ow_ob05 = chow05
  ow_ob07 = chow07 ow_ob10 = chow10 ow_ob13 = chow13 ow_ob14 = chow14
  ow_ob15 = chow15 ow_ob16 = chow16 ow_ob19 = chow19
  ));

  if chbmi96=. then baselinemiss = 1;
  else baselinemiss = 0;
  if chob96 = 1 then baselineob = 1;
  else baselineob=0;
  if chow96 = 1 then baselineow = 1;
  else baselineow=0;
  
  agebs = chage96;

run;
proc sort nodupkey data=gutsder9623;  by id; run;

/* GUTS1 race*/
%dboy9699 (keep = id race_c); /*$label 1.white; 2.black; 3.hispanic; 4.asian; 5.others*/
proc sort; by id; run;
proc freq; table race_c; run;
%dgir9699 (keep = id race_c); 
proc sort; by id; run;
proc freq; table race_c; run;

/* Physical activity from Nerea Martin-Calvo,
/proj/g2wtgs/g2wtg0a/progs/nerea *********************************************/
data paguts96;
  set gpadat.gpa96;
  chpa96=pa96hours;
  chst96=st96hours;
  keep id chpa96 chst96;
  proc sort;  by id;
run;

data paguts97;
  set gpadat.gpa97;
  chpa97=pa97hours;
  chst97=st97hours;
  keep id chpa97 chst97;
  proc sort;    by id;
run;

data paguts98;
  set gpadat.gpa98;
  chpa98=pa98hours;
  chst98=st98hours;
  keep id chpa98 chst98;
  proc sort;  by id;
run;

data paguts99;
  set gpadat.gpa99;
  chpa99=pa99hours;
  chst99=st99hours;
  keep id chpa99 chst99;
  proc sort; by id;
run;

data paguts00;
  set gpadat.gpa00;
  chpa00=pa00hours;
  chst00=st00hours;
  keep id chpa00 chst00;
  proc sort;  by id;
run;

data paguts01;
  set gpadat.gpa01;
  chpa01=pa01hours;
  chst01=st01hours;
  keep id chpa01 chst01;
  proc sort; by id;
run;

data paguts05;
  set gpadat.gpa05;
  chpa05=pa05hours;
  chst05=st05hours;
  keep id chpa05 chst05;
  proc sort;  by id;
run;

data paguts;
  merge paguts96 paguts97 paguts98 paguts99 paguts00 paguts01 paguts05 ;
  by id;

   %cumavg(cycle=7, cyclevar=2,
        varin =chpa96 chst96 chpa97 chst97 chpa98 chst98 chpa99 chst99 chpa00 chst00 chpa01 chst01 chpa05 chst05 ,
        varout=chpa96v chst96v chpa97v chst97v chpa98v chst98v chpa99v chst99v chpa00v chst00v chpa01v chst01v chpa05v chst05v );

array pa {*} chpa96 chpa97 chpa98 chpa99 chpa00 chpa01 chpa05 ;
array par {*} chpa96r chpa97r chpa98r chpa99r chpa00r chpa01r chpa05r ; /*BCAR to make a copy of the original pre carry forward*/
array pav {*} chpa96v chpa97v chpa98v chpa99v chpa00v chpa01v chpa05v ;
array st {*} chst96 chst97 chst98 chst99 chst00 chst01 chst05 ;
array str {*} chst96r chst97r chst98r chst99r chst00r chst01r chst05r ;/*BCAR to make a copy of the original pre carry forward*/
array stv {*} chst96v chst97v chst98v chst99v chst00v chst01v chst05v ;
 
  do i=1 to dim(pa);
		par{i}=pa{i}; 
		str{i}=st{i}; 
	end; drop i; 

	do i=2 to 7;
		if pa{i}=. then pa{i}=pa{i-1};
		if pav{i}=. then pav{i}=pav{i-1};
		if st{i}=. then st{i}=st{i-1};
		if stv{i}=. then stv{i}=stv{i-1};
	end; drop i; 


run;

proc means data=paguts; run;
/* replace missings with mean */
*proc standard data=paguts out=pagutsnomiss replace print;
proc sort nodupkey data=paguts;  by id;

/* AHEI Score without alcohol by Manar AlJazzaf ******************************/
data ahei1boy; set aheiguts.boysg1diet;
data ahei1girl; set aheiguts.girlsg1diet;

proc sort data=ahei1boy; by id; run;
proc sort data=ahei1girl; by id; run;

data ahei;
  set ahei1boy ahei1girl;

  chdiet96=ahei96; chdiet97=ahei97; chdiet98=ahei98; chdiet01=ahei01;

  %cumavg(cycle=4, cyclevar=1,
        varin =chdiet96 chdiet97 chdiet98 chdiet01,
        varout=chdiet96v chdiet97v chdiet98v chdiet01v);

array aheiarray {*} chdiet96 chdiet97 chdiet98 chdiet01;
array aheivarray {*} chdiet96v chdiet97v chdiet98v chdiet01v;

do i=2 to 4;
if aheiarray{i}=. then aheiarray{i}=aheiarray{i-1};
if aheivarray{i}=. then aheivarray{i}=aheivarray{i-1};
end;
keep id chdiet96 chdiet97 chdiet98 chdiet01 chdiet96v chdiet97v chdiet98v chdiet01v;
run;

/* replace missings with mean*/
*proc standard data=ahei out=aheigutsnomiss replace print;
proc sort nodupkey data=ahei;  by id;

/* GUTS western *****************************************************************/
data boy1western; set here.boywestern1; 
	*boy f296 f297 f198 f101 f204 f206 f208 f111 western was not always not second factor;
	 %cumavg(cycle=4, cyclevar=1,
        varin = f296     f297     f198     f101   ,
        varout= chwest96 chwest97 chwest98 chwest01  );


	chwest_96=f296; 
	chwest_97=f297;
	chwest_98=f198;  
	chwest_01=f101; /*BCAR updated code to keep time-varying values ; note using the original values with carryforward*/
	
	chwest96r=f296r; 
	chwest97r=f297r;
	chwest98r=f198r;  
	chwest01r=f101r; /*BCAR updated code to keep time-varying values ; note using the original values, not with carryforward*/
	
	keep id chwest96 chwest97 chwest98 chwest01 chwest_96 chwest_97 chwest_98 chwest_01
			chwest96r chwest97r chwest98r chwest01r;

proc sort; by id; run;



data girl1western; set here.girlwestern1; 
	*girls f296 f297 f198 f201 f204 f206 f208 f111;
	%cumavg(cycle=4, cyclevar=1,
        varin = f296     f297     f198     f201  ,
        varout= chwest96 chwest97 chwest98 chwest01  );
	
	chwest_96=f296; 
	chwest_97=f297;
	chwest_98=f198;  
	chwest_01=f201; /*BCAR updated code to keep time-varying values ; using the original values, with carryforward*/
	
	chwest96r=f296r; 
	chwest97r=f297r;
	chwest98r=f198r;  
	chwest01r=f201r; /*BCAR updated code to keep time-varying values ; note using the original values, not with carryforward*/
	
	keep id chwest96 chwest97 chwest98 chwest01 chwest_96 chwest_97 chwest_98 chwest_01 
			chwest96r chwest97r chwest98r chwest01r;

proc sort; by id; run;

data western;
	set boy1western girl1western;
run;


/* replace missings with mean*/
*proc standard data=upfguts out=upfgutsnomiss replace print;
proc sort nodupkey data=western;  by id;

/* total enery intake********************************************************/
*girls;
%g1g96_nts(keep = id calor96n); %g1g97_nts(keep = id calor97n);
%g1g98_nts(keep = id calor98n); %g1g01_nts(keep = id calor01n); 
*boys;
%g1b96_nts(keep = id calor96n); %g1b97_nts(keep = id calor97n);
%g1b98_nts(keep = id calor98n); %g1b01_nts(keep = id calor01n); 

data calgutsg;
  merge g1g96_nts g1g97_nts g1g98_nts g1g01_nts;
  by id;
run;
data calgutsb;
  merge g1b96_nts g1b97_nts g1b98_nts g1b01_nts;
  by id;
run;

data calguts;
  set calgutsg calgutsb;

  chcal96=calor96n; chcal97=calor97n;
  chcal98=calor98n; chcal01=calor01n;

 %cumavg(cycle=4, cyclevar=1,
        varin =chcal96 chcal97 chcal98 chcal01,
        varout=chcal96v chcal97v chcal98v chcal01v);

array cal {*} chcal96 chcal97 chcal98 chcal01;
array calv {*} chcal96v chcal97v chcal98v chcal01v;

	do i=2 to 4;
		if cal{i}=. then cal{i}=cal{i-1};
		if calv{i}=. then calv{i}=calv{i-1};
	end;

keep id chcal96 chcal97 chcal98 chcal01 chcal96v chcal97v chcal98v chcal01v;
run;
/* if still missing, replace missings with mean*/
*proc standard data=calguts out=calgutsnomiss replace print;
proc sort nodupkey data=calguts; by id;

/* Boys: living with mother & cig & alcohol & ED */
%boys96(keep = id momid mothr96b q7pt96b yob96b cohort
				cig96b /*1.yes 2.no 3.pt*/ beer96b wine96b liq96b 
				/* 1.never or <1/mo 2.1-3/mo 3.1/wk 4.1+/wk 5.pt */
				wtdo96b vomit96b laxat96b fast96b binge96b outof96b );
	cohort=1; 
data boys96; set boys96;
  rename yob96b = chyob;
  if cig96b = 1 then chcig96=1; else chcig96=0;
  if (beer96b >1 and beer96b <5) or (wine96b >1 and wine96b <5) or (liq96b >1 and liq96b <5) 
  	then chalc96=1; else chalc96=0;  
  	
run;
proc sort nodupkey data = boys96; by id; run; 

%boys97(keep = id momid mothr97b q4pt97b
				cig97b beer97b wine97b liq97b
				/*1.never/<1/mo 2.1-3/mo 3.1/wk 4.2-6/wk 5.7 or more/wk 6.pt */
				wtdo97b vomit97b laxat97b fast97b binge97b outof97b);
data boys97; set boys97;
  if cig97b = 1 then chcig97=1; else chcig97=0;
  if (beer97b >1 and beer97b <6) or (wine97b >1 and wine97b <6) or (liq97b >1 and liq97b <6) 
  	then chalc97=1; else chalc97=0; 
  	
  	in97=1;
run;
proc sort nodupkey data = boys97; by id; run; 

%boys98(keep = id momid mothr98b q4pt98b bosch98b misch98b
				ecig98b cig98b /*1.no 2.yes 3.pt */ beer98b wine98b liq98b);
data boys98; set boys98;
  if ecig98b=2 or cig98b=2 then chcig98=1; else chcig98=0;
  if (beer98b >1 and beer98b <6) or (wine98b >1 and wine98b <6) or (liq98b >1 and liq98b <6) 
  	then chalc98=1; else chalc98=0; 
  	in98=1;
run;
proc sort nodupkey data = boys98; by id; run;

%boys99(keep=  id momid bosch99b misch99b ecig99b cig99b  /*1.no 2.yes 3.pt*/ 
				alc99b /*1.yes 2.no 3.pt*/
				wtdo99b vomit99b laxat99b binge99b outof99b 
				sleep99b /*1.<5 2.5 3.6 4.7 5.8 6.9 7.10 8.11+ 9.pt*/);
data boys99; set boys99;
  if ecig99b=2 or cig99b=2 then chcig99=1; else chcig99=0;
  if alc99b=1 then chalc99=1; else chalc99=0;
  if sleep99b=1 then sleep99=4; 
  	else if sleep99b=2 then sleep99=5; 
  	else if sleep99b=3 then sleep99=6;
  	else if sleep99b=4 then sleep99=7;
  	else if sleep99b=5 then sleep99=8;
  	else if sleep99b=6 then sleep99=9;
  	else if sleep99b=7 then sleep99=10;
  	else if sleep99b=8 then sleep99=11;
  	else sleep99=.;       
run;
proc sort nodupkey data = boys99; by id; run;

%boys00(keep = id alc00b /*1.yes 2.no 3.pt*/ cig00b /*1.yes 2.no 3.p*/
				binge00b /*1.never 2.couple times 3.<1/month 4.1-3/month 5.1/wk 6.>1/wk 7.pt */
        		laxat00b /*1.never 2.<1/mo 3.1-3/mo 4.1/wk 5.2-6/wk 6.daily 7.pt*/
				outof00b /*1.yes 2.no 3.pt*/ );
data boys00; set boys00;
  if cig00b=1 then chcig00=1; else chcig00=0;
  if alc00b=1 then chalc00=1; else chalc00=0; 
run;
proc sort nodupkey data = boys00; by id; run;

%boys01(keep = id ecig01b cig01b /*1.no 2.yes 3.pt */
				alc01b /*1.yes 2.no 3.pt*/
				wtdes01b wtdo01b p6q3p01b fast01b vomit01b laxat01b volax01b 
			    binge01b bin3m01b p7q9p01b outof01b 
			    sleep01b /*1.<5 2.5 3.6 4.7 5.8 6.9 7.10 8.11+ 9.pt*/);
data boys01; set boys01;
  if ecig01b=2 or cig01b=2 then chcig01=1; else chcig01=0;
  if alc01b=1 then chalc01=1; else chalc01=0; 
  if sleep01b=1 then sleep01=4; 
  	else if sleep01b=2 then sleep01=5; 
  	else if sleep01b=3 then sleep01=6;
  	else if sleep01b=4 then sleep01=7;
  	else if sleep01b=5 then sleep01=8;
  	else if sleep01b=6 then sleep01=9;
  	else if sleep01b=7 then sleep01=10;
  	else if sleep01b=8 then sleep01=11;
  	else sleep01=.;   
run;
proc sort nodupkey data = boys01; by id; run;

%boys03(keep= id cig03b /*1.no 2.yes 3.pt */ alc03b /*1.yes 2.no 3.pt*/
				 wtdes03b wtdop03b wtdo03b fast03b vomit03b laxat03b volax03b
		         binpt03b binge03b bin3m03b qbinp03b outof03b);
data boys03; set boys03;
  if cig03b=2 then chcig03=1; else chcig03=0;
  if alc03b=1 then chalc03=1; else chalc03=0; 
run;
proc sort nodupkey data = boys03; by id; run;

%boys05(keep= id cig05b /*1.no 2.yes 3.pt */ aalc05b 
		/*1.dont drink 2.<1/month 3.<1/week 4.1-2days/wk 5.3-5days/wk 6.almost daily 7.daily 8.pt*/
		wtdes05b wtdo05b tlose05b fast05b vomit05b laxat05b volax05b
			        binge05b binpt05b bin3m05b outof05b);
data boys05; set boys05;
  if cig05b=2 then chcig05=1; else chcig05=0;
  if aalc05b>1 and aalc05b<8 then chalc05=1; else chalc05=0; 
run;
proc sort nodupkey data = boys05; by id; run;

data boys;
  merge boys96 boys97 boys98 boys99 boys01 boys03 boys05;
  by id;
  sex=1;
  chmens96=0; chmens97=0; chmens98=0; chmens99=0; chmens01=0; chmens03=0;
run;
proc freq data=boys;
	table sleep99 sleep01;
run;

/* Girls: living with mother & menstral cycle & pregnancy & cig & alcohol & ED */
%girls96(keep = id momid mothr96g q8pt96g yob96g
				menst96g menar96g /* 1.yes 2.no 3.pt 
				1.dont remember 2.<9 3.9 4.10 5.11 6.12 7.13 8.14 9.15 or older 10.pt */
				/*smoking and alcohol*/ 
				cig96g /*1.yes 2.no 3.pt*/ c10096g
				beer96g wine96g liq96g /* 1.never/<1/mo 2.1-3/mo 3.1/wk 4.+1/wk 5.pt*/ cohort
				Wtdo96g Vomit96g Laxat96g Fast96g Binge96g Outof96g );
				cohort=1; 
data girls96; set girls96;
  rename  yob96g = chyob;
  if menst96g ne 1 then chmens96=0; 
  	else if menar96g in (2,3,4,5,6) then chmens96=1; /*<13 y*/
  	else if menar96g = 7 then chmens96=2; /*13 y*/
  	else if menar96g in (8,9) then chmens96=3; /*14+ y*/
  	else chmens96=.; /*unknown age*/  
  if cig96g=1 then chcig96=1; else chcig96=0;
  if (beer96g>1 and beer96g<5) or (wine96g>1 and wine96g<5) or (liq96g>1 and liq96g<5) 
  			then chalc96=1; else chalc96=0;
run;
proc sort nodupkey data = girls96; by id; run; 

%girls97(keep = id momid mothr97g q6pt97g
				menst97g menar97g /* 1.yes 2.no 3.pt 
				1.dont remember 2.<9 3.9 4.10 5.11 6.12 7.13 8.14 9.15 or older 10.pt */
				cig97g /*1.yes 2.no 3.pt*/ beer97g wine97g liq97g 
				/*1.never/<1/mo 2.1-3/mo 3.1/wk 4.2-6/wk 5.7 or more/wk 6.pt */
				Wtdo97g Vomit97g Laxat97g Fast97g Binge97g Outof97g );
data girls97; set girls97;
  if menst97g ne 1 then chmens97=0; 
  	else if menar97g in (2,3,4,5,6) then chmens97=1; /*<13 y*/
  	else if menar97g = 7 then chmens97=2; /*13 y*/
  	else if menar97g in (8,9) then chmens97=3; /*14+ y*/
  	else chmens97=.; /*unknown age*/  
  if cig97g=1 then chcig97=1; else chcig97=0;
  if (beer97g>1 and beer97g<6) or (wine97g>1 and wine97g<6) or (liq97g>1 and liq97g<6) 
  			then chalc97=1; else chalc97=0; 		
  	in97=1;
run;
proc sort nodupkey data = girls97; by id; run; 

%girls98(keep = id momid mothr98g q4pt98g bosch98g misch98g
				menst98g menar98g /*1.dont remember 2.<9 3.9 4.10 5.11 6.12 7.13 8.14 9.15 or older 10.pt*/
				ecig98g /* ever 1.no 2.yes 3.pt*/ cig98g /*past year 1.no 2.yes 3.pt*/
				beer98g wine98g liq98g /*1.never/<1/mo 2.1-3/mo 3.1/wk 4.2-6/wk 5.7 or more/wk 6.pt */ );
data girls98; set girls98;
  if menst98g ne 1 then chmens98=0; 
  	else if menar98g in (2,3,4,5,6) then chmens98=1; /*<13 y*/
  	else if menar98g = 7 then chmens98=2; /*13 y*/
  	else if menar98g in (8,9) then chmens98=3; /*14+ y*/
  	else chmens98=.; /*unknown age*/  
  if ecig98g=2 or cig98g=2 then chcig98=1; else chcig98=0;
  if (beer98g>1 and beer98g<6) or (wine98g>1 and wine98g<6) or (liq98g>1 and liq98g<6) 
  			then chalc98=1; else chalc98=0; 
  in98=1;
run;
proc sort nodupkey data = girls98; by id; run; 

%girls99(keep = id momid bosch99g misch99g
				menst99g menar99g /* 1.don't know 2.<10 3.10 4.11 5.12 6.13 7.14 8.15 9.16+ 10.pt */
				ecig99g cig99g alc99g /* ever 1.yes 2.no 3.pt */
				wtdo99g vomit99g laxat99g binge99g outof99g 
				sleep99g /*1.<5 2.5 3.6 4.7 5.8 6.9 7.10 8.11+ 9.pt*/ );
data girls99; set girls99;
	if menst99g ne 1 then chmens99=0; 
  	else if menar99g in (2,3,4,5) then chmens99=1; /*<13 y*/
  	else if menar99g in (6,7) then chmens99=2; /*13,14 y*/
  	else if menar99g in (8,9) then chmens99=3; /*15+ y*/
  	else chmens99=.; /*unknown age*/  
	if ecig99g=2 or cig99g=2 then chcig99=1; else chcig99=0;
	if alc99g=1 then chalc99=1; else chalc99=0;	
	if sleep99g=1 then sleep99=4; 
  	else if sleep99g=2 then sleep99=5; 
  	else if sleep99g=3 then sleep99=6;
  	else if sleep99g=4 then sleep99=7;
  	else if sleep99g=5 then sleep99=8;
  	else if sleep99g=6 then sleep99=9;
  	else if sleep99g=7 then sleep99=10;
  	else if sleep99g=8 then sleep99=11;
  	else sleep99=.;   
run;
proc sort nodupkey data = girls99; by id; run; 

%girls00(keep = id alc00g /*1.yes 2.no 3.pt*/ cig00g /*1.yes 2.no 3.p*/
				binge00g /*1.never 2.couple times 3.<1/month 4.1-3/month 5.1/wk 6.>1/wk 7.pt */
        		laxat00g /*1.never 2.<1/mo 3.1-3/mo 4.1/wk 5.2-6/wk 6.daily 7.pt*/
				outof00g /*1.yes 2.no 3.pt*/ 
				menst00g /*1.yes, in last 2 yrs 2.yes, 2+ years 3.no 4.pt*/
				menar00g /*1.<13 2.13 3.14 4.15 5.16 6.17 7.18+ 8.pt */);
data girls00; set girls00;
  if cig00g=1 then chcig00=1; else chcig00=0;
  if alc00g=1 then chalc00=1; else chalc00=0; 

	if menst00g =3 then chmens00=0;
  		else if menar00g =1 then chmens00=1; /*<13 y*/
  		else if menar00g = 2 then chmens00=2; /*13 y*/
    	else if menar00g in (3,4,5,6,7) then chmens00=3; /*14+ y*/
  		else chmens00=.; /*unknown age*/ 
run;
proc sort nodupkey data = girls00; by id; run;

%girls01(keep = id menst01g /* 1.yes in last2yrs 2.yes more than 2yrs 3.no 4.pt */
				menar01g /* 1.< age 13 2.13 3.14 4.15 5.16 6.17 7.18+  8.pt */
				ecig01g cig01g beer01g wine01g liq01g 
				/*1.never/<1/mo 2.1-3/mo 3.1/wk 4.2-4/wk 5.5-6\wk 6.1/day 7.2-3/day 8.+3/day 9.pt */
				preg01g /*1.no 2.yes, currently 3.yes in past yr 4.don't know 5.pt */ 
				wtdes01g wtdo01g p6q3p01g fast01g vomit01g laxat01g volax01g 
			    binge01g bin3m01g p7q9p01g outof01g 
			    sleep01g /*1.<5 2.5 3.6 4.7 5.8 6.9 7.10 8.11+ 9.pt*/ );
data girls01; set girls01;
  if menst01g =3 then chmens01=0;
  	else if menar01g =1 then chmens01=1; /*<13 y*/
  	else if menar01g = 2 then chmens01=2; /*13 y*/
    else if menar01g in (3,4,5,6,7) then chmens01=3; /*14+ y*/
  	else chmens01=.; /*unknown age*/ 
  if ecig01g=2 or cig01g=2 then chcig01=1; else chcig01=0;
  if (beer01g>1 and beer01g<9) or (wine01g>1 and wine01g<9) or (liq01g>1 and liq01g<9) 
  			then chalc01=1; else chalc01=0; 
  if preg01g in (2,3) then chpreg01=1; else chpreg01=0;
  if sleep01g=1 then sleep01=4; 
  	else if sleep01g=2 then sleep01=5; 
  	else if sleep01g=3 then sleep01=6;
  	else if sleep01g=4 then sleep01=7;
  	else if sleep01g=5 then sleep01=8;
  	else if sleep01g=6 then sleep01=9;
  	else if sleep01g=7 then sleep01=10;
  	else if sleep01g=8 then sleep01=11;
  	else sleep01=.;   
run;
proc sort nodupkey data = girls01; by id; run; 

%girls03(keep = id preg03g /*1.yes 2.no 3.pt*/ cig03g alc03g /*1.yes 2.no 3.pt*/
				 wtdes03g wtdop03g wtdo03g fast03g vomit03g laxat03g volax03g
		         binpt03g binge03g bin3m03g qbinp03g outof03g
			     menar03g /*01.<10 yrs 02.10 03.11 04.12 05.13 06.14 07.15 08.16 09.17+ 10.not yet 11.pt */) ;
data girls03; set girls03;
	if preg03g=1 then chpreg03=1; else chpreg03=0;
	if cig03g=2 then chcig03=1; else chcig03=0;
	if alc03g=1 then chalc03=1; else chalc03=0;
	if menar03g=10 then chmens03=0;
		else if menar03g in (1,2,3,4) then chmens03=1; /*<13 y*/
		else if menar03g = 5 then chmens03=2; /*13 y*/
		else if menar03g in (6,7,8,9) then chmens03=3; /*14+ y*/
		else chmens03=.; /*unknown age*/
run;
proc sort nodupkey data = girls03; by id; run; 

%girls05(keep = id cig05g prgbf05g /*preg past year1.no 2.yes 3.pt*/ 
					aalc05g /*1.dont drink 2.<1/month 3.<1/week  4.1-2days/wk 5.3-5days/wk 6.almost daily 7.daily 8.pt */
					wtdes05g wtdo05g tlose05g fast05g vomit05g laxat05g volax05g 
			        binge05g binpt05g bin3m05g outof05g) ;
data girls05; set girls05;
	if prgbf05g=2 then chpreg05=1; else chpreg05=0;
	if cig05g=2 then chcig05=1; else chcig05=0;
	if aalc05g >1 and aalc05g<8 then chalc05=1; else chalc05=0;
run;
proc sort nodupkey data = girls05; by id; run; 

data girls;
  merge girls96 girls97 girls98 girls99 girls01 girls03 girls05;
  by id;
  sex=2;
run;
proc freq data=girls;
	table sleep99 sleep01;
run;

data boygirl;
  set boys girls;
run; 
proc sort nodupkey data=boygirl;  by id; run;

/* Merge variables for GUTS 1 ************************************************/
data guts1;
  merge gutsder9623(in=A) paguts calguts ahei western boygirl
  		dboy9699 dgir9699;
  by id;
  if A and cohort = 1 ;
  if ch_birthday=. then delete;
  
  if race_c=1 then white=1; 
	else white=0;
  
  chyob = chyob+1900;
  
	  /***************************
		Variable for Ever Reported not living with mom
		GUTS1:	reporting living with mother in 1996,1997,1998 
		reporting attending military or boarding school in 1998 or 1999
		fl_not_mom9698 = 1 means ever indicated not living with mom
	  **************************/  
	  mothr96 = max(of mothr96g mothr96b); 
	  mom96_pt = max(of q8pt96g q7pt96b);
	  mothr97 = max(of mothr97g mothr97b); 
	  mom97_pt = max(of q6pt97g q4pt97b);
	  mothr98 = max(of mothr98g mothr98b); 
	  mom98_pt = max(of q4pt98b q4pt98g);

	*if they reported living with anyone other then mom, flag them;
	if mothr96 = 1 or mom96_pt = 1 then fl_notmom96 = 0; else fl_notmom96 = 1;
			if in97 = 1 then do;
	if mothr97 = 1 or mom97_pt = 1 then fl_notmom97 = 0; else fl_notmom97 = 1; end;
			if in98 = 1 then do;
	if mothr98 = 1 or mom98_pt = 1 then fl_notmom98 = 0; else fl_notmom98 = 1; end;

	if fl_notmom96 = 1 or fl_notmom97 = 1 or fl_notmom98 = 1 then fl_not_mom9698 = 1;
	/************************
	Code military or boarding school GUTS1 - if fl_sch98 =1 or fl_sch99=1 then exclude for school
	************************/
	fl_sch98 = max(of bosch98g bosch98b misch98b misch98g); /*1 if they attended mil/board school*/
	fl_sch99 = max(of bosch99g bosch99b misch99b misch99g); /*1 if they attended mil/board school*/
 
	/***** if ever smoked or alcohol *****/
	array cig(*) chcig96 chcig97 chcig98 chcig99 chcig00 chcig01 chcig03 chcig05;
	array alc(*) chalc96 chalc97 chalc98 chalc99 chalc00 chalc01 chalc03 chalc05;
	array mens(*) chmens96 chmens97 chmens98 chmens99 chmens00 chmens01 chmens03 chmens03;
	
	do i=2 to dim(cig);
    	if cig{i}=. then cig{i}=cig{i-1};
    	if alc{i}=. then alc{i}=alc{i-1};
    	if mens{i}=. then mens{i}=mens{i-1};
    end; drop i;

	if sleep01=. & sleep99 ne . then sleep01=sleep99;
 	
run;
proc sort data=guts1; by momid; run;

    proc freq data=guts1;
		tables mothr96 mom96_pt mothr97 mom97_pt mothr98 mom98_pt
			fl_notmom96  fl_notmom97 fl_notmom98  fl_not_mom9698 / list missing;
	run;
*proc means data=guts1;  


proc datasets nolist;
delete gutsder9623 paguts96 paguts97 paguts98 paguts99 paguts00 paguts01 paguts05 
		ahei1boy ahei1girl calgutsb calgutsg boy1western  girl1western
		g1g96_nts g1g97_nts g1g98_nts g1g01_nts g1b96_nts g1b97_nts g1b98_nts g1b01_nts
		boys96 boys97 boys98 boys01 boys03 boys05 girls96 girls97 girls98 girls01 girls03 girls05
      paguts calguts ahei western  boygirl;
run;

