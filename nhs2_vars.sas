/**********************************************************************************************************************/
/*            Background                                                                                              */
/**********************************************************************************************************************/

/*
Programmer: Bethsaida Cardona
    Modified based on following files: 
        /udd/nhywa/MaternalUPF/data/nhs2_readin.sas

Original Program Name: /udd/n2bca/childhood_obesity/

Program start date: Dec 05, 2024

Project title: Transgenerational, personal, and social determinants of overweight and 
obesity during childhood and adolescence

Purpose of the program:
	To examine the association between various transgenerational, personal, and environmental factors with 
    childhood and adolescent overweight or obesity among GUTS children
	
    This script creates dataset on maternal characteristics (NHSII participants) to connect them to the 
    perinatal. Pregnancies occured prior to 2004. 

Main exposures/Covariates
    From NHS2 participants: 
        Maternal obesity (continous, based on derived bmi) [BMI89:BMI03; collected bienially]
        Maternal diet quality (AHEI 2010 w/out alcohol) (continuous) [AHEI2010_NOETOH91:AHEI2010_NOETOH03; collected every 4 years beginning in 1991]
        Maternal physical activity (in Mets, continuous) [ACT89M:ACT03M; approx every 4 years]
        Maternal smoking [SMK89:SMK03; PKYR89:PKYR03; collected bienially]
        Maternal drinking [ALCO91N:ALCOO3N collected every 4 years starting in 1991] 
        Gestational diabetes [GESDBG1-GESDBG16]
        C-section [CSECTG1-CSECTG16]
        Small or large for gestational age 
                [need to derive based on gestational age: GESCNG1-GESCNG16  GESCTG1-GESCTG16
                AND 
                birthweight: W1G1-W1G16 W2G1-W2G16 W3G1-W3G16 W4G1-W4G16 W5G1-W5G16 W6G1-W6G16 BWTCNG1-BWTCNG16]
        Gestational Weight gain [weight gain in kg (continuous): GESWEIGAIN; class for gestional weight gain (binary): GOTWEIGHT]
        Spouse education (hs or less/some college/grad school) [HUSBEDUC]
        Maternal job stress
            Job strain [categorical; CONTROL93 CONTROL97 DEMAND93 DEMAND97]
            Rotating night-shift work [categorical; SHIFT89:SHIFT97 SHI9301:SHI0105]
            Job insecurity [binary; SECURITY93, SECURITY97, SECURITY01]
        Modified Yale Food Addiction Scale (binary) [DIAGCLIN] 
        Experienced Teen/Child Abuse: PHYSABUSE SEXABUSE (either child/teen abuse) 
    
Other covariates: 
        Race/ethnicity (binary; Non-Hispanic White, Other) [RACE]
        Maternal birth date in months (continuous) [BIRTHDAY]
        Height (continuous) [HEIGHT89]

Input files: 
	BMI, smoking status, pack years, maternal race: %der8919
	NSES, region, population: %nses8917
	Physical Activity: %act8917
	Diet Quality: %ahei2010_9119
	Alcohol intake: %n91_nts, %n95_nts, %n99_nts, %n03_nts
    Gestational diabetes, c-section, small or large for gestational age: %grav09
    Gestational weight gain: derived from %der8919 and %moms99
    Spouse education: %nur99
    Yale Food Addiction scale: %nur09
    Job Strain: %ses93 &ses97
    Rotating shift-work: %nur91, %nur93, %ses97, %nur01, %nur05
    Job insecurity: %ses93, %ses97, %nur01
    Experienced Teen/Child Abuse: %v15to28 and /proj/n2cvds/n2cvd0a/vio/sxabct.dat


Future discussion points: 
    How to handle missingness for some of the variables making up the food addiction score 
    Creating variables for job strain (demand vs. control quadrants)
    Which teen/child abuse variables do we want to use? (binary yes/no? sexual or physical? variables that incorporate intensity?)
*/

/**********************************************************************************************************************/
/*            Program Set Up                                                                                          */
/**********************************************************************************************************************/

/**********************************************************************************************************************/
/*            Gather Variables of Interest                                                                            */
/**********************************************************************************************************************/

/***********************************************/
/*   Derived Data: BMI, Smoking Status, 
    Pack Years, Race                           */
/***********************************************/

/*
The Macro %der8919 has the official NHS2 population, 116429.

Significant updates and changes in der8919:

Data has been removed from der8919 for ID=772318 and ID=833814
We set all variables to missing (.) once a participant died.
*/

%der8919(keep=
			 id      birthday height89  mrace8905 eth8905 race
			 retmo89 retmo91  retmo93  retmo95 retmo97 retmo99 retmo01 retmo03 retmo05 retmo07 retmo09 retmo11 retmo13
			 age89 age91  age93  age95 age97 age99 age01 age03 age05 age07 age09 age11 age13
			 bmi89   bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 bmi07 bmi09 bmi11 bmi13
			 bmi89r   bmi91r    bmi93r    bmi95r   bmi97r   bmi99r   bmi01r   bmi03r  bmi05r bmi07r bmi09r bmi11r bmi13r
             bmi89v bmi91v bmi93v bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v bmi07v bmi09v bmi11v bmi13v 
			 smkdr89 smkdr91  smkdr93  smkdr95 smkdr97 smkdr99 smkdr01 smkdr03 smkdr05 smkdr07 smkdr09 smkdr11 smkdr13 
             smk89   smk91    smk93    smk95   smk97   smk99   smk01   smk03 smk05 smk07 smk09 smk11 smk13 
			 smk89r   smk91r   smk93r   smk95r   smk97r   smk99r   smk01r   smk03r  smk05r smk07r smk09r smk11r smk13r
             pkyr89  pkyr91   pkyr93   pkyr95  pkyr97  pkyr99  pkyr01  pkyr03 pkyr05 pkyr07 pkyr09 pkyr11 pkyr13  		 
		);
/* 
/proj/nhsass/nhsas00/dd/der8919.sas.dd
retmo = month of qq return 
smkdr = smoking status [various options for number of cigs/day]
pkyr = pack years (packs per day per year) numerical range 
mrace8905 = multiple race: 1)white, 2-black, 3-american indian, 4-asian,5-hawaiian, 6-other/unk, 7-multi-racial 
eth8905 = ethnicity: 1-hispanic, 2-not hispanic
*/ 
	array irt    {*} retmo89 retmo91 retmo93 retmo95 retmo97 retmo99 retmo01 retmo03 retmo05 retmo07 retmo09 retmo11 retmo13;
    array smkrawa{*} smkdr89 smkdr91  smkdr93 smkdr95 smkdr97 smkdr99 smkdr01 smkdr03 smkdr05 smkdr07 smkdr09 smkdr11 smkdr13 ;
    array smka   {*} smk89   smk91   smk93   smk95   smk97   smk99   smk01   smk03  smk05 smk07 smk09 smk11 smk13 ;
    array smkar   {*} smk89r   smk91r   smk93r   smk95r   smk97r   smk99r   smk01r   smk03r  smk05r smk07r smk09r smk11r smk13r ;  /*BCAR to make a copy of the original pre carry forward*/

    array pkyrarray {*} pkyr89  pkyr91   pkyr93   pkyr95  pkyr97  pkyr99  pkyr01  pkyr03 pkyr05 pkyr07 pkyr09 pkyr11 pkyr13;


	/*Create binary race variable*/
    race=.;
    if mrace8905=1 and eth8905=2 then race=1; /*non-hispanic white*/
    if mrace8905 in (2,3,4,5,7) or eth8905=1 then race=0; /*not not non-hispanic white, including biracial and those who only selected hispanic*/

    /*recode smoking*/
    do i= 1 to dim(irt);
        if smkrawa{i}=1 then smka{i}=1;/*never smoking*/
        else if 2 le smkrawa{i} le 8 then smka{i}=2;/*past smoking*/
        else if 9 <= smkrawa{i} <=15  then smka{i}=3;/*current smoking*/
        else smka{i}=1;

        if pkyrarray{i}=998 OR pkyrarray{i}=999 then pkyrarray{i}=.;

    end; drop i;

    /*BCAR recode smoking for exposure windows, either never smoker or current/past smoker*/
    do i= 1 to dim(irt);
        if smkrawa{i}=0 then smkar{i}=.; /*missing*/
        else if smkrawa{i}=1 then smkar{i}=0; /*never smoking*/
        else if 2 le smkrawa{i} <=15  then smkar{i}=1; /*past or current smoking*/
        else smkar{i}=.;
    end; drop i;
    
    %cumavg(cycle=13, cyclevar=1,
        varin =bmi89   bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 bmi07 bmi09 bmi11 bmi13 ,
        varout=bmi89v bmi91v bmi93v bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v bmi07v bmi09v bmi11v bmi13v );

	array bmi {*} bmi89   bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 bmi07 bmi09 bmi11 bmi13;
    array bmir {*} bmi89r   bmi91r    bmi93r    bmi95r   bmi97r   bmi99r   bmi01r   bmi03r  bmi05r bmi07r bmi09r bmi11r bmi13r;  /*BCAR to make a copy of the original pre carry forward*/
	array bmiv {*} bmi89v bmi91v bmi93v bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v bmi07v bmi09v bmi11v bmi13v;
	
    do i=1 to dim(bmi);
		bmir{i}=bmi{i}; 
	end; drop i; 


	do i=2 to dim(irt);
    	if smka{i}=. then smka{i}=smka{i-1};
    	if bmi{i}=. then bmi{i}=bmi{i-1};
    	if bmiv{i}=. then bmiv{i}=bmiv{i-1};
    end; drop i;
    

