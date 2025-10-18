/**********************************************************************************************************************/
/*            Background                                                                                              */
/**********************************************************************************************************************/

/*
Programmer: Bethsaida Cardona
    Modified based on following files: 
    /proj/nhairs/nhair2q/progs/env_htn/env.htn.0.readin.sas
	/proj/nhairs/nhair3a/SiddiquiNoreen_FFO_Inflammation_102024/1_finaldata.sas
        

Original Program Name: /udd/n2bca/childhood_obesity/

Program start date: Dec 23, 2024

Project title: Transgenerational, personal, and social determinants of overweight and 
obesity during childhood and adolescence

Purpose of the program:
	To examine the association between various transgenerational, personal, and environmental factors with 
    childhood and adolescent overweight or obesity among GUTS children
	
    This script creates dataset on environmental factors linked to residential address of NHSII participants. 
    Assummes GUTS participants (children of NHSII participants) lived with mom. 


Main exposures/Covariates
    nSES index (continuous) [NSES_XX, where XX=year]
    Greenspace (annual mean, continuous NDVI 0 to 1) [NDVI1YRXX NDVI2YRXX, where XX=year]
    Air pollution, PM2.5 PM10, NO2 (continuous) [PM25__: PM10__: NO2__:]
    Temperature: summer mean [TMEANS:] summer max [TMAXS] summer min [TMINS:] 
					winter mean [TMEANW:] winter max [TMAXW:] winter min [TMINW:]
	Number of fastfood stores: within a 500m buffer [FASTFOOD500:], a 1000m buffer [FASTFOOD1000:], and 1500m buffer [FASTFOOD1500:]
    Number of supermarket or grocery stores: within a 500m buffer [SUPERMARKET500:], a 1000m buffer [SUPERMARKET1000:], and 1500m buffer [SUPERMARKET1500:]    

Input files: 
	nses: %nses8917()
    greenspace: /proj/nhairs/nhair1w/landsat_ndvi/landsat_ndvi_nhs2_create.sas
	air pollution: /proj/nhairs/nhair0a/datasets/nhs2_pm_wide_cfinf.dat and /pc/nhair0a/2019_AP_exposures/JeffY/predictions20220328052532/
    temperature: '/pc/nhair0a/PRISM_data/nhsii8917_prism800m'
	number of fastfood and grocery stores: '/pc/nhair0a/Built_Environment/BE_Data/Geographic_Data/foodenvironment/buffered_rasters/nhs2_density_wide.csv'


Future discussion points: 
    Any other measures of air pollution to consider?
    Are these variables for temperature okay? 
   
*/


/**********************************************************************************************************************/
/*            Program Set Up                                                                                          */
/**********************************************************************************************************************/


/* Show full log, try to find which step is the slowest */
options msglevel=i fullstimer;

/* Path to macros*/
filename nhstools '/proj/nhsass/nhsas00/nhstools/sasautos/'; 
filename channing '/usr/local/channing/sasautos/';
options  mautosource sasautos=(channing nhstools);

/* Path to formats */
libname  nhsfmt   "/proj/nhsass/nhsas00/formats";
options fmtsearch=(nhsfmt);
/* options  fmtsearch=(nhsfmt) nofmterr nocenter nonumber nodate formdlim=' '; */

/* Path to datasets*/
libname nhair0a '/proj/nhairs/nhair0a/datasets';
libname jef "/pc/nhair0a/2019_AP_exposures/JeffY/predictions20220328052532/";
libname temp '/pc/nhair0a/PRISM_data/';

options  linesize=130 pagesize=78;

/* Create global macro variable date */
data _null_;
	date10=put(date(),yymmdd10.);
	call symput("date",translate(date10,"_","-"));
run;

/* Record start time */
%let _timer_start = %sysfunc(datetime());


/**********************************************************************************************************************/
/*            Gather Variables of Interest                                                                            */
/**********************************************************************************************************************/


/***********************************************/
/*            nSES				               */
/***********************************************/

/***Bring in nSES for NHS2 using macro***/
/* Useful documentation: https://docs.google.com/document/d/1ztfKXl100gFXTp0KZlG3EsN-H1h38CVaGYNQ1FemFhg/edit */
/* /proj/nhairs/nhair2g/progs/CVD/noise/carryback/n.0.readin_carryback.sas */
/* example program calculating nses /proj/n2dats/n2dat.der/nses8913/example_program/ */

