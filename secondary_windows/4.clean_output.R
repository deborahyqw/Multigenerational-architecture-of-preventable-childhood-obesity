


#####################################################
#CODE DOCUMENTATION
#####################################################/*
#Program name: /udd/nhywa/GUTSOB/secondary_windows/
#Pogrammer: Bethsaida Cardona (n2bca)
#Date started: 07/2025
#Program Purpose: Prepare exposure window analysis data for export, including number of cases and RR for each exposure window

#####################################################
#Program Setup
#####################################################

library(ggcorrplot)
library(tidyverse)
library(ggplot2)
library(patchwork)
library(haven)


#set working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
rm(list=ls())
getwd()


exwindows <- read.csv("1.data/exwindows.csv") 


#will run a correlation plot between all the exposures, will run the correlations WITHIN category: life, mom, socio

#########################################################################
#LIFE 
#will only have two exposure windows, child and adolescent 
#########################################################################

lifecorr <- exwindows  %>% 
    select(chwestv_ch, chwestv_adol, chstv_ch, chstv_adol, chpav_ch, chpav_adol) %>% 
    rename('West.Diet - Childhood'= chwestv_ch, 
           'West.Diet - Adolescence'= chwestv_adol, 
           'Sedentary - Childhood'= chstv_ch, 
           'Sedentary - Adolescence'= chstv_adol, 
           'Phys.Activity - Childhood'= chpav_ch, 
           'Phys.Activity - Adolescence'= chpav_adol)
           
cormat_lifecorr <- round(cor(lifecorr, method = "spearman", use = "complete.obs"),2)

p.mat_lifecorr <- cor_pmat(lifecorr)


lifecorr_p <- ggcorrplot(cormat_lifecorr,
                        type = "lower",
                        lab = TRUE
                        # p.mat = p.mat, 
                        # insig = "blank"
) + 
  labs(title = "A",
       subtitle = "Personal Factors") +
  theme(axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10))

#########################################################################
#MOM
#will all exposure windows: preg, earlych, childhood, adolescence
#########################################################################

momcorr <- exwindows  %>% 
  # select(mowestv_preg,  mopav_preg,  mosmkv_preg, moshiftv_preg, moob_preg,
  #        mowestv_earlych,  mopav_earlych,  mosmkv_earlych, moshiftv_earlych, moob_earlych,
  #        mowestv_ch,  mopav_ch,  mosmkv_ch, moshiftv_ch, moob_ch,
  #        mowestv_adol,  mopav_adol,  mosmkv_adol, moshiftv_adol, moob_adol) %>% 
  select(mowestv_preg, mowestv_earlych, mowestv_ch, mowestv_adol, 
         mopav_preg,  mopav_earlych, mopav_ch, mopav_adol,
         mosmkv_preg, mosmkv_earlych, mosmkv_ch, mosmkv_adol,
         moshiftv_preg, moshiftv_earlych, moshiftv_ch, moshiftv_adol, 
         moob_preg, moob_earlych, moob_ch, moob_adol) %>%
  rename('West.Diet - Pregnancy'= mowestv_preg,
         'West.Diet - Early Childhood'= mowestv_earlych, 
         'West.Diet - Childhood'= mowestv_ch, 
         'West.Diet - Adolescence'= mowestv_adol,
         
         'Phys.Activity - Pregnancy'= mopav_preg,
         'Phys.Activity - Early Childhood'= mopav_earlych, 
         'Phys.Activity - Childhood'= mopav_ch, 
         'Phys.Activity - Adolescence'= mopav_adol,
         
         'Smoking - Pregnancy'= mosmkv_preg,
         'Smoking - Early Childhood'= mosmkv_earlych, 
         'Smoking - Childhood'= mosmkv_ch, 
         'Smoking - Adolescence'= mosmkv_adol,
         
         'Shift Work - Pregnancy'= moshiftv_preg,
         'Shift Work - Early Childhood'= moshiftv_earlych, 
         'Shift Work - Childhood'= moshiftv_ch, 
         'Shift Work - Adolescence'= moshiftv_adol,
         
         'Obesity - Pregnancy'= moob_preg,
         'Obesity - Early Childhood'= moob_earlych, 
         'Obesity - Childhood'= moob_ch, 
         'Obesity - Adolescence'= moob_adol
         )

cormat_momcorr <- round(cor(momcorr, method = "spearman", use = "complete.obs"),2)

p.mat_momcorr <- cor_pmat(momcorr)


momcorr_p <- ggcorrplot(cormat_momcorr,
                         type = "lower",
                         lab = TRUE
                         # p.mat = p.mat, 
                         # insig = "blank"
) + 
  labs(title = "B",
       subtitle = "Maternal Factors") +
  theme(axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10))



#########################################################################
#SOCIO
#will all exposure windows: preg, earlych, childhood, adolescence
#########################################################################

