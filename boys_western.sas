/*
Program name: boys_western.sas 
Programmer: Yiqing Wang 
Template: udd/nkmal/GUTS/diet_quality/ Manar AlJazzaf
Date 03/2025
*/

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


/*************************************************************************************************
**************************************************************************************************
***********************************************BOYS***********************************************
**************************************************************************************************
**************************************************************************************************/

******************************************************************
Calling in 1996 Boys wave and keeping variables
******************************************************************;
%boys96 (keep= yr96b id momid
local96b coke96b punch96b itea96b tea96b coff96b beer96b wine96b liq96b
milk96b chocm96b instb96b whip96b yog96b cotch96b othch96b crch96b but96b marg96b
cburg96b burg96b pizza96b taco96b chnug96b dog96b spj96b sturk96b srb96b sbol96b stuna96b
chick96b fishs96b ofish96b shrim96b beef96b pork96b meatb96b lasag96b macch96b spag96b
eggs96b liver96b frtoa96b grlch96b eggro96b gravy96b ketch96b chowd96b soup96b mayo96b lcsdr96b saldr96b salsa96b
cer96b ckcer96b whbr96b dkbr96b engl96b muff96b cornb96b bisc96b rice96b pasta96b torti96b otgrn96b panca96b
fries96b mashp96b rais96b grape96b ban96b apple96b melon96b pear96b orang96b straw96b peach96b oj96b aj96b
tom96b tofu96b sbean96b beans96b brocc96b beet96b corn96b peas96b mixv96b spin96b kale96b grpep96b
yams96b eggpl96b ccar96b rcar96b celry96b lett96b slaw96b psald96b
pchip96b cchip96b nacho96b popc96b pretz96b nuts96b fufrt96b gcrax96b crack96b popt96b
cake96b twink96b sroll96b donut96b cooki96b brwni96b pie96b choco96b cdywi96b cdywo96b jello96b pudd96b
fryog96b icecr96b frapp96b pops96b seeds96b );

yr96b=1;
proc sort nodupkey data=boys96; by id; run;

data boys96; set boys96;

  array old1 {*} local96b coke96b punch96b othch96b;
  array new1 {*} local96 coke96 punch96 othch96;
  do i=1 to DIM(old1);
  if old1(i)=1 then new1(i)=0;
  else if old1(i)=2 then new1(i)=0.07;
  else if old1(i)=3 then new1(i)=0.14;
  else if old1(i)=4 then new1(i)=0.57;
  else if old1(i)=5 then new1(i)=1;
  else if old1(i)=6 then new1(i)=2.5;
  else if old1(i)=7 then new1(i)=4;
  else if old1(i)=8 then new1(i)=.;
  else new1(i)=0;
  end;

  array old2 {*} tea96b coff96b;
  array new2 {*} tea96 coff96;
  do i=1 to DIM(old2);
  if old2(i)=1 then new2(i)=0;
  else if old2(i)=2 then new2(i)=0.07;
  else if old2(i)=3 then new2(i)=0.21;
  else if old2(i)=4 then new2(i)=0.64;
  else if old2(i)=5 then new2(i)=2;
  else if old2(i)=6 then new2(i)=.;
  else new2(i)=0;
  end;

  array old3 {*} beer96b wine96b liq96b cotch96b fishs96b shrim96b lasag96b macch96b soup96b
                 otgrn96b panca96b melon96b slaw96b psald96b nacho96b pretz96b cake96b pie96b frapp96b;
  array new3 {*} beer96 wine96 liq96 cotch96 fishs96 shrim96 lasag96 macch96 soup96
                 otgrn96 panca96 melon96 slaw96 psald96 nacho96 pretz96 cake96 pie96 frapp96;
  do i=1 to DIM(old3);
  if old3(i)=1 then new3(i)=0;
  else if old3(i)=2 then new3(i)=0.07;
  else if old3(i)=3 then new3(i)=0.14;
  else if old3(i)=4 then new3(i)=0.29;
  else if old3(i)=5 then new3(i)=.;
  else new3(i)=0;
  end;

  array old4 {*} instb96b whip96b cburg96b burg96b pizza96b taco96b chnug96b dog96b
                  spj96b sturk96b srb96b sbol96b stuna96b chick96b ofish96b beef96b pork96b 
                  meatb96b spag96b eggs96b frtoa96b grlch96b eggro96b ketch96b engl96b
                  muff96b cornb96b bisc96b rice96b pasta96b torti96b fries96b mashp96b rais96b
                  grape96b ban96b straw96b peach96b tofu96b sbean96b brocc96b corn96b 
                  peas96b mixv96b spin96b kale96b grpep96b yams96b eggpl96b ccar96b rcar96b 
                  celry96b sroll96b brwni96b jello96b pudd96b fryog96b icecr96b pops96b seeds96b;
  array new4 {*} instb96 whip96 cburg96 burg96 pizza96 taco96 chnug96 dog96
                  spj96 sturk96 srb96 sbol96 stuna96 chick96 ofish96 beef96 pork96
                  meatb96 spag96 eggs96 frtoa96 grlch96 eggro96 ketch96 engl96
                  muff96 cornb96 bisc96 rice96 pasta96 torti96 fries96 mashp96 rais96 
                  grape96 ban96 straw96 peach96 tofu96 sbean96 brocc96 corn96
                  peas96 mixv96 spin96 kale96 grpep96 yams96 eggpl96 ccar96 rcar96 
                  celry96 sroll96 brwni96 jello96 pudd96 fryog96 icecr96 pops96 seeds96;
  do i=1 to DIM(old4);
  if old4(i)=1 then new4(i)=0;
  else if old4(i)=2 then new4(i)=0.07;
  else if old4(i)=3 then new4(i)=0.14;
  else if old4(i)=4 then new4(i)=0.43;
  else if old4(i)=5 then new4(i)=0.71;
  else if old4(i)=6 then new4(i)=.;
  else new4(i)=0;
  end;

  array old5 {*} yog96b crch96b oj96b aj96b;
  array new5 {*} yog96 crch96 oj96 aj96;
  do i=1 to DIM(old5);
  if old5(i)=1 then new5(i)=0;
  else if old5(i)=2 then new5(i)=0.07;
  else if old5(i)=3 then new5(i)=0.14;
  else if old5(i)=4 then new5(i)=0.57;
  else if old5(i)=5 then new5(i)=1;
  else if old5(i)=6 then new5(i)=2;
  else if old5(i)=7 then new5(i)=.;
  else new5(i)=0;
  end;

  array old6 {*} but96b marg96b;
  array new6 {*} but96 marg96;
  do i=1 to DIM(old6);
  if old6(i)=1 then new6(i)=0;
  else if old6(i)=2 then new6(i)=0.07;
  else if old6(i)=3 then new6(i)=0.14;
  else if old6(i)=4 then new6(i)=0.57;
  else if old6(i)=5 then new6(i)=1;
  else if old6(i)=6 then new6(i)=3;
  else if old6(i)=7 then new6(i)=5;
  else if old6(i)=8 then new6(i)=.;
  else new6(i)=0;
  end;

  array old7 {*} chowd96b mayo96b lcsdr96b saldr96b salsa96b apple96b pear96b orang96b
                tom96b lett96b pchip96b cchip96b twink96b donut96b choco96b cdywi96b cdywo96b;
  array new7 {*} chowd96 mayo96 lcsdr96 saldr96 salsa96 apple96 pear96 orang96
                tom96 lett96 pchip96 cchip96 twink96 donut96 choco96 cdywi96 cdywo96;
  do i=1 to DIM(old7);
  if old7(i)=1 then new7(i)=0;
    else if old7(i)=2 then new7(i)=0.07;
    else if old7(i)=3 then new7(i)=0.14;
    else if old7(i)=4 then new7(i)=0.57;
    else if old7(i)=5 then new7(i)=2;
    else if old7(i)=6 then new7(i)=.;
    else new7(i)=0; 
	end;

  array old8 {*} cer96b ckcer96b;
  array new8 {*} cer96 ckcer96;
  do i=1 to DIM(old8);
  if old8(i)=1 then new8(i)=0;
    else if old8(i)=2 then new8(i)=0.07;
    else if old8(i)=3 then new8(i)=0.14;
    else if old8(i)=4 then new8(i)=0.43;
    else if old8(i)=5 then new8(i)=0.86;
    else if old8(i)=6 then new8(i)=2;
    else if old8(i)=7 then new8(i)=.;
    else new8(i)=0; 
	end;

  array old9 {*} whbr96b dkbr96b;
  array new9 {*} whbr96 dkbr96;
  do i=1 to DIM(old9);
  if old9(i)=1 then new9(i)=0;
    else if old9(i)=2 then new9(i)=0.07;
    else if old9(i)=3 then new9(i)=0.43;
    else if old9(i)=4 then new9(i)=0.86;
    else if old9(i)=5 then new9(i)=2.5;
    else if old9(i)=6 then new9(i)=4;
    else if old9(i)=7 then new9(i)=.;
    else new9(i)=0; 
	end;

  array old10 {*} popc96b nuts96b fufrt96b gcrax96b crack96b; 
  array new10 {*} popc96 nuts96 fufrt96 gcrax96 crack96; 
  do i=1 to DIM(old10);
  if old10(i)=1 then new10(i)=0;
  else if old10(i)=2 then new10(i)=0.07;
  else if old10(i)=3 then new10(i)=0.36;
  else if old10(i)=4 then new10(i)=0.71;
  else if old10(i)=5 then new10(i)=.;
  else old10(i)=0; 
	end;

  if itea96b =1 then itea96 =0;
    else if itea96b =2 then itea96 =0.07;
    else if itea96b =3 then itea96 =0.36;
    else if itea96b =4 then itea96 =0.79;
    else if itea96b =5 then itea96 =2;
    else if itea96b =6 then itea96 =.;
    else itea96 =0;

  if milk96b=1 then milk96=0;
    else if milk96b=2 then milk96=0.14;
    else if milk96b=3 then milk96=0.57;
    else if milk96b=4 then milk96=1;
    else if milk96b=5 then milk96=2.5;
    else if milk96b=6 then milk96=4;
    else if milk96b=7 then milk96=.;
    else milk96=0;

  if chocm96b=1 then chocm96=0;
    else if chocm96b=2 then chocm96=0.07;
    else if chocm96b=3 then chocm96=0.14;
    else if chocm96b=4 then chocm96=0.57;
    else if chocm96b=5 then chocm96=1.5;
    else if chocm96b=6 then chocm96=3;
    else if chocm96b=7 then chocm96=.;
    else chocm96=0;

  if liver96b=1 then liver96=0;
    else if liver96b=2 then liver96=0.02;
    else if liver96b=3 then liver96=0.03;
    else if liver96b=4 then liver96=0.08;
    else if liver96b=5 then liver96=0.29;
    else if liver96b=6 then liver96=.;
    else liver96=0;

 if gravy96b=1 then gravy96=0;
  else if gravy96b=2 then gravy96=0.07;
  else if gravy96b=3 then gravy96=0.57;
  else if gravy96b=4 then gravy96=1;
  else if gravy96b=5 then gravy96=2;
  else if gravy96b=6 then gravy96=.;
  else gravy96=0;

  if beans96b=1 then beans96=0;
  else if beans96b=2 then beans96=0.14;
  else if beans96b=3 then beans96=0.57;
  else if beans96b=4 then beans96=1;
  else if beans96b=5 then beans96=.;
  else beans96=0;

  if beet96b=1 then beet96=0;
  else if beet96b=2 then beet96=0.07;
  else if beet96b=3 then beet96=0.14;
  else if beet96b=4 then beet96=.;
  else beet96=0;

  if popt96b=1 then popt96=0;
  else if popt96b=2 then popt96=0.07;
  else if popt96b=3 then popt96=0.5;
  else if popt96b=4 then popt96=2;
  else if popt96b=5 then popt96=.;
  else popt96=0;

  if cooki96b=1 then cooki96=0;
  else if cooki96b=2 then cooki96=0.07;
  else if cooki96b=3 then cooki96=0.14;
  else if cooki96b=4 then cooki96=0.57;
  else if cooki96b=5 then cooki96=2;
  else if cooki96b=6 then cooki96=4;
  else if cooki96b=7 then cooki96=.;
  else cooki96=0;
  
   promeat96   = sum (cburg96, burg96, taco96, chnug96, dog96, sbol96, meatb96);
   redmeat96   = sum (srb96, beef96, pork96);
   orgmeat96   = sum (liver96 );
   fish96      = sum (stuna96, fishs96, ofish96, shrim96);
   poult96     = sum (sturk96, chick96);
   eggs96      = sum (eggs96 );
   butter96    = sum (but96 );
   marg96      = sum (marg96 );
   lowdai96    = sum (chocm96, yog96, cotch96, fryog96 );
   highdai96   = sum (milk96, whip96, othch96, crch96, icecr96);
   wine96      = sum (wine96 );
   liquor96    = sum (liq96 );
   beer96      = sum (beer96 );
   tea96       = sum (itea96, tea96);
   coffee96    = sum (coff96 );
   fruit96     = sum (rais96, grape96, ban96, apple96, melon96, pear96, orang96, straw96, peach96, fufrt96);
   fruju96     = sum (oj96, aj96 );
   cruveg96    = sum (brocc96, slaw96);
   yelveg96    = sum (yams96, ccar96, rcar96 );
   tomato96    = sum (tom96 );
   leafveg96   = sum (spin96, kale96, lett96 );
   legume96    = sum (tofu96, sbean96, beans96, peas96 );
   othveg96    = sum (beet96, mixv96, grpep96, eggpl96, celry96);
   potato96    = sum (mashp96, psald96);
   french96    = sum (fries96);
   wholeg96    = sum (cer96, ckcer96, whbr96, dkbr96, engl96, cornb96, otgrn96, corn96, gcrax96);
   refing96    = sum (lasag96, macch96, spag96, frtoa96, grlch96, eggro96, bisc96, rice96, pasta96, torti96, panca96);
   pizza96     = sum (pizza96 );
   sugdrk96    = sum (coke96, punch96, instb96, frapp96 );
   lowdrk96    = sum (local96 );
   snack96     = sum (pchip96, cchip96, nacho96, popc96, pretz96, crack96  );
   nuts96      = sum (spj96, nuts96, seeds96);
   mayo96      = sum (mayo96 );
   dress96     = sum (lcsdr96, saldr96);
   crmsoup96   = sum (chowd96, soup96); 
   sweets96    = sum (muff96, popt96, cake96, twink96, sroll96, donut96, cooki96, brwni96, pie96, choco96, cdywi96, cdywo96, jello96, pudd96, pops96);
   condim96    = sum (gravy96, ketch96, salsa96);