%nses8917(); run;

data nses8917; 
	set nses8917; 
		keep id nSES: 
	; 
run;

proc sort data=nses8917; by id; run;

/***********************************************/
/*               Greenspace				       */
/***********************************************/

/* 
NDVI measures included in the file:       
   1) seasonal NDVI
   2) annual mean NDVI
   3) max NDVI in each year
   4) cumulative average annual NDVI from 1986
   5) cumulative average max NDVI from 1986

In the code I only keep the annual mean NDVI, coded as: 
ndviByrYY  where B = buffer (1=270, 2=1230) and YY = year (89, 90, 91...)

*/


%include '/proj/nhairs/nhair1w/landsat_ndvi/landsat_ndvi_nhs2_create.sas';
data ndvi;
   set nhs2_ndvi;
   nid=id*1;
   drop id;
   keep nid ndvi1yr: ndvi2yr: ;
run;

data ndvi;
   set ndvi;
   id=nid;
   drop nid;
run; 

proc sort data= ndvi; by id; 

/***********************************************/
/*               Air Pollution				   */
/***********************************************/

/*Per Jaime, pm25_37 is the monthly average for Jan 1988, NO2 starts with no2_61 (Jan 1990)

   37=jan1988		49=jan1989		61=jan1900		73=jan1991		85=jan1992		97=jan1993
   38=feb1988		50=feb1989		62=feb1900		74=feb1991		86=feb1992		98=feb1993
   39=mar1988		51=mar1989		63=mar1900		75=mar1991		87=mar1992		99=mar1993
   40=apr1988		52=apr1989		64=apr1900		76=apr1991		88=apr1992		100=apr1993
   41=may1988		53=may1989		65=may1900		77=may1991		89=may1992		101=may1993
   42=jun1988		54=jun1989		66=jun1900		78=jun1991		90=jun1992		102=jun1993
   43=jul1988		55=jul1989		67=jul1900		79=jul1991		91=jul1992		103=jul1993
   44=aug1988		56=aug1989		68=aug1900		80=aug1991		92=aug1992		104=aug1993
   45=sep1988		57=sept1989		69=sept1900		81=sep1991		93=sep1992		105=sept1993
   46=oct1988		58=oct1989		70=oct1900		82=oct1991		94=oct1992		106=oct1993
   47=nov1988		59=nov1989		71=nov1900		83=nov1991		95=nov1992		107=nov1993
   48=dec1988		60=dec1989		72=dec1900		84=dec1991		96=dec1992		108=dec1993

NO2 starts with no2_61 (Jan 1990)
   61=jan1900		73=jan1991		85=jan1992		97=jan1993
   62=feb1900		74=feb1991		86=feb1992		98=feb1993
   63=mar1900		75=mar1991		87=mar1992		99=mar1993
   64=apr1900		76=apr1991		88=apr1992		100=apr1993
   65=may1900		77=may1991		89=may1992		101=may1993
   66=jun1900		78=jun1991		90=jun1992		102=jun1993
   67=jul1900		79=jul1991		91=jul1992		103=jul1993
   68=aug1900		80=aug1991		92=aug1992		104=aug1993
   69=sept1900		81=sep1991		93=sep1992		105=sept1993
   70=oct1900		82=oct1991		94=oct1992		106=oct1993
   71=nov1900		83=nov1991		95=nov1992		107=nov1993
   72=dec1900		84=dec1991		96=dec1992		108=dec1993
*/ 

/*****bring in PM25 data 1988-1998*****/


data pm_88_98 ;
   set nhair0a.nhs2_pm_wide_cfinf;
   nid=id*1;
   keep nid pm25_37-pm25_168 pm10_: ;  *only keep up to dec 1998 for pm2.5, even if we didn't do this, vars from this file would just get overwritten;
   drop id; run;
   
data pm_88_98;
	set pm_88_98;
	id=nid;
	drop nid;
run;

proc sort data=pm_88_98;
    by id;

/*proc contents data=pm_88_98;
run;*/

/******* bring in U-W NO2 data Jan90 - Jul 17*/
data no2;
    set nhair0a.nhs2_uw_no2;
	nid=id*1;
   	drop id; run;

 data no2;
   set no2;
   id=nid;
   drop nid; run;

proc sort data=no2;
    by id;
run;

/*proc contents data=no2;
run;*/