run;


proc means data=der8919; 
    vars retmo89 retmo91 retmo93 retmo95 retmo97 retmo99 retmo01 retmo03 retmo05 retmo07 retmo09 retmo11 retmo13
    smkdr89 smkdr91  smkdr93 smkdr95 smkdr97 smkdr99 smkdr01 smkdr03 smkdr05 smkdr07 smkdr09 smkdr11 smkdr13
    smk89   smk91   smk93   smk95   smk97   smk99   smk01   smk03  smk05 smk07 smk09 smk11 smk13
    smk89r   smk91r   smk93r   smk95r   smk97r   smk99r   smk01r   smk03r  smk05r smk07r smk09r smk11r smk13r 
    pkyr89  pkyr91   pkyr93   pkyr95  pkyr97  pkyr99  pkyr01  pkyr03 pkyr05 pkyr07 pkyr09 pkyr11 pkyr13
    bmi89   bmi91    bmi93    bmi95   bmi97   bmi99   bmi01   bmi03  bmi05 bmi07 bmi09 bmi11 bmi13
    bmi89r   bmi91r    bmi93r    bmi95r   bmi97r   bmi99r   bmi01r   bmi03r  bmi05r bmi07r bmi09r bmi11r bmi13r
    bmi89v bmi91v bmi93v bmi95v bmi97v bmi99v bmi01v bmi03v bmi05v bmi07v bmi09v bmi11v bmi13v
    ;
run;

/***********************************************/
/*            SPOUSE EDUCATION                 */
/***********************************************/

/*Original values in husbe99: 1.<hs; 2.highschool; 3.2yr college;\
	4.4yr college; 5.grad school; 6.not app; 7.pt*/

%nur99(keep = id husbe99 husbeduc);
	/* husband education high school, college, and graduate school*/
	if husbe99=1 then husbeduc = 1;
		else if husbe99=2 then husbeduc = 1;
		else if husbe99 in(3,4) then husbeduc=2;
		else if husbe99=5 then husbeduc = 3;
		else if husbe99 in (6,7) then husbeduc = .; *missing or not applicable;
		else if husbe99=. then husbeduc = .; *missing or not applicable;
run;

/***********************************************/
/*            Diet Quality &   Western diet    */
/***********************************************/

/*** Using the AHEI (Alternative Healthy Eating Index) - without alcohol ***/
/*/proj/nhsass/nhsas00/dd/ahei2010_9119.sas.dd
Updated every 4 years, starting in 1991
*/

%ahei2010_9119(keep=id ahei2010_noETOH91 ahei2010_noETOH95 ahei2010_noETOH99 
				ahei2010_noETOH03 ahei2010_noETOH07 ahei2010_noETOH11);
data ahei2010_9119; set ahei2010_9119;

%cumavg(cycle=6, cyclevar=1,
        varin =ahei2010_noETOH91 ahei2010_noETOH95 ahei2010_noETOH99 ahei2010_noETOH03 ahei2010_noETOH07 ahei2010_noETOH11 ,
        varout=ahei91v ahei95v ahei99v ahei03v ahei07v ahei11v );
        
    array ahei{*}  ahei2010_noETOH91 ahei2010_noETOH95 ahei2010_noETOH99 ahei2010_noETOH03 ahei2010_noETOH07 ahei2010_noETOH11 ;
    array aheiv{*} ahei91v ahei95v ahei99v ahei03v ahei07v ahei11v ;
    
    do i=2 to dim(ahei);
    	if ahei{i}=. then ahei{i}=ahei{i-1};
    	if aheiv{i}=. then aheiv{i}=aheiv{i-1};
    end; drop i;
run;

data westprud; set here.westprud;
run;

proc means data=ahei2010_9119;
    vars ahei2010_noETOH91 ahei2010_noETOH95 ahei2010_noETOH99 ahei2010_noETOH03 ahei2010_noETOH07 ahei2010_noETOH11; 
run; 

/***********************************************/
/*            Drinking                  	   */
/***********************************************/

/* Raw intake total alcohol (grams/day) */
%n91_nts (keep=id alco91n calor91n);run;
%n95_nts (keep=id alco95n calor95n);run;
%n99_nts (keep=id alco99n calor99n);run;
%n03_nts (keep=id alco03n calor03n);run;
%n07_nts (keep=id alco07n calor07n);run;
%n11_nts (keep=id alco11n calor11n);run;

/* Merge alcohol files */
data alcohol;
	merge	n91_nts n95_nts n99_nts n03_nts n07_nts n11_nts;
	by id;
	
	%cumavg(cycle=6, cyclevar=2,
        varin =alco91n calor91n alco95n calor95n alco99n calor99n alco03n calor03n alco07n calor07n alco11n calor11n,
        varout=alco91v calor91v alco95v calor95v alco99v calor99v alco03v calor03v alco07v calor07v alco11v calor11v );

	array alc{*}  alco91n calor91n alco95n calor95n alco99n calor99n alco03n calor03n alco07n calor07n alco11n calor11n ;
    array alcv{*} alco91v calor91v alco95v calor95v alco99v calor99v alco03v calor03v alco07v calor07v alco11v calor11v ;
    
    do i=2 to dim(alc);
    	if alc{i}=. then alc{i}=alc{i-1};
    	if alcv{i}=. then alcv{i}=alcv{i-1};
    end; drop i;
run;

proc datasets;
	delete
	n91_nts n95_nts n99_nts n03_nts n07_nts n11_nts;
run; 

proc means data=alcohol; 
    vars alco91n calor91n alco95n calor95n alco99n calor99n alco03n calor03n alco07n calor07n alco11n calor11n
    alco91v calor91v alco95v calor95v alco99v calor99v alco03v calor03v alco07v calor07v alco11v calor11v
    ;
run;

/***********************************************/
/*            Physical Activity                */
/***********************************************/

