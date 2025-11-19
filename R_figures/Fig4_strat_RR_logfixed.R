library(dplyr)
library(tidyr)
library(stringr)
library(data.table)
library(ggplot2)
library(ggh4x)
library(patchwork)
library(cowplot)

setwd("/Users/yiqingwang/Dropbox (Partners HealthCare)/MGH/GUTS obesity&cancer/output/")
##############################################################################################

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

##############################################################################################

fig4_df <- read.csv("Fig4_stratRR_revised.csv")[,3:11]
names(fig4_df)[1] <- "Exposure"
#fig4_df <- fig4_df %>%
#  mutate(category = gsub("Social","Socioeconomic",category))

fig4_df_vars <- fig4_df %>%
  select(1,2,3,9) %>%
  mutate(Exposure = gsub("vs,","vs.",Exposure)) %>%
  mutate(
    Reference = str_trim(str_extract(Exposure, "(?<=vs\\. ).*")),
    lead_Exposure = lead(Exposure),
    first_two_words = paste(word(Exposure, 1), word(Exposure, 2)),
    lead_first_two_words = paste(word(lead_Exposure, 1), word(lead_Exposure, 2))
  ) %>%
  rowwise() %>%
  mutate(
    variable = ifelse(
      first_two_words == lead_first_two_words,
      longest_common_prefix(c(Exposure, lead_Exposure)),
      ""
    )
  )  %>%
  ungroup() %>%
  mutate(variable = ifelse(variable != "", variable, lag(variable))) 

fig4_df_vars <- fig4_df_vars %>%
  mutate(variable = gsub("Gestational weight gain excess vs. normal","Gestational weight gain†", variable)) %>%
  mutate(variable = gsub("Night-shift","Night shift", variable)) %>%
  mutate(variable = gsub("Pre-pregnancy obesity yes vs. no","Pre-pregnancy obesity", variable)) %>%
  mutate(variable = gsub("Obesity yes vs. no","Obesity", variable)) %>%
  mutate(variable = ifelse(Exposure %like% "Smoking", "Smoking", 
                           ifelse(Exposure %like% "Delivery mode", "Delivery mode", 
                                  ifelse(Exposure %like% "complication", "Pregnancy complication",variable))))

fig4_df_vars <- fig4_df_vars %>%
  select(-lead_Exposure, -first_two_words, -lead_first_two_words) %>%
  mutate(
    ComparedLevel = str_trim(
      str_remove(Exposure, paste0("^", fixed(variable), "\\s*"))
    ) %>%
      str_remove(paste0("\\s+vs\\.\\s*", fixed(Reference), "$"))
  )

fig4_df_vars <- fig4_df_vars %>%
  mutate(ComparedLevel = str_replace(ComparedLevel, ".*\\(m\\)\\s*", "")) %>%
  mutate(ComparedLevel = gsub("Night-shift work ","",ComparedLevel)) %>%
  mutate(ComparedLevel = gsub("Gestational weight gain excess","excess",ComparedLevel)) 

fig4_input <- cbind(fig4_df[,4:7],fig4_df_vars[,2:7]) %>%
  select(variable, ComparedLevel, Reference, group, subgroup, RR, LCI, UCI, category) %>%
  mutate(across(c(RR, LCI, UCI), as.numeric)) %>%
  pivot_longer(cols = c(RR, LCI, UCI), names_to = "Type", values_to = "Value") %>%
  mutate(
    Label = case_when(
      Type == "RR" ~ ComparedLevel,
      Type == "LCI" ~ paste0(ComparedLevel, "-LCI"),
      Type == "UCI" ~ paste0(ComparedLevel, "-UCI")
    )
  ) %>%
  select(variable, Value, Label, category, group, subgroup)

ref_rows <- cbind(fig4_df[,4:7],fig4_df_vars[,2:7]) %>%
  select(variable,Reference,category, group, subgroup) %>%
  distinct() %>%
  mutate(
    Value = 1,
    Label = Reference
  ) %>%
  select(variable, Value, Label, category, group, subgroup)

fig4_input <- rbind(fig4_input, ref_rows) %>%
  arrange(variable, Label)

