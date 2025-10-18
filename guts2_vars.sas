/*******************************************************************************
Title: Transgenerational, personal, and social determinants of overweight and obesity during childhood and adolescence 
Programmer: Yiqing Wang (nhywa)
Template: Klodian Dhana /udd/nhkld/guts/proj2/imputed/5mi/program/  Jie Chen /proj/nhairs/nhair2q/progs/env_htn/
Preparation date: 12/2024
1) Purpose: Prepare GUTS2 dataset for analysis
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
                                GUTS 2
******************************************************************************/

/* BMI ************************************************************************
    ******** id momid birthday and gender for adjusting *********************
 */
%gutsder9623 (keep= irt04 irt06 irt08 irt11 irt13 irt14 irt15 irt16 irt19 birthday
id momid cohort birthday natal_sex   
age04 age06 age08 age11 age13 age14 age15 age16 age19
bmi04 bmi06 bmi08 bmi11 bmi13 bmi14 bmi15 bmi16 bmi19        
ob04 ob06 ob08 ob11 ob13 ob14 ob15 ob16 ob19
bmipct04 bmipct06 bmipct08 bmipct11 bmipct13 bmipct14 bmipct15 bmipct16 bmipct19
bmiz04 bmiz06 bmiz08 bmiz11 bmiz13 bmiz14 bmiz15 bmiz16 bmiz19
ow_ob04 ow_ob06 ow_ob08 ow_ob11 ow_ob13 ow_ob14 ow_ob15 ow_ob16 ow_ob19);
/* there are few children who have same age in 2 subsequent visits the code below fix it */
  if age04=age06 then age06=age04+2;   if age06=age08 then age08=age06+2;
  if age08=age11 then age11=age08+3;   if age11=age13 then age13=age11+2;
  if age13=age14 then age14=age13+1;   if age14=age15 then age15=age14+1;
  if age15=age16 then age16=age15+1;   if age16=age19 then age19=age16+3;

  if cohort=2 then output;
run;
proc means; 
	var age04 age06 age08 age11 age13 age14 age15 age16 age19
		bmi04 bmi06 bmi08 bmi11 bmi13 bmi14 bmi15 bmi16 bmi19 
		bmipct04 bmipct06 bmipct08 bmipct11 bmipct13 bmipct14 bmipct15 bmipct16 bmipct19
		bmiz04 bmiz06 bmiz08 bmiz11 bmiz13 bmiz14 bmiz15 bmiz16 bmiz19 ;
run;
proc freq; 
	tables cohort natal_sex ob04 ob06 ob08 ob11 ob13 ob14 ob15 ob16 ob19
			ow_ob04 ow_ob06 ow_ob08 ow_ob11 ow_ob13 ow_ob14 ow_ob15 ow_ob16 ow_ob19;
run;