/* /proj/nhsass/nhsas00/dd/act8917.sas.dd
	The variable actXXm is the total mets of all activities for that year.
	The value 998 means that the person passed through the entire physical 
	activity section for that year.
	The value 999 means that the person either did not answer the
	questionnaire or answered the short questionnaire that year.
 */


%act8917(keep=id act89m act91m act97m act01m act05m act09m act13m);
data act8917; set act8917;

	array acta act89m act91m act97m act01m act05m act09m act13m;
	do over acta;
		if acta in (998, 999) then acta=.;
	end;
	
	%cumavg(cycle=7, cyclevar=1,
        varin =act89m act91m act97m act01m act05m act09m act13m,
        varout=act89v act91v act97v act01v act05v act09v act13v );
        
    array pa{*}  act89m act91m act97m act01m act05m act09m act13m ;
    array par{*}  act89mr act91mr act97mr act01mr act05mr act09mr act13mr ;  /*BCAR to make a copy of the original pre carry forward*/
    array pav{*} act89v act91v act97v act01v act05v act09v act13v ;
    
    do i=1 to dim(pa);
        par{i}=pa{i}; 
    end; drop i; 

    do i=2 to dim(pa);
    	if pa{i}=. then pa{i}=pa{i-1};
    	if pav{i}=. then pav{i}=pav{i-1};
    end; drop i;

run;

/*SAS does not give an error message for empty variables in arrays, running a proc means to ensure no unexpected 
empty variables*/

proc means data=act8917; 
    vars  act89m act91m act97m act01m act05m act09m act13m
    act89mr act91mr act97mr act01mr act05mr act09mr act13mr
    act89v act91v act97v act01v act05v act09v act13v
    ;
run; 

/***********************************************/
/*           JOB stress                        */
/***********************************************/
/*
Job stress is a combination of: 
1) Job Strain: 
    Four categories of job types were defined based on the levels of
    demands and control in the job, as below.
    o Low strain jobs (low job demands, and high job control)
    o Passive jobs (low job demands, and low job control)
    o Active jobs (high job demands, and high job control)
    o High strain jobs (high job demands, and low job control)

2) Rotating night shift 
3) Job Insecurity 
*/

/*job strain ****************************************
code from: /udd/nhctf/projects/jobOVCA/nhs2.readin.jobovca.final.sas
/proj/n2nios/n2nio0a/kaori/cum.rotat.shift/bmi9397.cumshiftwk.final.model.sas
*/

%ses93 (keep=id nxces93 dmand93 enoug93 wfast93 whard93 learn93 devel93 skill93 varie93 repet93 creat93 decis93 lfree93 say93);
%ses97 (keep=id nxces97 dmand97 enoug97 wfast97 whard97 learn97 devel97 skill97 varie97 repet97 creat97 decis97 lfree97 say97);


/* Merge job strain files */
data strain;
	merge	ses93 ses97;
	by id;
    
    /* Code Job Strain = main exposure; code from Ana Babin */	
    /* set missing to . */
    array missj {28} nxces93 dmand93 enoug93 wfast93 whard93 learn93 devel93 skill93 varie93 repet93 creat93 decis93 lfree93 say93
                    nxces97 dmand97 enoug97 wfast97 whard97 learn97 devel97 skill97 varie97 repet97 creat97 decis97 lfree97 say97;
    array newj {28} nxcesf93 dmandf93 enougf93 wfastf93 whardf93 learnf93 develf93 skillf93 varief93 repetf93 creatf93 decisf93 lfreef93 sayf93
                    nxcesf97 dmandf97 enougf97 wfastf97 whardf97 learnf97 develf97 skillf97 varief97 repetf97 creatf97 decisf97 lfreef97 sayf97;

    do i=1 to 28;
        newj{i}=missj{i};
        if 5<=missj{i}<=6 then newj{i}=.;
    end;

    /* recode pace and hard work variables so that low scores = high demands */
    array origj {8} wfastf93 whardf93 repetf93 lfreef93 wfastf97 whardf97 repetf97 lfreef97;
    array newj2 {8} wfastf293 whardf293 repetf293 lfreef293 wfastf297 whardf297 repetf297 lfreef297;

    do i=1 to 8;
        if origj{i}=1 then newj2{i}=4;
        else if origj{i}=2 then newj2{i}=3;
        else if origj{i}=3 then newj2{i}=2;
        else if origj{i}=4 then newj2{i}=1;
        else if origj{i}=. then newj2{i}=.;
    end;			

    /* calculate job strain variables */
    /* Create demand variable (higher score = lower demand) and set variable to missing if more than 1 item is missing */ 
    demand93n=n(nxcesf93,dmandf93,enougf93,wfastf293,whardf293);
    demand97n=n(nxcesf97,dmandf97,enougf97,wfastf297,whardf297);
    if demand93n ge 4 then demand93=sum(nxcesf93,dmandf93,enougf93,wfastf293,whardf293);
        else demand93=.;
    if demand97n ge 4 then demand97=sum(nxcesf97,dmandf97,enougf97,wfastf297,whardf297);
        else demand97=.;
    if demand93 ne . AND demand97 ne . then demandmean = (demand93 + demand97)/2;
        else if demand93 ne . then demandmean=demand93;
        else if demand97 ne . then demandmean=demand97;

    /* Create control variable (higher score = higher control) and set variable to missing if more than 2 items are missing */
    control93n=n(learnf93,develf93,skillf93,varief93,repetf293,creatf93,decisf93,lfreef293,sayf93);
    control97n=n(learnf97,develf97,skillf97,varief97,repetf297,creatf97,decisf97,lfreef297,sayf97);
    if control93n ge 7 then control93=sum(learnf93,develf93,skillf93,varief93,repetf293,creatf93,decisf93,lfreef293,sayf93);
        else control93=.;
    if control97n ge 7 then control97=sum(learnf97,develf97,skillf97,varief97,repetf297,creatf97,decisf97,lfreef297,sayf97);
        else control97=.;
    if control93 ne . AND control97 ne . then controlmean = (control93 + control97)/2;
        else if control93 ne . then controlmean=control93;
        else if control97 ne . then controlmean=control97;
        
     if demandmean =. and controlmean =. then strain=.; 
    	 	else if demandmean > 11.5 and controlmean > 27 then strain=1; *Low strain jobs (low job demands, and high job control);
     	    else if demandmean > 11.5 and controlmean < 27 then strain=2; *Passive jobs (low job demands, and low job control);
     	    else if demandmean < 11.5 and controlmean > 27 then strain=3; *Active jobs (high job demands, and high job control);
     	    else if demandmean < 11.5 and controlmean < 27 then strain=4; * High strain jobs (high job demands, and low job control);
    
run;

/*the following manuscripts dichotomized scores at the median in order to define “high job strain” as a
combination of high job demands (i.e., above median) and low job control (i.e., below median). 
We should discuss whether to do it at this step or later
https://sites.google.com/a/channing.harvard.edu/channing_review_archive_two_b/abstracts_group2b/job-strain-and-changes-in-the-body-mass-index-among-working-women-a-prospective-study
https://drive.google.com/file/d/11F3vyDy7Bzm8SmLEq9Vz2jCfrMIjCFoQ/view*/ 

proc datasets;
	delete 	ses93 ses97;
run; 

/*rotating shift work**************************************
code from: /proj/n2nios/n2nio0a/kaori/cum.rotat.shift/bmi9397.cumshiftwk.final.model.sas*/