keep yr96b id momid 
		promeat96   redmeat96  orgmeat96   fish96    poult96    eggs96     butter96    
  		marg96      lowdai96   highdai96   wine96    liquor96   beer96     tea96       
  		coffee96    fruit96    fruju96     cruveg96  yelveg96   tomato96   leafveg96   
  		legume96    othveg96   potato96    french96  wholeg96   refing96   pizza96    
  		sugdrk96    lowdrk96   snack96     nuts96    mayo96     dress96    crmsoup96   
  		sweets96    condim96     ;
run;

proc factor data=boys96 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f96;
	where promeat96 ne .;
	var promeat96   redmeat96  orgmeat96   fish96    poult96    eggs96     butter96    
  		marg96      lowdai96   highdai96   wine96    liquor96   beer96     tea96       
  		coffee96    fruit96    fruju96     cruveg96  yelveg96   tomato96   leafveg96   
  		legume96    othveg96   potato96    french96  wholeg96   refing96   pizza96    
  		sugdrk96    lowdrk96   snack96     nuts96    mayo96     dress96    crmsoup96   
  		sweets96    condim96; 
data f96; set f96 ( keep=id factor1 factor2 
				rename=(factor1=f196 factor2=f296));
proc sort; by id;  run;


*******************************************************************************************
Calling in 1997 boys and keeping variables for analysis
*******************************************************************************************;
%boys97 (keep= boys97 yrq97 id momid
local97b coke97b punch97b itea97b tea97b coff97b beer97b wine97b liq97b
milk97b chocm97b instb97b yog97b cotch97b othch97b crch97b but97b marg97b
cburg97b burg97b pizza97b taco97b chnug97b dog97b spj97b sturk97b srb97b sbol97b stuna97b
chick97b fishs97b ofish97b shrim97b beef97b pork97b meatb97b lasag97b macch97b spag97b
eggs97b bacon97b liver97b frtoa97b grlch97b eggro97b gravy97b ketch97b chowd97b soup97b mayo97b lcsdr97b saldr97b salsa97b
cer97b ckcer97b whbr97b drbr97b engl97b muff97b cornb97b bisc97b rice97b pasta97b torti97b otgrn97b panca97b
fries97b mashp97b rais97b grape97b ban97b apple97b melon97b pear97b orang97b straw97b peach97b oj97b aj97b
tom97b tofu97b sbean97b beans97b brocc97b corn97b peas97b mixv97b spin97b kale97b grpep97b
yams97b eggpl97b ccar97b rcar97b celry97b lett97b slaw97b psald97b
pchip97b cchip97b nacho97b popc97b pretz97b nuts97b fufrt97b gcrax97b crack97b popt97b
cake97b twink97b sroll97b donut97b cooki97b brwni97b pie97b choco97b cdyw97b cdywo97b jello97b pudd97b
fryog97b icecr97b frapp97b pops97b seeds97b );

yrq97=1; boys97=1;
proc sort nodupkey data=boys97; by id; run;

data boys97; set boys97;

  array old1 {*} local97b coke97b punch97b othch97b;
  array new1 {*} local97 coke97 punch97 othch97;
  do i=1 to DIM(old1);
  if old1(i)=1 then new1(i)=0;
  else if old1(i)=2 then new1(i)=0.07;
  else if old1(i)=3 then new1(i)=0.14;
  else if old1(i)=4 then new1(i)=0.57;
  else if old1(i)=5 then new1(i)=1;
  else if old1(i)=6 then new1(i)=2.5;
  else if old1(i)=7 then new1(i)=4;
  else if old1(i)=8 then new1(i)=.;
  else new1(i)=0;
  end;

  array old2 {*} tea97b coff97b;
  array new2 {*} tea97 coff97;
  do i=1 to DIM(old2);
  if old2(i)=1 then new2(i)=0;
  else if old2(i)=2 then new2(i)=0.07;
  else if old2(i)=3 then new2(i)=0.21;
  else if old2(i)=4 then new2(i)=0.64;
  else if old2(i)=5 then new2(i)=2;
  else if old2(i)=6 then new2(i)=.;
  else new2(i)=0;
  end;

  array old3 {*} cotch97b fishs97b shrim97b lasag97b macch97b soup97b
                 otgrn97b panca97b melon97b slaw97b psald97b nacho97b pretz97b cake97b pie97b frapp97b;
  array new3 {*} cotch97 fishs97 shrim97 lasag97 macch97 soup97
                 otgrn97 panca97 melon97 slaw97 psald97 nacho97 pretz97 cake97 pie97 frapp97;
  do i=1 to DIM(old3);
  if old3(i)=1 then new3(i)=0;
  else if old3(i)=2 then new3(i)=0.07;
  else if old3(i)=3 then new3(i)=0.14;
  else if old3(i)=4 then new3(i)=0.29;
  else if old3(i)=5 then new3(i)=.;
  else new3(i)=0;
  end;

  array old4 {*} instb97b cburg97b burg97b pizza97b taco97b chnug97b dog97b
                  spj97b sturk97b srb97b sbol97b stuna97b chick97b ofish97b beef97b pork97b 
                  meatb97b spag97b eggs97b bacon97b grlch97b eggro97b ketch97b engl97b
                  muff97b cornb97b bisc97b rice97b pasta97b torti97b fries97b mashp97b rais97b
                  grape97b ban97b straw97b peach97b tofu97b sbean97b brocc97b corn97b 
                  peas97b mixv97b spin97b kale97b grpep97b yams97b eggpl97b ccar97b rcar97b 
                  celry97b sroll97b brwni97b jello97b pudd97b fryog97b icecr97b pops97b seeds97b;
  array new4 {*} instb97 cburg97 burg97 pizza97 taco97 chnug97 dog97
                  spj97 sturk97 srb97 sbol97 stuna97 chick97 ofish97 beef97 pork97
                  meatb97 spag97 eggs97 bacon97 grlch97 eggro97 ketch97 engl97
                  muff97 cornb97 bisc97 rice97 pasta97 torti97 fries97 mashp97 rais97 
                  grape97 ban97 straw97 peach97 tofu97 sbean97 brocc97 corn97
                  peas97 mixv97 spin97 kale97 grpep97 yams97 eggpl97 ccar97 rcar97 
                  celry97 sroll97 brwni97 jello97 pudd97 fryog97 icecr97 pops97 seeds97;
  do i=1 to DIM(old4);
  if old4(i)=1 then new4(i)=0;
  else if old4(i)=2 then new4(i)=0.07;
  else if old4(i)=3 then new4(i)=0.14;
  else if old4(i)=4 then new4(i)=0.43;
  else if old4(i)=5 then new4(i)=0.71;
  else if old4(i)=6 then new4(i)=.;
  else new4(i)=0;
  end;

  array old5 {*} yog97b crch97b oj97b aj97b;
  array new5 {*} yog97 crch97 oj97 aj97;
  do i=1 to DIM(old5);
  if old5(i)=1 then new5(i)=0;
  else if old5(i)=2 then new5(i)=0.07;
  else if old5(i)=3 then new5(i)=0.14;
  else if old5(i)=4 then new5(i)=0.57;
  else if old5(i)=5 then new5(i)=1;
  else if old5(i)=6 then new5(i)=2;
  else if old5(i)=7 then new5(i)=.;
  else new5(i)=0;
  end;

  array old6 {*} but97b marg97b;
  array new6 {*} but97 marg97;
  do i=1 to DIM(old6);
  if old6(i)=1 then new6(i)=0;
  else if old6(i)=2 then new6(i)=0.07;
  else if old6(i)=3 then new6(i)=0.14;
  else if old6(i)=4 then new6(i)=0.57;
  else if old6(i)=5 then new6(i)=1;
  else if old6(i)=6 then new6(i)=3;
  else if old6(i)=7 then new6(i)=5;
  else if old6(i)=8 then new6(i)=.;
  else new6(i)=0;
  end;

  array old7 {*} beer97b wine97b liq97b chowd97b mayo97b lcsdr97b saldr97b salsa97b apple97b pear97b orang97b
                tom97b lett97b pchip97b cchip97b twink97b donut97b choco97b cdyw97b cdywo97b;
  array new7 {*} beer97 wine97 liq97 chowd97 mayo97 lcsdr97 saldr97 salsa97 apple97 pear97 orang97
                tom97 lett97 pchip97 cchip97 twink97 donut97 choco97 cdyw97 cdywo97;
  do i=1 to DIM(old7);
  if old7(i)=1 then new7(i)=0;
    else if old7(i)=2 then new7(i)=0.07;
    else if old7(i)=3 then new7(i)=0.14;
    else if old7(i)=4 then new7(i)=0.57;
    else if old7(i)=5 then new7(i)=2;
    else if old7(i)=6 then new7(i)=.;
    else new7(i)=0;
	end;

  array old8 {*} cer97b ckcer97b;
  array new8 {*} cer97 ckcer97;
  do i=1 to DIM(old8);
  if old8(i)=1 then new8(i)=0;
    else if old8(i)=2 then new8(i)=0.07;
    else if old8(i)=3 then new8(i)=0.14;
    else if old8(i)=4 then new8(i)=0.43;
    else if old8(i)=5 then new8(i)=0.86;
    else if old8(i)=6 then new8(i)=2;
    else if old8(i)=7 then new8(i)=.;
    else new8(i)=0;
	end;

  array old9 {*} whbr97b drbr97b;
  array new9 {*} whbr97 drbr97;
  do i=1 to DIM(old9);
  if old9(i)=1 then new9(i)=0;
    else if old9(i)=2 then new9(i)=0.07;
    else if old9(i)=3 then new9(i)=0.43;
    else if old9(i)=4 then new9(i)=0.86;
    else if old9(i)=5 then new9(i)=2.5;
    else if old9(i)=6 then new9(i)=4;
    else if old9(i)=7 then new9(i)=.;
    else new9(i)=0;
	end;

  array old10 {*} popc97b nuts97b fufrt97b gcrax97b crack97b; 
  array new10 {*} popc97 nuts97 fufrt97 gcrax97 crack97; 
  do i=1 to DIM(old10);
  if old10(i)=1 then new10(i)=0;
  else if old10(i)=2 then new10(i)=0.07;
  else if old10(i)=3 then new10(i)=0.36;
  else if old10(i)=4 then new10(i)=0.71;
  else if old10(i)=5 then new10(i)=.;
  else old10(i)=0;
  end;

  if itea97b =1 then itea97 =0;
    else if itea97b =2 then itea97 =0.07;
    else if itea97b =3 then itea97 =0.36;
    else if itea97b =4 then itea97 =0.79;
    else if itea97b =5 then itea97 =2;
    else if itea97b =6 then itea97 =.;
    else itea97 =0;

  if milk97b=1 then milk97=0;
    else if milk97b=2 then milk97=0.14;
    else if milk97b=3 then milk97=0.57;
    else if milk97b=4 then milk97=1;
    else if milk97b=5 then milk97=2.5;
    else if milk97b=6 then milk97=4;
    else if milk97b=7 then milk97=.;
    else milk97=0;

  if chocm97b=1 then chocm97=0;
    else if chocm97b=2 then chocm97=0.07;
    else if chocm97b=3 then chocm97=0.14;
    else if chocm97b=4 then chocm97=0.57;
    else if chocm97b=5 then chocm97=1.5;
    else if chocm97b=6 then chocm97=3;
    else if chocm97b=7 then chocm97=.;
    else chocm97=0;

  if liver97b=1 then liver97=0;
    else if liver97b=2 then liver97=0.02;
    else if liver97b=3 then liver97=0.03;
    else if liver97b=4 then liver97=0.08;
    else if liver97b=5 then liver97=0.29;
    else if liver97b=6 then liver97=.;
    else liver97=0;

  if frtoa97b=1 then frtoa97=0;
  	else if frtoa97b=2 then frtoa97=0.07;
	else if frtoa97b=3 then frtoa97=0.14;
	else if frtoa97b=4 then frtoa97=0.43;
	else if frtoa97b=5 then frtoa97=2;
	else if frtoa97b=6 then frtoa97=.;
	else frtoa97=0;

 if gravy97b=1 then gravy97=0;
  else if gravy97b=2 then gravy97=0.07;
  else if gravy97b=3 then gravy97=0.57;
  else if gravy97b=4 then gravy97=1;
  else if gravy97b=5 then gravy97=2;
  else if gravy97b=6 then gravy97=.;
  else gravy97=0;

  if beans97b=1 then beans97=0;
  else if beans97b=2 then beans97=0.14;
  else if beans97b=3 then beans97=0.57;
  else if beans97b=4 then beans97=1;
  else if beans97b=5 then beans97=.;
  else beans97=0;

  if popt97b=1 then popt97=0;
  else if popt97b=2 then popt97=0.07;
  else if popt97b=3 then popt97=0.5;
  else if popt97b=4 then popt97=2;
  else if popt97b=5 then popt97=.;
  else popt97=0;

  if cooki97b=1 then cooki97=0;
  else if cooki97b=2 then cooki97=0.07;
  else if cooki97b=3 then cooki97=0.14;
  else if cooki97b=4 then cooki97=0.57;
  else if cooki97b=5 then cooki97=2;
  else if cooki97b=6 then cooki97=4;
  else if cooki97b=7 then cooki97=.;
  else cooki97=0;

   promeat97   = sum (cburg97, burg97, taco97, chnug97, dog97, sbol97, meatb97, bacon97);
   redmeat97   = sum (srb97, beef97, pork97);
   orgmeat97   = sum (liver97 );
   fish97      = sum (stuna97, fishs97, ofish97, shrim97);
   poult97     = sum (sturk97, chick97);
   eggs97      = sum (eggs97 );
   butter97    = sum (but97 );
   marg97      = sum (marg97 );
   lowdai97    = sum (chocm97, yog97, cotch97, fryog97 );
   highdai97   = sum (milk97, othch97, crch97, icecr97);
   wine97      = sum (wine97 );
   liquor97    = sum (liq97 );
   beer97      = sum (beer97 );
   tea97       = sum (itea97, tea97);
   coffee97    = sum (coff97 );
   fruit97     = sum (rais97, grape97, ban97, apple97, melon97, pear97, orang97, straw97, peach97, fufrt97);
   fruju97     = sum (oj97, aj97 );
   cruveg97    = sum (brocc97, slaw97);
   yelveg97    = sum (yams97, ccar97, rcar97 );
   tomato97    = sum (tom97 );
   leafveg97   = sum (spin97, kale97, lett97 );
   legume97    = sum (tofu97, sbean97, beans97, peas97 );
   othveg97    = sum (mixv97, grpep97, eggpl97, celry97);
   potato97    = sum (mashp97, psald97);
   french97    = sum (fries97);
   wholeg97    = sum (cer97, ckcer97, whbr97, drbr97, engl97, cornb97, otgrn97, corn97, gcrax97);
   refing97    = sum (lasag97, macch97, spag97, frtoa97, grlch97, eggro97, bisc97, rice97, pasta97, torti97, panca97);
   pizza97     = sum (pizza97 );
   sugdrk97    = sum (coke97, punch97, instb97, frapp97 );
   lowdrk97    = sum (local97 );
   snack97     = sum (pchip97, cchip97, nacho97, popc97, pretz97, crack97  );
   nuts97      = sum (spj97, nuts97, seeds97);
   mayo97      = sum (mayo97 );
   dress97     = sum (lcsdr97, saldr97);
   crmsoup97   = sum (chowd97, soup97); 
   sweets97    = sum (popt97, cake97, twink97, sroll97, donut97, cooki97, brwni97, pie97, choco97, cdyw97, cdywo97, jello97, pudd97, pops97);
   condim97    = sum (gravy97, ketch97, salsa97);