/*****Bring in PM data for 1999-2017******/  
 data pm_99_17;
   set jef.nhs2_pm25_9917;
   nid=id*1;
   drop id; run;
 
 data pm_99_17;
   set pm_99_17;
   id=nid;
   drop nid; run;

proc sort data=pm_99_17;
    by id;
run;

/*proc contents data=pm_99_17;
run;*/

/******* merge 3 pollution datasets *******/

/*** Check if there's any duplicate variable other than ID ***/
%compmerge(list= pm_88_98 no2 pm_99_17);


data pollution;
    merge pm_88_98 no2 pm_99_17;
    by id;
run;

/*create annual averages for each calendar year*/

data pollution;
	set pollution;
		/*PM2.5 - old Yanosky model (Jan 90 - Dec 98) */
        pm25__89=mean(of pm25_49-pm25_60); /*inicates average for the year 1989, starting from january 1989 to december 1989*/
        pm25__90=mean(of pm25_61-pm25_72);
        pm25__91=mean(of pm25_73-pm25_84);
        pm25__92=mean(of pm25_85-pm25_96);
        pm25__93=mean(of pm25_97-pm25_108);
        pm25__94=mean(of pm25_109-pm25_120);
        pm25__95=mean(of pm25_121-pm25_132);
        pm25__96=mean(of pm25_133-pm25_144);
        pm25__97=mean(of pm25_145-pm25_156);
        pm25__98=mean(of pm25_157-pm25_168);   

        /*PM2.5 - (Jan 99 - Dec 17) */        
        pm25__99=mean(of pm25_169-pm25_180);
        pm25__00=mean(of pm25_180-pm25_192);
        pm25__01=mean(of pm25_193-pm25_204);
        pm25__02=mean(of pm25_205-pm25_216);
        pm25__03=mean(of pm25_217-pm25_228);
        pm25__04=mean(of pm25_229-pm25_240);
        pm25__05=mean(of pm25_241-pm25_252);
        pm25__06=mean(of pm25_253-pm25_264);
        pm25__07=mean(of pm25_265-pm25_276);
        pm25__08=mean(of pm25_277-pm25_288);
        pm25__09=mean(of pm25_289-pm25_300);
        pm25__10=mean(of pm25_301-pm25_312);
        pm25__11=mean(of pm25_313-pm25_324);
        pm25__12=mean(of pm25_325-pm25_336);
        pm25__13=mean(of pm25_337-pm25_348);
        pm25__14=mean(of pm25_349-pm25_360);
        pm25__15=mean(of pm25_361-pm25_372);
        pm25__16=mean(of pm25_373-pm25_384);
        pm25__17=mean(of pm25_385-pm25_396);


        /*pm10*/
        pm10__89=mean(of pm10_49-pm10_60);
        pm10__90=mean(of pm10_61-pm10_72);
        pm10__91=mean(of pm10_73-pm10_84);
        pm10__92=mean(of pm10_85-pm10_96);
        pm10__93=mean(of pm10_97-pm10_108);
        pm10__94=mean(of pm10_109-pm10_120);
        pm10__95=mean(of pm10_121-pm10_132);
        pm10__96=mean(of pm10_133-pm10_144);
        pm10__97=mean(of pm10_145-pm10_156);
        pm10__98=mean(of pm10_157-pm10_168);
        pm10__99=mean(of pm10_169-pm10_180);
        pm10__00=mean(of pm10_180-pm10_192);
        pm10__01=mean(of pm10_193-pm10_204);
        pm10__02=mean(of pm10_205-pm10_216);
        pm10__03=mean(of pm10_217-pm10_228);
        pm10__04=mean(of pm10_229-pm10_240);
        pm10__05=mean(of pm10_241-pm10_252);
        pm10__06=mean(of pm10_253-pm10_264);
        pm10__07=mean(of pm10_265-pm10_276);
        
        
        /*NO2 - U-W data (Jan 98  - Dec 14)*/
        no2__90=mean(of no2_61-no2_72);
        no2__91=mean(of no2_73-no2_84);
        no2__92=mean(of no2_85-no2_96);
        no2__93=mean(of no2_97-no2_108);
        no2__94=mean(of no2_109-no2_120);
        no2__95=mean(of no2_121-no2_132);
        no2__96=mean(of no2_133-no2_144);
        no2__97=mean(of no2_145-no2_156);
        no2__98=mean(of no2_157-no2_168);   
        no2__99=mean(of no2_169-no2_180);
        no2__00=mean(of no2_180-no2_192);
        no2__01=mean(of no2_193-no2_204);
        no2__02=mean(of no2_205-no2_216);
        no2__03=mean(of no2_217-no2_228);
        no2__04=mean(of no2_229-no2_240);
        no2__05=mean(of no2_241-no2_252);
        no2__06=mean(of no2_253-no2_264);
        no2__07=mean(of no2_265-no2_276);
        no2__08=mean(of no2_277-no2_288);
        no2__09=mean(of no2_289-no2_300);
        no2__10=mean(of no2_301-no2_312);
        no2__11=mean(of no2_313-no2_324);
        no2__12=mean(of no2_325-no2_336);
        no2__13=mean(of no2_337-no2_348);
        no2__14=mean(of no2_349-no2_360);
        no2__15=mean(of no2_361-no2_372);
        no2__16=mean(of no2_373-no2_384);

        keep id pm25__: pm10__: no2__: ;