##  Put CIs in different columns
df_wide <- fig4_input %>%
  filter(!is.na(Label)) %>%
  mutate(
    Label_clean = str_remove(Label, "-LCI|-UCI"),
    EstType = case_when(
      str_detect(Label, "-LCI") ~ "LCI",
      str_detect(Label, "-UCI") ~ "UCI",
      TRUE ~ "RR"
    )
  ) %>%
  select(variable, Label_clean, Value, EstType, category, group, subgroup) %>%
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


df_wide <- df_wide %>%
  mutate(RR = RR) %>%
  mutate(UCI = UCI) %>%
  mutate(LCI = LCI) %>%
  group_by(variable, subgroup) %>%
  mutate(
    Label_clean = {
      ref <- Label_clean[RR == 1]   # referent
      others <- Label_clean[!(RR == 1 | is.na(RR))][order(RR[!(RR == 1 | is.na(RR))])]
      factor(Label_clean, levels = c(ref, others))
    }
  ) %>%
  ungroup()

df_wide <- df_wide %>%
  mutate(subgroup = gsub("nomoob","no maternal obesity",subgroup)) %>%
  mutate(subgroup = gsub("moob","maternal obesity",subgroup)) %>%
  mutate(subgroup = Hmisc::capitalize(subgroup)) %>%
  mutate(subgroup = factor(subgroup, levels=c("Child","Teen","Male","Female","Maternal obesity", "No maternal obesity"))) %>%
  mutate(group = ifelse(group == "age", "Age", ifelse(group == "sex", "Sex","Maternal obesity"))) %>%
  mutate(group = factor(group, levels = c("Age","Sex","Maternal obesity")))

##############################################################################################

### Plot

##############################################################################################
##############################################################################################
### maternal
##############################################################################################
df_input <- df_wide[df_wide$category == "Maternal",]
variables <- unique(df_input$variable)

