
/*
Program name: girls_western.sas 
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
***********************************************GIRLS**********************************************
**************************************************************************************************
**************************************************************************************************/

******************************************************************
Calling in 1996 Girls wave and keeping variables
******************************************************************;
%girls96 (keep= yr96g id momid
local96g coke96g punch96g itea96g tea96g coff96g beer96g wine96g liq96g
milk96g chocm96g instb96g whip96g yog96g cotch96g othch96g crch96g but96g marg96g
cburg96g burg96g pizza96g taco96g chnug96g dog96g spj96g sturk96g srb96g sbol96g stuna96g
chick96g fishs96g ofish96g shrim96g beef96g pork96g meatb96g lasag96g macch96g spag96g
eggs96g liver96g frtoa96g grlch96g eggro96g gravy96g ketch96g chowd96g soup96g mayo96g lcsdr96g saldr96g salsa96g
cer96g ckcer96g whbr96g dkbr96g engl96g muff96g cornb96g bisc96g rice96g pasta96g torti96g otgrn96g panca96g
fries96g mashp96g rais96g grape96g ban96g apple96g melon96g pear96g orang96g straw96g peach96g oj96g aj96g
tom96g tofu96g sbean96g beans96g brocc96g beet96g corn96g peas96g mixv96g spin96g kale96g grpep96g
yams96g eggpl96g ccar96g rcar96g celry96g lett96g slaw96g psald96g
pchip96g cchip96g nacho96g popc96g pretz96g nuts96g fufrt96g gcrax96g crack96g popt96g
cake96g twink96g sroll96g donut96g cooki96g brwni96g pie96g choco96g cdyw96g cdywo96g jello96g pudd96g
fryog96g icecr96g frapp96g pops96g seeds96g );

yr96g=1;
proc sort nodupkey data=girls96; by id; run;

data girls96; set girls96;

  array old1 {*} local96g coke96g punch96g othch96g;
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

  array old2 {*} tea96g coff96g;
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

  array old3 {*} beer96g wine96g liq96g cotch96g fishs96g shrim96g lasag96g macch96g soup96g
                 otgrn96g panca96g melon96g slaw96g psald96g nacho96g pretz96g cake96g pie96g frapp96g;
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

  array old4 {*} instb96g whip96g cburg96g burg96g pizza96g taco96g chnug96g dog96g
                  spj96g sturk96g srb96g sbol96g stuna96g chick96g ofish96g beef96g pork96g 
                  meatb96g spag96g eggs96g frtoa96g grlch96g eggro96g ketch96g engl96g
                  muff96g cornb96g bisc96g rice96g pasta96g torti96g fries96g mashp96g rais96g
                  grape96g ban96g straw96g peach96g tofu96g sbean96g brocc96g corn96g 
                  peas96g mixv96g spin96g kale96g grpep96g yams96g eggpl96g ccar96g rcar96g 
                  celry96g sroll96g brwni96g jello96g pudd96g fryog96g icecr96g pops96g seeds96g;
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

  array old5 {*} yog96g crch96g oj96g aj96g;
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

  array old6 {*} but96g marg96g;
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

  array old7 {*} chowd96g mayo96g lcsdr96g saldr96g salsa96g apple96g pear96g orang96g
                tom96g lett96g pchip96g cchip96g twink96g donut96g choco96g cdyw96g cdywo96g;
  array new7 {*} chowd96 mayo96 lcsdr96 saldr96 salsa96 apple96 pear96 orang96
                tom96 lett96 pchip96 cchip96 twink96 donut96 choco96 cdyw96 cdywo96;
  do i=1 to DIM(old7);
  if old7(i)=1 then new7(i)=0;
    else if old7(i)=2 then new7(i)=0.07;
    else if old7(i)=3 then new7(i)=0.14;
    else if old7(i)=4 then new7(i)=0.57;
    else if old7(i)=5 then new7(i)=2;
    else if old7(i)=6 then new7(i)=.;
    else new7(i)=0; 
	end;

  array old8 {*} cer96g ckcer96g;
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

  array old9 {*} whbr96g dkbr96g;
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

  array old10 {*} popc96g nuts96g fufrt96g gcrax96g crack96g; 
  array new10 {*} popc96 nuts96 fufrt96 gcrax96 crack96; 
  do i=1 to DIM(old10);
  if old10(i)=1 then new10(i)=0;
  else if old10(i)=2 then new10(i)=0.07;
  else if old10(i)=3 then new10(i)=0.36;
  else if old10(i)=4 then new10(i)=0.71;
  else if old10(i)=5 then new10(i)=.;
  else old10(i)=0; 
	end;

  if itea96g =1 then itea96 =0;
    else if itea96g =2 then itea96 =0.07;
    else if itea96g =3 then itea96 =0.36;
    else if itea96g =4 then itea96 =0.79;
    else if itea96g =5 then itea96 =2;
    else if itea96g =6 then itea96 =.;
    else itea96 =0;

  if milk96g=1 then milk96=0;
    else if milk96g=2 then milk96=0.14;
    else if milk96g=3 then milk96=0.57;
    else if milk96g=4 then milk96=1;
    else if milk96g=5 then milk96=2.5;
    else if milk96g=6 then milk96=4;
    else if milk96g=7 then milk96=.;
    else milk96=0;

  if chocm96g=1 then chocm96=0;
    else if chocm96g=2 then chocm96=0.07;
    else if chocm96g=3 then chocm96=0.14;
    else if chocm96g=4 then chocm96=0.57;
    else if chocm96g=5 then chocm96=1.5;
    else if chocm96g=6 then chocm96=3;
    else if chocm96g=7 then chocm96=.;
    else chocm96=0;

  if liver96g=1 then liver96=0;
    else if liver96g=2 then liver96=0.02;
    else if liver96g=3 then liver96=0.03;
    else if liver96g=4 then liver96=0.08;
    else if liver96g=5 then liver96=0.29;
    else if liver96g=6 then liver96=.;
    else liver96=0;

 if gravy96g=1 then gravy96=0;
  else if gravy96g=2 then gravy96=0.07;
  else if gravy96g=3 then gravy96=0.57;
  else if gravy96g=4 then gravy96=1;
  else if gravy96g=5 then gravy96=2;
  else if gravy96g=6 then gravy96=.;
  else gravy96=0;

  if beans96g=1 then beans96=0;
  else if beans96g=2 then beans96=0.14;
  else if beans96g=3 then beans96=0.57;
  else if beans96g=4 then beans96=1;
  else if beans96g=5 then beans96=.;
  else beans96=0;

  if beet96g=1 then beet96=0;
  else if beet96g=2 then beet96=0.07;
  else if beet96g=3 then beet96=0.14;
  else if beet96g=4 then beet96=.;
  else beet96=0;

  if popt96g=1 then popt96=0;
  else if popt96g=2 then popt96=0.07;
  else if popt96g=3 then popt96=0.5;
  else if popt96g=4 then popt96=2;
  else if popt96g=5 then popt96=.;
  else popt96=0;

  if cooki96g=1 then cooki96=0;
  else if cooki96g=2 then cooki96=0.07;
  else if cooki96g=3 then cooki96=0.14;
  else if cooki96g=4 then cooki96=0.57;
  else if cooki96g=5 then cooki96=2;
  else if cooki96g=6 then cooki96=4;
  else if cooki96g=7 then cooki96=.;
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
   sweets96    = sum (muff96, popt96, cake96, twink96, sroll96, donut96, cooki96, brwni96, pie96, choco96, cdyw96, cdywo96, jello96, pudd96, pops96);
   condim96    = sum (gravy96, ketch96, salsa96);