run;

proc sort data=pollution; by id; run;

/***********************************************/
/*               Temperature				   */
/***********************************************/

data temperature;
set temp.nhsii8917_prism800m;
	nid = id*1;
	drop id;
    keep nid tmean: tmax: tmin: ;
run;

 data temperature;
   set temperature;
   id=nid;
   drop nid; 
run;


data temperature;
        set temperature;
/*tmean summer*/
        tmeans89=mean(of tmean_54-tmean_56);
		tmeans90=mean(of tmean_66-tmean_68);
		tmeans91=mean(of tmean_78-tmean_80);
		tmeans92=mean(of tmean_90-tmean_92);
		tmeans93=mean(of tmean_102-tmean_104);
		tmeans94=mean(of tmean_114-tmean_116);
		tmeans95=mean(of tmean_126-tmean_128);
		tmeans96=mean(of tmean_138-tmean_140);
		tmeans97=mean(of tmean_150-tmean_152);
		tmeans98=mean(of tmean_162-tmean_164);
		tmeans99=mean(of tmean_174-tmean_176);
		tmeans00=mean(of tmean_186-tmean_188);
		tmeans01=mean(of tmean_198-tmean_200);
		tmeans02=mean(of tmean_210-tmean_212);
		tmeans03=mean(of tmean_222-tmean_224);
		tmeans04=mean(of tmean_234-tmean_236);
		tmeans05=mean(of tmean_246-tmean_248);
		tmeans06=mean(of tmean_258-tmean_260);
		tmeans07=mean(of tmean_270-tmean_272);
		tmeans08=mean(of tmean_282-tmean_284);
		tmeans09=mean(of tmean_294-tmean_296);
		tmeans10=mean(of tmean_306-tmean_308);
		tmeans11=mean(of tmean_318-tmean_320);
		tmeans12=mean(of tmean_330-tmean_332);
		tmeans13=mean(of tmean_342-tmean_344);
		tmeans14=mean(of tmean_354-tmean_356);
/*tmax summer*/
		tmaxs89=mean(of tmax_54-tmax_56);
		tmaxs90=mean(of tmax_66-tmax_68);
		tmaxs91=mean(of tmax_78-tmax_80);
		tmaxs92=mean(of tmax_90-tmax_92);
		tmaxs93=mean(of tmax_102-tmax_104);
		tmaxs94=mean(of tmax_114-tmax_116);
		tmaxs95=mean(of tmax_126-tmax_128);
		tmaxs96=mean(of tmax_138-tmax_140);
		tmaxs97=mean(of tmax_150-tmax_152);
		tmaxs98=mean(of tmax_162-tmax_164);
		tmaxs99=mean(of tmax_174-tmax_176);
		tmaxs00=mean(of tmax_186-tmax_188);
		tmaxs01=mean(of tmax_198-tmax_200);
		tmaxs02=mean(of tmax_210-tmax_212);
		tmaxs03=mean(of tmax_222-tmax_224);
		tmaxs04=mean(of tmax_234-tmax_236);
		tmaxs05=mean(of tmax_246-tmax_248);
		tmaxs06=mean(of tmax_258-tmax_260);
		tmaxs07=mean(of tmax_270-tmax_272);
		tmaxs08=mean(of tmax_282-tmax_284);
		tmaxs09=mean(of tmax_294-tmax_296);
		tmaxs10=mean(of tmax_306-tmax_308);
		tmaxs11=mean(of tmax_318-tmax_320);
		tmaxs12=mean(of tmax_330-tmax_332);
		tmaxs13=mean(of tmax_342-tmax_344);
		tmaxs14=mean(of tmax_354-tmax_356);
