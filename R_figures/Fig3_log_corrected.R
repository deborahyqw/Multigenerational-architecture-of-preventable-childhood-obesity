library(dplyr)
library(tidyr)
library(stringr)
library(data.table)
library(ggplot2)
library(ggh4x)
library(patchwork)
library(cowplot)
library(scales)   
library(forcats)
library(ggh4x)   # for facet_grid2 and facetted_pos_scales
library(Cairo)

setwd("/Users/yiqingwang/Dropbox (Partners HealthCare)/MGH/GUTS obesity&cancer/output/")
##############################################################################################
fig3_par_df <- read.csv("Fig3_PAR_revised.csv", check.names = FALSE, header = TRUE)[1:22,] %>%
  mutate(Label = gsub(" risk factors","",Label)) %>%
  mutate(Label = gsub(" score","",Label)) %>%
  mutate(Label = gsub("Maternal Western diet","Western diet (m)",Label)) %>%
  mutate(Label = gsub("Born by cesarean section","Delivery mode",Label)) %>%
  mutate(Label = gsub("Maternal ","",Label)) %>%
  mutate(Label = gsub("excess gestational weight gain\\†","Gestational weight gain†",Label)) %>%
  mutate(Label = gsub("week","age",Label)) %>%
  mutate(Label = Hmisc::capitalize(Label)) %>%
  mutate(Label = gsub("Night shift","Night shift work",Label)) %>%
  mutate(Label = ifelse(category == "Maternal", gsub("Physical activity","Physical activity (m)",Label), Label)) %>%
  mutate(Label = gsub("Physical activity time","Physical activity",Label)) %>%
  mutate(PAF = as.numeric(PAR)) %>%
  mutate(LCI = as.numeric(LCI)) %>%
  mutate(UCI = as.numeric(UCI))


group_colors <- c(
  Personal = "#20854E99",
  Social = "#FFDC91FF",
  Maternal = "#0072B599",
  Intrauterine = "#6F99AD99",
  Total = "white"
)

fig3_par_df <- fig3_par_df %>%
  mutate(category = factor(category, levels = unique(category))) %>%
  group_by(category) %>%
  mutate(
    Label = {
      combined <- Label[grepl("Combined", Label)]
      non_combined <- Label[!grepl("Combined", Label)]
      # sort non-combined in *decreasing* PAR (so plot shows increasing up the axis)
      non_combined <- non_combined[order(-PAF[!grepl("Combined", Label)])]
      factor(Label, levels = c(combined, non_combined))
    }
  ) %>%
  ungroup()


fig3_par <- ggplot(fig3_par_df, aes(x = PAF, y = Label)) +
  geom_point(aes(fill = category), shape = 23, size = 2.5, color = "black") +
  scale_fill_manual(values = group_colors) +
  geom_errorbarh(aes(xmin = LCI, xmax = UCI), width = 0.4, orientation = "y") +
  ggh4x::facet_grid2(
    rows = vars(category),
    scales = "free_y",space="free",
    strip = ggh4x::strip_themed(
      background_y = ggh4x::elem_list_rect(fill = group_colors),
      text_y = ggh4x::elem_list_text(color = "black", size = 9)
    )
  ) +
  theme_bw() +
  theme(
    axis.title.y = element_blank(),
    panel.spacing = unit(1, "lines"),
    axis.text.x = element_text(angle=90, color="black"),
    axis.text.y = element_text(color="black"),
    legend.position = "none"
  )

#############################################################################################

longest_common_prefix <- function(strings) {
  if (length(strings) == 1) return(strings)
  split_strings <- strsplit(strings, " ")
  min_length <- min(sapply(split_strings, length))
  prefix <- character()
  for (i in seq_len(min_length)) {
    chars <- sapply(split_strings, function(x) x[i])
    if (length(unique(chars)) == 1) {
      prefix <- c(prefix, chars[1])
    } else {
      break
    }
  }
  str_trim(paste(prefix, collapse = " "))
}


fig3_df <- read.csv("Fig3_RR_revised.csv", check.names = FALSE, header = TRUE)[1:37,1:10] 