sociocorr <- exwindows  %>% 
  select(sesv_preg,  sesv_earlych,  sesv_ch,  sesv_adol) %>% 
  rename('nSES - Pregnancy'= sesv_preg,
  'nSES - Early Childhood'= sesv_earlych, 
  'nSES - Childhood'= sesv_ch, 
  'nSES - Adolescence'= sesv_adol)


cormat_sociocorr <- round(cor(sociocorr, method = "spearman", use = "complete.obs"),2)

p.mat_sociocorr <- cor_pmat(sociocorr)


sociocorr_p <- ggcorrplot(cormat_sociocorr,
                        type = "lower",
                        lab = TRUE
                        # p.mat = p.mat, 
                        # insig = "blank"
) + 
  labs(title = "C",
       subtitle = "nSES") +
  theme(axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10))


#########################################################################
#FOR NOW WILL ALSO CLEAN UP THE RR HERE AND GATHER CASE NUMBERS
#########################################################################
#assess approximate casenumbers and total population

life_cases <- exwindows %>% 
  select(X_Imputation_, id, momid, cohort, chobv_adol, chwestv_ch, chwestv_adol, chstv_ch, chstv_adol, chpav_ch, chpav_adol) %>% 
  drop_na() %>% 
  group_by(X_Imputation_) %>% 
  summarize(cases=sum(chobv_adol), 
            total=n()) %>% 
  mutate(group="life")


#check how many participants with full exposure data developed outcome in childhood versus adolescence
life_cases_2 <- exwindows %>% 
  select(X_Imputation_, id, momid, cohort, chobv_adol, chobv_ch, chwestv_ch, chstv_ch, chpav_ch) %>% 
  filter(!is.na(chwestv_ch) & !is.na(chstv_ch) & !is.na(chpav_ch)) %>% 
  group_by(X_Imputation_) %>% 
  summarize(cases_adol=sum(chobv_adol, na.rm=T),
            cases_ch=sum(chobv_ch, na.rm=T))


mom_cases <- exwindows %>% 
  select(X_Imputation_, id, momid, cohort, chobv_adol, mowestv_preg, mowestv_earlych, mowestv_ch, mowestv_adol,  
         mopav_preg, mopav_earlych, mopav_ch, mopav_adol, moob_preg, moob_earlych, moob_ch, moob_adol) %>% 
  drop_na() %>% 
  group_by(X_Imputation_) %>% 
  summarize(cases=sum(chobv_adol), 
            total=n()) %>% 
  mutate(group="mom")

#check how many participants with full exposure data developed outcome in childhood versus adolescence
mom_cases_2 <- exwindows %>% 
  select(X_Imputation_, id, momid, cohort, chobv_adol, chobv_ch, mowestv_preg, mowestv_earlych, mowestv_ch, mowestv_adol,  
         mopav_preg, mopav_earlych, mopav_ch, mopav_adol, moob_preg, moob_earlych, moob_ch, moob_adol) %>% 
  filter(!is.na(mowestv_preg) & !is.na(mopav_preg) & !is.na(moob_preg)) %>% 
  group_by(X_Imputation_) %>% 
  summarize(cases_adol=sum(chobv_adol, na.rm=T),
            cases_ch=sum(chobv_ch, na.rm=T))


#not maternal factors have less cases because maternal western diet doesn't start until 1991, while other variables start 1989

socio_cases <- exwindows %>% 
  select(X_Imputation_, id, momid, cohort, chobv_adol, sesv_preg, sesv_earlych, sesv_ch, sesv_adol) %>% 
  drop_na() %>% 
  group_by(X_Imputation_) %>% 
  summarize(cases=sum(chobv_adol), 
            total=n()) %>% 
  mutate(group="socio")

socio_cases_2 <- exwindows %>% 
  select(X_Imputation_, id, momid, cohort, chobv_adol, chobv_ch, sesv_preg, sesv_earlych, sesv_ch, sesv_adol) %>% 
  filter(!is.na(sesv_preg)) %>% 
  group_by(X_Imputation_) %>% 
  group_by(X_Imputation_) %>% 
  summarize(cases_adol=sum(chobv_adol, na.rm=T),
            cases_ch=sum(chobv_ch, na.rm=T))

#import datasets both sumulataneously adjusted for prior exposure windows and not
mom <- read_sas("1.data/mom_rr.sas7bdat") 
mom_mob <- read_sas("1.data/mom_mob_rr.sas7bdat") 
life <- read_sas("1.data/life_rr.sas7bdat") 
socio <- read_sas("1.data/socio_rr.sas7bdat") 

mom_adj <- read_sas("1.data/mom_rr_adj.sas7bdat") 
mom_mob_adj <- read_sas("1.data/mom_mob_rr_adj.sas7bdat") 
life_adj <- read_sas("1.data/life_rr_adj.sas7bdat") 
socio_adj <- read_sas("1.data/socio_rr_adj.sas7bdat") 