%nur89(keep=id shift89); /*1.never;\ 2.1-2 yrs;\ 3.3-5 yrs;\ 4.6-9 yrs;\ 5.10-14 yrs;\ 6.15-19 yrs;\ 7.20+ yrs;\ */
%nur91(keep=id shift91); /*1 = none; 2 = 1-4 months; 3 = 5-9 months; 4 = 10-14 months; 5 = 15-19 months; 6 = 20+ months; 7 = pass through */
%nur93(keep=id shift93); /*1 = none; 2 = 1-4 months; 3 = 5-9 months; 4 = 10-14 months; 5 = 15-19 months; 6 = 20+ months; 7 = pass through */
%ses97(keep=id shift97); /*Since 6/95, Months Rotating Shifts (L50) 1.0, 2.1-4, 3.5-9, 4.10-14, 5.15-19, 6.20+, 7.pt */
%nur01(keep=id shi9301 shi9501 shi9701 shi9901); /* Rotating Night Shifts: shi9301: 06/93-06/95; shi9501 06/95-06/97; shi9701 06/97-06/99; shi9901 since 06/99*/
                        /* 1.0, 2.1-4, 3.5-9, 4.10-14, 5.15-19, 6.20+, 7.pt ****/
%nur05(keep=id shi0105 shi0305); /*shi0105 6/01-6/03 shi0305 Since 6/03 
									1.none 2.1-4mos 3.5-9mos 4.10-14mos 5.15-19mos 6.20+ mos 7.pt */
%nur11(keep=id shift11); /*1.none 2.1-4 months 3.5-9 months 4.10-14 months 5.15-19 months 6.20+ months 7.pt*/
%nur07(keep=id shift07); /*Web only 0. missing 1.none 2.1-4 months 3.5-9 months 4.10-14 months 5.15-19 months 6.20+ months*/
%nur13(keep=id shift13); /*1.none 2.1-4 months 3.5-9 months 4.10-14 months 5.15-19 months 6.20+ months 7.pt*/

/* Merge shiftwork files */
data nightshift;
	merge	nur89 nur91 nur93 ses97 nur01 nur05 nur07 nur11 nur13;
	by id;
	
	/*   1989 is in categories of years, convert to months */
     if shift89=1 then shi89_con=0;
		else if shift89=2 then shi89_con=(1.5*12);
		else if shift89=3 then shi89_con=(4*12);
		else if shift89=4 then shi89_con=(7.5*12);
		else if shift89=5 then shi89_con=(12*12);
		else if shift89=6 then shi89_con=(17*12);
		else if shift89=7 then shi89_con=(20*12);
		else                   shi89_con=.;

     if shift91=1 then shi8991_con=0;
		else if shift91=2 then shi8991_con=2.5;
		else if shift91=3 then shi8991_con=7;
		else if shift91=4 then shi8991_con=12;
		else if shift91=5 then shi8991_con=17;
		else if shift91=6 then shi8991_con=22;
		else                   shi8991_con=.;
     
     if shift93=1 then shi9193_con=0;
		else if shift93=2 then shi9193_con=2.5;
		else if shift93=3 then shi9193_con=7;
		else if shift93=4 then shi9193_con=12;
		else if shift93=5 then shi9193_con=17;
		else if shift93=6 then shi9193_con=22;
		else                   shi9193_con=.;
		
		if shi9301=1 then shi9395_con=0;
		else if shi9301=2 then shi9395_con=2.5;
		else if shi9301=3 then shi9395_con=7;
		else if shi9301=4 then shi9395_con=12;
		else if shi9301=5 then shi9395_con=17;
		else if shi9301=6 then shi9395_con=22;
		else                   shi9395_con=.;

     /* if shi9501=1 then shi9597_con=0;
		else if shi9501=2 then shi9597_con=2.5;
		else if shi9501=3 then shi9597_con=7;
		else if shi9501=4 then shi9597_con=12;
		else if shi9501=5 then shi9597_con=17;
		else if shi9501=6 then shi9597_con=22;
		else                   shi9597_con=.; */
		
	/* use var from 97qx - call 3/16/15 */
      if shift97=1 then shi9597_con=0;
		else if shift97=2 then shi9597_con=2.5;
		else if shift97=3 then shi9597_con=7;
		else if shift97=4 then shi9597_con=12;
		else if shift97=5 then shi9597_con=17;
		else if shift97=6 then shi9597_con=22;
		else                   shi9597_con=.;
 
	if shi9701=1 then shi9799_con=0;
		else if shi9701=2 then shi9799_con=2.5;
		else if shi9701=3 then shi9799_con=7;
		else if shi9701=4 then shi9799_con=12;
		else if shi9701=5 then shi9799_con=17;
		else if shi9701=6 then shi9799_con=22;
		else                   shi9799_con=.;
		
	if shi9901=1 then shi9901_con=0;
		else if shi9901=2 then shi9901_con=2.5;
		else if shi9901=3 then shi9901_con=7;
		else if shi9901=4 then shi9901_con=12;
		else if shi9901=5 then shi9901_con=17;
		else if shi9901=6 then shi9901_con=22;
		else                   shi9901_con=.;
		
	if shi0105=1 then shi0103_con=0;
		else if shi0105=2 then shi0103_con=2.5;
		else if shi0105=3 then shi0103_con=7;
		else if shi0105=4 then shi0103_con=12;
		else if shi0105=5 then shi0103_con=17;
		else if shi0105=6 then shi0103_con=22;
		else                   shi0103_con=.;
		
	if shi0305=1 then shi0305_con=0;
		else if shi0305=2 then shi0305_con=2.5;
		else if shi0305=3 then shi0305_con=7;
		else if shi0305=4 then shi0305_con=12;
		else if shi0305=5 then shi0305_con=17;
		else if shi0305=6 then shi0305_con=22;
		else                   shi0305_con=.;
		
	if shift07=1 then shi07_con=0;
		else if shift07=2 then shi07_con=2.5;
		else if shift07=3 then shi07_con=7;
		else if shift07=4 then shi07_con=12;
		else if shift07=5 then shi07_con=17;
		else if shift07=6 then shi07_con=22;
		else                   shi07_con=.;
		
	if shift11=1 then shi11_con=0;
		else if shift11=2 then shi11_con=2.5;
		else if shift11=3 then shi11_con=7;
		else if shift11=4 then shi11_con=12;
		else if shift11=5 then shi11_con=17;
		else if shift11=6 then shi11_con=22;
		else                   shi11_con=.;
		
	if shift13=1 then shi13_con=0;
		else if shift13=2 then shi13_con=2.5;
		else if shift13=3 then shi13_con=7;
		else if shift13=4 then shi13_con=12;
		else if shift13=5 then shi13_con=17;
		else if shift13=6 then shi13_con=22;
		else                   shi13_con=.;
		
	%cumavg(cycle=12, cyclevar=1,
        varin =shi89_con shi8991_con shi9193_con shi9395_con shi9597_con shi9799_con shi9901_con shi0103_con shi0305_con shi07_con shi11_con shi13_con,
        varout=shi89v shi8991v shi9193v shi9395v shi9597v shi9799v shi9901v shi0103v shi0305v shi07v shi11v shi13v );
run;

proc datasets;
	delete nur89 nur91 nur93 ses97 nur01 nur05 nur07 nur11 nur13;
run; 

/*Job insecurity********************************************:
code from: /udd/nhctf/projects/jobOVCA/nhs2.readin.jobovca.final.sas */

%ses93(keep=id secur93); /*My Job Security is Good: 1=strongly disagree; 2=disagree; 3=agree; 4=strongly agree; 5=passthrough*/
%ses97(keep=id secur97);
%nur01(keep=id ljob01 incom01); /* Involuntarily Lose Job 1.not at all likely; 2.not too likely 3.somewhat likely; 4.very likely; 5.not currently employed; 6.pt*/
	/*$label 1.less than 15,000; 2.15,000-19; 3.20,000-29; 4.30,000-39; 5.40,000-49;\
        6.50,000-74; 7.75,000-99; 8.100,000-149; 9.150,000+; 10.pt */
        if incom01=10 then incom01=.;
proc freq; table incom01; run;