fig3_df_vars <- fig3_df %>%
  select(1,10) %>%
  mutate(
    Exposures = gsub("vs,", "vs.", Exposures),
    Exposures = gsub("obserivy", "obesity", Exposures),
    Exposures = gsub("past smokers", "smoking past", Exposures),
    Exposures = gsub("current smokers", "smoking current", Exposures),
    Reference = str_trim(str_extract(Exposures, "(?<=vs\\. ).*")),
    lead_Exposure = lead(Exposures),
    first_two_words = paste(word(Exposures, 1), word(Exposures, 2)),
    lead_first_two_words = paste(word(lead_Exposure, 1), word(lead_Exposure, 2))
  ) %>%
  rowwise() %>%
  mutate(
    variable = ifelse(
      first_two_words == lead_first_two_words,
      longest_common_prefix(c(Exposures, lead_Exposure)),
      ""
    )
  )  %>%
  ungroup() %>%
  mutate(variable = ifelse(variable != "", variable, lag(variable))) 

fig3_df_vars[fig3_df_vars$Exposures %like% "Maternal pre-pregnancy obesity","variable" ] <- "Maternal pre-pregnancy obesity" 
fig3_df_vars[fig3_df_vars$Exposures %like% "Maternal obesity","variable" ] <- "Maternal obesity" 
fig3_df_vars[fig3_df_vars$Exposures %like% "Born by","variable" ] <- "Born by" 
fig3_df_vars[fig3_df_vars$Exposures %like% "Maternal pregnancy complication","variable" ] <- "Maternal pregnancy complication" 
fig3_df_vars[fig3_df_vars$Exposures %like% "Maternal excess gestational weight gain","variable" ] <- "Maternal gestational weight gain" 


fig3_df_vars <- fig3_df_vars %>%
  select(-lead_Exposure, -first_two_words, -lead_first_two_words) %>%
  mutate(
    ComparedLevel = str_trim(
      str_remove(Exposures, paste0("^", variable, "\\s*"))
    ) %>%
      str_remove(paste0("\\s+vs\\.\\s*", Reference, "$"))
  )

fig3_df_vars[fig3_df_vars$Exposures %like% "Maternal excess gestational weight gain","ComparedLevel" ] <- "excess" 
fig3_df_vars[fig3_df_vars$Exposures %like% "Maternal pregnancy complication ","ComparedLevel" ] <- "complication" 
fig3_df_vars[fig3_df_vars$Exposures %like% "Maternal pre-pregnancy obesity ","ComparedLevel" ] <- "obesity" 
fig3_df_vars[fig3_df_vars$Exposures %like% "Maternal obesity ","ComparedLevel" ] <- "obesity" 
fig3_df_vars <- fig3_df_vars %>%
  mutate(variable = gsub(" score", "",variable)) %>%
  mutate(variable = gsub(" index", "",variable)) %>%
  mutate(variable = gsub("Gestational week", "Gestational age",variable)) %>%
  mutate(variable = gsub("night shift hours", "Night shift work",variable)) %>%
  mutate(variable = gsub("Born by", "Delivery mode",variable)) %>%
  mutate(variable = gsub("Physical activity time", "Physical activity",variable))

fig3_input <- cbind(fig3_df[,2:6],fig3_df_vars[,2:5]) %>%
  select(variable, ComparedLevel, Reference, RR, RRLCI, RRUCI, Cat) %>%
  mutate(across(c(RR, RRLCI, RRUCI), as.numeric)) %>%
  pivot_longer(cols = c(RR, RRLCI, RRUCI), names_to = "Type", values_to = "Value") %>%
  mutate(
    Label = case_when(
      Type == "RR" ~ ComparedLevel,
      Type == "RRLCI" ~ paste0(ComparedLevel, "-LCI"),
      Type == "RRUCI" ~ paste0(ComparedLevel, "-UCI")
    )
  ) %>%
  select(variable, Value, Label, Cat)