mom_tidy <- rbind(mom, mom_adj) %>% 
  select(analysis, Parm, mod, group, RR, UCI, LCI, Probt) %>% 
  mutate(across(where(is.numeric), ~ round(., 3))) %>% 
  mutate(exposure=case_when(grepl("mowestv_", Parm) ~ "Maternal Western Diet (trend)",
                            grepl("mowestq1", Parm) ~ "Maternal Western Diet Q2 vs. Q1",
                            grepl("mowestq2", Parm) ~ "Maternal Western Diet Q3 vs. Q1",
                            grepl("mowestq3", Parm) ~ "Maternal Western Diet Q4 vs. Q1",
                            
                            grepl("mopav_", Parm) ~ "Maternal  physical activity (trend)",
                            grepl("mopaq0", Parm) ~ "Maternal physical activity Q1 vs. Q4",
                            grepl("mopaq1", Parm) ~ "Maternal physical activity Q2 vs. Q4",
                            grepl("mopaq2", Parm) ~ "Maternal physical activity Q3 vs. Q4",
                            
                            grepl("mosmk", Parm) ~ "Maternal smoking Ever vs. Never",
                            grepl("moshiftb", Parm) ~ "Maternal Shiftwork Some vs. None"
  ))



mom_mob_tidy <- rbind(mom_mob, mom_mob_adj) %>% 
  select(analysis, Parm, mod, group, RR, UCI, LCI, Probt) %>% 
  mutate(across(where(is.numeric), ~ round(., 2))) %>% 
  mutate(exposure="Maternal Obesity")

  
  
life_tidy <- rbind(life, life_adj) %>% 
  select(analysis, Parm, mod, group, RR, UCI, LCI, Probt) %>% 
  mutate(across(where(is.numeric), ~ round(., 3))) %>% 
  mutate(exposure=case_when(
                            grepl("chwestv_", Parm) ~ "Western Diet (trend)",
                            grepl("chwestq1", Parm) ~ "Western Diet Q2 vs. Q1",
                            grepl("chwestq2", Parm) ~ "Western Diet Q3 vs. Q1",
                            grepl("chwestq3", Parm) ~ "Western Diet Q4 vs. Q1",
                            
                            grepl("chpav_", Parm) ~ "Physical activity (trend)",
                            grepl("chpaq0", Parm) ~ "Physical activity Q1 vs. Q4",
                            grepl("chpaq1", Parm) ~ "Physical activity Q2 vs. Q4",
                            grepl("chpaq2", Parm) ~ "Physical activity Q3 vs. Q4",
                            
                            grepl("chstv_", Parm) ~ "Sedentary time (trend)",
                            grepl("chstq1", Parm) ~ "Sedentary time Q2 vs. Q1",
                            grepl("chstq2", Parm) ~ "Sedentary time Q3 vs. Q1",
                            grepl("chstq3", Parm) ~ "Sedentary time Q4 vs. Q1",
  ))


socio_tidy <- rbind(socio, socio_adj) %>% 
  select(analysis, Parm, mod, group, RR, UCI, LCI, Probt) %>% 
  mutate(across(where(is.numeric), ~ round(., 3))) %>% 
  mutate(exposure=case_when(grepl("sesv_", Parm) ~ "nSES (trend)",
                            grepl("sesq0", Parm) ~ "nSES Q1 vs. Q4",
                            grepl("sesq1", Parm) ~ "nSES Q2 vs. Q4",
                            grepl("sesq2", Parm) ~ "nSES Q3 vs. Q4"))



rr <- rbind(life_tidy, mom_tidy, mom_mob_tidy, socio_tidy) %>% 
  #joing case numbers form first imputation 
  left_join(rbind(life_cases, mom_cases, socio_cases) %>% 
              filter(X_Imputation_==1) %>% select(group, cases, total))
#write_csv(rr, "2.output/rr_exposure_windows.csv")


# rr_tidy <- rr %>% 
#   mutate(RR_CI = paste0(
#     sprintf("%.2f", RR), " (",
#     sprintf("%.2f", LCI), ", ",
#     sprintf("%.2f", UCI), ")"), 
#     group=case_when(group=="life" ~ "Personal", 
#                     group=="mom" ~ "Maternal", 
#                     group=="socio" ~ "Social"))%>% 
#   select(analysis, mod, group, exposure, RR_CI) %>% 
#   pivot_wider(values_from = "RR_CI", names_from = "mod") %>% 
#   select(analysis, group, exposure, preg, earlych, ch, adol) %>% 
#   rename("Pregnancy to <1yr"="preg", 
#          "1yr to <5yrs" = "earlych", 
#          "5yrs to <11yrs"="ch", 
#          "12yrs to <18yrs" = "adol") %>% 
#   filter(analysis==
#            "unadjusted")

#write_csv(rr_tidy, "2.output/rr_exposure_windows.csv")



