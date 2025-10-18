/*** 

Program name: nhs2_western.sas
Created: Mar 2025
Purpose: Create western diet variables for NHS2

***/*;

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

%n91_dt (keep=id cerbr91d);  %n95_dt (keep=id cerbr95d chtyp95d);  %n99_dt (keep=id cerbr99d chnft99d chlit99d);
%nur03 (keep=id cerbr03d chty03d);  %nur07 (keep=id cerbr07d chlit07d chnft07d);  
%nur11 (keep=id cerbr11d chlit11d chnft11d);  
 
%serv91 ; array change _numeric_;
        do over change; if change=. then change=0; *assume na=no consumption;
        end; 
%serv95 ;  array change _numeric_;
        do over change; if change=. then change=0; *assume na=no consumption;
        end; 
%serv99 ;  array change _numeric_;
        do over change; if change=. then change=0; *assume na=no consumption;
        end; 
%serv03 ;  array change _numeric_;
        do over change; if change=. then change=0; *assume na=no consumption;
        end; 
%serv07 ;  array change _numeric_;
        do over change; if change=. then change=0; *assume na=no consumption;
        end; 
%serv11 ; array change _numeric_;
        do over change; if change=. then change=0; *assume na=no consumption;
        end; 

data food9115; 
	merge n91_dt n95_dt n99_dt nur03 nur07  nur11 
		  serv91 serv95 serv99 serv03 serv07 serv11 
		  end=_end_ ; 
	by id;	
  
/**** cereal brand to distinguish whole/refined grains*******/ 
array brand(*) cerbr91d cerbr95d cerbr99d cerbr03d cerbr07d cerbr11d  ;
array cereal(*) cer_s91 cer_s95 cer_s99 cer_s03 cer_s07 cer_s11 ;
array ref(*) rcer_s91 rcer_s95 rcer_s99 rcer_s03 rcer_s07 rcer_s11 ;
array who(*) wcer_s91 wcer_s95 wcer_s99 wcer_s03 wcer_s07 wcer_s11 ;

	do i=1 to dim(brand);
	if brand(i) IN (0,4,11,12,13,15,16,17,19,20,21,22,23,25,30,31,33,35,37,38,42,45,46,47,59,
                60,61,62,63,64,65,66,68,73,74,75,76,79,80,81,82,83,85,86,88,95,97,98,101,
                109,113,123,124,130,149,150,153,158,170,173,177,182)
                 /*29,43,84,96,111,112,114,115,119,127,128,129,131,132,133,134,146,147,148,151,152,154,155,157,164,165,166,167,176,184,185,186,188*/
                 /*0,4,11,12,13,15,16,17,19,20,21,22,23,25,30,31,33,35,42,45,46,59,60,61,62,63,64,65,66,68,74,75,76,79,80,81,82,83,85,86,88,95,97,98,101,
                   109,113,123,124,149,150,153,158,170,173,177,37,38,47,73,130,182*/ 
       then ref(i)=cereal(i); else who(i)=cereal(i); 
	if ref(i)=. then ref(i)=0; if who(i)=. then who(i)=0; 
	end; drop i;
	