keep yr96g id momid  
		promeat96   redmeat96  orgmeat96   fish96    poult96    eggs96     butter96    
  		marg96      lowdai96   highdai96   wine96    liquor96   beer96     tea96       
  		coffee96    fruit96    fruju96     cruveg96  yelveg96   tomato96   leafveg96   
  		legume96    othveg96   potato96    french96  wholeg96   refing96   pizza96    
  		sugdrk96    lowdrk96   snack96     nuts96    mayo96     dress96    crmsoup96   
  		sweets96    condim96     ;
  		
  if nmiss(of promeat96   redmeat96  orgmeat96   fish96    poult96    eggs96     butter96    
  		marg96      lowdai96   highdai96   wine96    liquor96   beer96     tea96       
  		coffee96    fruit96    fruju96     cruveg96  yelveg96   tomato96   leafveg96   
  		legume96    othveg96   potato96    french96  wholeg96   refing96   pizza96    
  		sugdrk96    lowdrk96   snack96     nuts96    mayo96     dress96    crmsoup96   
  		sweets96    condim96) >0 then delete; *433 missing removed;
  
run;

proc factor data=girls96 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f96;
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
Calling in 1997 girls and keeping variables for analysis
*******************************************************************************************;
%girls97 (keep= girls97 yrq97 id momid
local97g coke97g punch97g itea97g tea97g coff97g beer97g wine97g liq97g
milk97g chocm97g instb97g yog97g cotch97g othch97g crch97g but97g marg97g
cburg97g burg97g pizza97g taco97g chnug97g dog97g spj97g sturk97g srb97g sbol97g stuna97g
chick97g fishs97g ofish97g shrim97g beef97g pork97g meatb97g lasag97g macch97g spag97g
eggs97g bacon97g liver97g frtoa97g grlch97g eggro97g gravy97g ketch chowd97g soup97g mayo97g lcsdr97g saldr97g salsa97g
cer97g ckcer97g whbr97g dkbr97g engl97g muff97g cornb97g bisc97g rice97g pasta97g torti97g otgrn97g panca97g
fries97g mashp97g rais97g grape97g ban97g apple97g melon97g pear97g orang97g straw97g peach97g oj97g aj97g
tom97g tofu97g sbean97g beans97g brocc97g corn97g peas97g mixv97g spin97g kale97g grpep97g
yams97g eggpl97g ccar97g rcar97g celry97g lett97g slaw97g psald97g
pchip97g cchip97g nacho97g popc97g pretz97g nuts97g fufrt97g gcrax97g crack97g popt97g
cake97g twink97g sroll97g donut97g cooki97g brwni97g pie97g choco97g cdyw97g cdywo97g jello97g pudd97g
fryog97g icecr97g frapp97g pops97g seeds97g );

yrq97=1; girls97=1;
proc sort nodupkey data=girls97; by id; run;

