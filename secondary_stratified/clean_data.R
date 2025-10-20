

#####################################################
#CODE DOCUMENTATION
#####################################################/*
#Program name: /udd/nhywa/GUTSOB/secondary_stratified/
#Pogrammer: Bethsaida Cardona (n2bca)
#Date started: 07/2025
#Program Purpose: Prepare stratified analysis data for export, including RR and PAR for stratified groups 
#(by sex, age, maternal obesity status) and the p-value for heterogeneity obtained from metanalysis

#####################################################
#Program Setup
#####################################################
library(corrplot)
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(tidyverse)
library(foreign)
library(haven)
library(scales)
library(ggplot2)
library(ggstance) #for geom_pointrangeh function

#set working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("1.data")

rm(list=ls())

getwd()
#####################################################
#gather RR For each of the stratified groups
#####################################################
file.list <- list.files(pattern="_rr")
df.list <- lapply(file.list, read_sas)
df <- bind_rows(df.list, .id = "id")
df$id <- as.numeric(df$id)
df$parameter <- NA

for (i in 1:length(df.list)) {
  # Remove the file extension
  filename_clean <- sub("\\.sas7bdat$", "", file.list[i])
  
  # Split the cleaned filename by underscore
  parts <- strsplit(filename_clean, "_")[[1]]
  
  # Assign to appropriate columns in df
  df[df$id == i, 'parameter']  <- parts[3]
}

RR_dat <- df %>% 
  filter(!grepl("trend", mod)) %>%
  rename(subgroup=group) %>% 
  mutate(group = case_when(subgroup %in% c("male", "female")~ "sex", 
                           subgroup %in% c("child", "teen")~ "age", 
                           subgroup %in% c("moob", "nomoob")~ "mob")) %>% 
  select(parameter, Parm, mod, group, subgroup, RR, LCI, UCI) %>% 
  rename(exposure=Parm) %>% 
  mutate(across(where(is.numeric), ~ round(., 5))) 


#####################################################
#gather PAR For each of the stratified groups
#####################################################
rm(list=ls()[! ls() %in% c("RR_dat")])
file.list <- list.files(pattern="_par")
df.list <- lapply(file.list, read_sas)
df <- bind_rows(df.list, .id = "id")
df$id <- as.numeric(df$id)
df$mod <- NA
df$parameter <- NA

for (i in 1:length(df.list)) {
  # Remove the file extension
  filename_clean <- sub("\\.sas7bdat$", "", file.list[i])
  
  # Split the cleaned filename by underscore
  parts <- strsplit(filename_clean, "_")[[1]]
  
  # Assign to appropriate columns in df
  df[df$id == i, 'mod']  <- parts[1]
  df[df$id == i, 'parameter']     <- parts[3]
}

PAR_dat <- df %>% 
  rename(subgroup=group, PAR_estimate=Estimate, PAR_min=Min, PAR_max=Max) %>% 
  mutate(group = case_when(subgroup %in% c("male", "female")~ "sex", 
                           subgroup %in% c("child", "teen")~ "age", 
                           subgroup %in% c("moob", "nomoob")~ "mob")) %>% 
  select(parameter, mod, group, subgroup, exposure, PAR_estimate, PAR_min, PAR_max) %>% 
  mutate(across(where(is.numeric), ~ round(., 5))) 



#####################################################
#GATHER Q STATISTICS AND P-FOR HETEROGENEITY...
#####################################################
rm(list=ls()[! ls() %in% c("RR_dat", "PAR_dat")])
file.list <- list.files(pattern="(par_|rr_)")
df.list <- lapply(file.list, read_sas)
df <- bind_rows(df.list, .id = "id")
df$id <- as.numeric(df$id)
df$parameter <- NA
df$mod <- NA
df$exposure <- NA
df$group <- NA

for (i in 1:length(df.list)) {
  # Remove the file extension
  filename_clean <- sub("\\.sas7bdat$", "", file.list[i])
  
  # Split the cleaned filename by underscore
  parts <- strsplit(filename_clean, "_")[[1]]
  
  # Assign to appropriate columns in df
  df[df$id == i, 'parameter'] <- parts[1]
  df[df$id == i, 'mod']  <- parts[2]
  df[df$id == i, 'exposure']  <- parts[3]
  df[df$id == i, 'group']     <- parts[4]
}