make_var_plot <- function(df, var, show_col_strips = TRUE, group_colors) {
  # Identify category color
  cat <- unique(df$category[df$variable == var])
  strip_fill <- group_colors[cat]
  
  # Colors for subgroup points
  fill_vals <- c(
    "Child" = "black", "Teen" = "red",
    "Male" = "black", "Female" = "red",
    "Maternal obesity" = "black", "No maternal obesity" = "red"
  )
  
  # Subset to the one variable row this function will plot (1 x N facets)
  df_sub <- df[df$variable == var, ] %>%
    mutate(Label_clean = gsub("no obesity","no",Label_clean),
           Label_clean = gsub("obesity","yes",Label_clean),
           Label_clean = as.character(Label_clean))
  
  # Ensure consistent COLUMN order (left -> right) across all variables
  # If you've already set levels for group globally, this will respect them.
  grp_order <- levels(df$group)
  if (is.null(grp_order)) grp_order <- unique(df$group)
  df_sub <- df_sub %>% mutate(group = factor(group, levels = grp_order))
  
  # =============== 1) Assign numeric x_order per variable ===============
  df_sub <- df_sub %>%
    mutate(
      x_order = case_when(
        # Physical activity (m): reversed Q4→Q1 (Q4 ref)
        variable == "Physical activity (m)" & Label_clean == "Q4" ~ 1,
        variable == "Physical activity (m)" & Label_clean == "Q3" ~ 2,
        variable == "Physical activity (m)" & Label_clean == "Q2" ~ 3,
        variable == "Physical activity (m)" & Label_clean == "Q1" ~ 4,
        
        # Night shift work: Q1→Q4
        variable == "Night shift work" & Label_clean == "Q1" ~ 1,
        variable == "Night shift work" & Label_clean == "Q2" ~ 2,
        variable == "Night shift work" & Label_clean == "Q3" ~ 3,
        variable == "Night shift work" & Label_clean == "Q4" ~ 4,
        
        # Western diet (m): Q1→Q4
        variable == "Western diet (m)" & Label_clean == "Q1" ~ 1,
        variable == "Western diet (m)" & Label_clean == "Q2" ~ 2,
        variable == "Western diet (m)" & Label_clean == "Q3" ~ 3,
        variable == "Western diet (m)" & Label_clean == "Q4" ~ 4,
        
        # Smoking: never → past → current
        variable == "Smoking" & Label_clean == "never"   ~ 1,
        variable == "Smoking" & Label_clean == "past"    ~ 2,
        variable == "Smoking" & Label_clean == "current" ~ 3,
        
        # Obesity: no → yes
        variable == "Obesity" & Label_clean == "no"  ~ 1,
        variable == "Obesity" & Label_clean == "yes" ~ 2,
        
        # Fallback (if any labels differ), keep order of appearance
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
  
  # =============== 2) Main plot (x = x_order numeric) ===============
  p <- ggplot(df_sub, aes(x = x_order, y = RR, fill = subgroup, group = subgroup)) +
    geom_point(position = position_dodge(width = 0.5), shape = 23, size = 2) +
    geom_errorbar(aes(ymin = LCI, ymax = UCI),
                  width = 0.2,
                  position = position_dodge(width = 0.5)) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "gray30") +
    facet_grid(
      rows = vars(variable),    # single row (this var)
      cols = vars(group),       # multiple columns (strata)
      scales = "free", space = "free",
      labeller = labeller(variable = setNames(var, var))
    ) +
    scale_fill_manual(values = fill_vals, drop = TRUE) +
    scale_y_continuous(
      trans   = scales::log_trans(base = exp(1)),
      breaks  = c(0.5, 0.67, 1, 1.5, 2, 3, 4),
      labels  = scales::label_number(accuracy = 0.01),
      expand  = expansion(add = c(0.15, 0.15)),
      name    = "RR"
    ) +
    theme_bw() +
    theme(
      strip.placement.y = "outside",
      strip.background.y = element_rect(fill = strip_fill, color = "black"),
      strip.text.y = element_text(angle = 270),
      axis.title.x = element_blank()
    )
  
  # =============== 3) Column-wise (per-panel) axis labels via ggh4x ===============
  # Decide labels by VAR (since this plot shows only one var across cols)
  scale_for_this_var <- switch(
    var,
    "Physical activity (m)" = scale_x_continuous(breaks = 1:4, labels = c("Q4","Q3","Q2","Q1"), expand = expansion(add = 0.3)),
    "Night shift work"      = scale_x_continuous(breaks = 1:4, labels = c("Q1","Q2","Q3","Q4"), expand = expansion(add = 0.3)),
    "Western diet (m)"      = scale_x_continuous(breaks = 1:4, labels = c("Q1","Q2","Q3","Q4"), expand = expansion(add = 0.3)),
    "Smoking"               = scale_x_continuous(breaks = 1:3, labels = c("never","past","current"), expand = expansion(add = 0.3)),
    "Obesity"               = scale_x_continuous(breaks = 1:2, labels = c("no","yes"), expand = expansion(add = 0.3)),
    # default: try 4 breaks with numeric labels if an unexpected var appears
    scale_x_continuous(breaks = 1:4, labels = as.character(1:4), expand = expansion(add = 0.3))
  )
  
  # Replicate the same scale for each COLUMN (panel) in left→right order
  x_scales <- rep(list(scale_for_this_var), length(grp_order))
  
  p <- p + ggh4x::facetted_pos_scales(x = x_scales)
  
  if (!show_col_strips) {
    p <- p + theme(
      strip.background.x = element_blank(),
      strip.text.x = element_blank()
    )
  }
  
  return(p)
}


plots <- list(make_var_plot(df_wide, variables[1], show_col_strips = TRUE, group_colors))
plots <- c(
  plots,
  lapply(variables[-1], function(v)
    make_var_plot(df_wide, v, show_col_strips = FALSE, group_colors))
)

maternal_rr <- plot_grid(plotlist = plots, ncol = 1, align = "v", rel_heights = c(2,1.25,2,1.25,1.65))

#ggsave("RR_subgroup_maternal.pdf", plot=maternal_rr, family = "Helvetica", width = 8.9, height = 8.3)
cairo_pdf("RR_subgroup_maternal.pdf", height=8.5, width=8.9)
maternal_rr
dev.off()
##############################################################################################
### personal
##############################################################################################
df_input <- df_wide[df_wide$category == "Personal",]
variables <- unique(df_input$variable)

make_var_plot <- function(df, var, show_col_strips = TRUE, group_colors) {
  cat <- unique(df$category[df$variable == var])
  strip_fill <- group_colors[cat]
  
  fill_vals <- c(
    "Child" = "black", "Teen" = "red",
    "Male" = "black", "Female" = "red",
    "Maternal obesity" = "black", "No maternal obesity" = "red"
  )
  
  df_sub <- df[df$variable == var, ]
  
  # Assign numeric x_order for plotting
  df_sub <- df_sub %>%
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
        TRUE ~ as.numeric(factor(Label_clean))  # fallback for other labels
      )
    )
  
  # Plot using numeric x, then relabel ticks later
  p <- ggplot(df_sub,
              aes(x = x_order, y = RR,
                  fill = subgroup, group = subgroup)) +
    geom_point(position = position_dodge(width = 0.5), shape = 23, size = 2) +
    geom_errorbar(aes(ymin = LCI, ymax = UCI),
                  width = 0.2,
                  position = position_dodge(width = 0.5)) +
    facet_grid(
      rows = vars(variable),
      cols = vars(group),
      scales = "free",
      space = "free",
      labeller = labeller(variable = setNames(var, var))
    ) +
    scale_fill_manual(values = fill_vals, drop = TRUE) +
    theme_bw() +
    theme(
      strip.placement.y = "outside",
      strip.background.y = element_rect(fill = strip_fill, color = "black"),
      strip.text.y = element_text(angle = 270),
      axis.title.x = element_blank()
    ) +
    scale_y_continuous(
      trans   = scales::log_trans(base = exp(1)),
      breaks  = c(0.5, 0.67, 1, 1.5, 2, 3, 4),
      labels  = scales::label_number(accuracy = 0.01),
      expand  = expansion(add = c(0.15, 0.15)),
      name    = "RR"
    )
  
  # Add variable-specific x-axis labels
  if (var == "Physical activity") {
    p <- p +
      scale_x_continuous(
        breaks = c(1, 2, 3, 4),
        labels = c("Q4", "Q3", "Q2", "Q1"),  # reversed labels
        expand = expansion(add = 0.3)
      )
  } else if (grepl("Western diet|Sedentary time|Night shift work", var)) {
    p <- p +
      scale_x_continuous(
        breaks = c(1, 2, 3, 4),
        labels = c("Q1", "Q2", "Q3", "Q4"),
        expand = expansion(add = 0.3)
      )
  } else {
    # fallback: keep Label_clean as x labels for other variable types
    labs_unique <- unique(df_sub$Label_clean)
    p <- p +
      scale_x_continuous(
        breaks = seq_along(labs_unique),
        labels = labs_unique,
        expand = expansion(add = 0.3)
      )
  }
  
  if (!show_col_strips) {
    p <- p + theme(
      strip.background.x = element_blank(),
      strip.text.x = element_blank()
    )
  }
  
  return(p)
}