# Step 5: Add reference rows
ref_rows <- cbind(fig3_df[,2:6],fig3_df_vars[,2:5]) %>%
  select(variable,Reference, Cat) %>%
  distinct() %>%
  mutate(
    Value = 1,
    Label = Reference
  ) %>%
  select(variable, Value, Label, Cat)

fig3_input <- rbind(fig3_input, ref_rows) %>%
  arrange(variable, Label)


##  Put CIs in different columns
df_wide <- fig3_input %>%
  mutate(
    Label_clean = str_remove(Label, "-LCI|-UCI"),
    EstType = case_when(
      str_detect(Label, "-LCI") ~ "LCI",
      str_detect(Label, "-UCI") ~ "UCI",
      TRUE ~ "RR"
    )
  ) %>%
  select(variable, Label_clean, Value, EstType, Cat) %>%
  pivot_wider(
    names_from = EstType,
    values_from = Value
  ) %>%
  arrange(variable, Label_clean) %>%
  group_by(variable) %>%
  mutate(Label_clean = factor(Label_clean, levels = unique(Label_clean)))

group_colors <- c(
  Personal = "#20854E99",
  Social = "#FFDC91FF",
  Maternal = "#0072B599",
  Intrauterine = "#6F99AD99"
)

df_wide <- as.data.frame(df_wide) %>%
  mutate(variable = gsub("Maternal ","",variable)) %>%
  mutate(variable = Hmisc::capitalize(variable)) %>%
  mutate(variable = gsub("gain","gain†",variable)) %>%
  mutate(variable = ifelse(Cat == "Maternal", gsub("activity", 'activity (m)', variable),variable)) %>%
  mutate(variable = ifelse(Cat == "Maternal", gsub("diet", 'diet (m)', variable),variable))

##############################################################################
# Extract the Cat you want to plot
cat_name <- "Maternal"
cat_color <- group_colors[cat_name]
# Subset the data
plot_data_maternal <- df_wide[df_wide$Cat == cat_name, ] %>%
  mutate(Label_clean = gsub("no obesity","no",Label_clean)) %>%
  mutate(Label_clean = gsub("obesity","yes",Label_clean))

plot_data_maternal <- plot_data_maternal %>%
  mutate(Label_clean = as.character(Label_clean)) %>%
  group_by(variable) %>%
  mutate(
    Label_clean = {
      ref <- Label_clean[RR == 1.00]   # referent
      others <- Label_clean[!(RR == 1.00 | is.na(RR))][order(RR[!(RR == 1.00 | is.na(RR))])]
      factor(Label_clean, levels = c(ref, others))
    }
  ) %>%
  ungroup()

maternal_levels <- fig3_par_df %>%
  filter(category == "Maternal", !grepl("Combined", Label)) %>%
  arrange(PAR) %>%
  pull(Label) %>%
  as.character()

plot_data_maternal <- plot_data_maternal %>%
  mutate(variable = factor(as.character(variable), levels = maternal_levels))

# 1) Numeric order per variable
plot_data_maternal <- plot_data_maternal %>%
  mutate(
    x_order = case_when(
      # Physical activity (m): Q4 -> Q1 (reversed; Q4 ref)
      variable == "Physical activity (m)" & Label_clean == "Q4" ~ 1,
      variable == "Physical activity (m)" & Label_clean == "Q3" ~ 2,
      variable == "Physical activity (m)" & Label_clean == "Q2" ~ 3,
      variable == "Physical activity (m)" & Label_clean == "Q1" ~ 4,
      
      # Night shift work: Q1 -> Q4 (Q1 ref)
      variable == "Night shift work" & Label_clean == "Q1" ~ 1,
      variable == "Night shift work" & Label_clean == "Q2" ~ 2,
      variable == "Night shift work" & Label_clean == "Q3" ~ 3,
      variable == "Night shift work" & Label_clean == "Q4" ~ 4,
      
      # Western diet (m): Q1 -> Q4 (Q1 ref)
      variable == "Western diet (m)" & Label_clean == "Q1" ~ 1,
      variable == "Western diet (m)" & Label_clean == "Q2" ~ 2,
      variable == "Western diet (m)" & Label_clean == "Q3" ~ 3,
      variable == "Western diet (m)" & Label_clean == "Q4" ~ 4,
      
      # Smoking: never -> past -> current
      variable == "Smoking" & Label_clean == "never"   ~ 1,
      variable == "Smoking" & Label_clean == "past"    ~ 2,
      variable == "Smoking" & Label_clean == "current" ~ 3,
      
      # Obesity: no -> yes
      variable == "Obesity" & Label_clean == "no"  ~ 1,
      variable == "Obesity" & Label_clean == "yes" ~ 2,
      
      # Fallback: keep original order within facet
      TRUE ~ NA_real_
    )
  ) %>%
  group_by(variable) %>%
  mutate(
    x_order = ifelse(
      is.na(x_order),
      as.numeric(factor(Label_clean, levels = unique(Label_clean))),
      x_order
    )
  ) %>%
  ungroup()