meta_RR_random <- df %>% filter(shortname == "OR/RR (R)") %>%
  select(parameter, mod, group, exposure, varvalue, pvalue) 

meta_PAR_random <- df %>% filter(shortname == "Coeff" & varlabel == "Coefficient from random effects model (SE)") %>%
  select(parameter, mod, group, exposure, varvalue, pvalue) %>% 
  mutate(across(where(is.numeric), ~ round(., 3))) 
  
Q_dat <- df %>% filter(shortname == "Q") %>%
  select(parameter, mod, group, exposure, varvalue, pvalue) %>% 
  rename(Q_stat=varvalue, 
         p_het=pvalue) %>% 
  mutate(exposure=ifelse(exposure=="delivery", "Delivery", exposure)) %>% 
  mutate(across(where(is.numeric), ~ round(., 5))) 

#####################################################
#MERGE THE RR/PAR with the P for heterogeneity
#####################################################
rm(list=ls()[! ls() %in% c("RR_dat", "PAR_dat", "Q_dat")])

dict <- read_csv("/udd/nhywa/GUTSOB/secondary_stratified/1.data/data_dictionary.csv")

RR_Q_dat <- RR_dat %>% 
  filter(parameter=="rr") %>% 
  left_join(Q_dat, by=c("mod", "parameter", "group", "exposure")) %>% 
  filter(!is.na(Q_stat)) 

#write.csv(RR_Q_dat,"/udd/nhywa/GUTSOB/secondary_stratified/2.output/RR_Q_dat.csv")


PAR_Q_dat <- PAR_dat %>% 
  filter(parameter=="par") %>% 
  left_join(Q_dat, by=c("mod", "parameter", "group", "exposure")) 

#write.csv(PAR_Q_dat,"/udd/nhywa/GUTSOB/secondary_stratified/2.output/PAR_Q_dat.csv")


#Adjust datasets further for supplementary tables###############################

#RR
RR_Q_dat_tidy <- RR_Q_dat %>% 
  mutate(across(where(is.numeric), ~ round(., 2))) %>% 
  mutate(RR_CI = paste0(
    sprintf("%.2f", RR), " (",
    sprintf("%.2f", LCI), ", ",
    sprintf("%.2f", UCI), ")"
  )) %>% 
  left_join(dict %>% filter(type=="single"), 
            by=c("exposure"="exposure_abbrv")) %>% 
  arrange(order) %>% 
  select (-c(parameter, RR, LCI, UCI, Q_stat, exposure, mod, type, order)) %>% 
  rename("exposure"="exposure_full")


RR_Q_dat_sex <- RR_Q_dat_tidy %>% 
  filter(group=="sex") %>% 
  pivot_wider(names_from = "subgroup", values_from= "RR_CI") %>% 
  select(category, exposure, male, female, p_het) %>% 
  rename("Male RR (95% CI)"="male",
         "Female RR (95% CI)"="female", 
         "p-value* (RR/sex)"="p_het")

RR_Q_dat_age <- RR_Q_dat_tidy %>% 
  filter(group=="age") %>% 
  pivot_wider(names_from = "subgroup", values_from= "RR_CI") %>% 
  select(category, exposure, child, teen, p_het) %>% 
  rename("Child RR (95% CI)"="child",
         "Teen RR (95% CI)"="teen", 
         "p-value* (RR/age)"="p_het")

  
RR_Q_dat_mob <- RR_Q_dat_tidy %>% 
  filter(group=="mob") %>% 
  pivot_wider(names_from = "subgroup", values_from= "RR_CI") %>% 
  select(category, exposure, moob, nomoob, p_het) %>% 
  rename("Mom Obese RR (95% CI)"="moob",
         "Mom Not Obese RR (95% CI)"="nomoob", 
         "p-value* (RR/mob)"="p_het")