keep yrq97 id momid 
		promeat97   redmeat97  orgmeat97   fish97    poult97    eggs97     butter97    
  		marg97      lowdai97   highdai97   wine97    liquor97   beer97     tea97       
  		coffee97    fruit97    fruju97     cruveg97  yelveg97   tomato97   leafveg97   
  		legume97    othveg97   potato97    french97  wholeg97   refing97   pizza97    
  		sugdrk97    lowdrk97   snack97     nuts97    mayo97     dress97    crmsoup97   
  		sweets97    condim97      ;
run;

proc factor data=boys97 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f97;
	where promeat97 ne .;
	var promeat97   redmeat97  orgmeat97   fish97    poult97    eggs97     butter97    
  		marg97      lowdai97   highdai97   wine97    liquor97   beer97     tea97       
  		coffee97    fruit97    fruju97     cruveg97  yelveg97   tomato97   leafveg97   
  		legume97    othveg97   potato97    french97  wholeg97   refing97   pizza97    
  		sugdrk97    lowdrk97   snack97     nuts97    mayo97     dress97    crmsoup97   
  		sweets97    condim97  ; 
data f97; set f97 ( keep=id factor1 factor2 
				rename=(factor1=f197 factor2=f297));
proc sort; by id;  run;


**********************************************************************************************************
Calling in 1998 boys keeping variables for analysis
*******************************************************************************************************;
%boys98 (keep= yr98b id momid
local98b coke98b punch98b tea98b coff98b beer98b wine98b liq98b
milk98b chocm98b instb98b yog98b cotch98b othch98b crch98b but98b marg98b
cburg98b burg98b pizza98b taco98b chnug98b dog98b spj98b sturk98b srb98b sbol98b stuna98b
chick98b fishs98b ofish98b shrim98b beef98b pork98b meatb98b lasag98b macch98b grlch98b spag98b
eggs98b bacon98b gravy98b ketch98b chowd98b soup98b mayo98b lcsdr98b saldr98b salsa98b
cer98b ckcer98b whbr98b drbr98b engl98b muff98b pasta98b rice98b bisc98b torti98b panca98b
fries98b mashp98b rais98b grape98b ban98b apple98b melon98b pear98b orang98b straw98b peach98b oj98b aj98b
tom98b tofu98b sbean98b beans98b brocc98b corn98b peas98b mixv98b spin98b kale98b grpep98b
yams98b eggpl98b ccar98b rcar98b lett98b slaw98b psal98b
pchip98b cchip98b nacho98b popc98b pretz98b nuts98b fufrt98b gcrax98b crack98b popt98b
cake98b twink98b pie98b sroll98b cooki98b brwni98b choco98b cdywo98b pudd98b
fryog98b icecr98b frapp98b pops98b powrb98b protb98b );

yr98b=1;
proc sort nodupkey data=boys98; by id; run;

data boys98; set boys98;

  array old1 {*} local98b coke98b punch98b othch98b;
  array new1 {*} local98 coke98 punch98 othch98;
  do i=1 to DIM(old1);
  if old1(i)=1 then new1(i)=0;
  else if old1(i)=2 then new1(i)=0.07;
  else if old1(i)=3 then new1(i)=0.14;
  else if old1(i)=4 then new1(i)=0.57;
  else if old1(i)=5 then new1(i)=1;
  else if old1(i)=6 then new1(i)=2.5;
  else if old1(i)=7 then new1(i)=4;
  else if old1(i)=8 then new1(i)=.;
  else new1(i)=0;
  end;

  array old2 {*} tea98b coff98b;
  array new2 {*} tea98 coff98;
  do i=1 to DIM(old2);
  if old2(i)=1 then new2(i)=0;
  else if old2(i)=2 then new2(i)=0.07;
  else if old2(i)=3 then new2(i)=0.21;
  else if old2(i)=4 then new2(i)=0.64;
  else if old2(i)=5 then new2(i)=2;
  else if old2(i)=6 then new2(i)=.;
  else new2(i)=0;
  end;

  array old3 {*} cotch98b fishs98b shrim98b lasag98b macch98b soup98b 
                 otgrn98b panca98b melon98b slaw98b psal98b nacho98b pretz98b cake98b pie98b frapp98b;
  array new3 {*} cotch98 fishs98 shrim98 lasag98 macch98 soup98 
                 otgrn98 panca98 melon98 slaw98 psal98 nacho98 pretz98 cake98 pie98 frapp98;
  do i=1 to DIM(old3);
  if old3(i)=1 then new3(i)=0;
  else if old3(i)=2 then new3(i)=0.07;
  else if old3(i)=3 then new3(i)=0.14;
  else if old3(i)=4 then new3(i)=0.29;
  else if old3(i)=5 then new3(i)=.;
  else new3(i)=0;
  end;

  array old4 {*} instb98b cburg98b burg98b pizza98b taco98b chnug98b dog98b
                  spj98b sturk98b srb98b sbol98b stuna98b chick98b ofish98b beef98b pork98b 
                  meatb98b grlch98b spag98b eggs98b bacon98b ketch98b engl98b
                  muff98b fries98b mashp98b pasta98b rice98b bisc98b torti98b rais98b
                  grape98b ban98b straw98b peach98b tofu98b sbean98b brocc98b corn98b 
                  peas98b mixv98b spin98b kale98b grpep98b yams98b eggpl98b ccar98b rcar98b 
                  brwni98b pudd98b fryog98b icecr98b pops98b powrb98b protb98b;
  array new4 {*} instb98 cburg98 burg98 pizza98 taco98 chnug98 dog98
                  spj98 sturk98 srb98 sbol98 stuna98 chick98 ofish98 beef98 pork98
                  meatb98 grlch98 spag98 eggs98 bacon98 ketch98 engl98
                  muff98 fries98 mashp98 pasta98 rice98 bisc98 torti98 rais98 
                  grape98 ban98 straw98 peach98 tofu98 sbean98 brocc98 corn98
                  peas98 mixv98 spin98 kale98 grpep98 yams98 eggpl98 ccar98 rcar98 
                  brwni98 pudd98 fryog98 icecr98 pops98 powrb98 protb98;
  do i=1 to DIM(old4);
  if old4(i)=1 then new4(i)=0;
  else if old4(i)=2 then new4(i)=0.07;
  else if old4(i)=3 then new4(i)=0.14;
  else if old4(i)=4 then new4(i)=0.43;
  else if old4(i)=5 then new4(i)=0.71;
  else if old4(i)=6 then new4(i)=.;
  else new4(i)=0;
  end;

  array old5 {*} yog98b crch98b oj98b aj98b;
  array new5 {*} yog98 crch98 oj98 aj98;
  do i=1 to DIM(old5);
  if old5(i)=1 then new5(i)=0;
  else if old5(i)=2 then new5(i)=0.07;
  else if old5(i)=3 then new5(i)=0.14;
  else if old5(i)=4 then new5(i)=0.57;
  else if old5(i)=5 then new5(i)=1;
  else if old5(i)=6 then new5(i)=2;
  else if old5(i)=7 then new5(i)=.;
  else new5(i)=0;
  end;

  array old6 {*} but98b marg98b;
  array new6 {*} but98 marg98;
  do i=1 to DIM(old6);
  if old6(i)=1 then new6(i)=0;
  else if old6(i)=2 then new6(i)=0.07;
  else if old6(i)=3 then new6(i)=0.14;
  else if old6(i)=4 then new6(i)=0.57;
  else if old6(i)=5 then new6(i)=1;
  else if old6(i)=6 then new6(i)=3;
  else if old6(i)=7 then new6(i)=5;
  else if old6(i)=8 then new6(i)=.;
  else new6(i)=0;
  end;

  array old7 {*} beer98b wine98b liq98b chowd98b mayo98b lcsdr98b saldr98b salsa98b apple98b pear98b orang98b
                tom98b lett98b pchip98b cchip98b twink98b sroll98b choco98b cdywo98b;
  array new7 {*} beer98 wine98 liq98 chowd98 mayo98 lcsdr98 saldr98 salsa98 apple98 pear98 orang98
                tom98 lett98 pchip98 cchip98 twink98 sroll98 choco98 cdywo98;
  do i=1 to DIM(old7);
  if old7(i)=1 then new7(i)=0;
    else if old7(i)=2 then new7(i)=0.07;
    else if old7(i)=3 then new7(i)=0.14;
    else if old7(i)=4 then new7(i)=0.57;
    else if old7(i)=5 then new7(i)=2;
    else if old7(i)=6 then new7(i)=.;
    else new7(i)=0;
	end;

  array old8 {*} cer98b ckcer98b;
  array new8 {*} cer98 ckcer98;
  do i=1 to DIM(old8);
  if old8(i)=1 then new8(i)=0;
    else if old8(i)=2 then new8(i)=0.07;
    else if old8(i)=3 then new8(i)=0.14;
    else if old8(i)=4 then new8(i)=0.43;
    else if old8(i)=5 then new8(i)=0.86;
    else if old8(i)=6 then new8(i)=2;
    else if old8(i)=7 then new8(i)=.;
    else new8(i)=0;
	end;

  array old9 {*} whbr98b drbr98b;
  array new9 {*} whbr98 drbr98;
  do i=1 to DIM(old9);
  if old9(i)=1 then new9(i)=0;
    else if old9(i)=2 then new9(i)=0.07;
    else if old9(i)=3 then new9(i)=0.43;
    else if old9(i)=4 then new9(i)=0.86;
    else if old9(i)=5 then new9(i)=2.5;
    else if old9(i)=6 then new9(i)=4;
    else if old9(i)=7 then new9(i)=.;
    else new9(i)=0;
	end;

  array old10 {*} popc98b nuts98b fufrt98b gcrax98b crack98b; 
  array new10 {*} popc98 nuts98 fufrt98 gcrax98 crack98; 
  do i=1 to DIM(old10);
  if old10(i)=1 then new10(i)=0;
  else if old10(i)=2 then new10(i)=0.07;
  else if old10(i)=3 then new10(i)=0.36;
  else if old10(i)=4 then new10(i)=0.71;
  else if old10(i)=5 then new10(i)=.;
  else old10(i)=0;
  end;

  if milk98b=1 then milk98=0;
    else if milk98b=2 then milk98=0.14;
    else if milk98b=3 then milk98=0.57;
    else if milk98b=4 then milk98=1;
    else if milk98b=5 then milk98=2.5;
    else if milk98b=6 then milk98=4;
    else if milk98b=7 then milk98=.;
    else milk98=0;

  if chocm98b=1 then chocm98=0;
    else if chocm98b=2 then chocm98=0.07;
    else if chocm98b=3 then chocm98=0.14;
    else if chocm98b=4 then chocm98=0.57;
    else if chocm98b=5 then chocm98=1.5;
    else if chocm98b=6 then chocm98=3;
    else if chocm98b=7 then chocm98=.;
    else chocm98=0;

 if gravy98b=1 then gravy98=0;
  else if gravy98b=2 then gravy98=0.07;
  else if gravy98b=3 then gravy98=0.57;
  else if gravy98b=4 then gravy98=1;
  else if gravy98b=5 then gravy98=2;
  else if gravy98b=6 then gravy98=.;
  else gravy98=0;

  if beans98b=1 then beans98=0;
  else if beans98b=2 then beans98=0.14;
  else if beans98b=3 then beans98=0.57;
  else if beans98b=4 then beans98=1;
  else if beans98b=5 then beans98=.;
  else beans98=0;

  if popt98b=1 then popt98=0;
  else if popt98b=2 then popt98=0.07;
  else if popt98b=3 then popt98=0.5;
  else if popt98b=4 then popt98=2;
  else if popt98b=5 then popt98=.;
  else popt98=0;

  if cooki98b=1 then cooki98=0;
  else if cooki98b=2 then cooki98=0.07;
  else if cooki98b=3 then cooki98=0.14;
  else if cooki98b=4 then cooki98=0.57;
  else if cooki98b=5 then cooki98=2;
  else if cooki98b=6 then cooki98=4;
  else if cooki98b=7 then cooki98=.;
  else cooki98=0;

   promeat98   = sum (cburg98, burg98, taco98, chnug98, dog98, sbol98, meatb98, bacon98);
   redmeat98   = sum (srb98, beef98, pork98);
   fish98      = sum (stuna98, fishs98, ofish98, shrim98);
   poult98     = sum (sturk98, chick98);
   eggs98      = sum (eggs98 );
   butter98    = sum (but98 );
   marg98      = sum (marg98 );
   lowdai98    = sum (chocm98, yog98, cotch98, fryog98 );
   highdai98   = sum (milk98, othch98, crch98, icecr98);
   wine98      = sum (wine98 );
   liquor98    = sum (liq98 );
   beer98      = sum (beer98 );
   tea98       = sum (tea98);
   coffee98    = sum (coff98 );
   fruit98     = sum (rais98, grape98, ban98, apple98, melon98, pear98, orang98, straw98, peach98, fufrt98);
   fruju98     = sum (oj98, aj98 );
   cruveg98    = sum (brocc98, slaw98);
   yelveg98    = sum (yams98, ccar98, rcar98 );
   tomato98    = sum (tom98 );
   leafveg98   = sum (spin98, kale98, lett98 );
   legume98    = sum (tofu98, sbean98, beans98, peas98 );
   othveg98    = sum (mixv98, grpep98, eggpl98 );
   potato98    = sum (mashp98, psal98);
   french98    = sum (fries98);
   wholeg98    = sum (cer98, ckcer98, whbr98, drbr98, engl98, otgrn98, corn98, gcrax98);
   refing98    = sum (lasag98, macch98, spag98, grlch98, bisc98, rice98, pasta98, torti98, panca98);
   pizza98     = sum (pizza98 );
   sugdrk98    = sum (coke98, punch98, instb98, frapp98 );
   lowdrk98    = sum (local98 );
   snack98     = sum (pchip98, cchip98, nacho98, popc98, pretz98, crack98  );
   nuts98      = sum (spj98, nuts98 );
   mayo98      = sum (mayo98 );
   dress98     = sum (lcsdr98, saldr98);
   crmsoup98   = sum (chowd98, soup98); 
   sweets98    = sum (popt98, cake98, twink98, sroll98, cooki98, brwni98, pie98, choco98, cdywo98, pudd98, pops98, muff98, powrb98, protb98);
   condim98    = sum (gravy98, ketch98, salsa98);