/*============================================1991============================================*/*;
	promeat91   = sum (dog_s91, procm_s91, bacon_s91 );
   redmeat91   = sum (hamb_s91, bmix_s91, bmain_s91, pmain_s91 );
   orgmeat91   = sum (livc_s91, livb_s91 );
   fish91      = sum (ctuna_s91, dkfsh_s91, ofish_s91, shrim_s91 );
   othfish91   = sum (ctuna_s91, ofish_s91, shrim_s91 );
   poult91     = sum (chwo_s91, chwi_s91, turk_s91 );
   eggs91      = sum (egg_s91 );
   butter91    = sum (but_s91 );
   marg91      = sum (marg_s91 );
   lowdai91    = sum (skim_s91, yog_s91, sherb_s91, cotch_s91 );
   highdai91   = sum (whole_s91, cream_s91, sour_s91, crmch_s91, icecr_s91, otch_s91 );
   wine91      = sum (wwine_s91, rwine_s91 );
   liquor91    = sum (liq_s91 );
   beer91      = sum (beer_s91, lbeer_s91 );
   tea91       = sum (tea_s91 );
   coffee91    = sum (dcaf_s91, coff_s91 );
   fruit91     = sum (rais_s91, prune_s91, oran_s91, ban_s91, cant_s91, avo_s91, appl_s91, grfr_s91, straw_s91, blueb_s91, peach_s91 );
   fruju91     = sum (othj_s91, aj_s91, oj_s91, grj_s91 );
   cruveg91    = sum (brocc_s91, cabb_s91, kale_s91, cauli_s91, bruss_s91 );
   yelveg91    = sum (ccar_s91, rcar_s91, osqua_s91, yam_s91 );
   tomato91    = sum (tom_s91, toj_s91 , tosau_s91 );
   leafveg91   = sum (rspin_s91, cspin_s91, ilett_s91, rlett_s91 );
   legume91    = sum (tofu_s91, sbean_s91, peas_s91, bean_s91 );
   othveg91    = sum (corn_s91, mixv_s91, oniog_s91, oniov_s91, eggpl_s91, cel_s91, grpep_s91, beet_s91 );
   potato91    = sum (pot_s91 );
   french91    = sum (fries_s91 );
   wholeg91    = sum (oat_s91, ckcer_s91, dkbr_s91, brice_s91, wcer_s91, otgrn_s91, oatbr_s91, bran_s91, wgerm_s91);
   refing91    = sum (whbr_s91, engl_s91, muff_s91, pcake_s91, wrice_s91, pasta_s91, tort_s91, rcer_s91 );
   pizza91     = sum (pizza_s91 );
   sugdrk91    = sum (cola_s91, cnoc_s91, punch_s91, otsug_s91 );
   lowdrk91    = sum (lccaf_s91, lcoth_s91, lcnoc_s91 );
   snack91     = sum (pchip_s91, crack_s91, popc_s91 );
   nuts91      = sum (pbut_s91, pnut_s91, onut_s91 );
   mayo91      = sum (mayo_s91 );
   dress91     = sum (ooil_s91, oilv_s91 );
   crmsoup91   = sum (chowd_s91 ); 
   sweets91    = sum (choco_s91, cdyw_s91, cdywo_s91, cokh_s91, cokr_s91, brwn_s91, donut_s91, cakh_s91, cakr_s91, pieh_s91, pier_s91, srolr_s91, srolh_s91 );
   condim91    = sum (jam_s91, salt_s91, cofwh_s91, chsau_s91 );
                  
/*============================================1995============================================*/*;
	promeat_s95   = sum (bfdog_s95, ctdog_s95, procm_s95, bacon_s95 );
   redmeat_s95   = sum (hamb_s95, hambl_s95, bmix_s95, bmain_s95, pmain_s95 );
   orgmeat_s95   = sum (livc_s95, livb_s95 );
   fish_s95      = sum (ctuna_s95, dkfsh_s95, ofish_s95, shrim_s95, bfsh_s95 );
   othfish_s95   = sum (ctuna_s95, ofish_s95, shrim_s95 );
   poult_s95     = sum (chwo_s95, chwi_s95 );
   eggs_s95      = sum (egg_s95 );
   butter_s95    = sum (but_s95 );
   marg_s95      = sum (marg_s95 );
   lowdai_s95    = sum (skim_s95, m1or2_s95, flyog_s95, plyog_s95, sherb_s95, cotch_s95 );
   highdai_s95   = sum (whole_s95, cream_s95, crmch_s95, icecr_s95, otch_s95 );
   wine_s95      = sum (wwine_s95, rwine_s95 );
   liquor_s95    = sum (liq_s95 );
   beer_s95      = sum (beer_s95, lbeer_s95 );
   tea_s95       = sum (tea_s95, dtea_s95 );
   coffee_s95    = sum (dcaf_s95, coff_s95 );
   fruit_s95     = sum (rais_s95, prune_s95, oran_s95, ban_s95, cant_s95, avo_s95, appl_s95, grfr_s95, straw_s95, blueb_s95, peach_s95 );
   fruju_s95     = sum (othj_s95, aj_s95, oj_s95, grj_s95 );
   cruveg_s95    = sum (brocc_s95, cabb_s95, kale_s95, cauli_s95, bruss_s95 );
   yelveg_s95    = sum (ccar_s95, rcar_s95, osqua_s95, yam_s95 );
   tomato_s95    = sum (tom_s95, toj_s95 , tosau_s95 );
   leafveg_s95   = sum (rspin_s95, cspin_s95, ilett_s95, rlett_s95 );
   legume_s95    = sum (tofu_s95, sbean_s95, peas_s95, bean_s95 );
   othveg_s95    = sum (corn_s95, mixv_s95, oniog_s95, oniov_s95, eggpl_s95, cel_s95, grpep_s95 );
   potato_s95    = sum (pot_s95 );
   french_s95    = sum (fries_s95 );
   wholeg_s95    = sum (oat_s95, ckcer_s95, dkbr_s95, brice_s95, wcer_s95, otgrn_s95, oatbr_s95, bran_s95, wgerm_s95);
   refing_s95    = sum (whbr_s95, engl_s95, muff_s95, pcake_s95, wrice_s95, pasta_s95, tort_s95, rcer_s95 );
   pizza_s95     = sum (pizza_s95 );
   sugdrk_s95    = sum (cola_s95, cnoc_s95, punch_s95, otsug_s95 );
   lowdrk_s95    = sum (lccaf_s95, lcoth_s95, lcnoc_s95 );
   snack_s95     = sum (pchip_s95, crack_s95, popc_s95, pretz_s95 );
   nuts_s95      = sum (pbut_s95, pnut_s95, onut_s95 );
   mayo_s95      = sum (mayo_s95, lmayo_s95 );
   dress_s95     = sum (ooil_s95, dress_s95);
   crmsoup_s95   = sum (chowd_s95 ); 
   sweets_s95    = sum (choco_s95, cdyw_s95, cdywo_s95, cokh_s95, cokr_s95, brwn_s95, donut_s95, cakh_s95, cakr_s95, pieh_s95, pier_s95, srolr_s95, srolh_s95 );
   condim_s95    = sum (jam_s95, ketch_s95, salt_s95, nutrs_s95, salsa_s95, cofwh_s95 );