data girls97; set girls97;

  array old1 {*} local97g coke97g punch97g othch97g;
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

  array old2 {*} tea97g coff97g;
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

  array old3 {*} cotch97g fishs97g shrim97g lasag97g macch97g soup97g
                 otgrn97g panca97g melon97g slaw97g psald97g nacho97g pretz97g cake97g pie97g frapp97g;
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

  array old4 {*} instb97g cburg97g burg97g pizza97g taco97g chnug97g dog97g
                  spj97g sturk97g srb97g sbol97g stuna97g chick97g ofish97g beef97g pork97g 
                  meatb97g spag97g eggs97g bacon97g grlch97g eggro97g ketch engl97g
                  muff97g cornb97g bisc97g rice97g pasta97g torti97g fries97g mashp97g rais97g
                  grape97g ban97g straw97g peach97g tofu97g sbean97g brocc97g corn97g 
                  peas97g mixv97g spin97g kale97g grpep97g yams97g eggpl97g ccar97g rcar97g 
                  celry97g sroll97g brwni97g jello97g pudd97g fryog97g icecr97g pops97g seeds97g;
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

  array old5 {*} yog97g crch97g oj97g aj97g;
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

  array old6 {*} but97g marg97g;
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

  array old7 {*} beer97g wine97g liq97g chowd97g mayo97g lcsdr97g saldr97g salsa97g apple97g pear97g orang97g
                tom97g lett97g pchip97g cchip97g twink97g donut97g choco97g cdyw97g cdywo97g;
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

  array old8 {*} cer97g ckcer97g;
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

  array old9 {*} whbr97g dkbr97g;
  array new9 {*} whbr97 dkbr97;
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

  array old10 {*} popc97g nuts97g fufrt97g gcrax97g crack97g; 
  array new10 {*} popc97 nuts97 fufrt97 gcrax97 crack97; 
  do i=1 to DIM(old10);
  if old10(i)=1 then new10(i)=0;
  else if old10(i)=2 then new10(i)=0.07;
  else if old10(i)=3 then new10(i)=0.36;
  else if old10(i)=4 then new10(i)=0.71;
  else if old10(i)=5 then new10(i)=.;
  else old10(i)=0;
  end;

  if itea97g =1 then itea97 =0;
    else if itea97g =2 then itea97 =0.07;
    else if itea97g =3 then itea97 =0.36;
    else if itea97g =4 then itea97 =0.79;
    else if itea97g =5 then itea97 =2;
    else if itea97g =6 then itea97 =.;
    else itea97 =0;

  if milk97g=1 then milk97=0;
    else if milk97g=2 then milk97=0.14;
    else if milk97g=3 then milk97=0.57;
    else if milk97g=4 then milk97=1;
    else if milk97g=5 then milk97=2.5;
    else if milk97g=6 then milk97=4;
    else if milk97g=7 then milk97=.;
    else milk97=0;

  if chocm97g=1 then chocm97=0;
    else if chocm97g=2 then chocm97=0.07;
    else if chocm97g=3 then chocm97=0.14;
    else if chocm97g=4 then chocm97=0.57;
    else if chocm97g=5 then chocm97=1.5;
    else if chocm97g=6 then chocm97=3;
    else if chocm97g=7 then chocm97=.;
    else chocm97=0;

  if liver97g=1 then liver97=0;
    else if liver97g=2 then liver97=0.02;
    else if liver97g=3 then liver97=0.03;
    else if liver97g=4 then liver97=0.08;
    else if liver97g=5 then liver97=0.29;
    else if liver97g=6 then liver97=.;
    else liver97=0;

  if frtoa97g=1 then frtoa97=0;
  	else if frtoa97g=2 then frtoa97=0.07;
	else if frtoa97g=3 then frtoa97=0.14;
	else if frtoa97g=4 then frtoa97=0.43;
	else if frtoa97g=5 then frtoa97=2;
	else if frtoa97g=6 then frtoa97=.;
	else frtoa97=0;

 if gravy97g=1 then gravy97=0;
  else if gravy97g=2 then gravy97=0.07;
  else if gravy97g=3 then gravy97=0.57;
  else if gravy97g=4 then gravy97=1;
  else if gravy97g=5 then gravy97=2;
  else if gravy97g=6 then gravy97=.;
  else gravy97=0;

  if beans97g=1 then beans97=0;
  else if beans97g=2 then beans97=0.14;
  else if beans97g=3 then beans97=0.57;
  else if beans97g=4 then beans97=1;
  else if beans97g=5 then beans97=.;
  else beans97=0;

  if popt97g=1 then popt97=0;
  else if popt97g=2 then popt97=0.07;
  else if popt97g=3 then popt97=0.5;
  else if popt97g=4 then popt97=2;
  else if popt97g=5 then popt97=.;
  else popt97=0;

  if cooki97g=1 then cooki97=0;
  else if cooki97g=2 then cooki97=0.07;
  else if cooki97g=3 then cooki97=0.14;
  else if cooki97g=4 then cooki97=0.57;
  else if cooki97g=5 then cooki97=2;
  else if cooki97g=6 then cooki97=4;
  else if cooki97g=7 then cooki97=.;
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
   wholeg97    = sum (cer97, ckcer97, whbr97, dkbr97, engl97, cornb97, otgrn97, corn97, gcrax97);
   refing97    = sum (lasag97, macch97, spag97, frtoa97, grlch97, eggro97, bisc97, rice97, pasta97, torti97, panca97);
   pizza97     = sum (pizza97 );
   sugdrk97    = sum (coke97, punch97, instb97, frapp97 );
   lowdrk97    = sum (local97 );
   snack97     = sum (pchip97, cchip97, nacho97, popc97, pretz97, crack97  );
   nuts97      = sum (spj97, nuts97, seeds97);
   mayo97      = sum (mayo97 );
   dress97     = sum (lcsdr97, saldr97);
   crmsoup97   = sum (chowd97, soup97); 
   sweets97    = sum (popt97, cake97, twink97, sroll97, donut97, cooki97, brwni97, pie97, choco97, cdyw97, cdywo97, jello97, pudd97, pops97, muff97);
   condim97    = sum (gravy97, ketch97, salsa97);

keep yrq97 id momid 
		promeat97   redmeat97  orgmeat97   fish97    poult97    eggs97     butter97    
  		marg97      lowdai97   highdai97   wine97    liquor97   beer97     tea97       
  		coffee97    fruit97    fruju97     cruveg97  yelveg97   tomato97   leafveg97   
  		legume97    othveg97   potato97    french97  wholeg97   refing97   pizza97    
  		sugdrk97    lowdrk97   snack97     nuts97    mayo97     dress97    crmsoup97   
  		sweets97    condim97      ;

  if nmiss(of promeat97   redmeat97  orgmeat97   fish97    poult97    eggs97     butter97    
  		marg97      lowdai97   highdai97   wine97    liquor97   beer97     tea97       
  		coffee97    fruit97    fruju97     cruveg97  yelveg97   tomato97   leafveg97   
  		legume97    othveg97   potato97    french97  wholeg97   refing97   pizza97    
  		sugdrk97    lowdrk97   snack97     nuts97    mayo97     dress97    crmsoup97   
  		sweets97    condim97) >0 then delete; *315 missing removed;

run;

proc factor data=girls97 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f97;
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
Calling in 1998 girls keeping variables for analysis
*******************************************************************************************************;
%girls98 (keep= yr98g id momid
local98g coke98g punch98g tea98g coff98g beer98g wine98g liq98g
milk98g chocm98g instb98g yog98g cotch98g othch98g crch98g but98g marg98g
cburg98g burg98g pizza98g taco98g chnug98g dog98g spj98g sturk98g srb98g sbol98g stuna98g
chick98g fishs98g ofish98g shrim98g beef98g pork98g meatb98g lasag98g macch98g grlch98g spag98g
eggs98g bacon98g gravy98g ketch98g chowd98g soup98g mayo98g lcsdr98g saldr98g salsa98g
cer98g ckcer98g whbr98g drbr98g engl98g muff98g pasta98g rice98g bisc98g torti98g panca98g
fries98g mashp98g rais98g grape98g ban98g apple98g melon98g pear98g orang98g straw98g peach98g oj98g aj98g
tom98g tofu98g sbean98g beans98g brocc98g corn98g peas98g mixv98g spin98g kale98g grpep98g
yams98g eggpl98g ccar98g rcar98g lett98g slaw98g psal98g
pchip98g cchip98g nacho98g popc98g pretz98g nuts98g fufrt98g gcrax98g crack98g popt98g
cake98g twink98g pie98g sroll98g cooki98g brwni98g choco98g cdywo98g pudd98g
fryog98g icecr98g frapp98g pops98g powrb98g protb98g );

yr98g=1;
proc sort nodupkey data=girls98; by id; run;