/* Merge job insecurity files */
data jobinsecure;
	merge ses93 ses97 nur01;
	by id;

    /* Create job insecurity variable */
    if secur93=5 OR secur93=. then security93=.;
        else if 1<=secur93<=2 then security93=1;
        else if 3<=secur93<=4 then security93=0;
    if secur97=5 OR secur97=. then security97=.;
        else if 1<=secur97<=2 then security97=1;
        else if 3<=secur97<=4 then security97=0;
    if ljob01=5 OR ljob01=6 OR ljob01=. then security01=.; /* slightly different question in 2001, this is why it is coded differently */
        else if 3<=ljob01<=4 then security01=1;
        else if 1<=ljob01<=2 then security01=0;

	if security97=. then security97=security93;
	if security01=. then security01=security97;
run;

proc datasets;
	delete
	ses93 ses97 nur01;
run; 


/************************************************************************************************************
**********************************GEOGRAPHIC DATA *************************************
*************************************************************************************************************/
* regions;
%nses8917(keep= id region10_89 region10_91 region10_93 region10_95 region10_97 region10_99 region10_01 
				region10_03 region10_05 region10_07 region10_09 region10_11 region10_13 region10_15
				regionall evermove);
	array regionx(14) region10_89 region10_91 region10_93 region10_95 region10_97 region10_99 region10_01 
					  region10_03 region10_05 region10_07 region10_09 region10_11 region10_13 region10_15;
	do i=2 to 14;
		if regionx(i) =. & regionx(i-1) ne . then  regionx(i) = regionx(i-1);
	end; drop i; 
   	regionall = coalesce(of regionx[*]); 
   	evermove=0;
	do i=1 to 14;
		if regionx(i) ne . and regionx(i) ne regionall then evermove=1; 
	end; 
run;

*Read geographic data prepared by Bethsaida;
proc import datafile="/udd/nhywa/GUTSOB/nhs2.spatial.vars.csv"
        out=geo
        dbms=csv
        replace;
run;
data geo; set geo;
	rename momid=id;