data gutsder9623;
  set gutsder9623 (rename=(birthday=ch_birthday
age04 = chage04 age06 = chage06 age08 = chage08 age11 = chage11 age13 = chage13
age14 = chage14 age15 = chage15 age16 = chage16 age19 = chage19
bmi04 = chbmi04 bmi06 = chbmi06 bmi08 = chbmi08 bmi11 = chbmi11 bmi13 = chbmi13
bmi14 = chbmi14 bmi15 = chbmi15 bmi16 = chbmi16 bmi19 = chbmi19
bmipct04 = chbmipct04 bmipct06 = chbmipct06 bmipct08 = chbmipct08 bmipct11 = chbmipct11 bmipct13 = chbmipct13
bmipct14 = chbmipct14 bmipct15 = chbmipct15 bmipct16 = chbmipct16 bmipct19 = chbmipct19
bmiz04 = chbmiz04 bmiz06 = chbmiz06 bmiz08 = chbmiz08 bmiz11 = chbmiz11 bmiz13 = chbmiz13
bmiz14 = chbmiz14 bmiz15 = chbmiz15 bmiz16 = chbmiz16 bmiz19 = chbmiz19
ob04 = chob04 ob06 = chob06 ob08 = chob08 ob11 = chob11 ob13 = chob13
ob14 = chob14 ob15 = chob15 ob16 = chob16 ob19 = chob19
ow_ob04 = chow04 ow_ob06 = chow06 ow_ob08 = chow08 ow_ob11 = chow11 ow_ob13 = chow13
ow_ob14 = chow14 ow_ob15 = chow15 ow_ob16 = chow16 ow_ob19 = chow19)
  );

  birth_year=ch_birthday/12;
  conception=ch_birthday - 38/4;

  array irt{9} irt04 irt06 irt08 irt11 irt13 irt14 irt15 irt16 irt19;
	array chage{9} chage04 chage06 chage08 chage11 chage13 chage14 chage15 chage16 chage19;
  
  do i=1 to 9;
  if chage{i}=. then chage{i}=(irt{i}-ch_birthday)/12;
	end; drop i;
    if chage06=. then chage06=chage04+2; if chage08=. then chage08=chage06+2;
    if chage11=. then chage11=chage08+3; if chage13=. then chage13=chage11+2;
	if chage14=. then chage14=chage13+1; if chage15=. then chage15=chage14+1;
	if chage16=. then chage16=chage15+1; if chage19=. then chage19=chage16+3;

  if chbmi04=. then baselinemiss = 1;
  else baselinemiss = 0;
  if chob04 = 1 then baselineob = 1;
  else baselineob=0;
  if chow04 = 1 then baselineow = 1;
  else baselineow=0;
  
  agebs = chage04;

run;
proc sort nodupkey data=gutsder9623;  by id;

/* Physical activity from Nerea Martin-Calvo,
/proj/g2wtgs/g2wtg0a/progs/nerea *********************************************/
data paguts204;
  set gpadat.gpa204;
  chpa04=pa204hours;
  chst04=st204hours;
  keep id chpa04 chst04;
  proc sort;   by id;
run;

data paguts206;
  set gpadat.gpa206;
  chpa06=pa206hours;
  chst06=st206hours;
  keep id chpa06 chst06;
  proc sort;   by id;
run;

data paguts208;
  set gpadat.gpa208;
  chpa08=pa208hours;
  chst08=st208hours;
  keep id chpa08 chst08;
  proc sort; by id;
run;

data paguts211;
  set gpadat.gpa211;
  chpa11=pa211hours;
  chst11=st211hours;
  keep id chpa11 chst11;
  proc sort;  by id;
run;

data paguts;
  merge paguts204 paguts206 paguts208 paguts211 ;
  by id;

   %cumavg(cycle=4, cyclevar=2,
        varin =chpa04 chst04 chpa06 chst06 chpa08 chst08 chpa11 chst11 ,
        varout=chpa04v chst04v chpa06v chst06v chpa08v chst08v chpa11v chst11v );

array pa {*} chpa04 chpa06 chpa08 chpa11 ;
array par {*} chpa04r chpa06r chpa08r chpa11r ; /*BCAR to make a copy of the original pre carry forward*/
array pav {*} chpa04v chpa06v chpa08v chpa11v ;
array st {*} chst04 chst06 chst08 chst11 ;
array str {*} chst04r chst06r chst08r chst11r ; /*BCAR to make a copy of the original pre carry forward*/
array stv {*} chst04v chst06v chst08v chst11v ;

do i=1 to dim(pa);
	par{i}=pa{i}; 
	str{i}=st{i}; 
end; drop i; 

do i=2 to 4;
if pa{i}=. then pa{i}=pa{i-1};
if pav{i}=. then pav{i}=pav{i-1};
if st{i}=. then st{i}=st{i-1};
if stv{i}=. then stv{i}=stv{i-1};
end; drop i; 



run;

/* replace missings with mean */
*proc standard data=paguts out=pagutsnomiss replace print;
proc sort nodupkey data=paguts;  by id;

/* AHEI Score without alcohol by Manar AlJazzaf ******************************/
data ahei2boy; set aheiguts.boysg2diet;
data ahei2girl; set aheiguts.girlsg2diet;

proc sort data=ahei2boy; by id; run;
proc sort data=ahei2girl; by id; run;