# 2) Plot using x_order (numeric)
p <- ggplot(plot_data_maternal, aes(x = x_order, y = RR)) +
  geom_point(shape = 23, size = 2, color = "black", fill = cat_color) +
  geom_errorbar(aes(ymin = LCI, ymax = UCI), color = "black", width = 0.3) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray30") +
  facet_grid2(
    cols = vars(variable),
    scales = "free_x", space = "free_x",
    strip = strip_themed(
      background_x = elem_list_rect(fill = rep(cat_color, length(unique(plot_data_maternal$variable)))),
      text_x       = elem_list_text(color = "black", size = 9)
    )
  ) +
  scale_y_continuous(
    trans  = log_trans(base = exp(1)),
    breaks = c(0.5, 0.67, 1, 1.5, 2, 3, 4),
    labels = label_number(accuracy = 0.01),
    expand = expansion(add = c(0.15, 0.15)),
    name   = "RR"
  ) +
  theme_bw() +
  theme(
    axis.text.x  = element_text(angle = 45, hjust = 1, color = "black"),
    axis.title.x = element_blank()
  )

# 3) Facet-specific x-axis labels (this is the key) - seems like it is by sequence not by matching with the correct labels
maternal_facets <- p + ggh4x::facetted_pos_scales(
  x = list(
    "Physical activity (m)" = scale_x_continuous(
      breaks = 1:4, labels = c("Q1","Q2","Q3","Q4"), expand = expansion(add = 0.3)
    ),
    "Night shift work" = scale_x_continuous(
      breaks = 1:4, labels = c("Q1","Q2","Q3","Q4"), expand = expansion(add = 0.3)
    ),
    "Western diet (m)" = scale_x_continuous(
      breaks = 1:2, labels = c("no","yes"), expand = expansion(add = 0.3)
    ),
    "Smoking" = scale_x_continuous(
      breaks = 1:4, labels = c("Q4","Q3","Q2","Q1"), expand = expansion(add = 0.3)
    ),
    "Obesity" = scale_x_continuous(
      breaks = 1:3, labels = c("never","past","current"), expand = expansion(add = 0.3)
    )
  )
)

################################################################################
# Extract the Cat you want to plot
cat_name <- "Personal"
cat_color <- group_colors[cat_name]
# Subset the data
plot_data_personal <- df_wide[df_wide$Cat == cat_name, ]

plot_data_personal$Label_clean <- factor(plot_data_personal$Label_clean, levels=c("Q1","Q2","Q3","Q4"))

personal_levels <- fig3_par_df %>%
  filter(category == "Personal", !grepl("Combined", Label)) %>%
  arrange(PAR) %>%
  pull(Label) %>%
  as.character()

plot_data_personal <- plot_data_personal %>%
  mutate(variable = factor(as.character(variable), levels = personal_levels))

#plot_data_personal$Label_clean <- factor(as.character(plot_data_personal$Label_clean), levels=c("Q1","Q2","Q3","Q4"))
plot_data_personal <- plot_data_personal %>%
  mutate(
    x_order = case_when(
      variable == "Physical activity" & Label_clean == "Q4" ~ 1,
      variable == "Physical activity" & Label_clean == "Q3" ~ 2,
      variable == "Physical activity" & Label_clean == "Q2" ~ 3,
      variable == "Physical activity" & Label_clean == "Q1" ~ 4,
      Label_clean == "Q1" ~ 1,
      Label_clean == "Q2" ~ 2,
      Label_clean == "Q3" ~ 3,
      Label_clean == "Q4" ~ 4,
      TRUE ~ NA_real_
    )
  )