/*missings in 1989 nSES - carry backward 1991*/
   nSES_89r=nSES_89; /*BCAR will also keep the original for the exposure windows analysis*/
   if nSES_89 eq . and nSES_91 ne . then nSES_89 = nSES_91;
   
   nSES_89v = nSES_89;
   nSES_91v = mean(nSES_89, nSES_91);
   nSES_93v = mean(nSES_89, nSES_91, nSES_93);  
   nSES_95v = mean(nSES_89, nSES_91, nSES_93, nSES_95); 
   nSES_97v = mean(nSES_89, nSES_91, nSES_93, nSES_95, nSES_97);  
   nSES_99v = mean(nSES_89, nSES_91, nSES_93, nSES_95, nSES_97, nSES_99);  
   nSES_01v = mean(nSES_89, nSES_91, nSES_93, nSES_95, nSES_97, nSES_99, nSES_01);
   nSES_03v = mean(nSES_89, nSES_91, nSES_93, nSES_95, nSES_97, nSES_99, nSES_01, nSES_03); 
   nSES_05v = mean(nSES_89, nSES_91, nSES_93, nSES_95, nSES_97, nSES_99, nSES_01, nSES_03, nSES_05);
   nSES_07v = mean(nSES_89, nSES_91, nSES_93, nSES_95, nSES_97, nSES_99, nSES_01, nSES_03, nSES_05, nSES_07);
   nSES_09v = mean(nSES_89, nSES_91, nSES_93, nSES_95, nSES_97, nSES_99, nSES_01, nSES_03, nSES_05, nSES_07, nSES_09);
   nSES_11v = mean(nSES_89, nSES_91, nSES_93, nSES_95, nSES_97, nSES_99, nSES_01, nSES_03, nSES_05, nSES_07, nSES_09, nSES_11);
   nSES_13v = mean(nSES_89, nSES_91, nSES_93, nSES_95, nSES_97, nSES_99, nSES_01, nSES_03, nSES_05, nSES_07, nSES_09, nSES_11, nSES_13);
   
   convenience1500_1999v = convenience1500_1999;
   convenience1500_2001v = mean(convenience1500_1999, convenience1500_2001);
   convenience1500_2003v = mean(convenience1500_1999, convenience1500_2001, convenience1500_2003);  
   convenience1500_2005v = mean(convenience1500_1999, convenience1500_2001, convenience1500_2003, convenience1500_2005); 
   convenience1500_2007v = mean(convenience1500_1999, convenience1500_2001, convenience1500_2003, convenience1500_2005, convenience1500_2007);  
   convenience1500_2009v = mean(convenience1500_1999, convenience1500_2001, convenience1500_2003, convenience1500_2005, convenience1500_2007, convenience1500_2009);  
   convenience1500_2011v = mean(convenience1500_1999, convenience1500_2001, convenience1500_2003, convenience1500_2005, convenience1500_2007, convenience1500_2009, convenience1500_2011);
   convenience1500_2013v = mean(convenience1500_1999, convenience1500_2001, convenience1500_2003, convenience1500_2005, convenience1500_2007, convenience1500_2009, convenience1500_2011, convenience1500_2013); 

   fastfood1500_1999v = fastfood1500_1999;
   fastfood1500_2001v = mean(fastfood1500_1999, fastfood1500_2001);
   fastfood1500_2003v = mean(fastfood1500_1999, fastfood1500_2001, fastfood1500_2003);  
   fastfood1500_2005v = mean(fastfood1500_1999, fastfood1500_2001, fastfood1500_2003, fastfood1500_2005); 
   fastfood1500_2007v = mean(fastfood1500_1999, fastfood1500_2001, fastfood1500_2003, fastfood1500_2005, fastfood1500_2007);  
   fastfood1500_2009v = mean(fastfood1500_1999, fastfood1500_2001, fastfood1500_2003, fastfood1500_2005, fastfood1500_2007, fastfood1500_2009);  
   fastfood1500_2011v = mean(fastfood1500_1999, fastfood1500_2001, fastfood1500_2003, fastfood1500_2005, fastfood1500_2007, fastfood1500_2009, fastfood1500_2011);
   fastfood1500_2013v = mean(fastfood1500_1999, fastfood1500_2001, fastfood1500_2003, fastfood1500_2005, fastfood1500_2007, fastfood1500_2009, fastfood1500_2011, fastfood1500_2013); 

   restaurant1500_1999v = restaurant1500_1999;
   restaurant1500_2001v = mean(restaurant1500_1999, restaurant1500_2001);
   restaurant1500_2003v = mean(restaurant1500_1999, restaurant1500_2001, restaurant1500_2003);  
   restaurant1500_2005v = mean(restaurant1500_1999, restaurant1500_2001, restaurant1500_2003, restaurant1500_2005); 
   restaurant1500_2007v = mean(restaurant1500_1999, restaurant1500_2001, restaurant1500_2003, restaurant1500_2005, restaurant1500_2007);  
   restaurant1500_2009v = mean(restaurant1500_1999, restaurant1500_2001, restaurant1500_2003, restaurant1500_2005, restaurant1500_2007, restaurant1500_2009);  
   restaurant1500_2011v = mean(restaurant1500_1999, restaurant1500_2001, restaurant1500_2003, restaurant1500_2005, restaurant1500_2007, restaurant1500_2009, restaurant1500_2011);
   restaurant1500_2013v = mean(restaurant1500_1999, restaurant1500_2001, restaurant1500_2003, restaurant1500_2005, restaurant1500_2007, restaurant1500_2009, restaurant1500_2011, restaurant1500_2013); 

   supermarket1500_1999v = supermarket1500_1999;
   supermarket1500_2001v = mean(supermarket1500_1999, supermarket1500_2001);
   supermarket1500_2003v = mean(supermarket1500_1999, supermarket1500_2001, supermarket1500_2003);  
   supermarket1500_2005v = mean(supermarket1500_1999, supermarket1500_2001, supermarket1500_2003, supermarket1500_2005); 
   supermarket1500_2007v = mean(supermarket1500_1999, supermarket1500_2001, supermarket1500_2003, supermarket1500_2005, supermarket1500_2007);  
   supermarket1500_2009v = mean(supermarket1500_1999, supermarket1500_2001, supermarket1500_2003, supermarket1500_2005, supermarket1500_2007, supermarket1500_2009);  
   supermarket1500_2011v = mean(supermarket1500_1999, supermarket1500_2001, supermarket1500_2003, supermarket1500_2005, supermarket1500_2007, supermarket1500_2009, supermarket1500_2011);
   supermarket1500_2013v = mean(supermarket1500_1999, supermarket1500_2001, supermarket1500_2003, supermarket1500_2005, supermarket1500_2007, supermarket1500_2009, supermarket1500_2011, supermarket1500_2013); 
  
	%cumavg(cycle=25, cyclevar=7,
        varin = ndvi1yr89 ndvi2yr89 pm25__89 pm10__89 XXXXX   tmeans89 tmeanw89
        		ndvi1yr90 ndvi2yr90 pm25__90 pm10__90 no2__90 tmeans90 tmeanw90
        		ndvi1yr91 ndvi2yr91 pm25__91 pm10__91 no2__91 tmeans91 tmeanw91
        		ndvi1yr92 ndvi2yr92 pm25__92 pm10__92 no2__92 tmeans92 tmeanw92
        		ndvi1yr93 ndvi2yr93 pm25__93 pm10__93 no2__93 tmeans93 tmeanw93
        		ndvi1yr94 ndvi2yr94 pm25__94 pm10__94 no2__94 tmeans94 tmeanw94
        		ndvi1yr95 ndvi2yr95 pm25__95 pm10__95 no2__95 tmeans95 tmeanw95
        		ndvi1yr96 ndvi2yr96 pm25__96 pm10__96 no2__96 tmeans96 tmeanw96
        		ndvi1yr97 ndvi2yr97 pm25__97 pm10__97 no2__97 tmeans97 tmeanw97
        		ndvi1yr98 ndvi2yr98 pm25__98 pm10__98 no2__98 tmeans98 tmeanw98
        		ndvi1yr99 ndvi2yr99 pm25__99 pm10__99 no2__99 tmeans99 tmeanw99
        		ndvi1yr00 ndvi2yr00 pm25__00 pm10__00 no2__00 tmeans00 tmeanw00
        		ndvi1yr01 ndvi2yr01 pm25__01 pm10__01 no2__01 tmeans01 tmeanw01
        		ndvi1yr02 ndvi2yr02 pm25__02 pm10__02 no2__02 tmeans02 tmeanw02
        		ndvi1yr03 ndvi2yr03 pm25__03 pm10__03 no2__03 tmeans03 tmeanw03
        		ndvi1yr04 ndvi2yr04 pm25__04 pm10__04 no2__04 tmeans04 tmeanw04
        		ndvi1yr05 ndvi2yr05 pm25__05 pm10__05 no2__05 tmeans05 tmeanw05
        		ndvi1yr06 ndvi2yr06 pm25__06 pm10__06 no2__06 tmeans06 tmeanw06
        		ndvi1yr07 ndvi2yr07 pm25__07 pm10__07 no2__07 tmeans07 tmeanw07
        		ndvi1yr08 ndvi2yr08 pm25__08 XXXXX    no2__08 tmeans08 tmeanw08
        		ndvi1yr09 ndvi2yr09 pm25__09 XXXXX    no2__09 tmeans09 tmeanw09
        		ndvi1yr10 ndvi2yr10 pm25__10 XXXXX    no2__10 tmeans10 tmeanw10
        		ndvi1yr11 ndvi2yr11 pm25__11 XXXXX    no2__11 tmeans11 tmeanw11
        		ndvi1yr12 ndvi2yr12 pm25__12 XXXXX    no2__12 tmeans12 tmeanw12
        		ndvi1yr13 ndvi2yr13 pm25__13 XXXXX    no2__13 tmeans13 tmeanw13 ,
        varout= ndvi1yr89v ndvi2yr89v pm25__89v pm10__89v XXXXX   tmeans89v tmeanw89v
        		ndvi1yr90v ndvi2yr90v pm25__90v pm10__90v no2__90v tmeans90v tmeanw90v
        		ndvi1yr91v ndvi2yr91v pm25__91v pm10__91v no2__91v tmeans91v tmeanw91v
        		ndvi1yr92v ndvi2yr92v pm25__92v pm10__92v no2__92v tmeans92v tmeanw92v
        		ndvi1yr93v ndvi2yr93v pm25__93v pm10__93v no2__93v tmeans93v tmeanw93v
        		ndvi1yr94v ndvi2yr94v pm25__94v pm10__94v no2__94v tmeans94v tmeanw94v
        		ndvi1yr95v ndvi2yr95v pm25__95v pm10__95v no2__95v tmeans95v tmeanw95v
        		ndvi1yr96v ndvi2yr96v pm25__96v pm10__96v no2__96v tmeans96v tmeanw96v
        		ndvi1yr97v ndvi2yr97v pm25__97v pm10__97v no2__97v tmeans97v tmeanw97v
        		ndvi1yr98v ndvi2yr98v pm25__98v pm10__98v no2__98v tmeans98v tmeanw98v
        		ndvi1yr99v ndvi2yr99v pm25__99v pm10__99v no2__99v tmeans99v tmeanw99v
        		ndvi1yr00v ndvi2yr00v pm25__00v pm10__00v no2__00v tmeans00v tmeanw00v
        		ndvi1yr01v ndvi2yr01v pm25__01v pm10__01v no2__01v tmeans01v tmeanw01v
        		ndvi1yr02v ndvi2yr02v pm25__02v pm10__02v no2__02v tmeans02v tmeanw02v
        		ndvi1yr03v ndvi2yr03v pm25__03v pm10__03v no2__03v tmeans03v tmeanw03v
        		ndvi1yr04v ndvi2yr04v pm25__04v pm10__04v no2__04v tmeans04v tmeanw04v
        		ndvi1yr05v ndvi2yr05v pm25__05v pm10__05v no2__05v tmeans05v tmeanw05v
        		ndvi1yr06v ndvi2yr06v pm25__06v pm10__06v no2__06v tmeans06v tmeanw06v
        		ndvi1yr07v ndvi2yr07v pm25__07v pm10__07v no2__07v tmeans07v tmeanw07v
        		ndvi1yr08v ndvi2yr08v pm25__08v XXXXX    no2__08v tmeans08v tmeanw08v
        		ndvi1yr09v ndvi2yr09v pm25__09v XXXXX    no2__09v tmeans09v tmeanw09v
        		ndvi1yr10v ndvi2yr10v pm25__10v XXXXX    no2__10v tmeans10v tmeanw10v
        		ndvi1yr11v ndvi2yr11v pm25__11v XXXXX    no2__11v tmeans11v tmeanw11v
        		ndvi1yr12v ndvi2yr12v pm25__12v XXXXX    no2__12v tmeans12v tmeanw12v
        		ndvi1yr13v ndvi2yr13v pm25__13v XXXXX    no2__13v tmeans13v tmeanw13v);
        
proc sort; by id;  run; 

*Read primary physician and food desert data derived from USDA food environment atlas and https://www.countyhealthrankings.org/health-data;
proc import datafile="/udd/nhywa/GUTSOB/food_physician/nhs2_primary_food.csv"
        out=primary_food
        dbms=csv
        replace;