plots <- list(make_var_plot(df_wide, variables[1], show_col_strips = TRUE, group_colors))

plots <- c(
  plots,
  lapply(variables[-1], function(v) make_var_plot(df_wide, v, show_col_strips = FALSE, group_colors))
)

personal_rr <- plot_grid(plotlist = plots, ncol = 1, align = "v", rel_heights = c(2,2,2))
#ggsave("RR_subgroup_personal.pdf", plot=personal_rr, family = "Helvetica", width = 8.9, height = 5.6)

cairo_pdf("RR_subgroup_personal.pdf", height=5.6, width=8.9)
personal_rr
dev.off()

##############################################################################################
### intrauterine - changing labeller
##############################################################################################
make_var_plot <- function(df, var, show_col_strips = TRUE, group_colors) {
  # find category for this variable
  cat <- unique(df$category[df$variable == var])
  strip_fill <- group_colors[cat]
  
  # define a consistent mapping across ALL subgroup types
  fill_vals <- c(
    "Child" = "black", "Teen" = "red",
    "Male" = "black", "Female" = "red",
    "Maternal obesity" = "black", "No maternal obesity" = "red"
  )
  
  p <- ggplot(df[df$variable == var, ],
              aes(x = Label_clean, y = RR,
                  fill = subgroup, group = subgroup)) +
    geom_point(position = position_dodge(width = 0.5), shape=23, size=2) +
    geom_errorbar(aes(ymin = LCI, ymax = UCI),
                  width = 0.2,
                  position = position_dodge(width = 0.5)) +
    facet_grid(
      rows = vars(variable),
      cols = vars(group),
      scales = "free",
      space = "free",
      labeller = labeller(variable = label_wrap_gen(width = 15))
    ) +
    scale_fill_manual(values = fill_vals, drop = TRUE) +
    theme_bw() +
    theme(
      strip.placement.y = "outside",
      strip.background.y = element_rect(fill = strip_fill, color = "black"),
      strip.text.y = element_text(angle = 270),
      axis.title.x = element_blank()
    )
  
  if (!show_col_strips) {
    p <- p + theme(
      strip.background.x = element_blank(),
      strip.text.x = element_blank()
    )
  }
  
  return(p)
}