#PAR
PAR_Q_dat_tidy <- PAR_Q_dat %>% 
  mutate_at(.vars = vars(PAR_estimate, PAR_min, PAR_max),
            .funs = ~ . * 100) %>% 
  mutate(across(where(is.numeric), ~ round(., 2))) %>% 
  mutate(PAR_range = paste0(
    sprintf("%.2f", PAR_estimate), " (",
    sprintf("%.2f", PAR_min), ", ",
    sprintf("%.2f", PAR_max), ")"
  )) %>% 
  left_join(dict, 
            by=c("exposure"="exposure_abbrv"), relationship = "many-to-many") %>% 
  arrange(desc(type), order) %>% 
  select (-c(parameter, PAR_estimate, PAR_min, PAR_max, Q_stat, exposure, mod, type, order)) %>% 
  rename("exposure"="exposure_full") 



PAR_Q_dat_sex <- PAR_Q_dat_tidy %>% 
  filter(group=="sex") %>% 
  pivot_wider(names_from = "subgroup", values_from= "PAR_range") %>% 
  select(category, exposure, male, female, p_het) %>% 
  mutate(male=ifelse(male=="0.00 (0.00, 0.00)", NA, male), 
         female=ifelse(female=="0.00 (0.00, 0.00)", NA, female),
         p_het=ifelse(male=="0.00 (0.00, 0.00)" | female=="0.00 (0.00, 0.00)", NA, p_het)) %>% 
  rename("Male PAR (95% CI)"="male",
         "Female PAR (95% CI)"="female", 
         "p-value* (PAR/sex)"="p_het")


PAR_Q_dat_age <- PAR_Q_dat_tidy %>% 
  filter(group=="age") %>% 
  pivot_wider(names_from = "subgroup", values_from= "PAR_range") %>% 
  select(category, exposure, child, teen, p_het) %>% 
  mutate(child=ifelse(child=="0.00 (0.00, 0.00)", NA, child), 
         teen=ifelse(teen=="0.00 (0.00, 0.00)", NA, teen),
         p_het=ifelse(child=="0.00 (0.00, 0.00)" | teen=="0.00 (0.00, 0.00)", NA, p_het)) %>% 
  rename("Child PAR (95% CI)"="child",
         "Teen PAR (95% CI)"="teen", 
         "p-value* (PAR/age)"="p_het")


PAR_Q_dat_mob <- PAR_Q_dat_tidy %>% 
  filter(group=="mob") %>% 
  pivot_wider(names_from = "subgroup", values_from= "PAR_range") %>% 
  select(category, exposure, moob, nomoob, p_het) %>% 
  mutate(moob=ifelse(moob=="0.00 (0.00, 0.00)", NA, moob), 
         nomoob=ifelse(nomoob=="0.00 (0.00, 0.00)", NA, nomoob),
         p_het=ifelse(moob=="0.00 (0.00, 0.00)" | nomoob=="0.00 (0.00, 0.00)", NA, p_het)) %>% 
  rename("Mom Obese PAR (95% CI)"="moob",
         "Mom Not Obese PAR (95% CI)"="nomoob", 
         "p-value* (PAR/mob)"="p_het")

#PREPARE SUPPLEMENTARY TABLES FOR EXPORT###############################


all <- PAR_Q_dat_sex %>% 
  left_join(RR_Q_dat_sex, by = join_by(category, exposure)) %>% 
  left_join(PAR_Q_dat_age, by = join_by(category, exposure)) %>% 
  left_join(RR_Q_dat_age, by = join_by(category, exposure)) %>% 
  left_join(PAR_Q_dat_mob, by = join_by(category, exposure)) %>% 
  left_join(RR_Q_dat_mob, by = join_by(category, exposure)) %>% 
  mutate(across(where(is.numeric), ~ paste0('="', sprintf("%.2f", .), '"'))) #to keep trailing zeros in numeric variables when opening csv files


#write.csv(all,"/udd/nhywa/GUTSOB/secondary_stratified/2.output/supp_table_data.csv", quote = TRUE, row.names=FALSE)