data girls98; set girls98;

  array old1 {*} local98g coke98g punch98g othch98g;
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

  array old2 {*} tea98g coff98g;
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

  array old3 {*} cotch98g fishs98g shrim98g lasag98g macch98g soup98g 
                 otgrn98g panca98g melon98g slaw98g psal98g nacho98g pretz98g cake98g pie98g frapp98g;
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

  array old4 {*} instb98g cburg98g burg98g pizza98g taco98g chnug98g dog98g
                  spj98g sturk98g srb98g sbol98g stuna98g chick98g ofish98g beef98g pork98g 
                  meatb98g grlch98g spag98g eggs98g bacon98g ketch98g engl98g
                  muff98g fries98g mashp98g pasta98g rice98g bisc98g torti98g rais98g
                  grape98g ban98g straw98g peach98g tofu98g sbean98g brocc98g corn98g 
                  peas98g mixv98g spin98g kale98g grpep98g yams98g eggpl98g ccar98g rcar98g 
                  brwni98g pudd98g fryog98g icecr98g pops98g powrb98g protb98g;
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

  array old5 {*} yog98g crch98g oj98g aj98g;
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

  array old6 {*} but98g marg98g;
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

  array old7 {*} beer98g wine98g liq98g chowd98g mayo98g lcsdr98g saldr98g salsa98g apple98g pear98g orang98g
                tom98g lett98g pchip98g cchip98g twink98g sroll98g choco98g cdywo98g;
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

  array old8 {*} cer98g ckcer98g;
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

  array old9 {*} whbr98g drbr98g;
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

  array old10 {*} popc98g nuts98g fufrt98g gcrax98g crack98g; 
  array new10 {*} popc98 nuts98 fufrt98 gcrax98 crack98; 
  do i=1 to DIM(old10);
  if old10(i)=1 then new10(i)=0;
  else if old10(i)=2 then new10(i)=0.07;
  else if old10(i)=3 then new10(i)=0.36;
  else if old10(i)=4 then new10(i)=0.71;
  else if old10(i)=5 then new10(i)=.;
  else old10(i)=0;
  end;

  if milk98g=1 then milk98=0;
    else if milk98g=2 then milk98=0.14;
    else if milk98g=3 then milk98=0.57;
    else if milk98g=4 then milk98=1;
    else if milk98g=5 then milk98=2.5;
    else if milk98g=6 then milk98=4;
    else if milk98g=7 then milk98=.;
    else milk98=0;

  if chocm98g=1 then chocm98=0;
    else if chocm98g=2 then chocm98=0.07;
    else if chocm98g=3 then chocm98=0.14;
    else if chocm98g=4 then chocm98=0.57;
    else if chocm98g=5 then chocm98=1.5;
    else if chocm98g=6 then chocm98=3;
    else if chocm98g=7 then chocm98=.;
    else chocm98=0;

 if gravy98g=1 then gravy98=0;
  else if gravy98g=2 then gravy98=0.07;
  else if gravy98g=3 then gravy98=0.57;
  else if gravy98g=4 then gravy98=1;
  else if gravy98g=5 then gravy98=2;
  else if gravy98g=6 then gravy98=.;
  else gravy98=0;

  if beans98g=1 then beans98=0;
  else if beans98g=2 then beans98=0.14;
  else if beans98g=3 then beans98=0.57;
  else if beans98g=4 then beans98=1;
  else if beans98g=5 then beans98=.;
  else beans98=0;

  if popt98g=1 then popt98=0;
  else if popt98g=2 then popt98=0.07;
  else if popt98g=3 then popt98=0.5;
  else if popt98g=4 then popt98=2;
  else if popt98g=5 then popt98=.;
  else popt98=0;

  if cooki98g=1 then cooki98=0;
  else if cooki98g=2 then cooki98=0.07;
  else if cooki98g=3 then cooki98=0.14;
  else if cooki98g=4 then cooki98=0.57;
  else if cooki98g=5 then cooki98=2;
  else if cooki98g=6 then cooki98=4;
  else if cooki98g=7 then cooki98=.;
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

keep yr98g id momid 
		promeat98   redmeat98   fish98    poult98    eggs98     butter98    
  		marg98      lowdai98   highdai98   wine98    liquor98   beer98     tea98       
  		coffee98    fruit98    fruju98     cruveg98  yelveg98   tomato98   leafveg98   
  		legume98    othveg98   potato98    french98  wholeg98   refing98   pizza98    
  		sugdrk98    lowdrk98   snack98     nuts98    mayo98     dress98    crmsoup98   
  		sweets98    condim98      ;

  if nmiss(of promeat98   redmeat98   fish98    poult98    eggs98     butter98    
  		marg98      lowdai98   highdai98   wine98    liquor98   beer98     tea98       
  		coffee98    fruit98    fruju98     cruveg98  yelveg98   tomato98   leafveg98   
  		legume98    othveg98   potato98    french98  wholeg98   refing98   pizza98    
  		sugdrk98    lowdrk98   snack98     nuts98    mayo98     dress98    crmsoup98   
  		sweets98    condim98) >0 then delete; *289 missing removed;

run;

proc factor data=girls98 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f98;
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
Calling in girls01 keeping variables for analysis
*******************************************************************;
%girls01 (keep= girls01 yrq01 id momid
local01g coke01g punch01g tea01g coff01g beer01g wine01g liq01g
milk01g chocm01g instb01g yog01g cotch01g othch01g crch01g but01g marg01g
cburg01g burg01g pizza01g taco01g chnug01g dog01g spj01g sturk01g srb01g sbol01g stuna01g
chick01g fishs01g ofish01g shrim01g beef01g pork01g meatb01g lasag01g macch01g grlch01g spag01g
eggs01g bacon01g gravy01g ketch01g chowd01g soup01g mayo01g lcsdr01g saldr01g salsa01g
cer01g ckcer01g whbr01g dbr01g engl01g muff01g panca01g fries01g mashp01g pasta01g rice01g bisc01g torti01g
rais01g grape01g ban01g apple01g melon01g pear01g orang01g straw01g peach01g oj01g aj01g
tom01g tofu01g sbean01g beans01g brocc01g corn01g peas01g mveg01g spin01g kale01g grpep01g
yams01g eggpl01g ccar01g rcar01g lett01g slaw01g psald01g
pchip01g cchip01g nacho01g popc01g pretz01g nuts01g fufrt01g gcrax01g crack01g popt01g
cake01g twink01g pie01g sroll01g cooki01g brwni01g choco01g cdywo01g pudd01g
fryog01g icecr01g frapp01g pops01g powrb01g protb01g );

yrq01=1; girls01=1;
proc sort nodupkey data=girls01; by id; run;