df_input <- df_wide[df_wide$category == "Intrauterine",]
variables <- unique(df_input$variable)

plots <- list(make_var_plot(df_wide, variables[1], show_col_strips = TRUE, group_colors))

plots <- c(
  plots,
  lapply(variables[-1], function(v) make_var_plot(df_wide, v, show_col_strips = FALSE, group_colors))
)

uterine_rr <- plot_grid(plotlist = plots, ncol = 1, align = "v")
cairo_pdf("RR_subgroup_uterine.pdf", height=8.5, width=9)
uterine_rr
dev.off()

##############################################################################################
### Socioeconomic - changing angle on x axis text & labeling
##############################################################################################
make_var_plot <- function(df, var, show_col_strips = TRUE, group_colors) {
  # find category for this variable
  cat <- unique(df$category[df$variable == var])
  strip_fill <- group_colors[cat]
  
  # define a consistent mapping across ALL subgroup types
  fill_vals <- c(
    "Child" = "black", "Teen" = "red",
    "Male" = "black", "Female" = "red",
    "Maternal obesity" = "black", "No maternal obesity" = "red"
  )
  
  p <- ggplot(df[df$variable == var, ],
              aes(x = Label_clean, y = RR,
                  fill = subgroup, group = subgroup)) +
    geom_point(position = position_dodge(width = 0.5), shape=23, size=2) +
    geom_errorbar(aes(ymin = LCI, ymax = UCI),
                  width = 0.2,
                  position = position_dodge(width = 0.5)) +
    facet_grid(
      rows = vars(variable),
      cols = vars(group),
      scales = "free",
      space = "free",
      labeller = labeller(variable = label_wrap_gen(width = 15))
    ) +
    scale_fill_manual(values = fill_vals, drop = TRUE) +
    theme_bw() +
    theme(
      strip.placement.y = "outside",
      strip.background.y = element_rect(fill = strip_fill, color = "black"),
      strip.text.y = element_text(angle = 270),
      axis.title.x = element_blank(),
      axis.text.x = element_text(angle=45, hjust=1)
    )
  
  if (!show_col_strips) {
    p <- p + theme(
      strip.background.x = element_blank(),
      strip.text.x = element_blank()
    )
  }
  
  return(p)
}
df_input <- df_wide[df_wide$category == "Social",]
variables <- unique(df_input$variable)

plots <- list(make_var_plot(df_wide, variables[1], show_col_strips = TRUE, group_colors))

plots <- c(
  plots,
  lapply(variables[-1], function(v) make_var_plot(df_wide, v, show_col_strips = FALSE, group_colors))
)

socio_rr <- plot_grid(plotlist = plots, ncol = 1, align = "v")
cairo_pdf("RR_subgroup_socio.pdf", height=5.6, width=9)
socio_rr
dev.off()

####################################################################################
############## combine ########################

top    <- plot_grid(personal_rr, socio_rr, ncol = 2, rel_widths  = c(1, 1.8), align = "v", axis = "tb")
bottom <- plot_grid(maternal_rr, uterine_rr, ncol = 2, rel_widths  = c(1, 1),   align = "v", axis = "tb")

big <- plot_grid(top, bottom, ncol = 1, rel_heights = c(1.2, 1))  # top taller than bottom
big