/*tmin summer*/
		tmins89=mean(of tmin_54-tmin_56);
		tmins90=mean(of tmin_66-tmin_68);
		tmins91=mean(of tmin_78-tmin_80);
		tmins92=mean(of tmin_90-tmin_92);
		tmins93=mean(of tmin_102-tmin_104);
		tmins94=mean(of tmin_114-tmin_116);
		tmins95=mean(of tmin_126-tmin_128);
		tmins96=mean(of tmin_138-tmin_140);
		tmins97=mean(of tmin_150-tmin_152);
		tmins98=mean(of tmin_162-tmin_164);
		tmins99=mean(of tmin_174-tmin_176);
		tmins00=mean(of tmin_186-tmin_188);
		tmins01=mean(of tmin_198-tmin_200);
		tmins02=mean(of tmin_210-tmin_212);
		tmins03=mean(of tmin_222-tmin_224);
		tmins04=mean(of tmin_234-tmin_236);
		tmins05=mean(of tmin_246-tmin_248);
		tmins06=mean(of tmin_258-tmin_260);
		tmins07=mean(of tmin_270-tmin_272);
		tmins08=mean(of tmin_282-tmin_284);
		tmins09=mean(of tmin_294-tmin_296);
		tmins10=mean(of tmin_306-tmin_308);
		tmins11=mean(of tmin_318-tmin_320);
		tmins12=mean(of tmin_330-tmin_332);
		tmins13=mean(of tmin_342-tmin_344);
		tmins14=mean(of tmin_354-tmin_356);
/*tmean winter*/
		tmeanw89=mean(of tmean_48-tmean_50);
		tmeanw90=mean(of tmean_60-tmean_62);
		tmeanw91=mean(of tmean_72-tmean_74);
		tmeanw92=mean(of tmean_84-tmean_86);
		tmeanw93=mean(of tmean_96-tmean_98);
		tmeanw94=mean(of tmean_108-tmean_110);
		tmeanw95=mean(of tmean_120-tmean_122);
		tmeanw96=mean(of tmean_132-tmean_134);
		tmeanw97=mean(of tmean_144-tmean_146);
		tmeanw98=mean(of tmean_156-tmean_158);
		tmeanw99=mean(of tmean_168-tmean_170);
		tmeanw00=mean(of tmean_180-tmean_182);
		tmeanw01=mean(of tmean_192-tmean_194);
		tmeanw02=mean(of tmean_204-tmean_206);
		tmeanw03=mean(of tmean_216-tmean_218);
		tmeanw04=mean(of tmean_228-tmean_230);
		tmeanw05=mean(of tmean_240-tmean_242);
		tmeanw06=mean(of tmean_252-tmean_254);
		tmeanw07=mean(of tmean_264-tmean_266);
		tmeanw08=mean(of tmean_276-tmean_278);
		tmeanw09=mean(of tmean_288-tmean_290);
		tmeanw10=mean(of tmean_300-tmean_302);
		tmeanw11=mean(of tmean_312-tmean_314);
		tmeanw12=mean(of tmean_324-tmean_326);
		tmeanw13=mean(of tmean_336-tmean_338);
		tmeanw14=mean(of tmean_348-tmean_350);
/*tmax winter*/
		tmaxw89=mean(of tmax_48-tmax_50);
		tmaxw90=mean(of tmax_60-tmax_62);
		tmaxw91=mean(of tmax_72-tmax_74);
		tmaxw92=mean(of tmax_84-tmax_86);
		tmaxw93=mean(of tmax_96-tmax_98);
		tmaxw94=mean(of tmax_108-tmax_110);
		tmaxw95=mean(of tmax_120-tmax_122);
		tmaxw96=mean(of tmax_132-tmax_134);
		tmaxw97=mean(of tmax_144-tmax_146);
		tmaxw98=mean(of tmax_156-tmax_158);
		tmaxw99=mean(of tmax_168-tmax_170);
		tmaxw00=mean(of tmax_180-tmax_182);
		tmaxw01=mean(of tmax_192-tmax_194);
		tmaxw02=mean(of tmax_204-tmax_206);
		tmaxw03=mean(of tmax_216-tmax_218);
		tmaxw04=mean(of tmax_228-tmax_230);
		tmaxw05=mean(of tmax_240-tmax_242);
		tmaxw06=mean(of tmax_252-tmax_254);
		tmaxw07=mean(of tmax_264-tmax_266);
		tmaxw08=mean(of tmax_276-tmax_278);
		tmaxw09=mean(of tmax_288-tmax_290);
		tmaxw10=mean(of tmax_300-tmax_302);
		tmaxw11=mean(of tmax_312-tmax_314);
		tmaxw12=mean(of tmax_324-tmax_326);
		tmaxw13=mean(of tmax_336-tmax_338);
		tmaxw14=mean(of tmax_348-tmax_350);