# Plot using numeric x values, and relabel ticks manually to reverse the order of physical activity
personal_facets <- ggplot(plot_data_personal, aes(x = x_order, y = RR)) +
  geom_point(shape = 23, size = 2, color = "black", fill = cat_color) +
  geom_errorbar(aes(ymin = LCI, ymax = UCI), color = "black", width = 0.3) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray30") +
  facet_grid2(
    cols = vars(variable),
    scales = "free_x",
    strip = strip_themed(
      background_x = elem_list_rect(fill = rep(cat_color, length(unique(plot_data_personal$variable)))),
      text_x = elem_list_text(color = "black", size = 9)
    )
  ) +
  scale_x_continuous(
    breaks = c(1, 2, 3, 4),
    labels = c("Q4", "Q3", "Q2", "Q1"),   # Show reversed labels
    expand = expansion(add = 0.3)
  ) +
  scale_y_continuous(
    trans   = scales::log_trans(base = exp(1)),
    breaks  = c(0.5, 0.67, 1, 1.5, 2, 3, 4),
    labels  = scales::label_number(accuracy = 0.01),
    expand  = expansion(add = c(0.15, 0.15)),
    name    = "RR"
  ) +
  theme_bw() +
  theme(
    axis.text.x  = element_text(angle = 45, hjust = 1, color = "black"),
    axis.title.x = element_blank()
  )

##############################################################################
# Extract the Cat you want to plot
cat_name <- "Intrauterine"
cat_color <- group_colors[cat_name]
# Subset the data
plot_data_intra <- df_wide[df_wide$Cat == cat_name, ]

plot_data_intra <- plot_data_intra %>%
  mutate(Label_clean = gsub("vaginal delivery","vaginal", Label_clean)) %>%
  mutate(Label_clean = gsub("cesarean section","C-section", Label_clean)) %>%
  mutate(Label_clean = gsub("no obesity","no",Label_clean)) %>%
  mutate(Label_clean = gsub("obesity","yes",Label_clean)) %>%
  mutate(Label_clean = gsub(" gain†","",Label_clean)) %>%
  mutate(Label_clean = gsub("no complication","no",Label_clean)) %>%
  mutate(Label_clean = gsub("complication","yes",Label_clean))

intra_levels <- fig3_par_df %>%
  filter(category == "Intrauterine", !grepl("Combined", Label)) %>%
  arrange(PAR) %>%
  pull(Label) %>%
  as.character()

plot_data_intra <- plot_data_intra %>%
  mutate(variable = factor(as.character(variable), levels = intra_levels))


plot_data_intra <- plot_data_intra %>%
  mutate(Label_clean = as.character(Label_clean)) %>%
  group_by(variable) %>%
  mutate(
    Label_clean = {
      ref <- Label_clean[RR == 1.00]   # referent
      others <- Label_clean[!(RR == 1.00 | is.na(RR))][order(RR[!(RR == 1.00 | is.na(RR))])]
      factor(Label_clean, levels = c(ref, others))
    }
  ) %>%
  ungroup()      

# Create the plot
intra_facets <- ggplot(plot_data_intra, aes(x = Label_clean, y = RR)) +
  geom_point(shape = 23, size = 2, color = "black", fill=cat_color) +
  geom_errorbar(aes(ymin = LCI, ymax = UCI), color = "black", width=0.3) + 
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray30") +
  facet_grid2(
    cols = vars(variable),
    scales = "free_x",
    labeller = labeller(variable = label_wrap_gen(width = 12)),
    strip = strip_themed(
      background_x = elem_list_rect(fill = rep(cat_color, length(unique(plot_data_intra$variable)))),
      text_x = elem_list_text(color = "black", size=9)
    )
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1,color="black")
  ) +xlab("Quartiles or categories") +
  scale_y_continuous(
    trans   = scales::log_trans(base = exp(1)),   # natural log spacing (use log10_trans() if you prefer)
    breaks  = c(0.5, 0.67, 1, 1.5, 2, 3, 4),      # pick values that suit your data
    labels  = label_number(accuracy = 0.01),
    expand  = expansion(add = c(0.15, 0.15)),
    name    = "RR"
  )