/*============================================1999============================================*/*;
 	promeat_s99   = sum (bfdog_s99, ctdog_s99, procm_s99, bacon_s99, pmsan_s99 );
   redmeat_s99   = sum (hamb_s99, hambl_s99, bmix_s99, bmain_s99, pmain_s99 );
   orgmeat_s99   = sum (livc_s99, livb_s99 );
   fish_s99      = sum (ctuna_s99, dkfsh_s99, ofish_s99, shrim_s99, bfsh_s99 );
   othfish_s99   = sum (ctuna_s99, ofish_s99, shrim_s99 );
   poult_s99     = sum (chksa_s99, chwo_s99, chwi_s99 );
   eggs_s99      = sum (egg_s99, eggwh_s99 );
   butter_s99    = sum (but_s99 );
   marg_s99      = sum (marg_s99 );
   lowdai_s99    = sum (skim_s99, m2_s99, flyog_s99, plyog_s99, sherb_s99, cotch_s99 );
   highdai_s99   = sum (whole_s99, cream_s99, crmch_s99, icecr_s99, otch_s99 );
   wine_s99      = sum (wwine_s99, rwine_s99 );
   liquor_s99    = sum (liq_s99 );
   beer_s99      = sum (beer_s99, lbeer_s99 );
   tea_s99       = sum (tea_s99, dtea_s99 );
   coffee_s99    = sum (dcaf_s99, coff_s99 );
   fruit_s99     = sum (rais_s99, prune_s99, oran_s99, ban_s99, cant_s99, avo_s99, appl_s99, grfr_s99, straw_s99, blueb_s99, peach_s99 );
   fruju_s99     = sum (prunj_s99, othj_s99, aj_s99, oj_s99, ojca_s99);
   cruveg_s99    = sum (brocc_s99, cabb_s99, kale_s99, cauli_s99, bruss_s99 );
   yelveg_s99    = sum (ccar_s99, rcar_s99, osqua_s99, yam_s99 );
   tomato_s99    = sum (tom_s99, toj_s99 , tosau_s99 );
   leafveg_s99   = sum (rspin_s99, cspin_s99, ilett_s99, rlett_s99 );
   legume_s99    = sum (tofu_s99, sbean_s99, peas_s99, bean_s99, soy_s99 );
   othveg_s99    = sum (corn_s99, mixv_s99, oniog_s99, oniov_s99, eggpl_s99, cel_s99, grpep_s99 );
   potato_s99    = sum (pot_s99 );
   french_s99    = sum (fries_s99 );
   wholeg_s99    = sum (oat_s99, ckcer_s99, dkbr_s99, brice_s99, wcer_s99, otgrn_s99, oatbr_s99, bran_s99, wgerm_s99);
   refing_s99    = sum (whbr_s99, engl_s99, muff_s99, pcake_s99, wrice_s99, pasta_s99, tort_s99, rcer_s99 );
   pizza_s99     = sum (pizza_s99 );
   sugdrk_s99    = sum (cola_s99, punch_s99, otsug_s99, otsnc_s99 );
   lowdrk_s99    = sum (lccaf_s99, lcoth_s99, lcnoc_s99 );
   snack_s99     = sum (pchip_s99, crack_s99, popc_s99, pretz_s99 );
   nuts_s99      = sum (pbut_s99, pnut_s99, wnut_s99, onut_s99 );
   mayo_s99      = sum (mayo_s99, lmayo_s99 );
   dress_s99     = sum (ooil_s99, dress_s99);
   crmsoup_s99   = sum (chowd_s99 ); 
   sweets_s99    = sum (choco_s99, cdyw_s99, cdywo_s99, coknf_s99, cokh_s99, cokr_s99, brwn_s99, donut_s99, cakh_s99, cakr_s99, pieh_s99, srolf_s99, srolr_s99, srolh_s99 );
   condim_s99    = sum (jam_s99, ketch_s99, salt_s99, nutrs_s99, salsa_s99, cofwh_s99 );