data girls01; set girls01;

  array old1 {*} local01g coke01g punch01g tea01g coff01g beer01g wine01g liq01g milk01g chocm01g instb01g 
				 yog01g cotch01g othch01g crch01g but01g marg01g cburg01g burg01g pizza01g taco01g chnug01g dog01g
                 spj01g sturk01g srb01g sbol01g stuna01g chick01g fishs01g ofish01g shrim01g beef01g pork01g
				 meatb01g lasag01g macch01g grlch01g spag01g eggs01g bacon01g gravy01g ketch01g chowd01g
				 soup01g mayo01g lcsdr01g saldr01g salsa01g cer01g ckcer01g whbr01g dbr01g engl01g muff01g panca01g
				 fries01g  mashp01g pasta01g rice01g bisc01g torti01g rais01g grape01g ban01g apple01g melon01g 
				 pear01g orang01g straw01g peach01g oj01g aj01g tom01g tofu01g sbean01g beans01g
				 brocc01g corn01g peas01g mveg01g spin01g kale01g grpep01g yams01g eggpl01g ccar01g rcar01g 
  				 lett01g slaw01g psald01g pchip01g cchip01g nacho01g popc01g pretz01g nuts01g fufrt01g 
				 gcrax01g crack01g popt01g cake01g twink01g pie01g sroll01g cooki01g
				 brwni01g choco01g cdywo01g pudd01g fryog01g icecr01g frapp01g pops01g powrb01g protb01g;
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

 if nmiss(of promeat01   redmeat01   fish01    poult01    eggs01     butter01    
  		marg01      lowdai01   highdai01   wine01    liquor01   beer01     tea01       
  		coffee01    fruit01    fruju01     cruveg01  yelveg01   tomato01   leafveg01   
  		legume01    othveg01   potato01    french01  wholeg01   refing01   pizza01    
  		sugdrk01    lowdrk01   snack01     nuts01    mayo01     dress01    crmsoup01   
  		sweets01    condim01 ) >0 then delete; *139 missing removed;

run;

proc factor data=girls01 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f01;
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
Calling in girls04 keeping variables for analysis
*****************************************************/
%girls204 (keep= id yr204g momid
local204g coke204g punch204g spdrk204g tea204g coff204g beer204g wine204g liq204g
milk204g chocm204g instb204g yog204g cotch204g othch204g crch204g but204g marg204g
cburg204g burg204g pizza204g taco204g chnug204g dog204g spj204g sturk204g srb204g sbol204g stuna204g
chick204g fishs204g ofish204g shrim204g beef204g pork204g meatb204g lasag204g macch204g spag204g
eggs204g bacon204g liver204g frtoa204g grlch204g eggro204g gravy204g ketch204g chowd204g soup204g mayo204g lcsdr204g saldr204g salsa204g
cer204g oat204g ckcer204g whbr204g dkbr204g engl204g muff204g cornb204g bisc204g rice204g pasta204g torti204g panca204g
fries204g mashp204g rais204g grape204g ban204g apple204g melon204g pear204g orang204g straw204g peach204g oj204g aj204g
tom204g tofu204g sbean204g beans204g brocc204g corn204g peas204g mixv204g spin204g kale204g grpep204g
yams204g eggpl204g ccar204g rcar204g celry204g lett204g slaw204g psald204g
pchip204g cchip204g popc204g pretz204g nuts204g fufrt204g gcrax204g crack204g popt204g
cake204g twink204g sroll204g donut204g cooki204g brwni204g pie204g choco204g cdyw204g cdywo204g jello204g pudd204g
fryog204g icecr204g frapp204g pops204g seeds204g powrb204g protb204g );

yr204g=1;
proc sort nodupkey data=girls204; by id; run;

data girls204; set girls204; 
 
  array old1 {*} local204g coke204g punch204g othch204g whbr204g dkbr204g;
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

  if spdrk204g=1 then spdrk204=0;
	else if spdrk204g=2 then spdrk204=0.07;
	else if spdrk204g=3 then spdrk204=0.36;
	else if spdrk204g=4 then spdrk204=0.79;
	else if spdrk204g=5 then spdrk204=2; 
	else if spdrk204g=6 then spdrk204=.;
	else spdrk204=0;

  array old2{*} tea204g coff204g;
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

  array old3{*} beer204g wine204g liq204g chowd204g mayo204g lcsdr204g saldr204g salsa204g apple204g pear204g 
				orang204g tom204g beans204g lett204g pchip204g cchip204g popt204g twink204g donut204g
				choco204g cdyw204g cdywo204g;
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

  if milk204g=1 then milk204=0;
  	else if milk204g=2 then milk204=0.07;
	else if milk204g=3 then milk204=0.57;
	else if milk204g=4 then milk204=1;
	else if milk204g=5 then milk204=2.5;
	else if milk204g=6 then milk204=4;
	else if milk204g=7 then milk204=.;
	else milk204=0;

  if chocm204g=1 then chocm204=0;
   	else if chocm204g=2 then chocm204=0.07;
	else if chocm204g=3 then chocm204=0.14;
	else if chocm204g=4 then chocm204=0.57;
	else if chocm204g=5 then chocm204=1.5;
	else if chocm204g=6 then chocm204=3;
	else if chocm204g=7 then chocm204=.;
	else chocm204=0;

array old6{*} instb204g cburg204g burg204g pizza204g taco204g chnug204g dog204g spj204g sturk204g srb204g sbol204g  
			stuna204g chick204g ofish204g beef204g pork204g meatb204g spag204g eggs204g bacon204g grlch204g
			eggro204g ketch204g engl204g muff204g cornb204g bisc204g rice204g pasta204g torti204g fries204g
			mashp204g rais204g grape204g ban204g straw204g peach204g tofu204g sbean204g brocc204g corn204g 
			peas204g mixv204g spin204g kale204g grpep204g yams204g eggpl204g ccar204g rcar204g celry204g popc204g
			nuts204g fufrt204g gcrax204g crack204g sroll204g brwni204g jello204g pudd204g fryog204g icecr204g
			pops204g seeds204g powrb204g protb204g;
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

array old4{*} yog204g crch204g oj204g aj204g;
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

array old7{*} cotch204g fishs204g shrim204g lasag204g macch204g liver204g gravy204g soup204g panca204g melon204g
			slaw204g psald204g pretz204g cake204g pie204g frapp204g;
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

array old5{*} but204g marg204g;
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

if frtoa204g=1 then frtoa204=0;
	else if frtoa204g=2 then frtoa204=0.07;
	else if frtoa204g=3 then frtoa204=0.14;
	else if frtoa204g=4 then frtoa204=0.43;
	else if frtoa204g=5 then frtoa204=2;
	else if frtoa204g=6 then frtoa204=.;
	else frtoa204=0;

  array old8 {*} cer204g oat204g ckcer204g;
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

  if cooki204g=1 then cooki204=0;
  	else if cooki204g=2 then cooki204=0.07;
	else if cooki204g=3 then cooki204=0.14;
	else if cooki204g=4 then cooki204=0.57;
	else if cooki204g=5 then cooki204=2;
	else if cooki204g=6 then cooki204=4;
	else if cooki204g=7 then cooki204=.;
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