keep yr98b id momid 
		promeat98   redmeat98   fish98    poult98    eggs98     butter98    
  		marg98      lowdai98   highdai98   wine98    liquor98   beer98     tea98       
  		coffee98    fruit98    fruju98     cruveg98  yelveg98   tomato98   leafveg98   
  		legume98    othveg98   potato98    french98  wholeg98   refing98   pizza98    
  		sugdrk98    lowdrk98   snack98     nuts98    mayo98     dress98    crmsoup98   
  		sweets98    condim98      ;
run;

proc factor data=boys98 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f98;
	where promeat98 ne .;
	var promeat98   redmeat98   fish98    poult98    eggs98     butter98    
  		marg98      lowdai98   highdai98   wine98    liquor98   beer98     tea98       
  		coffee98    fruit98    fruju98     cruveg98  yelveg98   tomato98   leafveg98   
  		legume98    othveg98   potato98    french98  wholeg98   refing98   pizza98    
  		sugdrk98    lowdrk98   snack98     nuts98    mayo98     dress98    crmsoup98   
  		sweets98    condim98    ; 
data f98; set f98 ( keep=id factor1 factor2 
				rename=(factor1=f198 factor2=f298));
proc sort; by id;  run;


*********************************************************************
Calling in Boys01 keeping variables for analysis
*******************************************************************;
%boys01 (keep= boys01 yrq01 id momid
local01b coke01b punch01b tea01b coff01b beer01b wine01b liq01b
milk01b chocm01b instb01b yog01b cotch01b othch01b crch01b but01b marg01b
cburg01b burg01b pizza01b taco01b chnug01b dog01b spj01b sturk01b srb01b sbol01b stuna01b
chick01b fishs01b ofish01b shrim01b beef01b pork01b meatb01b lasag01b macch01b grlch01b spag01b
eggs01b bacon01b gravy01b ketch01b chowd01b soup01b mayo01b lcsdr01b saldr01b salsa01b
cer01b ckcer01b whbr01b dbr01b engl01b muff01b panca01b fries01b mashp01b pasta01b rice01b bisc01b torti01b
rais01b grape01b ban01b apple01b melon01b pear01b orang01b straw01b peach01b oj01b aj01b
tom01b tofu01b sbean01b beans01b brocc01b corn01b peas01b mveg01b spin01b kale01b grpep01b
yams01b eggpl01b ccar01b rcar01b lett01b slaw01b psald01b
pchip01b cchip01b nacho01b popc01b pretz01b nuts01b fufrt01b gcrax01b crack01b popt01b
cake01b twink01b pie01b sroll01b cooki01b brwni01b choco01b cdywo01b pudd01b
fryog01b icecr01b frapp01b pops01b powrb01b protb01b );

yrq01=1; boys01=1;
proc sort nodupkey data=boys01; by id; run;

data boys01; set boys01;

  array old1 {*} local01b coke01b punch01b tea01b coff01b beer01b wine01b liq01b milk01b chocm01b instb01b 
				 yog01b cotch01b othch01b crch01b but01b marg01b cburg01b burg01b pizza01b taco01b chnug01b dog01b
                 spj01b sturk01b srb01b sbol01b stuna01b chick01b fishs01b ofish01b shrim01b beef01b pork01b
				 meatb01b lasag01b macch01b grlch01b spag01b eggs01b bacon01b gravy01b ketch01b chowd01b
				 soup01b mayo01b lcsdr01b saldr01b salsa01b cer01b ckcer01b whbr01b dbr01b engl01b muff01b panca01b
				 fries01b  mashp01b pasta01b rice01b bisc01b torti01b rais01b grape01b ban01b apple01b melon01b 
				 pear01b orang01b straw01b peach01b oj01b aj01b tom01b tofu01b sbean01b beans01b
				 brocc01b corn01b peas01b mveg01b spin01b kale01b grpep01b yams01b eggpl01b ccar01b rcar01b 
  				 lett01b slaw01b psald01b pchip01b cchip01b nacho01b popc01b pretz01b nuts01b fufrt01b 
				 gcrax01b crack01b popt01b cake01b twink01b pie01b sroll01b cooki01b
				 brwni01b choco01b cdywo01b pudd01b fryog01b icecr01b frapp01b pops01b powrb01b protb01b;
  array new1 {*} local01 coke01 punch01 tea01 coff01 beer01 wine01 liq01 milk01 chocm01 instb01 
				 yog01 cotch01 othch01 crch01 but01 marg01 cburg01 burg01 pizza01 taco01 chnug01 dog01
                 spj01 sturk01 srb01 sbol01 stuna01 chick01 fishs01 ofish01 shrim01 beef01 pork01
				 meatb01 lasag01 macch01 grlch01 spag01 eggs01 bacon01 gravy01 ketch01 chowd01
				 soup01 mayo01 lcsdr01 saldr01 salsa01 cer01 ckcer01 whbr01 dbr01 engl01 muff01 panca01
				 fries01 mashp01 pasta01 rice01 bisc01 torti01 rais01 grape01 ban01 apple01 melon01
				 pear01 orang01 straw01 peach01 oj01 aj01 tom01 tofu01 sbean01 beans01
				 brocc01 corn01 peas01 mveg01 spin01 kale01 grpep01 yams01 eggpl01 ccar01 rcar01 
  				 lett01 slaw01 psald01 pchip01 cchip01 nacho01 popc01 pretz01 nuts01 fufrt01 
				 gcrax01 crack01 popt01 cake01 twink01 pie01 sroll01 cooki01
				 brwni01 choco01 cdywo01 pudd01 fryog01 icecr01 frapp01 pops01 powrb01 protb01;

  do i=1 to DIM(old1);
  if old1(i)=1 then new1(i)=0;
  else if old1(i)=2 then new1(i)=0.07;
  else if old1(i)=3 then new1(i)=0.14;
  else if old1(i)=4 then new1(i)=0.57;
  else if old1(i)=5 then new1(i)=1;
  else if old1(i)=6 then new1(i)=2.5;
  else if old1(i)=7 then new1(i)=4;
  else if old1(i)=8 then new1(i)=.;
  else new1(i)=0;
  end;

   promeat01   = sum (cburg01, burg01, taco01, chnug01, dog01, sbol01, meatb01, bacon01);
   redmeat01   = sum (srb01, beef01, pork01);
   fish01      = sum (stuna01, fishs01, ofish01, shrim01);
   poult01     = sum (sturk01, chick01);
   eggs01      = sum (eggs01 );
   butter01    = sum (but01 );
   marg01      = sum (marg01 );
   lowdai01    = sum (chocm01, yog01, cotch01, fryog01 );
   highdai01   = sum (milk01, othch01, crch01, icecr01);
   wine01      = sum (wine01 );
   liquor01    = sum (liq01 );
   beer01      = sum (beer01 );
   tea01       = sum (tea01);
   coffee01    = sum (coff01 );
   fruit01     = sum (rais01, grape01, ban01, apple01, melon01, pear01, orang01, straw01, peach01, fufrt01);
   fruju01     = sum (oj01, aj01 );
   cruveg01    = sum (brocc01, slaw01);
   yelveg01    = sum (yams01, ccar01, rcar01 );
   tomato01    = sum (tom01 );
   leafveg01   = sum (spin01, kale01, lett01 );
   legume01    = sum (tofu01, sbean01, beans01, peas01 );
   othveg01    = sum (mveg01, grpep01, eggpl01 );
   potato01    = sum (mashp01, psald01);
   french01    = sum (fries01);
   wholeg01    = sum (cer01, ckcer01, whbr01, dbr01, engl01, corn01, gcrax01);
   refing01    = sum (lasag01, macch01, spag01, grlch01, bisc01, rice01, pasta01, torti01, panca01);
   pizza01     = sum (pizza01 );
   sugdrk01    = sum (coke01, punch01, instb01, frapp01 );
   lowdrk01    = sum (local01 );
   snack01     = sum (pchip01, cchip01, nacho01, popc01, pretz01, crack01  );
   nuts01      = sum (spj01, nuts01 );
   mayo01      = sum (mayo01 );
   dress01     = sum (lcsdr01, saldr01);
   crmsoup01   = sum (chowd01, soup01); 
   sweets01    = sum (popt01, cake01, twink01, sroll01, cooki01, brwni01, pie01, choco01, cdywo01, pudd01, pops01, muff01, powrb01, protb01);
   condim01    = sum (gravy01, ketch01, salsa01);

keep yrq01 id momid 
		promeat01   redmeat01   fish01    poult01    eggs01     butter01    
  		marg01      lowdai01   highdai01   wine01    liquor01   beer01     tea01       
  		coffee01    fruit01    fruju01     cruveg01  yelveg01   tomato01   leafveg01   
  		legume01    othveg01   potato01    french01  wholeg01   refing01   pizza01    
  		sugdrk01    lowdrk01   snack01     nuts01    mayo01     dress01    crmsoup01   
  		sweets01    condim01      ;

run;

proc factor data=boys01 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f01;
	where promeat01 ne .;
	var promeat01   redmeat01   fish01    poult01    eggs01     butter01    
  		marg01      lowdai01   highdai01   wine01    liquor01   beer01     tea01       
  		coffee01    fruit01    fruju01     cruveg01  yelveg01   tomato01   leafveg01   
  		legume01    othveg01   potato01    french01  wholeg01   refing01   pizza01    
  		sugdrk01    lowdrk01   snack01     nuts01    mayo01     dress01    crmsoup01   
  		sweets01    condim01    ; 
data f01; set f01 ( keep=id factor1 factor2 
				rename=(factor1=f101 factor2=f201));
proc sort; by id;  run;