/*============================================2003============================================*/*;
	promeat_s03   = sum (bfdog_s03, ctdog_s03, procm_s03, bacon_s03, pmsan_s03 );
   redmeat_s03   = sum (hamb_s03, hambl_s03, bmix_s03, bmain_s03, pmain_s03 );
   orgmeat_s03   = sum (livc_s03, livb_s03 );
   fish_s03      = sum (ctuna_s03, dkfsh_s03, ofish_s03, shrim_s03, bfsh_s03 );
   othfish_s03   = sum (ctuna_s03, ofish_s03, shrim_s03 );
   poult_s03     = sum (chksa_s03, chwo_s03, chwi_s03 );
   eggs_s03      = sum (egg_s03, eggwh_s03 );
   butter_s03    = sum (but_s03 );
   marg_s03      = sum (marg_s03 );
   lowdai_s03    = sum (skim_s03, m1or2_s03, flyog_s03, plyog_s03, sherb_s03, cotch_s03 );
   highdai_s03   = sum (whole_s03, cream_s03, crmch_s03, icecr_s03, otch_s03 );
   wine_s03      = sum (wwine_s03, rwine_s03 );
   liquor_s03    = sum (liq_s03 );
   beer_s03      = sum (beer_s03, lbeer_s03 );
   tea_s03       = sum (tea_s03, dtea_s03 );
   coffee_s03    = sum (dcaf_s03, coff_s03 );
   fruit_s03     = sum (rais_s03, grape_s03, prune_s03, oran_s03, ban_s03, cant_s03, apsau_s03, appl_s03, grfr_s03, straw_s03, blueb_s03, peach_s03 );
   fruju_s03     = sum (prunj_s03, othj_s03, aj_s03, oj_s03, ojca_s03);
   cruveg_s03    = sum (brocc_s03, cabb_s03, kale_s03, cauli_s03, bruss_s03 );
   yelveg_s03    = sum (ccar_s03, rcar_s03, osqua_s03, yam_s03 );
   tomato_s03    = sum (tom_s03, toj_s03 , tosau_s03 );
   leafveg_s03   = sum (rspin_s03, cspin_s03, ilett_s03, rlett_s03 );
   legume_s03    = sum (tofu_s03, sbean_s03, peas_s03, bean_s03, soy_s03 );
   othveg_s03    = sum (corn_s03, mixv_s03, oniog_s03, oniov_s03, eggpl_s03, cel_s03, grpep_s03 );
   potato_s03    = sum (pot_s03 );
   french_s03    = sum (fries_s03 );
   wholeg_s03    = sum (oat_s03, ckcer_s03, ryebr_s03, dkbr_s03, brice_s03, wcer_s03, oatbr_s03, bran_s03, wgerm_s03);
   refing_s03    = sum (whbr_s03, engl_s03, muff_s03, pcake_s03, wrice_s03, pasta_s03, tort_s03, rcer_s03 );
   pizza_s03     = sum (pizza_s03 );
   sugdrk_s03    = sum (cola_s03, punch_s03, otsug_s03 );
   lowdrk_s03    = sum (lccaf_s03, lcnoc_s03 );
   snack_s03     = sum (pchip_s03, crlit_s03, crack_s03, ffpop_s03, popc_s03, pretz_s03 );
   nuts_s03      = sum (pbut_s03, pnut_s03, wnut_s03, onut_s03 );
   mayo_s03      = sum (mayo_s03, lmayo_s03 );
   dress_s03     = sum (ooil_s03, dress_s03);
   crmsoup_s03   = sum (chowd_s03 ); 
   sweets_s03    = sum (choc_s03, cdyw_s03, cdywo_s03, coknf_s03, cokh_s03, cokr_s03, brwn_s03, donut_s03, cakh_s03, cakr_s03, pieh_s03, srolf_s03, srolr_s03, srolh_s03 );
   condim_s03    = sum (jam_s03, ketch_s03, salt_s03, nutrs_s03, salsa_s03, cofwh_s03 );
 