keep yr204g id momid 
		promeat204   redmeat204  orgmeat204   fish204    poult204    eggs204     butter204    
  		marg204      lowdai204   highdai204   wine204    liquor204   beer204     tea204       
  		coffee204    fruit204    fruju204     cruveg204  yelveg204   tomato204   leafveg204   
  		legume204    othveg204   potato204    french204  wholeg204   refing204   pizza204    
  		sugdrk204    lowdrk204   snack204     nuts204    mayo204     dress204    crmsoup204   
  		sweets204    condim204      ;

 if nmiss(of promeat204   redmeat204  orgmeat204   fish204    poult204    eggs204     butter204    
  		marg204      lowdai204   highdai204   wine204    liquor204   beer204     tea204       
  		coffee204    fruit204    fruju204     cruveg204  yelveg204   tomato204   leafveg204   
  		legume204    othveg204   potato204    french204  wholeg204   refing204   pizza204    
  		sugdrk204    lowdrk204   snack204     nuts204    mayo204     dress204    crmsoup204   
  		sweets204    condim204 ) >0 then delete; *296 missing removed;

run;

proc factor data=girls204 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f04;
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
Calling Girls06 Keeping Variables for analysis
************************************************;
%girls206 (keep= id yr206g momid
local206g coke206g punch206g spdrk206g tea206g coff206g latte206g beer206g wine206g liq206g
milk206g chocm206g instb206g yog206g cotch206g othch206g crch206g but206g marg206g
cburg206g burg206g pizza206g taco206g chnug206g dog206g spj206g sturk206g srb206g sbol206g stuna206g
chick206g fishs206g ofish206g shrim206g beef206g pork206g meatb206g lasag206g macch206g spag206g
eggs206g bacon206g frtoa206g grlch206g eggro206g gravy206g ketch206g chowd206g soup206g mayo206g lcsdr206g saldr206g salsa206g
cer206g htcer206g whbr206g dkbr206g engl206g muff206g cornb206g bisc206g rice206g pasta206g torti206g panca206g
fries206g mashp206g rais206g grape206g ban206g apple206g melon206g pear206g orang206g straw206g peach206g oj206g aj206g
tom206g tofu206g sbean206g beans206g brocc20bg corn206g peas206g mixv206g spin206g kale206g grpep206g
yams206g eggpl206g ccar206g rcar206g celry206g lett206g slaw206g psald206g
pchip206g cchip206g popc206g pretz206g nuts206g fufrt206g gcrax206g crack206g popt206g
cake206g twink206g sroll206g donut206g cooki206g brwni206g pie206g choco206g cdyw206g cdywo206g jello206g pudd206g
fryog206g icecr206g frapp206g pops206g seeds206g powrb206g protb206g);

yr06g=1;
proc sort nodupkey data=girls206; by id; run;

data girls206; set girls206;

  array old1 {*} local206g coke206g punch206g othch206g whbr206g dkbr206g;
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

  if spdrk206g=1 then spdrk206=0;
	else if spdrk206g=2 then spdrk206=0.07;
	else if spdrk206g=3 then spdrk206=0.36;
	else if spdrk206g=4 then spdrk206=0.79;
	else if spdrk206g=5 then spdrk206=2; 
	else if spdrk206g=6 then spdrk206=.;
	else spdrk206=0;

  array old2{*} tea206g coff206g latte206g;
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

  array old3{*} beer206g wine206g liq206g chowd206g soup206g mayo206g lcsdr206g saldr206g salsa206g 
				apple206g pear206g orang206g tom206g beans206g lett206g pchip206g cchip206g popt206g 
				twink206g donut206g choco206g cdyw206g cdywo206g;
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

  if milk206g=1 then milk206=0;
  	else if milk206g=2 then milk206=0.07;
	else if milk206g=3 then milk206=0.57;
	else if milk206g=4 then milk206=1;
	else if milk206g=5 then milk206=2.5;
	else if milk206g=6 then milk206=4;
	else if milk206g=7 then milk206=.;
	else milk206=0;

  if chocm206g=1 then chocm206=0;
   	else if chocm206g=2 then chocm206=0.07;
	else if chocm206g=3 then chocm206=0.14;
	else if chocm206g=4 then chocm206=0.57;
	else if chocm206g=5 then chocm206=1.5;
	else if chocm206g=6 then chocm206=3;
	else if chocm206g=7 then chocm206=.;
	else chocm206=0;

array old6{*} instb206g cburg206g burg206g pizza206g taco206g chnug206g dog206g spj206g sturk206g srb206g sbol206g  
			stuna206g chick206g ofish206g beef206g pork206g meatb206g spag206g eggs206g bacon206g grlch206g
			eggro206g ketch206g engl206g muff206g cornb206g bisc206g rice206g pasta206g torti206g fries206g
			mashp206g rais206g grape206g ban206g straw206g peach206g tofu206g sbean206g brocc20bg corn206g 
			peas206g mixv206g spin206g kale206g grpep206g yams206g eggpl206g ccar206g rcar206g celry206g popc206g
			nuts206g fufrt206g gcrax206g crack206g sroll206g brwni206g jello206g pudd206g fryog206g icecr206g
			pops206g seeds206g powrb206g protb206g;
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

array old4{*} yog206g crch206g oj206g aj206g;
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

array old7{*} cotch206g fishs206g shrim206g lasag206g macch206g gravy206g panca206g melon206g
			slaw206g psald206g pretz206g cake206g pie206g frapp206g;
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

array old5{*} but206g marg206g;
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

if frtoa206g=1 then frtoa206=0;
	else if frtoa206g=2 then frtoa206=0.07;
	else if frtoa206g=3 then frtoa206=0.14;
	else if frtoa206g=4 then frtoa206=0.43;
	else if frtoa206g=5 then frtoa206=2;
	else if frtoa206g=6 then frtoa206=.;
	else frtoa206=0;

  array old8 {*} cer206g htcer206g ;
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

  if cooki206g=1 then cooki206=0;
  	else if cooki206g=2 then cooki206=0.07;
	else if cooki206g=3 then cooki206=0.14;
	else if cooki206g=4 then cooki206=0.57;
	else if cooki206g=5 then cooki206=2;
	else if cooki206g=6 then cooki206=4;
	else if cooki206g=7 then cooki206=.;
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