/*******************************************************
Calling in Boys04 keeping variables for analysis
*****************************************************/
%boys204 (keep= id yr204b momid
local204b coke204b punch204b spdrk204b tea204b coff204b beer204b wine204b liq204b
milk204b chocm204b instb204b yog204b cotch204b othch204b crch204b but204b marg204b
cburg204b burg204b pizza204b taco204b chnug204b dog204b spj204b sturk204b srb204b sbol204b stuna204b
chick204b fishs204b ofish204b shrim204b beef204b pork204b meatb204b lasag204b macch204b spag204b
eggs204b bacon204b liver204b frtoa204b grlch204b eggro204b gravy204b ketch204b chowd204b soup204b mayo204b lcsdr204b saldr204b salsa204b
cer204b oat204b ckcer204b whbr204b dkbr204b engl204b muff204b cornb204b bisc204b rice204b pasta204b torti204b panca204b
fries204b mashp204b rais204b grape204b ban204b apple204b melon204b pear204b orang204b straw204b peach204b oj204b aj204b
tom204b tofu204b sbean204b beans204b brocc204b corn204b peas204b mixv204b spin204b kale204b grpep204b
yams204b eggpl204b ccar204b rcar204b celry204b lett204b slaw204b psald204b
pchip204b cchip204b popc204b pretz204b nuts204b fufrt204b gcrax204b crack204b popt204b
cake204b twink204b sroll204b donut204b cooki204b brwni204b pie204b choco204b cdyw204b cdywo204b jello204b pudd204b
fryog204b icecr204b frapp204b pops204b seeds204b powrb204b protb204b );

yr204b=1;
proc sort nodupkey data=boys204; by id; run;

data boys204; set boys204; 
 
  array old1 {*} local204b coke204b punch204b othch204b whbr204b dkbr204b;
  array new1 {*} local204 coke204 punch204 othch204 whbr204 dkbr204;

  do i=1 to DIM(old1);
  if old1(i)=1 then new1(i)=0;
  else if old1(i)=2 then new1(i)=0.07;
  else if old1(i)=3 then new1(i)=0.14;
  else if old1(i)=4 then new1(i)=0.57;
  else if old1(i)=5 then new1(i)=1;
  else if old1(i)=6 then new1(i)=2.5;
  else if old1(i)=7 then new1(i)=4;
  else if old1(i)=8 then new1(i)=.;
  else new1(i)=0;
  end;

  if spdrk204b=1 then spdrk204=0;
	else if spdrk204b=2 then spdrk204=0.07;
	else if spdrk204b=3 then spdrk204=0.36;
	else if spdrk204b=4 then spdrk204=0.79;
	else if spdrk204b=5 then spdrk204=2; 
	else if spdrk204b=6 then spdrk204=.;
	else spdrk204=0;

  array old2{*} tea204b coff204b;
  array new2{*} tea204 coff204;
	 do i=1 to DIM(old2);
	  if old2(i)=1 then new2(i)=0;
	  else if old2(i)=2 then new2(i)=0.07;
	  else if old2(i)=3 then new2(i)=0.21;
	  else if old2(i)=4 then new2(i)=0.64;
	  else if old2(i)=5 then new2(i)=2;
	  else if old2(i)=6 then new2(i)=.;
	  else new2(i)=0;
	  end;

  array old3{*} beer204b wine204b liq204b chowd204b mayo204b lcsdr204b saldr204b salsa204b apple204b pear204b 
				orang204b tom204b beans204b lett204b pchip204b cchip204b popt204b twink204b donut204b
				choco204b cdyw204b cdywo204b;
  array new3{*} beer204 wine204 liq204 chowd204 mayo204 lcsdr204 saldr204 salsa204 apple204 pear204 
				orang204 tom204 beans204 lett204 pchip204 cchip204 popt204 twink204 donut204
				choco204 cdyw204 cdywo204;
  	 do i=1 to DIM(old3);
	  if old3(i)=1 then new3(i)=0;
	  else if old3(i)=2 then new3(i)=0.07;
	  else if old3(i)=3 then new3(i)=0.14;
	  else if old3(i)=4 then new3(i)=0.57;
	  else if old3(i)=5 then new3(i)=2;
	  else if old3(i)=6 then new3(i)=.;
	  else new3(i)=0;
	  end;

  if milk204b=1 then milk204=0;
  	else if milk204b=2 then milk204=0.07;
	else if milk204b=3 then milk204=0.57;
	else if milk204b=4 then milk204=1;
	else if milk204b=5 then milk204=2.5;
	else if milk204b=6 then milk204=4;
	else if milk204b=7 then milk204=.;
	else milk204=0;

  if chocm204b=1 then chocm204=0;
   	else if chocm204b=2 then chocm204=0.07;
	else if chocm204b=3 then chocm204=0.14;
	else if chocm204b=4 then chocm204=0.57;
	else if chocm204b=5 then chocm204=1.5;
	else if chocm204b=6 then chocm204=3;
	else if chocm204b=7 then chocm204=.;
	else chocm204=0;

array old6{*} instb204b cburg204b burg204b pizza204b taco204b chnug204b dog204b spj204b sturk204b srb204b sbol204b  
			stuna204b chick204b ofish204b beef204b pork204b meatb204b spag204b eggs204b bacon204b grlch204b
			eggro204b ketch204b engl204b muff204b cornb204b bisc204b rice204b pasta204b torti204b fries204b
			mashp204b rais204b grape204b ban204b straw204b peach204b tofu204b sbean204b brocc204b corn204b 
			peas204b mixv204b spin204b kale204b grpep204b yams204b eggpl204b ccar204b rcar204b celry204b popc204b
			nuts204b fufrt204b gcrax204b crack204b sroll204b brwni204b jello204b pudd204b fryog204b icecr204b
			pops204b seeds204b powrb204b protb204b;
array new6{*} instb204 cburg204 burg204 pizza204 taco204 chnug204 dog204 spj204 sturk204 srb204 sbol204  
			stuna204 chick204 ofish204 beef204 pork204 meatb204 spag204 eggs204 bacon204 grlch204
			eggro204 ketch204 engl204 muff204 cornb204 bisc204 rice204 pasta204 torti204 fries204
			mashp204 rais204 grape204 ban204 straw204 peach204 tofu204 sbean204 brocc204 corn204 
			peas204 mixv204 spin204 kale204 grpep204 yams204 eggpl204 ccar204 rcar204 celry204 popc204
			nuts204 fufrt204 gcrax204 crack204 sroll204 brwni204 jello204 pudd204 fryog204 icecr204
			pops204 seeds204 powrb204 protb204;
	do i=1 to DIM(old6);
	  if old6(i)=1 then new6(i)=0;
	  else if old6(i)=2 then new6(i)=0.07;
	  else if old6(i)=3 then new6(i)=0.14;
	  else if old6(i)=4 then new6(i)=0.43;
	  else if old6(i)=5 then new6(i)=0.71;
	  else if old6(i)=6 then new6(i)=.;
	  else new6(i)=0;
	  end;

array old4{*} yog204b crch204b oj204b aj204b;
array new4{*} yog204 crch204 oj204 aj204; 
	do i=1 to DIM(old4);
	  if old4(i)=1 then new4(i)=0;
	  else if old4(i)=2 then new4(i)=0.07;
	  else if old4(i)=3 then new4(i)=0.14;
	  else if old4(i)=4 then new4(i)=0.57;
	  else if old4(i)=5 then new4(i)=1;
	  else if old4(i)=6 then new4(i)=2;
	  else if old4(i)=7 then new4(i)=.;
	  else new4(i)=0;
	  end;

array old7{*} cotch204b fishs204b shrim204b lasag204b macch204b liver204b gravy204b soup204b panca204b melon204b
			slaw204b psald204b pretz204b cake204b pie204b frapp204b;
array new7{*} cotch204 fishs204 shrim204 lasag204 macch204 liver204 gravy204 soup204 panca204 melon204
			slaw204 psald204 pretz204 cake204 pie204 frapp204;
	do i=1 to DIM(old7);
	  if old7(i)=1 then new7(i)=0;
	  else if old7(i)=2 then new7(i)=0.07;
	  else if old7(i)=3 then new7(i)=0.14;
	  else if old7(i)=4 then new7(i)=0.29;
	  else if old7(i)=5 then new7(i)=.;
	  else new7(i)=0;
	  end;

array old5{*} but204b marg204b;
array new5{*} but204 marg204; 
	do i=1 to DIM(old5);
	  if old5(i)=1 then new5(i)=0;
	  else if old5(i)=2 then new5(i)=0.07;
	  else if old5(i)=3 then new5(i)=0.14;
	  else if old5(i)=4 then new5(i)=0.57;
	  else if old5(i)=5 then new5(i)=1;
	  else if old5(i)=6 then new5(i)=3;
	  else if old5(i)=7 then new5(i)=5;
	  else if old5(i)=8 then new5(i)=.;
	  else new5(i)=0;
	  end;

if frtoa204b=1 then frtoa204=0;
	else if frtoa204b=2 then frtoa204=0.07;
	else if frtoa204b=3 then frtoa204=0.14;
	else if frtoa204b=4 then frtoa204=0.43;
	else if frtoa204b=5 then frtoa204=2;
	else if frtoa204b=6 then frtoa204=.;
	else frtoa204=0;

  array old8 {*} cer204b oat204b ckcer204b;
  array new8 {*} cer204 oat204 ckcer204;
  do i=1 to DIM(old8);
  if old8(i)=1 then new8(i)=0;
    else if old8(i)=2 then new8(i)=0.07;
    else if old8(i)=3 then new8(i)=0.14;
    else if old8(i)=4 then new8(i)=0.43;
    else if old8(i)=5 then new8(i)=0.86;
    else if old8(i)=6 then new8(i)=2;
    else if old8(i)=7 then new8(i)=.;
    else new8(i)=0; 
	end;

  if cooki204b=1 then cooki204=0;
  	else if cooki204b=2 then cooki204=0.07;
	else if cooki204b=3 then cooki204=0.14;
	else if cooki204b=4 then cooki204=0.57;
	else if cooki204b=5 then cooki204=2;
	else if cooki204b=6 then cooki204=4;
	else if cooki204b=7 then cooki204=.;
	else cooki204=0;

   promeat204   = sum (cburg204, burg204, taco204, chnug204, dog204, sbol204, meatb204, bacon204);
   orgmeat204   = sum (liver204);
   redmeat204   = sum (srb204, beef204, pork204);
   fish204      = sum (stuna204, fishs204, ofish204, shrim204);
   poult204     = sum (sturk204, chick204);
   eggs204      = sum (eggs204 );
   butter204    = sum (but204 );
   marg204      = sum (marg204 );
   lowdai204    = sum (chocm204, yog204, cotch204, fryog204 );
   highdai204   = sum (milk204, othch204, crch204, icecr204);
   wine204      = sum (wine204 );
   liquor204    = sum (liq204 );
   beer204      = sum (beer204 );
   tea204       = sum (tea204);
   coffee204    = sum (coff204 );
   fruit204     = sum (rais204, grape204, ban204, apple204, melon204, pear204, orang204, straw204, peach204, fufrt204);
   fruju204     = sum (oj204, aj204 );
   cruveg204    = sum (brocc204, slaw204);
   yelveg204    = sum (yams204, ccar204, rcar204 );
   tomato204    = sum (tom204 );
   leafveg204   = sum (spin204, kale204, lett204 );
   legume204    = sum (tofu204, sbean204, beans204, peas204 );
   othveg204    = sum (mixv204, grpep204, eggpl204, celry204 );
   potato204    = sum (mashp204, psald204);
   french204    = sum (fries204);
   wholeg204    = sum (cer204, ckcer204, whbr204, dkbr204, engl204, corn204, gcrax204, oat204, cornb204);
   refing204    = sum (lasag204, macch204, spag204, grlch204, bisc204, rice204, pasta204, torti204, panca204, frtoa204, eggro204);
   pizza204     = sum (pizza204 );
   sugdrk204    = sum (coke204, punch204, instb204, frapp204, spdrk204 );
   lowdrk204    = sum (local204 );
   snack204     = sum (pchip204, cchip204, popc204, pretz204, crack204  );
   nuts204      = sum (spj204, nuts204, seeds204);
   mayo204      = sum (mayo204 );
   dress204     = sum (lcsdr204, saldr204);
   crmsoup204   = sum (chowd204, soup204); 
   sweets204    = sum (popt204, cake204, twink204, sroll204, cooki204, brwni204, pie204, choco204, cdyw204, cdywo204, pudd204, pops204, muff204, powrb204, protb204, donut204, jello204);
   condim204    = sum (gravy204, ketch204, salsa204);

keep yr204b id momid
		promeat204   redmeat204  orgmeat204   fish204    poult204    eggs204     butter204    
  		marg204      lowdai204   highdai204   wine204    liquor204   beer204     tea204       
  		coffee204    fruit204    fruju204     cruveg204  yelveg204   tomato204   leafveg204   
  		legume204    othveg204   potato204    french204  wholeg204   refing204   pizza204    
  		sugdrk204    lowdrk204   snack204     nuts204    mayo204     dress204    crmsoup204   
  		sweets204    condim204      ;

run;

proc factor data=boys204 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f04;
	where promeat204 ne .;
	var promeat204   redmeat204  orgmeat204   fish204    poult204    eggs204     butter204    
  		marg204      lowdai204   highdai204   wine204    liquor204   beer204     tea204       
  		coffee204    fruit204    fruju204     cruveg204  yelveg204   tomato204   leafveg204   
  		legume204    othveg204   potato204    french204  wholeg204   refing204   pizza204    
  		sugdrk204    lowdrk204   snack204     nuts204    mayo204     dress204    crmsoup204   
  		sweets204    condim204   ; 
data f04; set f04 ( keep=id factor1 factor2 
				rename=(factor1=f104 factor2=f204));
proc sort; by id;  run;