/*============================================2007============================================*/*;
	promeat_s07   = sum (bfdog_s07, ctdog_s07, procm_s07, bacon_s07, pmsan_s07 );
   redmeat_s07   = sum (hamb_s07, hambl_s07, bmix_s07, bmain_s07, pmain_s07 );
   orgmeat_s07   = sum (livc_s07, livb_s07 );
   fish_s07      = sum (ctuna_s07, dkfsh_s07, ofish_s07, shrim_s07, bfsh_s07 );
   othfish_s07   = sum (ctuna_s07, ofish_s07, shrim_s07 );
   poult_s07     = sum (chksa_s07, chwo_s07, chwi_s07 );
   eggs_s07      = sum (egg_s07, eggom_s07 );
   butter_s07    = sum (but_s07, spbut_s07 );
   marg_s07      = sum (marg_s07 );
   lowdai_s07    = sum (skim_s07, m1or2_s07, flyog_s07, plyog_s07, sherb_s07, cotch_s07 );
   highdai_s07   = sum (whole_s07, cream_s07, crmch_s07, icecr_s07, otch_s07 );
   wine_s07      = sum (wwine_s07, rwine_s07 );
   liquor_s07    = sum (liq_s07 );
   beer_s07      = sum (beer_s07, lbeer_s07 );
   tea_s07       = sum (tea_s07, dtea_s07 );
   coffee_s07    = sum (dcaf_s07, coff_s07, dcofdk_s07 );
   fruit_s07     = sum (rais_s07, prune_s07, oran_s07, ban_s07, cant_s07, avo_s07, appl_s07, grfr_s07, straw_s07, blueb_s07, peach_s07, apric_s07);
   fruju_s07     = sum (prunj_s07, othj_s07, aj_s07, oj_s07, ojca_s07);
   cruveg_s07    = sum (brocc_s07, cabb_s07, kale_s07, cauli_s07, bruss_s07 );
   yelveg_s07    = sum (ccar_s07, rcar_s07, osqua_s07, yam_s07 );
   tomato_s07    = sum (tom_s07, toj_s07 , tosau_s07 );
   leafveg_s07   = sum (rspin_s07, cspin_s07, ilett_s07, rlett_s07 );
   legume_s07    = sum (tofu_s07, sbean_s07, peas_s07, bean_s07, soy_s07 );
   othveg_s07    = sum (corn_s07, mixv_s07, oniog_s07, oniov_s07, eggpl_s07, cel_s07, grpep_s07 );
   potato_s07    = sum (pot_s07 );
   french_s07    = sum (fries_s07 );
   wholeg_s07    = sum (oat_s07, ckcer_s07, ryebr_s07, dkbr_s07, brice_s07, wcer_s07, oatbr_s07, bran_s07);
   refing_s07    = sum (whbr_s07, engl_s07, muff_s07, pcake_s07, wrice_s07, pasta_s07, tort_s07, rcer_s07 );
   pizza_s07     = sum (pizza_s07 );
   sugdrk_s07    = sum (cola_s07, punch_s07, otsug_s07 );
   lowdrk_s07    = sum (lccaf_s07, lcnoc_s07 );
   snack_s07     = sum (crack_s07, pchip_s07, ffpop_s07, popc_s07, pretz_s07 );
   nuts_s07      = sum (pbut_s07, pnut_s07, wnut_s07, onut_s07 );
   mayo_s07      = sum (mayo_s07, lmayo_s07 );
   dress_s07     = sum (ooil_s07, dress_s07);
   crmsoup_s07   = sum (chowd_s07 );
   sweets_s07    = sum (mchoc_s07, dchoc_s07, cdyw_s07, cdywo_s07, coknf_s07, cokh_s07, cokr_s07, donut_s07, cake_s07, piehr_s07, 
				srolf_s07, srolr_s07, srolh_s07 ); *brbar_s07, enbar_s07, lcbar_s07;
   condim_s07    = sum (jam_s07, splnd_s07, otswt_s07, ketch_s07, salsa_s07, cofwh_s07 );