data ahei;
  set ahei2girl ahei2boy;

  chdiet04=ahei04; chdiet06=ahei06; chdiet08=ahei08; chdiet11=ahei11;

   %cumavg(cycle=4, cyclevar=1,
        varin =chdiet04 chdiet06 chdiet08 chdiet11,
        varout=chdiet04v chdiet06v chdiet08v chdiet11v);

array aheiarray {*} chdiet04 chdiet06 chdiet08 chdiet11;
array aheivarray {*} chdiet04v chdiet06v chdiet08v chdiet11v;

do i=2 to 4;
if aheiarray{i}=. then aheiarray{i}=aheiarray{i-1};
if aheivarray{i}=. then aheivarray{i}=aheivarray{i-1};
end;
keep id chdiet04 chdiet06 chdiet08 chdiet11 chdiet04v chdiet06v chdiet08v chdiet11v;
run;

/* replace missings with mean*/
*proc standard data=ahei out=aheigutsnomiss replace print;
proc sort nodupkey data=ahei;  by id;

/* GUTS western *****************************************************************/
data boy2western; set here.boywestern2; 
proc sort; by id; run;
data girl2western; set here.girlwestern2; 
proc sort; by id; run;

data western;
	set boy2western girl2western;
	*boy f296 f297 f198 f101 f204 f206 f208 f111 western was not always not second factor;
	*girls f296 f297 f198 f201 f204 f206 f208 f111;
	 %cumavg(cycle=4, cyclevar=1,
        varin = f204     f206     f208     f111   ,
        varout= chwest04 chwest06 chwest08 chwest11  );

	chwest_04=f204; 
	chwest_06=f206;
	chwest_08=f208;  
	chwest_11=f111; /*BCAR updated code to keep time-varying values; note using the original values, with carryforward*/

	chwest04r=f204r; 
	chwest06r=f206r;
	chwest08r=f208r;  
	chwest11r=f111r; /*BCAR updated code to keep time-varying values; note using the original values, not with carryforward*/

	keep id chwest04 chwest06 chwest08 chwest11 chwest_04 chwest_06 chwest_08 chwest_11 
			chwest04r chwest06r chwest08r chwest11r;
run;

proc sort nodupkey data=western;  by id;

/* total enery intake *********************************************************                                    
*/
*boys;
%g2b04_nts(keep = id calor04n); %g2b06_nts(keep = id calor06n);
%g2b08_nts(keep = id calor08n); %gab11_nts(keep = id calor11n); 
*girls;
%g2g04_nts(keep = id calor04n); %g2g06_nts(keep = id calor06n);
%g2g08_nts(keep = id calor08n); %gag11_nts(keep = id calor11n); 
proc sort data=g2g08_nts; by id; run;

data calgutsb;
  merge g2b04_nts g2b06_nts g2b08_nts gab11_nts;
  by id;
run;
data calgutsg;
  merge g2g04_nts g2g06_nts g2g08_nts gag11_nts;
  by id;
run;

data calguts;
  set calgutsb calgutsg;

  chcal04=calor04n; chcal06=calor06n; chcal08=calor08n; chcal11=calor11n;

   %cumavg(cycle=4, cyclevar=1,
        varin =chcal04 chcal06 chcal08 chcal11,
        varout=chcal04v chcal06v chcal08v chcal11v);

array aheiarray {*} chcal04 chcal06 chcal08 chcal11;
array aheivarray {*} chcal04v chcal06v chcal08v chcal11v;

do i=2 to 4;
if aheiarray{i}=. then aheiarray{i}=aheiarray{i-1};
if aheivarray{i}=. then aheivarray{i}=aheivarray{i-1};
end;

keep id chcal04 chcal06 chcal08 chcal11 chcal04v chcal06v chcal08v chcal11v;
run;
/* if still missing, replace missings with mean*/
*proc standard data=calguts out=calgutsnomiss replace print;
proc sort nodupkey data=calguts; by id;


/* Boys: cig & alcohol & ED */
%boys204(keep=id yob204b beer204b wine204b liq204b
				hisp204b white204b black204b asian204b nativ204b hawaii204b oanc204b q4apt204b cohort);
				cohort=2;