/*tmin winter*/
		tminw89=mean(of tmin_48-tmin_50);
		tminw90=mean(of tmin_60-tmin_62);
		tminw91=mean(of tmin_72-tmin_74);
		tminw92=mean(of tmin_84-tmin_86);
		tminw93=mean(of tmin_96-tmin_98);
		tminw94=mean(of tmin_108-tmin_110);
		tminw95=mean(of tmin_120-tmin_122);
		tminw96=mean(of tmin_132-tmin_134);
		tminw97=mean(of tmin_144-tmin_146);
		tminw98=mean(of tmin_156-tmin_158);
		tminw99=mean(of tmin_168-tmin_170);
		tminw00=mean(of tmin_180-tmin_182);
		tminw01=mean(of tmin_192-tmin_194);
		tminw02=mean(of tmin_204-tmin_206);
		tminw03=mean(of tmin_216-tmin_218);
		tminw04=mean(of tmin_228-tmin_230);
		tminw05=mean(of tmin_240-tmin_242);
		tminw06=mean(of tmin_252-tmin_254);
		tminw07=mean(of tmin_264-tmin_266);
		tminw08=mean(of tmin_276-tmin_278);
		tminw09=mean(of tmin_288-tmin_290);
		tminw10=mean(of tmin_300-tmin_302);
		tminw11=mean(of tmin_312-tmin_314);
		tminw12=mean(of tmin_324-tmin_326);
		tminw13=mean(of tmin_336-tmin_338);
		tminw14=mean(of tmin_348-tmin_350);
run;
proc sort; 
by id; run;	

/***********************************************
      FAST FOOD AND GROCERY STORES 			
***********************************************/
/*code primarily from: /proj/nhairs/nhair3a/SiddiquiNoreen_FFO_Inflammation_102024/1_finaldata.sas*/

/*gather the number of stores within a 500m, 1000m, and 1500m radius of the home*/ 

DATA  nhs2_density;
INFILE  "/pc/nhair0a/Built_Environment/BE_Data/Geographic_Data/foodenvironment/buffered_rasters/nhs2_density_wide.csv" 
     DSD 
     LRECL= 684 ;