###################################################################################
# Extract the Cat you want to plot
cat_name <- "Social"
cat_color <- group_colors[cat_name]
# Subset the data
plot_data_socio <- df_wide[df_wide$Cat == cat_name, ]

socio_levels <- fig3_par_df %>%
  filter(category == "Social", !grepl("Combined", Label)) %>%
  arrange(PAR) %>%
  pull(Label) %>%
  as.character()

plot_data_socio <- plot_data_socio %>%
  mutate(variable = factor(as.character(variable), levels = socio_levels))

plot_data_socio <- plot_data_socio %>%
  mutate(Label_clean = gsub("graduate","grad",Label_clean)) %>%
  mutate(Label_clean = gsub("high school and below","≤ high school",Label_clean)) %>%
  mutate(Label_clean = as.character(Label_clean)) %>%
  group_by(variable) %>%
  mutate(
    Label_clean = {
      ref <- Label_clean[RR == 1.00]   # referent
      others <- Label_clean[!(RR == 1.00 | is.na(RR))][order(RR[!(RR == 1.00 | is.na(RR))])]
      factor(Label_clean, levels = c(ref, others))
    }
  ) %>%
  ungroup()       


# Create the plot
socio_facets <- ggplot(plot_data_socio, aes(x = Label_clean, y = RR)) +
  geom_point(shape = 23, size = 2, color = "black", fill=cat_color) +
  geom_errorbar(aes(ymin = LCI, ymax = UCI), color = "black", width=0.3) + 
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray30") +
  facet_grid2(
    cols = vars(variable),
    scales = "free_x",
    strip = strip_themed(
      background_x = elem_list_rect(fill = rep(cat_color, length(unique(plot_data_socio$variable)))),
      text_x = elem_list_text(color = "black", size=9)
    )
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1,color="black"),
    axis.title.x = element_blank() 
  )+ 
  scale_y_continuous(
    trans   = scales::log_trans(base = exp(1)),   # natural log spacing (use log10_trans() if you prefer)
    breaks  = c(0.5, 0.67, 1, 1.5, 2, 3, 4),      # pick values that suit your data
    labels  = label_number(accuracy = 0.01),
    expand  = expansion(add = c(0.15, 0.15)),
    name    = "RR"
  )

fig3_rr <- plot_grid(
  personal_facets,
  socio_facets,
  maternal_facets,
  intra_facets,
  ncol = 1,                 # stack vertically
  align = "v",              # align vertically
  axis = "l",               # align left edges
  rel_heights = c(1.35, 1.75, 1.75, 2.75)
)


#myplot <- plot_grid(fig3_rr, fig3_par, align="v", axis = c("bt"), rel_widths = c(1, 0.5))
ggsave("Figure3_RR.pdf", plot=fig3_rr, family = "Helvetica", width = 7.3, height = 10)
ggsave("Figure3_PAR.pdf", plot=fig3_par, family = "Helvetica", width = 5, height = 6)


CairoPDF("Figure 3.pdf", family = "Helvetica", width = 10.83, height = 10)
#plot_grid(fig3_rr, fig3_par, align="v", axis = c("bt"), rel_widths = c(1, 0.5))
plot_grid(
  fig3_rr, fig3_par,
  ncol = 2,
  labels = c("A", "B"),
  label_size = 16,
  label_fontface = "bold",
  label_colour = "black",
  label_x = 0.01,  # x position within each panel (0 = left)
  label_y = 0.99,  # y position within each panel (1 = top)
  hjust = 0, vjust = 1,
  align = "v",
  axis = "bt",
  rel_widths = c(1, 0.5)
)
dev.off()