/*============================================2011============================================*/*;
 	promeat_s11   = sum (bfdog_s11, ctdog_s11, procm_s11, bacon_s11, pmsan_s11 );
   redmeat_s11   = sum (hamb_s11, hambl_s11, bmix_s11, bmain_s11, pmain_s11 );
   orgmeat_s11   = sum (livc_s11, livb_s11 );
   fish_s11      = sum (ctuna_s11, dkfsh_s11, ofish_s11, shrim_s11, bfsh_s11 );
   othfish_s11   = sum (ctuna_s11, ofish_s11, shrim_s11 );
   poult_s11     = sum (chksa_s11, chwo_s11, chwi_s11 );
   eggs_s11      = sum (egg_s11, eggom_s11 );
   butter_s11    = sum (but_s11, spbut_s11 );
   marg_s11      = sum (marg_s11 );
   lowdai_s11    = sum (skim_s11, m1or2_s11, artyog_s11, flyog_s11, plyog_s11, sherb_s11, cotch_s11 );
   highdai_s11   = sum (whole_s11, cream_s11, crmch_s11, icecr_s11, otch_s11 );
   wine_s11      = sum (wwine_s11, rwine_s11 );
   liquor_s11    = sum (liq_s11 );
   beer_s11      = sum (beer_s11, lbeer_s11 );
   tea_s11       = sum (tea_s11, dtea_s11 );
   coffee_s11    = sum (dcaf_s11, coff_s11, dcofdk_s11 );
   fruit_s11     = sum (rais_s11, prune_s11, oran_s11, ban_s11, cant_s11, avo_s11, appl_s11, grfr_s11,straw_s11, blueb_s11, peach_s11, apric_s11); * mdrfr_s11;
   fruju_s11     = sum (prunj_s11, othj_s11, aj_s11, oj_s11, ojca_s11);
   cruveg_s11    = sum (brocc_s11, cabb_s11, kale_s11, cauli_s11, bruss_s11 );
   yelveg_s11    = sum (ccar_s11, rcar_s11, osqua_s11, yam_s11 );
   tomato_s11    = sum (tom_s11, toj_s11 , tosau_s11 );
   leafveg_s11   = sum (rspin_s11, cspin_s11, ilett_s11, rlett_s11 );
   legume_s11    = sum (tofu_s11, sbean_s11, peas_s11, bean_s11, soy_s11 );
   othveg_s11    = sum (corn_s11, mixv_s11, oniog_s11, oniov_s11, eggpl_s11, cel_s11, grpep_s11 );
   potato_s11    = sum (pot_s11 );
   french_s11    = sum (fries_s11 );
   wholeg_s11    = sum (oat_s11, ckcer_s11, ryebr_s11, dkbr_s11, brice_s11, wcer_s11, oatbr_s11, wgerm_s11);
   refing_s11    = sum (whbr_s11, engl_s11, muff_s11, pcake_s11, wrice_s11, pasta_s11, tort_s11, rcer_s11 );
   pizza_s11     = sum (pizza_s11 );
   sugdrk_s11    = sum (cola_s11, punch_s11, otsug_s11 );
   lowdrk_s11    = sum (lccaf_s11, lcnoc_s11 );
   snack_s11     = sum (crackww_s11, crackot_s11, pchip_s11, ffpop_s11, popc_s11, pretz_s11 );
   nuts_s11      = sum (pbut_s11, pnut_s11, wnut_s11, onut_s11 ); *flaxd_s11;
   mayo_s11      = sum (mayo_s11, lmayo_s11 );
   dress_s11     = sum (ooil_s11, dress_s11);
   crmsoup_s11   = sum (chowd_s11 );
   sweets_s11    = sum (mchoc_s11, dchoc_s11, cdyw_s11, cdywo_s11, coknf_s11, cokh_s11, cokr_s11, donut_s11, cake_s11, sroll_s11, piehr_s11 ); * brbar_s11, enbar_s11;
   condim_s11    = sum (jam_s11, artswt_s11, ketch_s11, salsa_s11, cofwh_s11 );
 