keep yr206g id momid
		promeat206   redmeat206    fish206    poult206    eggs206     butter206    
  		marg206      lowdai206   highdai206   wine206    liquor206   beer206     tea206       
  		coffee206    fruit206    fruju206     cruveg206  yelveg206   tomato206   leafveg206   
  		legume206    othveg206   potato206    french206  wholeg206   refing206   pizza206    
  		sugdrk206    lowdrk206   snack206     nuts206    mayo206     dress206    crmsoup206   
  		sweets206    condim206      ;

 if nmiss(of promeat206   redmeat206    fish206    poult206    eggs206     butter206    
  		marg206      lowdai206   highdai206   wine206    liquor206   beer206     tea206       
  		coffee206    fruit206    fruju206     cruveg206  yelveg206   tomato206   leafveg206   
  		legume206    othveg206   potato206    french206  wholeg206   refing206   pizza206    
  		sugdrk206    lowdrk206   snack206     nuts206    mayo206     dress206    crmsoup206   
  		sweets206    condim206 ) >0 then delete; *148 missing removed;

run;

proc factor data=girls206 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f06;
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
Calling in Girls08 Keeping Variables for Analysis
**********************************************;
%girls208 (keep= id yr208g momid
local208g coke208g punch208g spdrk208g tea208g coff208g latte208g beer208g wine208g liq208g rdbul208g
milk208g chocm208g instb208g yog208g cotch208g othch208g crch208g but208g marg208g
cburg208g burg208g vburg208g subburg208g pizza208g taco208g chnug208g dog208g spj208g sturk208g srb208g sbol208g stuna208g
chick208g fishs208g ofish208g shrim208g beef208g pork208g meatb208g lasag208g macch208g spag208g
eggs208g bacon208g frtoa208g grlch208g liver208g gravy208g ketch208g chowd208g soup208g mayo208g lcsdr208g saldr208g salsa208g
sugar208g cer208g htcer208g whbr208g dkbr208g engl208g muff208g cornb208g bisc208g rice208g pasta208g torti208g panca208g
fries208g mashp208g rais208g grape208g ban208g apple208g melon208g pear208g orang208g straw208g peach208g oj208g aj208g
tom208g sbean208g beans208g brocc208g corn208g peas208g mixv208g spin208g kale208g grpep208g
yams208g eggpl208g ccar208g rcar208g celry208g lett208g slaw208g psald208g
pchip208g cchip208g popc208g pretz208g nuts208g fufrt208g gcrax208g crack208g popt208g
cake208g twink208g sroll208g donut208g cooki208g brwni208g pie208g choco208g cdyw208g cdywo208g jello208g pudd208g
fryog208g icecr208g frapp208g pops208g seeds208g powrb208g protb208g cergb208g);

yr208g=1;
proc sort nodupkey data=girls208; by id; run;

data girls208; set girls208;

  array old1{*} local208g coke208g punch208g othch208g whbr208g dkbr208g;
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

  array old9{*} spdrk208g rdbul208g; 
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

  array old2{*} tea208g coff208g latte208g;
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

  array old3{*} beer208g wine208g liq208g chowd208g soup208g mayo208g lcsdr208g saldr208g salsa208g 
				apple208g pear208g orang208g tom208g beans208g lett208g pchip208g cchip208g popt208g 
				twink208g donut208g choco208g cdyw208g cdywo208g;
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

  if milk208g=1 then milk208=0;
  	else if milk208g=2 then milk208=0.07;
	else if milk208g=3 then milk208=0.57;
	else if milk208g=4 then milk208=1;
	else if milk208g=5 then milk208=2.5;
	else if milk208g=6 then milk208=4;
	else if milk208g=7 then milk208=.;
	else milk208=0;

  if chocm208g=1 then chocm208=0;
   	else if chocm208g=2 then chocm208=0.07;
	else if chocm208g=3 then chocm208=0.14;
	else if chocm208g=4 then chocm208=0.57;
	else if chocm208g=5 then chocm208=1.5;
	else if chocm208g=6 then chocm208=3;
	else if chocm208g=7 then chocm208=.;
	else chocm208=0;

array old6{*} instb208g cburg208g burg208g vburg208g subburg208g pizza208g taco208g chnug208g dog208g spj208g 
			sturk208g srb208g sbol208g stuna208g chick208g ofish208g beef208g pork208g meatb208g spag208g 
			eggs208g bacon208g grlch208g ketch208g engl208g muff208g cornb208g bisc208g rice208g pasta208g torti208g 
			fries208g mashp208g rais208g grape208g ban208g straw208g peach208g sbean208g brocc208g corn208g 
			peas208g mixv208g spin208g kale208g grpep208g yams208g eggpl208g ccar208g rcar208g celry208g popc208g
			nuts208g fufrt208g gcrax208g crack208g sroll208g brwni208g jello208g pudd208g fryog208g icecr208g
			pops208g seeds208g powrb208g protb208g;
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

array old4{*} yog208g crch208g oj208g aj208g;
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

array old7{*} cotch208g fishs208g shrim208g lasag208g macch208g gravy208g panca208g melon208g
			slaw208g psald208g pretz208g cake208g pie208g frapp208g;
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

array old5{*} but208g marg208g;
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

	array old10{*} frtoa208g cergb208g;
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

  array old8{*} cer208g htcer208g ;
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

  if cooki208g=1 then cooki208=0;
  	else if cooki208g=2 then cooki208=0.07;
	else if cooki208g=3 then cooki208=0.14;
	else if cooki208g=4 then cooki208=0.57;
	else if cooki208g=5 then cooki208=2;
	else if cooki208g=6 then cooki208=4;
	else if cooki208g=7 then cooki208=.;
	else cooki208=0;

  if liver208g=1 then liver208=0;
  	else if liver208g=2 then liver208=0.03;
	else if liver208g=3 then liver208=0.08;
	else if liver208g=4 then liver208=0.29;
	else if liver208g=5 then liver208=.;
	else liver208=0;

  if sugar208g=1 then sugar208=0;
  	else if sugar208g=2 then sugar208=1.5;
	else if sugar208g=3 then sugar208=3.5;
	else if sugar208g=4 then sugar208=6;
	else if sugar208g=5 then sugar208=.;
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

keep yr208g id momid   
		promeat208   redmeat208  orgmeat208   fish208    poult208    eggs208     butter208    
  		marg208      lowdai208   highdai208   wine208    liquor208   beer208     tea208       
  		coffee208    fruit208    fruju208     cruveg208  yelveg208   tomato208   leafveg208   
  		legume208    othveg208   potato208    french208  wholeg208   refing208   pizza208    
  		sugdrk208    lowdrk208   snack208     nuts208    mayo208     dress208    crmsoup208   
  		sweets208    condim208      ;

 if nmiss(of promeat208   redmeat208  orgmeat208   fish208    poult208    eggs208     butter208    
  		marg208      lowdai208   highdai208   wine208    liquor208   beer208     tea208       
  		coffee208    fruit208    fruju208     cruveg208  yelveg208   tomato208   leafveg208   
  		legume208    othveg208   potato208    french208  wholeg208   refing208   pizza208    
  		sugdrk208    lowdrk208   snack208     nuts208    mayo208     dress208    crmsoup208   
  		sweets208    condim208  ) >0 then delete; *63 missing removed;