*************************************************
Calling Boys06 Keeping Variables for analysis
************************************************;
%boys206 (keep= id yr206b momid
local206b coke206b punch206b spdrk206b tea206b coff206b latte206b beer206b wine206b liq206b
milk206b chocm206b instb206b yog206b cotch206b othch206b crch206b but206b marg206b
cburg206b burg206b pizza206b taco206b chnug206b dog206b spj206b sturk206b srb206b sbol206b stuna206b
chick206b fishs206b ofish206b shrim206b beef206b pork206b meatb206b lasag206b macch206b spag206b
eggs206b bacon206b frtoa206b grlch206b eggro206b gravy206b ketch206b chowd206b soup206b mayo206b lcsdr206b saldr206b salsa206b
cer206b htcer206b whbr206b dkbr206b engl206b muff206b cornb206b bisc206b rice206b pasta206b torti206b panca206b
fries206b mashp206b rais206b grape206b ban206b apple206b melon206b pear206b orang206b straw206b peach206b oj206b aj206b
tom206b tofu206b sbean206b beans206b brocc206b corn206b peas206b mixv206b spin206b kale206b grpep206b
yams206b eggpl206b ccar206b rcar206b celry206b lett206b slaw206b psald206b
pchip206b cchip206b popc206b pretz206b nuts206b fufrt206b gcrax206b crack206b popt206b
cake206b twink206b sroll206b donut206b cooki206b brwni206b pie206b choco206b cdyw206b cdywo206b jello206b pudd206b
fryog206b icecr206b frapp206b pops206b seeds206b powrb206b protb206b);

yr06b=1;
proc sort nodupkey data=boys206; by id; run;

data boys206; set boys206;

  array old1 {*} local206b coke206b punch206b othch206b whbr206b dkbr206b;
  array new1 {*} local206 coke206 punch206 othch206 whbr206 dkbr206;

  do i=1 to DIM(old1);
  if old1(i)=1 then new1(i)=0;
  else if old1(i)=2 then new1(i)=0.07;
  else if old1(i)=3 then new1(i)=0.14;
  else if old1(i)=4 then new1(i)=0.57;
  else if old1(i)=5 then new1(i)=1;
  else if old1(i)=6 then new1(i)=2.5;
  else if old1(i)=7 then new1(i)=4;
  else if old1(i)=8 then new1(i)=.;
  else new1(i)=0;
  end;

  if spdrk206b=1 then spdrk206=0;
	else if spdrk206b=2 then spdrk206=0.07;
	else if spdrk206b=3 then spdrk206=0.36;
	else if spdrk206b=4 then spdrk206=0.79;
	else if spdrk206b=5 then spdrk206=2; 
	else if spdrk206b=6 then spdrk206=.;
	else spdrk206=0;

  array old2{*} tea206b coff206b latte206b;
  array new2{*} tea206 coff206 latte206;
	 do i=1 to DIM(old2);
	  if old2(i)=1 then new2(i)=0;
	  else if old2(i)=2 then new2(i)=0.07;
	  else if old2(i)=3 then new2(i)=0.21;
	  else if old2(i)=4 then new2(i)=0.64;
	  else if old2(i)=5 then new2(i)=2;
	  else if old2(i)=6 then new2(i)=.;
	  else new2(i)=0;
	  end;

  array old3{*} beer206b wine206b liq206b chowd206b soup206b mayo206b lcsdr206b saldr206b salsa206b 
				apple206b pear206b orang206b tom206b beans206b lett206b pchip206b cchip206b popt206b 
				twink206b donut206b choco206b cdyw206b cdywo206b;
  array new3{*} beer206 wine206 liq206 chowd206 soup206 mayo206 lcsdr206 saldr206 salsa206 
				apple206 pear206 orang206 tom206 beans206 lett206 pchip206 cchip206 popt206 
				twink206 donut206 choco206 cdyw206 cdywo206;
  	 do i=1 to DIM(old3);
	  if old3(i)=1 then new3(i)=0;
	  else if old3(i)=2 then new3(i)=0.07;
	  else if old3(i)=3 then new3(i)=0.14;
	  else if old3(i)=4 then new3(i)=0.57;
	  else if old3(i)=5 then new3(i)=2;
	  else if old3(i)=6 then new3(i)=.;
	  else new3(i)=0;
	  end;

  if milk206b=1 then milk206=0;
  	else if milk206b=2 then milk206=0.07;
	else if milk206b=3 then milk206=0.57;
	else if milk206b=4 then milk206=1;
	else if milk206b=5 then milk206=2.5;
	else if milk206b=6 then milk206=4;
	else if milk206b=7 then milk206=.;
	else milk206=0;

  if chocm206b=1 then chocm206=0;
   	else if chocm206b=2 then chocm206=0.07;
	else if chocm206b=3 then chocm206=0.14;
	else if chocm206b=4 then chocm206=0.57;
	else if chocm206b=5 then chocm206=1.5;
	else if chocm206b=6 then chocm206=3;
	else if chocm206b=7 then chocm206=.;
	else chocm206=0;

array old6{*} instb206b cburg206b burg206b pizza206b taco206b chnug206b dog206b spj206b sturk206b srb206b sbol206b  
			stuna206b chick206b ofish206b beef206b pork206b meatb206b spag206b eggs206b bacon206b grlch206b
			eggro206b ketch206b engl206b muff206b cornb206b bisc206b rice206b pasta206b torti206b fries206b
			mashp206b rais206b grape206b ban206b straw206b peach206b tofu206b sbean206b brocc206b corn206b 
			peas206b mixv206b spin206b kale206b grpep206b yams206b eggpl206b ccar206b rcar206b celry206b popc206b
			nuts206b fufrt206b gcrax206b crack206b sroll206b brwni206b jello206b pudd206b fryog206b icecr206b
			pops206b seeds206b powrb206b protb206b;
array new6{*} instb206 cburg206 burg206 pizza206 taco206 chnug206 dog206 spj206 sturk206 srb206 sbol206  
			stuna206 chick206 ofish206 beef206 pork206 meatb206 spag206 eggs206 bacon206 grlch206
			eggro206 ketch206 engl206 muff206 cornb206 bisc206 rice206 pasta206 torti206 fries206
			mashp206 rais206 grape206 ban206 straw206 peach206 tofu206 sbean206 brocc206 corn206 
			peas206 mixv206 spin206 kale206 grpep206 yams206 eggpl206 ccar206 rcar206 celry206 popc206
			nuts206 fufrt206 gcrax206 crack206 sroll206 brwni206 jello206 pudd206 fryog206 icecr206
			pops206 seeds206 powrb206 protb206;
	do i=1 to DIM(old6);
	  if old6(i)=1 then new6(i)=0;
	  else if old6(i)=2 then new6(i)=0.07;
	  else if old6(i)=3 then new6(i)=0.14;
	  else if old6(i)=4 then new6(i)=0.43;
	  else if old6(i)=5 then new6(i)=0.71;
	  else if old6(i)=6 then new6(i)=.;
	  else new6(i)=0;
	  end;

array old4{*} yog206b crch206b oj206b aj206b;
array new4{*} yog206 crch206 oj206 aj206; 
	do i=1 to DIM(old4);
	  if old4(i)=1 then new4(i)=0;
	  else if old4(i)=2 then new4(i)=0.07;
	  else if old4(i)=3 then new4(i)=0.14;
	  else if old4(i)=4 then new4(i)=0.57;
	  else if old4(i)=5 then new4(i)=1;
	  else if old4(i)=6 then new4(i)=2;
	  else if old4(i)=7 then new4(i)=.;
	  else new4(i)=0;
	  end;

array old7{*} cotch206b fishs206b shrim206b lasag206b macch206b gravy206b panca206b melon206b
			slaw206b psald206b pretz206b cake206b pie206b frapp206b;
array new7{*} cotch206 fishs206 shrim206 lasag206 macch206 gravy206 panca206 melon206
			slaw206 psald206 pretz206 cake206 pie206 frapp206;
	do i=1 to DIM(old7);
	  if old7(i)=1 then new7(i)=0;
	  else if old7(i)=2 then new7(i)=0.07;
	  else if old7(i)=3 then new7(i)=0.14;
	  else if old7(i)=4 then new7(i)=0.29;
	  else if old7(i)=5 then new7(i)=.;
	  else new7(i)=0;
	  end;

array old5{*} but206b marg206b;
array new5{*} but206 marg206; 
	do i=1 to DIM(old5);
	  if old5(i)=1 then new5(i)=0;
	  else if old5(i)=2 then new5(i)=0.07;
	  else if old5(i)=3 then new5(i)=0.14;
	  else if old5(i)=4 then new5(i)=0.57;
	  else if old5(i)=5 then new5(i)=1;
	  else if old5(i)=6 then new5(i)=3;
	  else if old5(i)=7 then new5(i)=5;
	  else if old5(i)=8 then new5(i)=.;
	  else new5(i)=0;
	  end;

if frtoa206b=1 then frtoa206=0;
	else if frtoa206b=2 then frtoa206=0.07;
	else if frtoa206b=3 then frtoa206=0.14;
	else if frtoa206b=4 then frtoa206=0.43;
	else if frtoa206b=5 then frtoa206=2;
	else if frtoa206b=6 then frtoa206=.;
	else frtoa206=0;

  array old8 {*} cer206b htcer206b ;
  array new8 {*} cer206 htcer206 ;
  do i=1 to DIM(old8);
  if old8(i)=1 then new8(i)=0;
    else if old8(i)=2 then new8(i)=0.07;
    else if old8(i)=3 then new8(i)=0.14;
    else if old8(i)=4 then new8(i)=0.43;
    else if old8(i)=5 then new8(i)=0.86;
    else if old8(i)=6 then new8(i)=2;
    else if old8(i)=7 then new8(i)=.;
    else new8(i)=0; 
	end;

  if cooki206b=1 then cooki206=0;
  	else if cooki206b=2 then cooki206=0.07;
	else if cooki206b=3 then cooki206=0.14;
	else if cooki206b=4 then cooki206=0.57;
	else if cooki206b=5 then cooki206=2;
	else if cooki206b=6 then cooki206=4;
	else if cooki206b=7 then cooki206=.;
	else cooki206=0;

   promeat206   = sum (cburg206, burg206, taco206, chnug206, dog206, sbol206, meatb206, bacon206);
   redmeat206   = sum (srb206, beef206, pork206);
   fish206      = sum (stuna206, fishs206, ofish206, shrim206);
   poult206     = sum (sturk206, chick206);
   eggs206      = sum (eggs206 );
   butter206    = sum (but206 );
   marg206      = sum (marg206 );
   lowdai206    = sum (chocm206, yog206, cotch206, fryog206 );
   highdai206   = sum (milk206, othch206, crch206, icecr206);
   wine206      = sum (wine206 );
   liquor206    = sum (liq206 );
   beer206      = sum (beer206 );
   tea206       = sum (tea206);
   coffee206    = sum (coff206, latte206);
   fruit206     = sum (rais206, grape206, ban206, apple206, melon206, pear206, orang206, straw206, peach206, fufrt206);
   fruju206     = sum (oj206, aj206 );
   cruveg206    = sum (brocc206, slaw206);
   yelveg206    = sum (yams206, ccar206, rcar206 );
   tomato206    = sum (tom206 );
   leafveg206   = sum (spin206, kale206, lett206 );
   legume206    = sum (tofu206, sbean206, beans206, peas206 );
   othveg206    = sum (mixv206, grpep206, eggpl206, celry206 );
   potato206    = sum (mashp206, psald206);
   french206    = sum (fries206);
   wholeg206    = sum (cer206, htcer206, whbr206, dkbr206, engl206, corn206, gcrax206, cornb206);
   refing206    = sum (lasag206, macch206, spag206, grlch206, bisc206, rice206, pasta206, torti206, panca206, frtoa206, eggro206);
   pizza206     = sum (pizza206 );
   sugdrk206    = sum (coke206, punch206, instb206, frapp206, spdrk206 );
   lowdrk206    = sum (local206 );
   snack206     = sum (pchip206, cchip206, popc206, pretz206, crack206  );
   nuts206      = sum (spj206, nuts206, seeds206);
   mayo206      = sum (mayo206 );
   dress206     = sum (lcsdr206, saldr206);
   crmsoup206   = sum (chowd206, soup206); 
   sweets206    = sum (popt206, cake206, twink206, sroll206, cooki206, brwni206, pie206, choco206, cdyw206, cdywo206, pudd206, pops206, muff206, powrb206, protb206, donut206, jello206);
   condim206    = sum (gravy206, ketch206, salsa206);

keep yr206b id momid 
		promeat206   redmeat206    fish206    poult206    eggs206     butter206    
  		marg206      lowdai206   highdai206   wine206    liquor206   beer206     tea206       
  		coffee206    fruit206    fruju206     cruveg206  yelveg206   tomato206   leafveg206   
  		legume206    othveg206   potato206    french206  wholeg206   refing206   pizza206    
  		sugdrk206    lowdrk206   snack206     nuts206    mayo206     dress206    crmsoup206   
  		sweets206    condim206      ;
run;

proc factor data=boys206 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f06;
	where promeat206 ne .;
	var promeat206   redmeat206    fish206    poult206    eggs206     butter206    
  		marg206      lowdai206   highdai206   wine206    liquor206   beer206     tea206       
  		coffee206    fruit206    fruju206     cruveg206  yelveg206   tomato206   leafveg206   
  		legume206    othveg206   potato206    french206  wholeg206   refing206   pizza206    
  		sugdrk206    lowdrk206   snack206     nuts206    mayo206     dress206    crmsoup206   
  		sweets206    condim206  ; 
data f06; set f06 ( keep=id factor1 factor2 
				rename=(factor1=f106 factor2=f206));
proc sort; by id;  run;