data boys204; set boys204;
	rename  yob204b = chyob;
				/* re-coding race*/
				if white204b = 1 then race_c = 1;
				else if black204b = 1 then race_c = 2;
				else if hisp204b = 1 then race_c = 3;
				else if asian204b = 1 then race_c = 4;
				else if nativ204b = 1 or hawaii204b = 1 or oanc204b = 1 then race_c = 5; 
   if beer204b in (2,3,4,5) or wine204b in (2,3,4,5) or liq204b in (2,3,4,5) then chalc04=1; else chalc04=0;
run;
proc sort nodupkey data=boys204; by id;	run;
		
%boys206(keep = id evtryc206b sleep206b /*1.< 5 2.5hrs 3.6hrs 4.7hrs 5.8hrs 6.9hrs 7.10hrs 8.11+ hrs 9.pt*/ 
				beer206b wine206b liq206b /*1.never/<1/mo 2.1-3/mo 3.1/wk 4.2-6/wk 5.7 or more/wk 6.pt*/);
data boys206; set boys206;
	if evtryc206b=2 then chcig06=1; else chcig06=0;
	if (beer206b >1 and beer206b <6) or (wine206b >1 and wine206b <6) or (liq206b >1 and liq206b <6) 
  		then chalc06=1; else chalc06=0; 
  	if sleep206b=1 then sleep06=4; 
  	else if sleep206b=2 then sleep06=5; 
  	else if sleep206b=3 then sleep06=6;
  	else if sleep206b=4 then sleep06=7;
  	else if sleep206b=5 then sleep06=8;
  	else if sleep206b=6 then sleep06=9;
  	else if sleep206b=7 then sleep06=10;
  	else if sleep206b=8 then sleep06=11;
  	else sleep06=.;   
run;
proc sort nodupkey data=boys206; by id;	run;

%boys208(keep = id pstyrsm208b beer208b wine208b liq208b /* 1.never/<1/mo 2.1-3/mo 3.1/wk 4.2-6/wk 5.7 or more/wk 6.pt*/
		sleep208b trytols208b fast208b thrwup208b lxtv208b bng208b nctrl208b);
		/*1.< 5; 2.5hrs; 3.6hrs; 4.7hrs; 5.8hrs; 6.9hrs; 7.10hrs; 8.11+ hrs; 9.pt */
data boys208; set boys208;
	if pstyrsm208b=2 then chcig08=1; else chcig08=0;
	if (beer208b >1 and beer208b <6) or (wine208b >1 and wine208b <6) or (liq208b >1 and liq208b <6) 
  		then chalc08=1; else chalc08=0;
  	if sleep208b=1 then sleep08=4; 
  	else if sleep208b=2 then sleep08=5; 
  	else if sleep208b=3 then sleep08=6;
  	else if sleep208b=4 then sleep08=7;
  	else if sleep208b=5 then sleep08=8;
  	else if sleep208b=6 then sleep08=9;
  	else if sleep208b=7 then sleep08=10;
  	else if sleep208b=8 then sleep08=11;
  	else sleep08=.;   
run;
proc sort nodupkey data=boys208; by id;	run;

%boys211(keep = id lcig211b beer211b lbeer211b wine211b liq211b sleep211b
		tlose211b vomit211b laxat211b binge211b outof211b anor211b);
		/*1.Less than 5 hours; 2.5 hours; 3.6 hours; 4.7 hours;5.8 hours; 6.9 hours; 7.10 hours; 8.11 or more hours; 9.pt */
data boys211; set boys211;
	if lcig211b in (2,3,4,5,6,7) then chcig11=1; else chcig11=0;
	if (beer211b >2 and beer211b <11) or (lbeer211b >2 and lbeer211b <11) or (wine211b >2 and wine211b <11) or (liq211b >2 and liq211b <11) 
  		then chalc11=1; else chalc11=0;
  	if sleep211b=1 then sleep11=4; 
  	else if sleep211b=2 then sleep11=5; 
  	else if sleep211b=3 then sleep11=6;
  	else if sleep211b=4 then sleep11=7;
  	else if sleep211b=5 then sleep11=8;
  	else if sleep211b=6 then sleep11=9;
  	else if sleep211b=7 then sleep11=10;
  	else if sleep211b=8 then sleep11=11;
  	else sleep11=.;   
  		run;