run;
proc factor data=girls208 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f08;
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
Calling in Girls11 Keeping Variables for Analysis
********************************************;
%girls211 (keep=  id yr211g girls211 momid
rais211g grape211g ban211g appl211g apsau211g cant211g wtrml211g oran211g straw211g peach211g oj211g aj211g
tom211g toj211g sbean211g brocc211g corn211g peas211g mixv211g rspin211g cspin211g bruss211g grpep211g
yams211g eggp211g ccar211g rcar211g celry211g ilett211g ptsld211g fries211g mashp211g oniov211g oniog211g
cer211g oat211g ckcer211g whbr211g dkbr211g engl211g muff211g crnbr211g bisct211g wrice211g brice211g tort211g panca211g frtst211g
skim211g m1or2211g whole211g chocm211g soy211g instb211g prosh211g plyog211g yoglt211g yog211g cotch211g crch211g
but211g sbu211g marg211g whip211g cream211g ketch211g chowd211g soup211g mayo211g lcsdr211g saldr211g salsa211g jam211g pbut211g
lccaf211g lcnoc211g coke211g otsug211g punch211g spdrk211g rdbsf211g rdbul211g rdbor211g tea211g smth211g beer211g lbeer211g
wine211g liq211g sodas211g decaf211g coff211g cdff211g latte211g icff211g icd211g
egg211g cburg211g burg211g vburg211g tofu211g pizza211g chnug211g dog211g ctdog211g bacon211g procm211g
fsan211g fbur211g fpas211g fmix211g beef211g chwi211g chwo211g pork211g beans211g tosau211g fishs211g ctuna211g dkfsh211g
shrim211g ofish211g macch211g othch211g chip211g bchip211g popc211g pretz211g pnut211g wnut211g onut211g seeds211g
fsnk211g crack211g popt211g twink211g sroll211g donut211g cooki211g brwni211g pie211g choco211g cdyw211g cdywo211g pudd211g
fryog211g icecr211g pops211g powrb211g protb211g brbar211g sugar211g
stsa211g stbf211g stt211g stvg211g stct211g stpb211g stpt211g );

girls211=1; yrq11=1;
proc sort nodupkey data=girls211; by id; run;

data girls211; set girls211;

array old1{*} rais211g grape211g ban211g appl211g apsau211g cant211g wtrml211g oran211g straw211g peach211g oj211g aj211g
tom211g toj211g sbean211g brocc211g corn211g peas211g mixv211g rspin211g cspin211g bruss211g grpep211g yams211g 
eggp211g ccar211g rcar211g celry211g ilett211g ptsld211g fries211g mashp211g oniov211g oniog211g cer211g oat211g ckcer211g 
whbr211g dkbr211g engl211g muff211g crnbr211g bisct211g wrice211g brice211g tort211g panca211g frtst211g
skim211g m1or2211g whole211g chocm211g soy211g instb211g prosh211g plyog211g yoglt211g yog211g cotch211g crch211g
but211g sbu211g marg211g whip211g cream211g ketch211g chowd211g soup211g mayo211g lcsdr211g saldr211g salsa211g jam211g pbut211g
lccaf211g lcnoc211g coke211g otsug211g punch211g spdrk211g rdbsf211g rdbul211g rdbor211g tea211g smth211g beer211g lbeer211g
wine211g liq211g  egg211g cburg211g burg211g vburg211g tofu211g pizza211g chnug211g dog211g ctdog211g bacon211g procm211g
fsan211g fbur211g fpas211g fmix211g beef211g chwi211g chwo211g pork211g beans211g tosau211g fishs211g ctuna211g dkfsh211g
shrim211g ofish211g macch211g othch211g chip211g bchip211g popc211g pretz211g pnut211g wnut211g onut211g seeds211g
fsnk211g crack211g popt211g twink211g sroll211g donut211g cooki211g brwni211g pie211g choco211g cdyw211g cdywo211g pudd211g
fryog211g icecr211g pops211g powrb211g protb211g brbar211g ;

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

  if sugar211g=1 then sugar211=0;
  	else if sugar211g=2 then sugar211=1.5;
	else if sugar211g=3 then sugar211=3.5;
	else if sugar211g=4 then sugar211=6;
	else if sugar211g=5 then sugar211=.;
	else sugar211=0;

array old2{*} decaf211g coff211g cdff211g latte211g icff211g icd211g;
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
   condim211    = sum (ketch211, salsa211, oniog211 );

keep id yr211g momid 
		promeat211   redmeat211    fish211    poult211    eggs211     butter211    
  		marg211      lowdai211   highdai211   wine211    liquor211   beer211     tea211       
  		coffee211    fruit211    fruju211     cruveg211  yelveg211   tomato211   leafveg211   
  		legume211    othveg211   potato211    french211  wholeg211   refing211   pizza211    
  		sugdrk211    lowdrk211   snack211     nuts211    mayo211     dress211    crmsoup211   
  		sweets211    condim211      ;

 if nmiss(of promeat211   redmeat211    fish211    poult211    eggs211     butter211    
  		marg211      lowdai211   highdai211   wine211    liquor211   beer211     tea211       
  		coffee211    fruit211    fruju211     cruveg211  yelveg211   tomato211   leafveg211   
  		legume211    othveg211   potato211    french211  wholeg211   refing211   pizza211    
  		sugdrk211    lowdrk211   snack211     nuts211    mayo211     dress211    crmsoup211   
  		sweets211    condim211    ) >0 then delete; *52 missing removed;

run;
proc factor data=girls211 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f11;
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
data here.girlwestern1;  
merge f96 f97 f98 f01;
by id;

	array prud    {*}   f196   f197  f198    f101      ; 
  array prudr    {*}   f196r   f197r  f198r    f101r      ; /*BCAR updated code to keep original values without carrying forward*/
	array west    {*}   f296   f297  f298    f201    ; 
  array westr   {*}   f296r  f297r f298r   f201r   ; /*BCAR updated code to keep original values without carrying forward*/
	
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

data here.girlwestern2; 
merge f04 f06 f08 f11; 
by id;

	array prud    {*}   f104   f106  f108    f111     ; 
  array prudr    {*}   f104r   f106r  f108r    f111r     ; /*BCAR updated code to keep original values without carrying forward*/
	array west    {*}   f204   f206  f208    f211     ; 
	array westr   {*}   f204r  f206r f208r   f211r    ; /*BCAR updated code to keep original values without carrying forward*/

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