run; * most missing values were due to mismatched state/county, which have been corrected manually in csv;
data primary_food; set primary_food;
	
	*convert food desert to percentage - limit access to healthy food;
	food_desert12=food_desert12*100;
	food_desert13=food_desert13*100;
	
	*physician ratio <=0 indicate no physicians,make sure they are categorized to the worst group later;
	if NOT MISSING(county_LSAD_x) & physician_ratio10 <=0 then physician_ratio10 = 0;
	if NOT MISSING(county_LSAD_y) & physician_ratio12 <=0 then physician_ratio12 = 0;
	if NOT MISSING(county_LSAD) & physician_ratio13 <=0 then physician_ratio13 = 0;
	
	*carry backward about 116 observations;
	if physician_ratio10=. then physician_ratio10=physician_ratio12;
	if physician_ratio12=. then physician_ratio12=physician_ratio13; 
	if food_desert10=. then food_desert10=food_desert12;
	if food_desert12=. then food_desert12=food_desert13; 
	
	%cumavg(cycle=3, cyclevar=2,
        varin = physician_ratio10 food_desert10
        		physician_ratio12 food_desert12
        		physician_ratio13 food_desert13 ,
        varout= physician_ratio10v food_desert10v
        		physician_ratio12v food_desert12v
        		physician_ratio13v food_desert13v);

proc sort; by id;  run; 
proc means n nmiss mean std min median max; 
	var physician_ratio10 food_desert10 physician_ratio12 food_desert12 physician_ratio13 food_desert13
		physician_ratio10v food_desert10v physician_ratio12v food_desert12v physician_ratio13v food_desert13v;
run;


/**********************************************************************************************************************
     MERGE FILES AND RUN DESCRIPTIVE ANALYSES                                                             
**********************************************************************************************************************/

/* Merge files */
data nhs2_vars;
	merge der8919 (in=mstr) nur99 ahei2010_9119 westprud alcohol act8917 
				strain nightshift jobinsecure geo nses8917 primary_food;
	by id;
    exrec=1;

	if first.id and mstr then
		exrec=0; /*indicate not a duplicate*/
    
    /*exclude birthday=. as this convention is used to denote anyone who withdrew from study participation*/
    if birthday NE .; 

    rename id=momid;

run; 

/*run descriptive analyses to ensure the variables of interest make sense*/*;
*proc means data=nhs2_vars n nmiss mean std min median max; 

/***********************************************/
/*            Pregnancy complications          */
/***********************************************/

/*will have to match to each child in GUTS. to combine with rest of the data?*/

%grav0109; 

data grav09dt;
    set grav0109 (keep = id
    yearg1-yearg16 /*Year Pregnancy Ended*/
    
    gescng1-gescng16  gesctg1-gesctg16 /*gestational age (continuos and categorical)*/
    
    gesdbg1-gesdbg16 /*Gestational Diabetes*/
    
    prghtng1-prghtng16 /*Pregnancy-Related HBP*/
    
    peclmpg1-peclmpg16 /*Pre-eclampsia/Toxemia*/
    
    w1g1-w1g16 w2g1-w2g16 w3g1-w3g16 w4g1-w4g16 w5g1-w5g16 w6g1-w6g16 /*Birth Weight (categorical and continues)*/
    bwtcng1-bwtcng16 /* birthweight continuous by midpoint of category */
    
    csectg1-csectg16 /*c-section*/
	
    /*Vaginal Birth $range 1 $label 1.vaginal birth*/
    vagnlg1-vagnlg16 
    
    /*Total gravidity from 2009*/
    totgrav09);

  rename id=momid;
run;

/*proc contents data=grav09dt; 
run; */
proc sort data=grav09dt; by momid;

/* identify which pregnancies in grav09 match with GUTS child, by matching their birth year. 
we have pregnancy information for every children of the nurse, but GUTS II children aged 9-14y */
  /* First will get the birth year for children in GUTS I and GUTS II */
 
  /* GUTS I */
  %girls96(keep= id momid yob96g mothr96g);
  %boys96(keep= id momid yob96b mothr96b);
data girls96; set girls96;
    rename yob96g =chyob;
data boys96; set boys96;
    rename yob96b =chyob;
data guts1yob; set boys96 girls96;
    chyob = chyob+1900;
proc sort data=guts1yob; by momid; run;

  /* GUTS 2 */
  %girls204(keep= id momid yob204g pct5204g);*somatotype age 5;
  %boys204(keep= id momid yob204b pct5204b);
data girls204; set girls204;
  rename yob204g =chyob;
  rename  pct5204g= pct5_04;
data boys204; set boys204;
  rename yob204b =chyob;
  rename  pct5204b= pct5_04;
data guts2yob; set boys204 girls204;
  chyob = chyob+1900;
proc sort data=guts2yob; by momid; run;

/***** merge with GUTS1 *****/
data grav09guts1;
  merge grav09dt(in=a) guts1yob(in=b) ;
  by momid;
  if a and b;

*array function;
array A_Yearg (16) yearg1-yearg16;
array	A_MethDeliv_Csectg (16) csectg1-csectg16;
array A_MethDeliv_Vagnlg (16)  vagnlg1-vagnlg16;
array A_GestAgeg (16)	gesctg1-gesctg16;
array	A_w1 (16)	w1g1-w1g16;
array	A_w2 (16)	w2g1-w2g16;
array	A_w3 (16)	w3g1-w3g16;
array	A_w4 (16)	w4g1-w4g16;
array	A_w5 (16)	w5g1-w5g16;
array	A_w6 (16)	w6g1-w6g16;
array A_bwc (16) bwtcng1-bwtcng16;
array A_Comp_Gesdbg	(16) gesdbg1-gesdbg16;
array	A_Comp_prghtng (16) prghtng1-prghtng16;
array	A_Comp_peclmpg (16)	peclmpg1-peclmpg16;

do p = 1 to 16;
if chyob = A_Yearg[p] then do;
	MethDeliv_Csectg = A_MethDeliv_Csectg[p];
	MethDeliv_Vagnlg = A_MethDeliv_Vagnlg[p];
	GestAgeg = A_GestAgeg[p];
	w1 = A_w1[p]; w2 = A_w2[p]; w3 = A_w3[p];
	w4 = A_w4[p]; w5 = A_w5[p]; w6 = A_w6[p];
	Comp_bwc = A_bwc[p];
	Comp_Gesdbg = A_Comp_Gesdbg[p];
	Comp_prghtng = A_Comp_prghtng[p];
	Comp_peclmpg = A_Comp_peclmpg[p];
end;
end;

	/* define birth order */
	if chyob=yearg1 then birth_o=1;
	if chyob=yearg2 then birth_o=2;
	if chyob=yearg3 then birth_o=3;
	if chyob=yearg4 then birth_o=4;
	if chyob=yearg5 then birth_o=5;
	if chyob=yearg6 then birth_o=6;
	if chyob=yearg7 then birth_o=7;
	if chyob=yearg8 then birth_o=8;
	if chyob=yearg9 then birth_o=9;
	if chyob=yearg10 then birth_o=10;
	if chyob=yearg11 then birth_o=11;
	if chyob=yearg12 then birth_o=12;
	if chyob=yearg13 then birth_o=13;
	if chyob=yearg14 then birth_o=14;
	if chyob=yearg15 then birth_o=15;
	if chyob=yearg16 then birth_o=16;

	if birth_o=1 then prev_preg=0; *Nulliparity ;
	if birth_o=2 then prev_preg=1; *One previous pregnancy;
	if birth_o=3 then prev_preg=2; *Two previous pregnancies;
	if birth_o>=4 then prev_preg=3; *Three previous pregnancies;
	if birth_o=. then prev_preg=.;

  * recode some variables variables of array;
  if w1=1 then bwg=1; *birthweight groups;
  else if w2=1 then bwg=1;
  else if w3=1 then bwg=2;
  else if w4=1 then bwg=2;
  else if w5=1 then bwg=2;
  else if w6=1 then bwg=3;
  /*missing*/
  else bwg=.;
  *bwg 1 = <2.50 kg, 2 = 2.50-4.49 kg, 3 = >=4.50 kg;

  if 1<=GestAgeg<=6 then gestweek=1; *gestional age;
  else if GestAgeg=7 then gestweek=2;
  else if GestAgeg=8 then gestweek=2;
  else if GestAgeg=9 then gestweek=3;
  /*missing*/
  else gestweek=.;
  *GestAgeg 1 = <37, 2 = 37-42, 3 = >=43;

  * 0 might include missing information!!!;
  if MethDeliv_Csectg=1 then Delivery=1; *recode the method of delivery;
  else Delivery=0;
  *the pregnancy complications was 1 if had complications and . if not;
  if Comp_Gesdbg=. then Comp_Gesdbg=0;
  if Comp_prghtng=. then Comp_prghtng=0;
  if Comp_peclmpg=. then Comp_peclmpg=0;
  
  keep id momid chyob birth_o prev_preg bwg gestweek Delivery Comp_Gesdbg Comp_prghtng Comp_peclmpg ;