keep id 
  promeat91   redmeat91  orgmeat91   fish91    poult91    eggs91     butter91    
  marg91      lowdai91   highdai91   wine91    liquor91   beer91     tea91       
  coffee91    fruit91    fruju91     cruveg91  yelveg91   tomato91   leafveg91   
  legume91    othveg91   potato91    french91  wholeg91   refing91   pizza91    
  sugdrk91    lowdrk91   snack91     nuts91    mayo91     dress91    crmsoup91   
  sweets91    condim91   othfish91
  promeat_s95   redmeat_s95  orgmeat_s95   fish_s95    poult_s95    eggs_s95     butter_s95    
  marg_s95      lowdai_s95   highdai_s95   wine_s95    liquor_s95   beer_s95     tea_s95       
  coffee_s95    fruit_s95    fruju_s95     cruveg_s95  yelveg_s95   tomato_s95   leafveg_s95   
  legume_s95    othveg_s95   potato_s95    french_s95  wholeg_s95   refing_s95   pizza_s95    
  sugdrk_s95    lowdrk_s95   snack_s95     nuts_s95    mayo_s95     dress_s95    crmsoup_s95   
  sweets_s95    condim_s95  othfish_s95
  promeat_s99   redmeat_s99  orgmeat_s99   fish_s99    poult_s99    eggs_s99     butter_s99    
  marg_s99      lowdai_s99   highdai_s99   wine_s99    liquor_s99   beer_s99     tea_s99       
  coffee_s99    fruit_s99    fruju_s99     cruveg_s99  yelveg_s99   tomato_s99   leafveg_s99   
  legume_s99    othveg_s99   potato_s99    french_s99  wholeg_s99   refing_s99   pizza_s99    
  sugdrk_s99    lowdrk_s99   snack_s99     nuts_s99    mayo_s99     dress_s99    crmsoup_s99   
  sweets_s99    condim_s99  othfish_s99
  promeat_s03   redmeat_s03  orgmeat_s03   fish_s03    poult_s03    eggs_s03     butter_s03    
  marg_s03      lowdai_s03   highdai_s03   wine_s03    liquor_s03   beer_s03     tea_s03       
  coffee_s03    fruit_s03    fruju_s03     cruveg_s03  yelveg_s03   tomato_s03   leafveg_s03   
  legume_s03    othveg_s03   potato_s03    french_s03  wholeg_s03   refing_s03   pizza_s03    
  sugdrk_s03    lowdrk_s03   snack_s03     nuts_s03    mayo_s03     dress_s03    crmsoup_s03   
  sweets_s03    condim_s03   othfish_s03
  promeat_s07   redmeat_s07  orgmeat_s07   fish_s07    poult_s07    eggs_s07     butter_s07    
  marg_s07      lowdai_s07   highdai_s07   wine_s07    liquor_s07   beer_s07     tea_s07       
  coffee_s07    fruit_s07    fruju_s07     cruveg_s07  yelveg_s07   tomato_s07   leafveg_s07   
  legume_s07    othveg_s07   potato_s07    french_s07  wholeg_s07   refing_s07   pizza_s07    
  sugdrk_s07    lowdrk_s07   snack_s07     nuts_s07    mayo_s07     dress_s07    crmsoup_s07   
  sweets_s07    condim_s07   othfish_s07
  promeat_s11   redmeat_s11  orgmeat_s11   fish_s11    poult_s11    eggs_s11     butter_s11    
  marg_s11      lowdai_s11   highdai_s11   wine_s11    liquor_s11   beer_s11     tea_s11       
  coffee_s11    fruit_s11    fruju_s11     cruveg_s11  yelveg_s11   tomato_s11   leafveg_s11   
  legume_s11    othveg_s11   potato_s11    french_s11  wholeg_s11   refing_s11   pizza_s11    
  sugdrk_s11    lowdrk_s11   snack_s11     nuts_s11    mayo_s11     dress_s11    crmsoup_s11   
  sweets_s11    condim_s11   othfish_s11
   ;
run;
proc sort nodupkey; by id; run; 

proc datasets;
delete n91_dt n95_dt n99_dt nur03 nur07  nur11  
		  serv91 serv95 serv99 serv03 serv07 serv11 ; 
run;

/*************************************************************************/ 
*------------------------  Western/Prudent ---------------------------------------;
proc factor data=food9115 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f11;
	where promeat_s11 ne .;
	var promeat_s11   redmeat_s11  orgmeat_s11   fish_s11    poult_s11    eggs_s11     butter_s11    
  		marg_s11      lowdai_s11   highdai_s11   wine_s11    liquor_s11   beer_s11     tea_s11       
  		coffee_s11    fruit_s11    fruju_s11     cruveg_s11  yelveg_s11   tomato_s11   leafveg_s11   
  		legume_s11    othveg_s11   potato_s11    french_s11  wholeg_s11   refing_s11   pizza_s11    
  		sugdrk_s11    lowdrk_s11   snack_s11     nuts_s11    mayo_s11     dress_s11    crmsoup_s11   
  		sweets_s11    condim_s11 ; 
data f11; set f11 ( keep=id factor1 factor2 
				rename=(factor1=f111 factor2=f211));
proc sort; by id;  run;

proc factor data=food9115 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f07;
	where promeat_s07 ne .;
	var promeat_s07   redmeat_s07  orgmeat_s07   fish_s07    poult_s07    eggs_s07     butter_s07    
  		marg_s07      lowdai_s07   highdai_s07   wine_s07    liquor_s07   beer_s07     tea_s07       
 	    coffee_s07    fruit_s07    fruju_s07     cruveg_s07  yelveg_s07   tomato_s07   leafveg_s07   
  		legume_s07    othveg_s07   potato_s07    french_s07  wholeg_s07   refing_s07   pizza_s07    
  		sugdrk_s07    lowdrk_s07   snack_s07     nuts_s07    mayo_s07     dress_s07    crmsoup_s07   
  		sweets_s07    condim_s07 ; 
data f07; set f07 ( keep=id factor1 factor2  
				rename=(factor1=f107 factor2=f207));
proc sort; by id;  run;

proc factor data=food9115 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f03;
	where promeat_s03 ne .;
	var promeat_s03   redmeat_s03  orgmeat_s03   fish_s03    poult_s03    eggs_s03     butter_s03    
  		marg_s03      lowdai_s03   highdai_s03   wine_s03    liquor_s03   beer_s03     tea_s03       
  		coffee_s03    fruit_s03    fruju_s03     cruveg_s03  yelveg_s03   tomato_s03   leafveg_s03   
  		legume_s03    othveg_s03   potato_s03    french_s03  wholeg_s03   refing_s03   pizza_s03    
  		sugdrk_s03    lowdrk_s03   snack_s03     nuts_s03    mayo_s03     dress_s03    crmsoup_s03   
  		sweets_s03    condim_s03  ; 