***********************************************
Calling in Boys08 Keeping Variables for Analysis
**********************************************;
%boys208 (keep= id yr208b momid
local208b coke208b punch208b spdrk208b tea208b coff208b latte208b beer208b wine208b liq208b rdbul208b
milk208b chocm208b instb208b yog208b cotch208b othch208b crch208b but208b marg208b
cburg208b burg208b vburg208b subburg208b pizza208b taco208b chnug208b dog208b spj208b sturk208b srb208b sbol208b stuna208b
chick208b fishs208b ofish208b shrim208b beef208b pork208b meatb208b lasag208b macch208b spag208b
eggs208b bacon208b frtoa208b grlch208b liver208b gravy208b ketch208b chowd208b soup208b mayo208b lcsdr208b saldr208b salsa208b
sugar208b cer208b htcer208b whbr208b dkbr208b engl208b muff208b cornb208b bisc208b rice208b pasta208b torti208b panca208b
fries208b mashp208b rais208b grape208b ban208b apple208b melon208b pear208b orang208b straw208b peach208b oj208b aj208b
tom208b sbean208b beans208b brocc208b corn208b peas208b mixv208b spin208b kale208b grpep208b
yams208b eggpl208b ccar208b rcar208b celry208b lett208b slaw208b psald208b
pchip208b cchip208b popc208b pretz208b nuts208b fufrt208b gcrax208b crack208b popt208b
cake208b twink208b sroll208b donut208b cooki208b brwni208b pie208b choco208b cdyw208b cdywo208b jello208b pudd208b
fryog208b icecr208b frapp208b pops208b seeds208b powrb208b protb208b cergb208b);

yr208b=1;
proc sort nodupkey data=boys208; by id; run;

data boys208; set boys208;

  array old1{*} local208b coke208b punch208b othch208b whbr208b dkbr208b;
  array new1{*} local208 coke208 punch208 othch208 whbr208 dkbr208;
  do i=1 to DIM(old1);
  if old1(i)=1 then new1(i)=0;
  else if old1(i)=2 then new1(i)=0.07;
  else if old1(i)=3 then new1(i)=0.14;
  else if old1(i)=4 then new1(i)=0.57;
  else if old1(i)=5 then new1(i)=1;
  else if old1(i)=6 then new1(i)=2.5;
  else if old1(i)=7 then new1(i)=4;
  else if old1(i)=8 then new1(i)=.;
  else new1(i)=0;
  end;

  array old9{*} spdrk208b rdbul208b; 
  array new9{*} spdrk208 rdbul208; 
   do i=1 to DIM(old9);
	  if old9(i)=1 then new9(i)=0;
	  else if old9(i)=2 then new9(i)=0.07;
	  else if old9(i)=3 then new9(i)=0.36;
	  else if old9(i)=4 then new9(i)=0.79;
	  else if old9(i)=5 then new9(i)=2;
	  else if old9(i)=6 then new9(i)=.;
	  else new9(i)=0;
	  end;

  array old2{*} tea208b coff208b latte208b;
  array new2{*} tea208 coff208 latte208;
	 do i=1 to DIM(old2);
	  if old2(i)=1 then new2(i)=0;
	  else if old2(i)=2 then new2(i)=0.07;
	  else if old2(i)=3 then new2(i)=0.21;
	  else if old2(i)=4 then new2(i)=0.64;
	  else if old2(i)=5 then new2(i)=2;
	  else if old2(i)=6 then new2(i)=.;
	  else new2(i)=0;
	  end;

  array old3{*} beer208b wine208b liq208b chowd208b soup208b mayo208b lcsdr208b saldr208b salsa208b 
				apple208b pear208b orang208b tom208b beans208b lett208b pchip208b cchip208b popt208b 
				twink208b donut208b choco208b cdyw208b cdywo208b;
  array new3{*} beer208 wine208 liq208 chowd208 soup208 mayo208 lcsdr208 saldr208 salsa208 
				apple208 pear208 orang208 tom208 beans208 lett208 pchip208 cchip208 popt208 
				twink208 donut208 choco208 cdyw208 cdywo208;
  	 do i=1 to DIM(old3);
	  if old3(i)=1 then new3(i)=0;
	  else if old3(i)=2 then new3(i)=0.07;
	  else if old3(i)=3 then new3(i)=0.14;
	  else if old3(i)=4 then new3(i)=0.57;
	  else if old3(i)=5 then new3(i)=2;
	  else if old3(i)=6 then new3(i)=.;
	  else new3(i)=0;
	  end;

  if milk208b=1 then milk208=0;
  	else if milk208b=2 then milk208=0.07;
	else if milk208b=3 then milk208=0.57;
	else if milk208b=4 then milk208=1;
	else if milk208b=5 then milk208=2.5;
	else if milk208b=6 then milk208=4;
	else if milk208b=7 then milk208=.;
	else milk208=0;

  if chocm208b=1 then chocm208=0;
   	else if chocm208b=2 then chocm208=0.07;
	else if chocm208b=3 then chocm208=0.14;
	else if chocm208b=4 then chocm208=0.57;
	else if chocm208b=5 then chocm208=1.5;
	else if chocm208b=6 then chocm208=3;
	else if chocm208b=7 then chocm208=.;
	else chocm208=0;

array old6{*} instb208b cburg208b burg208b vburg208b subburg208b pizza208b taco208b chnug208b dog208b spj208b 
			sturk208b srb208b sbol208b stuna208b chick208b ofish208b beef208b pork208b meatb208b spag208b 
			eggs208b bacon208b grlch208b ketch208b engl208b muff208b cornb208b bisc208b rice208b pasta208b torti208b 
			fries208b mashp208b rais208b grape208b ban208b straw208b peach208b sbean208b brocc208b corn208b 
			peas208b mixv208b spin208b kale208b grpep208b yams208b eggpl208b ccar208b rcar208b celry208b popc208b
			nuts208b fufrt208b gcrax208b crack208b sroll208b brwni208b jello208b pudd208b fryog208b icecr208b
			pops208b seeds208b powrb208b protb208b;
array new6{*} instb208 cburg208 burg208 vburg208 subburg208 pizza208 taco208 chnug208 dog208 spj208 
			sturk208 srb208 sbol208 stuna208 chick208 ofish208 beef208 pork208 meatb208 spag208 
			eggs208 bacon208 grlch208 ketch208 engl208 muff208 cornb208 bisc208 rice208 pasta208 torti208 
			fries208 mashp208 rais208 grape208 ban208 straw208 peach208 sbean208 brocc208 corn208 
			peas208 mixv208 spin208 kale208 grpep208 yams208 eggpl208 ccar208 rcar208 celry208 popc208
			nuts208 fufrt208 gcrax208 crack208 sroll208 brwni208 jello208 pudd208 fryog208 icecr208
			pops208 seeds208 powrb208 protb208;
	do i=1 to DIM(old6);
	  if old6(i)=1 then new6(i)=0;
	  else if old6(i)=2 then new6(i)=0.07;
	  else if old6(i)=3 then new6(i)=0.14;
	  else if old6(i)=4 then new6(i)=0.43;
	  else if old6(i)=5 then new6(i)=0.71;
	  else if old6(i)=6 then new6(i)=.;
	  else new6(i)=0;
	  end;

array old4{*} yog208b crch208b oj208b aj208b;
array new4{*} yog208 crch208 oj208 aj208; 
	do i=1 to DIM(old4);
	  if old4(i)=1 then new4(i)=0;
	  else if old4(i)=2 then new4(i)=0.07;
	  else if old4(i)=3 then new4(i)=0.14;
	  else if old4(i)=4 then new4(i)=0.57;
	  else if old4(i)=5 then new4(i)=1;
	  else if old4(i)=6 then new4(i)=2;
	  else if old4(i)=7 then new4(i)=.;
	  else new4(i)=0;
	  end;

array old7{*} cotch208b fishs208b shrim208b lasag208b macch208b gravy208b panca208b melon208b
			slaw208b psald208b pretz208b cake208b pie208b frapp208b;
array new7{*} cotch208 fishs208 shrim208 lasag208 macch208 gravy208 panca208 melon208
			slaw208 psald208 pretz208 cake208 pie208 frapp208;
	do i=1 to DIM(old7);
	  if old7(i)=1 then new7(i)=0;
	  else if old7(i)=2 then new7(i)=0.07;
	  else if old7(i)=3 then new7(i)=0.14;
	  else if old7(i)=4 then new7(i)=0.29;
	  else if old7(i)=5 then new7(i)=.;
	  else new7(i)=0;
	  end;

array old5{*} but208b marg208b;
array new5{*} but208 marg208; 
	do i=1 to DIM(old5);
	  if old5(i)=1 then new5(i)=0;
	  else if old5(i)=2 then new5(i)=0.07;
	  else if old5(i)=3 then new5(i)=0.14;
	  else if old5(i)=4 then new5(i)=0.57;
	  else if old5(i)=5 then new5(i)=1;
	  else if old5(i)=6 then new5(i)=3;
	  else if old5(i)=7 then new5(i)=5;
	  else if old5(i)=8 then new5(i)=.;
	  else new5(i)=0;
	  end;

	array old10{*} frtoa208b cergb208b;
	array new10{*} frtoa208 cergb208;
		do i=1 to DIM(old10);
	  if old10(i)=1 then new10(i)=0;
	  else if old10(i)=2 then new10(i)=0.07;
	  else if old10(i)=3 then new10(i)=0.14;
	  else if old10(i)=4 then new10(i)=0.43;
	  else if old10(i)=5 then new10(i)=0.71;
	  else if old10(i)=8 then new10(i)=.;
	  else new10(i)=0;
	  end;

  array old8{*} cer208b htcer208b ;
  array new8{*} cer208 htcer208 ;
  do i=1 to DIM(old8);
  if old8(i)=1 then new8(i)=0;
    else if old8(i)=2 then new8(i)=0.07;
    else if old8(i)=3 then new8(i)=0.14;
    else if old8(i)=4 then new8(i)=0.43;
    else if old8(i)=5 then new8(i)=0.86;
    else if old8(i)=6 then new8(i)=2;
    else if old8(i)=7 then new8(i)=.;
    else new8(i)=0; 
	end;

  if cooki208b=1 then cooki208=0;
  	else if cooki208b=2 then cooki208=0.07;
	else if cooki208b=3 then cooki208=0.14;
	else if cooki208b=4 then cooki208=0.57;
	else if cooki208b=5 then cooki208=2;
	else if cooki208b=6 then cooki208=4;
	else if cooki208b=7 then cooki208=.;
	else cooki208=0;

  if liver208b=1 then liver208=0;
  	else if liver208b=2 then liver208=0.03;
	else if liver208b=3 then liver208=0.08;
	else if liver208b=4 then liver208=0.29;
	else if liver208b=5 then liver208=.;
	else liver208=0;

  if sugar208b=1 then sugar208=0;
  	else if sugar208b=2 then sugar208=1.5;
	else if sugar208b=3 then sugar208=3.5;
	else if sugar208b=4 then sugar208=6;
	else if sugar208b=5 then sugar208=.;
	else sugar208=0;

   promeat208   = sum (cburg208, burg208, taco208, chnug208, dog208, sbol208, meatb208, bacon208);
   redmeat208   = sum (srb208, beef208, pork208);
   orgmeat208   = sum (liver208);
   fish208      = sum (stuna208, fishs208, ofish208, shrim208);
   poult208     = sum (sturk208, chick208);
   eggs208      = sum (eggs208 );
   butter208    = sum (but208 );
   marg208      = sum (marg208 );
   lowdai208    = sum (chocm208, yog208, cotch208, fryog208 );
   highdai208   = sum (milk208, othch208, crch208, icecr208);
   wine208      = sum (wine208 );
   liquor208    = sum (liq208 );
   beer208      = sum (beer208 );
   tea208       = sum (tea208);
   coffee208    = sum (coff208, latte208);
   fruit208     = sum (rais208, grape208, ban208, apple208, melon208, pear208, orang208, straw208, peach208, fufrt208);
   fruju208     = sum (oj208, aj208 );
   cruveg208    = sum (brocc208, slaw208);
   yelveg208    = sum (yams208, ccar208, rcar208 );
   tomato208    = sum (tom208 );
   leafveg208   = sum (spin208, kale208, lett208 );
   legume208    = sum (sbean208, beans208, peas208, subburg208);
   othveg208    = sum (vburg208, mixv208, grpep208, eggpl208, celry208 );
   potato208    = sum (mashp208, psald208);
   french208    = sum (fries208);
   wholeg208    = sum (cer208, htcer208, whbr208, dkbr208, engl208, corn208, gcrax208, cornb208);
   refing208    = sum (lasag208, macch208, spag208, grlch208, bisc208, rice208, pasta208, torti208, panca208, frtoa208);
   pizza208     = sum (pizza208 );
   sugdrk208    = sum (coke208, punch208, instb208, frapp208, spdrk208, rdbul208);
   lowdrk208    = sum (local208 );
   snack208     = sum (pchip208, cchip208, popc208, pretz208, crack208  );
   nuts208      = sum (spj208, nuts208, seeds208);
   mayo208      = sum (mayo208 );
   dress208     = sum (lcsdr208, saldr208);
   crmsoup208   = sum (chowd208, soup208); 
   sweets208    = sum (popt208, cake208, twink208, sroll208, cooki208, brwni208, pie208, choco208, cdyw208, cdywo208, pudd208, pops208, muff208, powrb208, protb208, donut208, jello208, sugar208, cergb208);
   condim208    = sum (gravy208, ketch208, salsa208);

keep yr208b id momid  
		promeat208   redmeat208  orgmeat208   fish208    poult208    eggs208     butter208    
  		marg208      lowdai208   highdai208   wine208    liquor208   beer208     tea208       
  		coffee208    fruit208    fruju208     cruveg208  yelveg208   tomato208   leafveg208   
  		legume208    othveg208   potato208    french208  wholeg208   refing208   pizza208    
  		sugdrk208    lowdrk208   snack208     nuts208    mayo208     dress208    crmsoup208   
  		sweets208    condim208      ;