proc sort nodupkey data=boys211; by id;	run;

%boys13(keep=id oftsmk13b aalc13b
		tlose13b wtlsmpt13b vomit13b laxat13b binge13b outof13b  );
data boys13; set boys13;
	if oftsmk13b in (2,3,4,5) then chcig13=1; else chcig13=0;
	if aalc13b in (2,3,4,5,6,7) then chalc13=1; else chalc13=0;
run;
proc sort nodupkey data=boys13; by id;	run;

data boys;
  merge boys204 boys206 boys208 boys211 boys13;
  by id;
  if cohort=2;
  sex=1;
  chmens04=0; chmens06=0; chmens08=0; 
run;
proc freq data=boys; table sleep06 sleep08 sleep11; run;

/* Girls: & menstral cycle & pregnancy & cig & alcohol & ED */
%girls204 (keep = id yob204g beer204g  wine204g liq204g menst204g menar204g
			hisp204g white204g black204g asian204g nativ204g hawaii204g oanc204g cohort);
			cohort=2; 
data girls204; set girls204;
	rename  yob204g = chyob;
			/* re-coding race*/
	if white204g = 1 then race_c = 1;
			else if black204g = 1 then race_c = 2;
			else if hisp204g = 1 then race_c = 3;
			else if asian204g = 1 then race_c = 4;
			else if nativ204g = 1 or hawaii204g = 1 or oanc204g = 1 then race_c = 5; 
	if menst204g ne 2 then chmens04=0; 
  		else if menar204g in (2,3,4,5,6) then chmens04=1; /*<13 y*/
  		else if menar204g = 7 then chmens04=2; /*13 y*/
  		else if menar204g in (8,9) then chmens04=3; /*14+ y*/
  		else chmens04=.; /*unknown age*/  			
	if beer204g in (2,3,4,5) or wine204g in (2,3,4,5) or liq204g in (2,3,4,5) then chalc04=1; else chalc04=0;			
run;
proc sort nodupkey data=girls204; by id; run;

%girls206(keep = id menst206g menar206g sleep206g evtryc206g beer206g wine206g liq206g);
data girls206; set girls206;
	if menst206g ne 2 then chmens06=0; 
  		else if menar206g in (2,3,4,5,6) then chmens06=1; /*<13 y*/
  		else if menar206g = 7 then chmens06=2; /*13 y*/
  		else if menar206g in (8,9) then chmens06=3; /*14+ y*/
  		else chmens06=.; /*unknown age*/ 
  	if evtryc206g =2 then chcig06=1; else chcig06=0;
	if beer206g in (2,3,4,5) or wine206g in (2,3,4,5) or liq206g in (2,3,4,5) then chalc06=1; else chalc06=0;
	if sleep206g=1 then sleep06=4; 
  	else if sleep206g=2 then sleep06=5; 
  	else if sleep206g=3 then sleep06=6;
  	else if sleep206g=4 then sleep06=7;
  	else if sleep206g=5 then sleep06=8;
  	else if sleep206g=6 then sleep06=9;
  	else if sleep206g=7 then sleep06=10;
  	else if sleep206g=8 then sleep06=11;
  	else sleep06=.;   
run;
proc sort nodupkey data=girls206; by id; run;
	
%girls208(keep = id menst208g menar208g sleep208g pstyrsm208g beer208g wine208g liq208g
				 trytols208g fast208g thrwup208g lxtv208g bng208g nctrl208g);
data girls208; set girls208;
	if menst208g <2 and menst208g >3 then chmens08=0; 
  		else if menar208g in (1,2,3,4,5) then chmens08=1; /*<13 y*/
  		else if menar208g = 6 then chmens08=2; /*13 y*/
  		else if menar208g in (7,8) then chmens08=3; /*14+ y*/
  		else chmens08=.; /*unknown age*/ 
  	if pstyrsm208g=2 then chcig08=1; else chcig08=0; 
  	if beer208g in (2,3,4,5) or wine208g in (2,3,4,5) or liq208g in (2,3,4,5) then chalc08=1; else chalc08=0;
	if sleep208g=1 then sleep08=4; 
  	else if sleep208g=2 then sleep08=5; 
  	else if sleep208g=3 then sleep08=6;
  	else if sleep208g=4 then sleep08=7;
  	else if sleep208g=5 then sleep08=8;
  	else if sleep208g=6 then sleep08=9;
  	else if sleep208g=7 then sleep08=10;
  	else if sleep208g=8 then sleep08=11;
  	else sleep08=.;   
  run;