data f03; set f03 ( keep=id factor1 factor2  
				rename=(factor1=f103 factor2=f203));
proc sort; by id;  run;

proc factor data=food9115 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f99;
	where promeat_s99 ne .;
	var  promeat_s99   redmeat_s99  orgmeat_s99   fish_s99    poult_s99    eggs_s99     butter_s99    
  		marg_s99      lowdai_s99   highdai_s99   wine_s99    liquor_s99   beer_s99     tea_s99       
  		coffee_s99    fruit_s99    fruju_s99     cruveg_s99  yelveg_s99   tomato_s99   leafveg_s99   
  		legume_s99    othveg_s99   potato_s99    french_s99  wholeg_s99   refing_s99   pizza_s99    
  		sugdrk_s99    lowdrk_s99   snack_s99     nuts_s99    mayo_s99     dress_s99    crmsoup_s99   
  		sweets_s99    condim_s99 ; 
data f99; set f99 ( keep=id factor1 factor2  
				rename=(factor1=f199 factor2=f299));
proc sort; by id;  run;

proc factor data=food9115 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f95;
	where promeat_s95 ne .;
	var promeat_s95   redmeat_s95  orgmeat_s95   fish_s95    poult_s95    eggs_s95     butter_s95    
  		marg_s95      lowdai_s95   highdai_s95   wine_s95    liquor_s95   beer_s95     tea_s95       
  		coffee_s95    fruit_s95    fruju_s95     cruveg_s95  yelveg_s95   tomato_s95   leafveg_s95   
  		legume_s95    othveg_s95   potato_s95    french_s95  wholeg_s95   refing_s95   pizza_s95    
  		sugdrk_s95    lowdrk_s95   snack_s95     nuts_s95    mayo_s95     dress_s95    crmsoup_s95   
  		sweets_s95    condim_s95; 
data f95; set f95 ( keep=id factor1 factor2 
				rename=(factor1=f195 factor2=f295));
proc sort; by id;  run;

proc factor data=food9115 rotate=varimax mineigen=1.5 fuzz=0.10 nfactor=3 scree reorder out=f91;
	where promeat91 ne .;
	var promeat91   redmeat91  orgmeat91   fish91    poult91    eggs91     butter91    
  		marg91      lowdai91   highdai91   wine91    liquor91   beer91     tea91       
  		coffee91    fruit91    fruju91     cruveg91  yelveg91   tomato91   leafveg91   
  		legume91    othveg91   potato91    french91  wholeg91   refing91   pizza91    
  		sugdrk91    lowdrk91   snack91     nuts91    mayo91     dress91    crmsoup91   
  		sweets91    condim91 ; 
data f91; set f91 ( keep=id factor1 factor2  
				rename=(factor1=f191 factor2=f291));
proc sort; by id;  run;

data here.westprud;  
	merge f11 f07 f03 f99 f95 f91 end=_end_;  
	by id; if first.id; 

	array prud    {*}    f191   f195  f199    f103   f107   f111    ; 
        array prudr    {*}    f191r   f195r  f199r    f103r   f107r   f111r    ; /*BCAR updated code to keep original values without carrying forward*/
	array west    {*}    f291   f295  f299    f203   f207   f211    ; 
        array westr    {*}    f291r   f295r  f299r    f203r   f207r   f211r    ;  /*BCAR updated code to keep original values without carrying forward*/
	
        do i=1 to dim(prud);
	    prudr{i}=prud{i}; 
            westr{i}=west{i}; 
	end; drop i; 

	do i=2 to DIM(prud);
	if prud{i} =. and prud{i-1} ne . then prud{i} = prud{i-1};
	if west{i} =. and west{i-1} ne . then west{i} = west{i-1};
	end; drop i;


	%cumavg(cycle=6, cyclevar=2,
        varin = f191  f291  f195  f295  f199  f299  f103  f203  f107 f207 f111 f211 ,
        varout= f191v  f291v  f195v  f295v  f199v  f299v  f103v  f203v  f107v f207v f111v f211v);
	
keep id 
  f191r  f291r  f195r  f295r  f199r  f299r  f103r  f203r  f107r f207r f111r f211r /*BC updated code to also keep original western values*/
  f191  f291  f195  f295  f199  f299  f103  f203  f107 f207 f111 f211 /*BC also keeping the values with carry-forward of missing*/
f191v  f291v  f195v  f295v  f199v  f299v  f103v  f203v  f107v f207v f111v f211v; 
run;