run;
proc factor data=boys208 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f08;
	where promeat208 ne .;
	var promeat208   redmeat208  orgmeat208   fish208    poult208    eggs208     butter208    
  		marg208      lowdai208   highdai208   wine208    liquor208   beer208     tea208       
  		coffee208    fruit208    fruju208     cruveg208  yelveg208   tomato208   leafveg208   
  		legume208    othveg208   potato208    french208  wholeg208   refing208   pizza208    
  		sugdrk208    lowdrk208   snack208     nuts208    mayo208     dress208    crmsoup208   
  		sweets208    condim208    ; 
data f08; set f08 ( keep=id factor1 factor2 
				rename=(factor1=f108 factor2=f208));
proc sort; by id;  run;


****************************************
Calling in Boys11 Keeping Variables for Analysis
********************************************;
%boys211 (keep=  id yr211b boys211 momid
rais211b grape211b ban211b appl211b apsau211b cant211b wtrml211b oran211b straw211b peach211b oj211b aj211b
tom211b toj211b sbean211b brocc211b corn211b peas211b mixv211b rspin211b cspin211b bruss211b grpep211b
yams211b eggp211b ccar211b rcar211b celry211b ilett211b ptsld211b fries211b mashp211b oniov211b oniog211b
cer211b oat211b ckcer211b whbr211b dkbr211b engl211b muff211b crnbr211b bisct211b wrice211b brice211b tort211b panca211b frtst211b
skim211b m1or2211b whole211b chocm211b soy211b instb211b prosh211b plyog211b yoglt211b yog211b cotch211b crch211b
but211b sbu211b marg211b whip211b cream211b ketch211b chowd211b soup211b mayo211b lcsdr211b saldr211b salsa211b jam211b pbut211b
lccaf211b lcnoc211b coke211b otsug211b punch211b spdrk211b rdbsf211b rdbul211b rdbor211b tea211b smth211b beer211b lbeer211b
wine211b liq211b sodas211b decaf211b coff211b cdff211b latte211b icff211b icd211b
egg211b cburg211b burg211b vburg211b tofu211b pizza211b chnug211b dog211b ctdog211b bacon211b procm211b
fsan211b fbur211b fpas211b fmix211b beef211b chwi211b chwo211b pork211b beans211b tosau211b fishs211b ctuna211b dkfsh211b
shrim211b ofish211b macch211b othch211b chip211b bchip211b popc211b pretz211b pnut211b wnut211b onut211b seeds211b
fsnk211b crack211b popt211b twink211b sroll211b donut211b cooki211b brwni211b pie211b choco211b cdyw211b cdywo211b pudd211b
fryog211b icecr211b pops211b powrb211b protb211b brbar211b sugar211b
stsa211b stbf211b stt211b stvg211b stct211b stpb211b stpt211b );

boys211=1; yrq11=1;
proc sort nodupkey data=boys211; by id; run;

data boys211; set boys211;

array old1{*} rais211b grape211b ban211b appl211b apsau211b cant211b wtrml211b oran211b straw211b peach211b oj211b aj211b
tom211b toj211b sbean211b brocc211b corn211b peas211b mixv211b rspin211b cspin211b bruss211b grpep211b yams211b 
eggp211b ccar211b rcar211b celry211b ilett211b ptsld211b fries211b mashp211b oniov211b oniog211b cer211b oat211b ckcer211b 
whbr211b dkbr211b engl211b muff211b crnbr211b bisct211b wrice211b brice211b tort211b panca211b frtst211b
skim211b m1or2211b whole211b chocm211b soy211b instb211b prosh211b plyog211b yoglt211b yog211b cotch211b crch211b
but211b sbu211b marg211b whip211b cream211b ketch211b chowd211b soup211b mayo211b lcsdr211b saldr211b salsa211b jam211b pbut211b
lccaf211b lcnoc211b coke211b otsug211b punch211b spdrk211b rdbsf211b rdbul211b rdbor211b tea211b smth211b beer211b lbeer211b
wine211b liq211b  egg211b cburg211b burg211b vburg211b tofu211b pizza211b chnug211b dog211b ctdog211b bacon211b procm211b
fsan211b fbur211b fpas211b fmix211b beef211b chwi211b chwo211b pork211b beans211b tosau211b fishs211b ctuna211b dkfsh211b
shrim211b ofish211b macch211b othch211b chip211b bchip211b popc211b pretz211b pnut211b wnut211b onut211b seeds211b
fsnk211b crack211b popt211b twink211b sroll211b donut211b cooki211b brwni211b pie211b choco211b cdyw211b cdywo211b pudd211b
fryog211b icecr211b pops211b powrb211b protb211b brbar211b ;

array new1{*} rais211 grape211 ban211 appl211 apsau211 cant211 wtrml211 oran211 straw211 peach211 oj211 aj211
tom211 toj211 sbean211 brocc211 corn211 peas211 mixv211 rspin211 cspin211 bruss211 grpep211 yams211 
eggp211 ccar211 rcar211 celry211 ilett211 ptsld211 fries211 mashp211 oniov211 oniog211 cer211 oat211 ckcer211 
whbr211 dkbr211 engl211 muff211 crnbr211 bisct211 wrice211 brice211 tort211 panca211 frtst211
skim211 m1or2211 whole211 chocm211 soy211 instb211 prosh211 plyog211 yoglt211 yog211 cotch211 crch211
but211 sbu211 marg211 whip211 cream211 ketch211 chowd211 soup211 mayo211 lcsdr211 saldr211 salsa211 jam211 pbut211
lccaf211 lcnoc211 coke211 otsug211 punch211 spdrk211 rdbsf211 rdbul211 rdbor211 tea211 smth211 beer211 lbeer211
wine211 liq211  egg211 cburg211 burg211 vburg211 tofu211 pizza211 chnug211 dog211 ctdog211 bacon211 procm211
fsan211 fbur211 fpas211 fmix211 beef211 chwi211 chwo211 pork211 beans211 tosau211 fishs211 ctuna211 dkfsh211
shrim211 ofish211 macch211 othch211 chip211 bchip211 popc211 pretz211 pnut211 wnut211 onut211 seeds211
fsnk211 crack211 popt211 twink211 sroll211 donut211 cooki211 brwni211 pie211 choco211 cdyw211 cdywo211 pudd211
fryog211 icecr211 pops211 powrb211 protb211 brbar211;

  do i=1 to DIM(old1);
  if old1(i)=1 then new1(i)=0;
    else if old1(i)=2 then new1(i)=0.02;
    else if old1(i)=3 then new1(i)=0.07;
    else if old1(i)=4 then new1(i)=0.14;
    else if old1(i)=5 then new1(i)=0.43;
    else if old1(i)=6 then new1(i)=0.79;
    else if old1(i)=7 then new1(i)=1;
	else if old1(i)=8 then new1(i)=2.5;
	else if old1(i)=9 then new1(i)=4.5;
	else if old1(i)=10 then new1(i)=7;
	else if old1(i)=11 then new1(i)=.;
    else new1(i)=0; 
	end;

  if sugar211b=1 then sugar211=0;
  	else if sugar211b=2 then sugar211=1.5;
	else if sugar211b=3 then sugar211=3.5;
	else if sugar211b=4 then sugar211=6;
	else if sugar211b=5 then sugar211=.;
	else sugar211=0;

array old2{*} decaf211b coff211b cdff211b latte211b icff211b icd211b;
array new2{*} decaf211 coff211 cdff211 latte211 icff211 icd211;
do i=1 to DIM(old2);
  if old2(i)=1 then new2(i)=0;
    else if old2(i)=2 then new2(i)=0.02;
    else if old2(i)=3 then new2(i)=0.07;
    else if old2(i)=4 then new2(i)=0.21;
    else if old2(i)=5 then new2(i)=0.64;
    else if old2(i)=6 then new2(i)=1;
    else if old2(i)=7 then new2(i)=3;
	else if old2(i)=8 then new2(i)=.;
    else new2(i)=0; 
	end;

   promeat211   = sum (cburg211, burg211, chnug211, dog211, bacon211, ctdog211, procm211);
   redmeat211   = sum (beef211, pork211);
   fish211      = sum (fishs211, ofish211, shrim211, ctuna211, dkfsh211);
   poult211     = sum (chwi211, chwo211 );
   eggs211      = sum (egg211);
   butter211    = sum (but211, sbu211);
   marg211      = sum (marg211 );
   lowdai211    = sum (chocm211, yog211, cotch211, fryog211, skim211, m1or2211, prosh211, plyog211, yoglt211 );
   highdai211   = sum (othch211, crch211, icecr211, whole211, whip211, cream211);
   wine211      = sum (wine211 );
   liquor211    = sum (liq211 );
   beer211      = sum (beer211, lbeer211);
   tea211       = sum (tea211);
   coffee211    = sum (coff211, latte211, decaf211,  cdff211,  icff211, icd211);
   fruit211     = sum (rais211, grape211, ban211, appl211, straw211, peach211, apsau211, cant211, wtrml211, oran211);
   fruju211     = sum (oj211, aj211, smth211 );
   cruveg211    = sum (brocc211, bruss211 );
   yelveg211    = sum (yams211, ccar211, rcar211 );
   tomato211    = sum (tom211, toj211, tosau211);
   leafveg211   = sum (rspin211, cspin211, ilett211 );
   legume211    = sum (tofu211, sbean211, beans211, peas211, soy211);
   othveg211    = sum (vburg211, mixv211, grpep211, celry211, eggp211, oniov211);
   potato211    = sum (mashp211, ptsld211);
   french211    = sum (fries211);
   wholeg211    = sum (cer211, whbr211, dkbr211, engl211, corn211, oat211, ckcer211, crnbr211, brice211);
   refing211    = sum (macch211, panca211, bisct211, wrice211, tort211, frtst211);
   pizza211     = sum (pizza211 );
   sugdrk211    = sum (coke211, punch211, instb211, spdrk211, rdbul211, otsug211);
   lowdrk211    = sum (lccaf211, lcnoc211, rdbsf211, rdbor211 );
   snack211     = sum (popc211, pretz211, crack211, chip211, bchip211);
   nuts211      = sum (seeds211, pbut211, pnut211, wnut211, onut211);
   mayo211      = sum (mayo211 );
   dress211     = sum (lcsdr211, saldr211);
   crmsoup211   = sum (chowd211, soup211); 
   sweets211    = sum (popt211, twink211, sroll211, cooki211, brwni211, pie211, choco211, cdyw211, cdywo211, pudd211, pops211, muff211, powrb211, protb211, donut211, jam211, fsnk211, brbar211);
   condim211    = sum (ketch211, salsa211, oniog211);

keep yr211b id momid  
		promeat211   redmeat211    fish211    poult211    eggs211     butter211    
  		marg211      lowdai211   highdai211   wine211    liquor211   beer211     tea211       
  		coffee211    fruit211    fruju211     cruveg211  yelveg211   tomato211   leafveg211   
  		legume211    othveg211   potato211    french211  wholeg211   refing211   pizza211    
  		sugdrk211    lowdrk211   snack211     nuts211    mayo211     dress211    crmsoup211   
  		sweets211    condim211      ;
run;
proc factor data=boys211 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f11;
	where promeat211 ne .;
	var promeat211   redmeat211    fish211    poult211    eggs211     butter211    
  		marg211      lowdai211   highdai211   wine211    liquor211   beer211     tea211       
  		coffee211    fruit211    fruju211     cruveg211  yelveg211   tomato211   leafveg211   
  		legume211    othveg211   potato211    french211  wholeg211   refing211   pizza211    
  		sugdrk211    lowdrk211   snack211     nuts211    mayo211     dress211    crmsoup211   
  		sweets211    condim211    ; 
data f11; set f11 ( keep=id factor1 factor2 
				rename=(factor1=f111 factor2=f211));
proc sort; by id;  run;


/*****************************************************************************************
*****************************************************************************************
										Merge data
*****************************************************************************************
*****************************************************************************************
*****************************************************************************************/

data here.boywestern1;  
merge f96 f97 f98 f01;
by id;

	array prud    {*}   f196   f197  f198    f101      ; 
	array prudr    {*}   f196r   f197r  f198r    f101r      ;  /*BCAR updated code to keep original values without carrying forward*/
	array west    {*}   f296   f297  f298    f201    ; 
  array westr   {*}   f296r  f297r f298r   f201r    ; /*BCAR updated code to keep original values without carrying forward*/
	
  do i=1 to dim(prud);
		  prudr{i}=prud{i}; 
      westr{i}=west{i}; 
	end; drop i; 

  do i=2 to DIM(prud);
	if prud{i} =. and prud{i-1} ne . then prud{i} = prud{i-1};
	if west{i} =. and west{i-1} ne . then west{i} = west{i-1};
	end; drop i;

	%cumavg(cycle=4, cyclevar=2,
        varin = f196  f296  f197  f297  f198  f298  f101  f201   ,
        varout= f196v  f296v  f197v  f297v  f198v  f298v  f101v  f201v  );
run;

data here.boywestern2; 
merge f04 f06 f08 f11; 
by id;

	array prud    {*}   f104   f106  f108    f111      ; 
  array prudr    {*}   f104r   f106r  f108r    f111r      ;  /*BCAR updated code to keep original values without carrying forward*/
	array west    {*}   f204   f206  f208    f211    ; 
  array westr   {*}   f204r  f206r f208r   f211r    ;  /*BCAR updated code to keep original values without carrying forward*/

  do i=1 to dim(prud);
		  prudr{i}=prud{i}; 
      westr{i}=west{i}; 
	end; drop i; 
	
	do i=2 to DIM(prud);
	if prud{i} =. and prud{i-1} ne . then prud{i} = prud{i-1};
	if west{i} =. and west{i-1} ne . then west{i} = west{i-1};
	end; drop i;


	%cumavg(cycle=4, cyclevar=2,
        varin = f104  f204  f106  f206  f108  f208  f111  f211   ,
        varout= f104v  f204v  f106v  f206v  f108v  f208v  f111v  f211v  );
run;