proc sort nodupkey data=girls208; by id; run;

%girls211(keep = id sleep211g lcig211g beer211g lbeer211g wine211g liq211g
				 tlose211g vomit211g laxat211g binge211g outof211g anor211g);
data girls211; set girls211;
	if lcig211g in (2,3,4,5,6,7) then chcig11=1; else chcig11=0;
	if (beer211g >2 and beer211g <11) or (lbeer211g >2 and lbeer211g <11) or (wine211g >2 and wine211g <11) or (liq211g >2 and liq211g <11) 
  		then chalc11=1; else chalc11=0;
	if sleep211g=1 then sleep11=4; 
  	else if sleep211g=2 then sleep11=5; 
  	else if sleep211g=3 then sleep11=6;
  	else if sleep211g=4 then sleep11=7;
  	else if sleep211g=5 then sleep11=8;
  	else if sleep211g=6 then sleep11=9;
  	else if sleep211g=7 then sleep11=10;
  	else if sleep211g=8 then sleep11=11;
  	else sleep11=.;   
run;
proc sort nodupkey data=girls211; by id; run;

%girls13(keep=id cpreg13g npregyr13g oftsmk13g ncig13g aalc13g nalc13g
			  tlose13g wtlsmpt13g vomit13g laxat13g binge13g outof13g );
data girls13; set girls13;
	if cpreg13g=1 or npregyr13g in (1,2,3,4) then chpreg13=1; else chpreg13=0;
	if oftsmk13g in (2,3,4,5) or ncig13g in (2,3,4,5,6) then chcig13=1; else chcig13=0;
	if aalc13g in (2,3,4,5,6,7) or nalc13g in (2,3,4,5,6,7,8) then chalc13=1; else chalc13=0;
run;
proc sort nodupkey data=girls13; by id; run;

data girls;
  merge girls204 girls206 girls208 girls211 girls13;
  by id;
  if cohort=2;
  sex=2;
run;
proc freq data=girls;
	table sleep06 sleep08 sleep11; run;

data boygirl;
  set boys girls; 	
run;
proc sort nodupkey data=boygirl;  by id; run;

/* Merge variables for GUTS 2 ************************************************/
data guts2;
	merge gutsder9623(in=A) paguts calguts ahei western boygirl;
  	by id;
  	if A and cohort = 2 then output;
  	if ch_birthday=. then delete;
run;

data guts2; set guts2;  	
  	
  	if race_c=1 then white=1; 
	else white=0;
	
	chyob = chyob+1900;
 	     	
	/***** if ever smoked or alcohol *****/
	array cig(*) chcig06 chcig06 chcig08 chcig11 chcig13 ;
	array alc(*) chalc04 chalc06 chalc08 chalc11 chalc13 ;
	array mens(*) chmens04 chmens06 chmens08 chmens08 chmens08;
	
	do i=2 to dim(cig);
    	if cig{i}=. then cig{i}=cig{i-1};
    	if alc{i}=. then alc{i}=alc{i-1};
    	if mens{i}=. then mens{i}=mens{i-1};
    end; drop i;

run;	
proc sort data=guts2; by momid; run;

proc datasets nolist;
delete gutsder9623 paguts204 paguts206 paguts208 paguts211 
		ahei2girl ahei2boy calgutsb calgutsg boy2western girl2western
		g2b04_nts g2b06_nts g2b08_nts gab11_nts g2g04_nts g2g06_nts g2g08_nts gag11_nts
		boys204 boys206 boys208 boys211 boys13 girls204 girls206 girls208 girls211 girls13
		 paguts calguts ahei western boygirl;
run;