run;
proc sort; by id; run;

/***** merge with GUTS1 *****/
data grav09guts2;
  merge grav09dt(in=a) guts2yob(in=b) ;
  by momid;
  if a and b;

*array function;
  array A_Yearg (16) yearg1-yearg16;
  array	A_MethDeliv_Csectg (16) csectg1-csectg16;
	array A_MethDeliv_Vagnlg (16)  vagnlg1-vagnlg16;
  array A_GestAgeg (16)	gesctg1-gesctg16;
  array	A_w1 (16)	w1g1-w1g16;
  array	A_w2 (16)	w2g1-w2g16;
  array	A_w3 (16)	w3g1-w3g16;
  array	A_w4 (16)	w4g1-w4g16;
  array	A_w5 (16)	w5g1-w5g16;
  array	A_w6 (16)	w6g1-w6g16;
  array A_bwc (16) bwtcng1-bwtcng16;
  array A_Comp_Gesdbg	(16) gesdbg1-gesdbg16;
  array	A_Comp_prghtng (16) prghtng1-prghtng16;
  array	A_Comp_peclmpg (16)	peclmpg1-peclmpg16;

  do p = 1 to 16;
  if chyob = A_Yearg[p] then do;
    MethDeliv_Csectg = A_MethDeliv_Csectg[p];
		MethDeliv_Vagnlg = A_MethDeliv_Vagnlg[p];
    GestAgeg = A_GestAgeg[p];
  	w1 = A_w1[p]; w2 = A_w2[p]; w3 = A_w3[p];
  	w4 = A_w4[p]; w5 = A_w5[p]; w6 = A_w6[p];
    Comp_bwc = A_bwc[p];
  	Comp_Gesdbg = A_Comp_Gesdbg[p];
  	Comp_prghtng = A_Comp_prghtng[p];
  	Comp_peclmpg = A_Comp_peclmpg[p];
  end;
end;

	/* define birth order */
	if chyob=yearg1 then birth_o=1;
	if chyob=yearg2 then birth_o=2;
	if chyob=yearg3 then birth_o=3;
	if chyob=yearg4 then birth_o=4;
	if chyob=yearg5 then birth_o=5;
	if chyob=yearg6 then birth_o=6;
	if chyob=yearg7 then birth_o=7;
	if chyob=yearg8 then birth_o=8;
	if chyob=yearg9 then birth_o=9;
	if chyob=yearg10 then birth_o=10;
	if chyob=yearg11 then birth_o=11;
	if chyob=yearg12 then birth_o=12;
	if chyob=yearg13 then birth_o=13;
	if chyob=yearg14 then birth_o=14;
	if chyob=yearg15 then birth_o=15;
	if chyob=yearg16 then birth_o=16;

	if birth_o=1 then prev_preg=0; *Nulliparity ;
  if birth_o=2 then prev_preg=1; *One previous pregnancy;
  if birth_o=3 then prev_preg=2; *Two previous pregnancies;
  if birth_o>=4 then prev_preg=3; *Three previous pregnancies;
  if birth_o=. then prev_preg=.;

  * recode some variables variables of array;
  if w1=1 then bwg=1; *birthweight groups <5lb; 
  else if w2=1 then bwg=1; *5-5.4lb;
  else if w3=1 then bwg=2; *5.5-6.9;
  else if w4=1 then bwg=2; *7-8.4;
  else if w5=1 then bwg=2; *8.5-9.9;
  else if w6=1 then bwg=3; *10+;
  /*missing*/
  else bwg=.;
  *bwg 1 = <2.50 kg, 2 = 2.50-4.49 kg, 3 = >=4.50 kg;

  if 1<=GestAgeg<=6 then gestweek=1; *gestional age;
  else if GestAgeg=7 then gestweek=2;
  else if GestAgeg=8 then gestweek=2;
  else if GestAgeg=9 then gestweek=3;
  /*missing*/
  else gestweek=.;
  *GestAgeg 1 = <37, 2 = 37-42, 3 = >=43;

  * 0 might include missing information!!!;
  if MethDeliv_Csectg=1 then Delivery=1; *recode the method of delivery;
  else Delivery=0;
  *the pregnancy complications was 1 if had complications and . if not;
  if Comp_Gesdbg=. then Comp_Gesdbg=0;
  if Comp_prghtng=. then Comp_prghtng=0;
  if Comp_peclmpg=. then Comp_peclmpg=0;
   
  keep id momid chyob birth_o prev_preg bwg gestweek Delivery Comp_Gesdbg Comp_prghtng Comp_peclmpg 
	 pct5_04;
run;
proc sort; by id; run;

/******************************************************************************
    Gestational weight gain (NO INFO IN GUTS2) 
******************************************************************************/
/* /proj/nhsass/nhsas00/dd/act8917.sas.dd
wtgp99m = Weight Gained During Pregnancy
wtbp99m = Weight Before Pregnancy 
*/

%moms99(keep = id momid wtgp99m wtbp99m);

data moms99; 
    set moms99;
    if wtgp99m=999 then gesweigain=.;
        else gesweigain=wtgp99m;
proc sort; by momid; run;


data bmibpregdt;
  merge moms99(in=a) der8919(keep= id height89 rename=(id=momid) in=b);
  by momid; if a and b;

  /*calculate bmi before pregnancy using reported weight before pregnancy*/
  height89m = height89*0.0254; /* convert height from inches to m */
  if wtbp99m ^= 999 and height89m ^=. then do;
     weightbpreg_m=wtbp99m*0.45359237;  /* convert weight before pregnancy to kg */
     bmibpreg=weightbpreg_m/(height89m*height89m); /*use height and weight to calculate bmi before pregnancy*/
  end;

  /* class for gestational weight gain */
  if gesweigain ^=. and bmibpreg ^=. then do;
    if bmibpreg<18.5 and gesweigain>40 then gotweight = 1;
    else if 18.5<=bmibpreg<25 and gesweigain>35 then gotweight = 1;
    else if 25<=bmibpreg<30 and gesweigain>25 then gotweight = 1;
    else if bmibpreg>=30 and gesweigain>20 then gotweight = 1;
    else gotweight=0;
  end;

  keep id momid bmibpreg gesweigain gotweight;
  proc sort;  by id; 
run;
proc means; var gotweight; run;

proc means data=bmibpregdt; 
    vars gesweigain;
run;
proc freq data=bmibpregdt; 
    tables gotweight;
run;


proc datasets nolist;
delete der8919 nur99 ahei2010_9119 westprud alcohol act8917 strain nightshift jobinsecure 
		moms99 grav09dt grav0109 guts1yob guts2yob boys96 girls96 boys204 girls204 geo nses8917 primary_food;
run;

