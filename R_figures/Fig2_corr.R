library(tidyverse)
library(dplyr)
library(ComplexHeatmap)
library(data.table)
library(circlize)
library(RColorBrewer)
library(scales)

setwd("/Users/yiqingwang/Dropbox (Partners HealthCare)/MGH/GUTS obesity&cancer/output/")

cor_mat <- read.csv("Fig2_corr_exposure_revised.csv", row.names = 1, header = TRUE, check.names = FALSE) |> as.matrix()
cor_mat <- round(cor_mat,3)
#Define each variable’s type
group_df <- tribble(
  ~var,                             ~type,
  "BMI",                            "Personal",
  "Western diet",                   "Personal",
  "Sedentary time",                 "Personal",
  "Physical activity time",         "Personal",
  "Paternal education",             "Social",
  "Household income",               "Social",
  "Neighborhood SES index",         "Social",
  "Maternal BMI",                   "Maternal",
  "Maternal Western diet",          "Maternal",
  "Maternal physical activity",     "Maternal",
  "Maternal smoking",               "Maternal",
  "Maternal shift work",            "Maternal",
  "Maternal pre-pregnancy BMI",     "Intrauterine",
  "Birth weight",                   "Intrauterine",
  "Gestational week",               "Intrauterine",
  "Born by cesarean section",       "Intrauterine",
  "Maternal pregnancy complication","Intrauterine",
  "Maternal excess gestational weight gain", "Intrauterine"
) |> as.data.frame() %>%
  mutate(var = gsub("Western diet","Western diet score",var)) %>%
  mutate(var = gsub("Maternal Western diet score","Western diet score (M)",var)) %>%
  mutate(var = ifelse(var %like% "BMI", gsub("Maternal BMI","Obesity",var), gsub("Maternal ","",var))) %>%
  mutate(var = gsub("Maternal pre-pregnancy BMI","Pre-pregnancy obesity",var)) %>%
  mutate(var = gsub("excess gestational weight gain","Excess gest. weight gain*",var)) %>%
  mutate(var = gsub("week","age",var)) %>%
  mutate(var = gsub("Born by ","",var)) %>%
  mutate(var = Hmisc::capitalize(var)) %>%
  mutate(var = gsub("Shift work","Night shift hours",var)) %>%
  mutate(var = gsub("Neighborhood ","n",var))

colnames(cor_mat) <- as.character(group_df$var)
rownames(cor_mat) <- as.character(group_df$var)

var_order <- group_df %>% arrange(type) %>% pull(var)
group_df <- group_df %>%
  mutate(var = factor(var, levels = var_order))

group_colors <- c(
  Personal = "#20854E99",
  Social = "#FFDC91FF",
  Maternal = "#0072B599",
  Intrauterine = "#6F99AD99"
)
cor_mat[lower.tri(cor_mat)] <- NA # fill it
diag(cor_mat) <- NA  # only diag is NA (gray)

# Row and column annotations beside labels
row_anno <- rowAnnotation(
  Group = group_df$type,
  col = list(Group = group_colors),
  show_annotation_name = FALSE,
  width = unit(0.01, "inches")
)

col_anno <- columnAnnotation(
  Group = group_df$type,
  col = list(Group = group_colors),
  show_annotation_name = FALSE,
  height = unit(0.75, "mm")
)

full_colors <- rev(brewer.pal(11, "RdBu"))  # Red = high

# Create interpolated breaks with yellow exactly at 0
col_fun <- colorRamp2(
  c(-0.25, 0, 0.25),
  c(full_colors[2], full_colors[6], full_colors[10])  # blue - yellow - red
)

Heatmap(
  cor_mat,
  name = "Correlation",
  col = col_fun,
  cluster_rows = FALSE,
  cluster_columns = FALSE,
  show_row_names = TRUE,
  #rect_gp = gpar(col = "black", lwd = 0.5),
  show_column_names = TRUE,
  #top_annotation = col_anno,
  right_annotation = row_anno,
  column_names_side = "top",
  column_names_rot = 45,
  row_title = NULL,
  column_title = "",
  na_col = "white",  # lower triangle will be white
  cell_fun = function(j, i, x, y, width, height, fill) {
    val <- cor_mat[i, j]
    
    # Diagonal: gray background + white text + border
    if (i == j) {
      grid::grid.rect(x, y, width, height, gp = gpar(fill = "gray30", col = "black", lwd = 0.5))
      #grid::grid.text(sprintf("%.2f", val), x, y, gp = gpar(fontsize = 8, col = "white"))
    }
    
    # Upper triangle: show value + border
    else if (!is.na(val)) {
      grid::grid.rect(x, y, width, height, gp = gpar(col = "black", fill = fill, lwd = 0.5))
      grid::grid.text(sprintf("%.2f", val), x, y, gp = gpar(fontsize = 11))
    }
    
    # Lower triangle (NA): do nothing (i.e., no border, no fill, no text)
  }
)