INPUT
 id
 convenience500_1999
 convenience500_2001
 convenience500_2003
 convenience500_2005
 convenience500_2007
 convenience500_2009
 convenience500_2011
 convenience500_2013
 convenience500_2015
 convenience500_2017
 convenience1000_1999
 convenience1000_2001
 convenience1000_2003
 convenience1000_2005
 convenience1000_2007
 convenience1000_2009
 convenience1000_2011
 convenience1000_2013
 convenience1000_2015
 convenience1000_2017
 convenience1500_1999
 convenience1500_2001
 convenience1500_2003
 convenience1500_2005
 convenience1500_2007
 convenience1500_2009
 convenience1500_2011
 convenience1500_2013
 convenience1500_2015
 convenience1500_2017
 fastfood500_1999
 fastfood500_2001
 fastfood500_2003
 fastfood500_2005
 fastfood500_2007
 fastfood500_2009
 fastfood500_2011
 fastfood500_2013
 fastfood500_2015
 fastfood500_2017
 fastfood1000_1999
 fastfood1000_2001
 fastfood1000_2003
 fastfood1000_2005
 fastfood1000_2007
 fastfood1000_2009
 fastfood1000_2011
 fastfood1000_2013
 fastfood1000_2015
 fastfood1000_2017
 fastfood1500_1999
 fastfood1500_2001
 fastfood1500_2003
 fastfood1500_2005
 fastfood1500_2007
 fastfood1500_2009
 fastfood1500_2011
 fastfood1500_2013
 fastfood1500_2015
 fastfood1500_2017
 restaurant500_1999
 restaurant500_2001
 restaurant500_2003
 restaurant500_2005
 restaurant500_2007
 restaurant500_2009
 restaurant500_2011
 restaurant500_2013
 restaurant500_2015
 restaurant500_2017
 restaurant1000_1999
 restaurant1000_2001
 restaurant1000_2003
 restaurant1000_2005
 restaurant1000_2007
 restaurant1000_2009
 restaurant1000_2011
 restaurant1000_2013
 restaurant1000_2015
 restaurant1000_2017
 restaurant1500_1999
 restaurant1500_2001
 restaurant1500_2003
 restaurant1500_2005
 restaurant1500_2007
 restaurant1500_2009
 restaurant1500_2011
 restaurant1500_2013
 restaurant1500_2015
 restaurant1500_2017
 supermarket500_1999
 supermarket500_2001
 supermarket500_2003
 supermarket500_2005
 supermarket500_2007
 supermarket500_2009
 supermarket500_2011
 supermarket500_2013
 supermarket500_2015
 supermarket500_2017
 supermarket1000_1999
 supermarket1000_2001
 supermarket1000_2003
 supermarket1000_2005
 supermarket1000_2007
 supermarket1000_2009
 supermarket1000_2011
 supermarket1000_2013
 supermarket1000_2015
 supermarket1000_2017
 supermarket1500_1999
 supermarket1500_2001
 supermarket1500_2003
 supermarket1500_2005
 supermarket1500_2007
 supermarket1500_2009
 supermarket1500_2011
 supermarket1500_2013
 supermarket1500_2015
 supermarket1500_2017
 supermarket2000_1999
 supermarket2000_2001
 supermarket2000_2003
 supermarket2000_2005
 supermarket2000_2007
 supermarket2000_2009
 supermarket2000_2011
 supermarket2000_2013
 supermarket2000_2015
 supermarket2000_2017
 supermarket2500_1999
 supermarket2500_2001
 supermarket2500_2003
 supermarket2500_2005
 supermarket2500_2007
 supermarket2500_2009
 supermarket2500_2011
 supermarket2500_2013
 supermarket2500_2015
 supermarket2500_2017
 fitness500_1999
 fitness500_2001
 fitness500_2003
 fitness500_2005
 fitness500_2007
 fitness500_2009
 fitness500_2011
 fitness500_2013
 fitness500_2015
 fitness500_2017
 fitness1000_1999
 fitness1000_2001
 fitness1000_2003
 fitness1000_2005
 fitness1000_2007
 fitness1000_2009
 fitness1000_2011
 fitness1000_2013
 fitness1000_2015
 fitness1000_2017
 fitness1500_1999
 fitness1500_2001
 fitness1500_2003
 fitness1500_2005
 fitness1500_2007
 fitness1500_2009
 fitness1500_2011
 fitness1500_2013
 fitness1500_2015
 fitness1500_2017
 fitness2000_1999
 fitness2000_2001
 fitness2000_2003
 fitness2000_2005
 fitness2000_2007
 fitness2000_2009
 fitness2000_2011
 fitness2000_2013
 fitness2000_2015
 fitness2000_2017
 fitness2500_1999
 fitness2500_2001
 fitness2500_2003
 fitness2500_2005
 fitness2500_2007
 fitness2500_2009
 fitness2500_2011
 fitness2500_2013
 fitness2500_2015
 fitness2500_2017
;
RUN;

proc sort data=nhs2_density; by id; run;


/**********************************************************************************************************************
     MERGE FILES AND RUN DESCRIPTIVE ANALYSES                                                             
**********************************************************************************************************************/

%compmerge(list= nses8917 ndvi pollution temperature nhs2_density);

/* Merge files with spatial variables */
data spatial;
	merge nses8917 ndvi pollution temperature nhs2_density;
	by id;
    rename id=momid;
run; 

proc export data=spatial
	outfile='nhs2.spatial.vars.csv'
	dbms=csv replace;
run; 

proc means data=spatial; 
	var nses_:  NDVI1YR: NDVI2YR: PM25__: PM10__: NO2__: 
		TMEANS: TMAXS: TMINS: TMEANW: TMAXW: TMINW: fastfood: supermarket:
	; 
run; 

