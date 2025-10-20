library(dplyr)
library(tidyr)
library(stringr)
library(data.table)
library(ggplot2)
library(ggh4x)
library(patchwork)
library(cowplot)

setwd("/Users/yiqingwang/Dropbox (Partners HealthCare)/MGH/GUTS obesity&cancer/output/")

fig5_df <- read.csv("Fig5_PAR_strat_figure.csv")[,3:15]
names(fig5_df)[4] <- "Exposure"
fig5_df <- fig5_df %>%
  mutate(category = gsub("Social","Socioeconomic",category)) %>%
  mutate(Exposure = gsub("Social","Socioeconomic",Exposure)) %>%
  mutate(category = ifelse(Exposure == "Pre-pregnancy obesity","Intrauterine",category)) %>%
  mutate(group = ifelse(group == "age", "Age", ifelse(group == "sex", "Sex","Maternal obesity"))) %>%
  mutate(group = factor(group, levels = c("Age","Sex","Maternal obesity"))) %>%
  mutate(subgroup = gsub("nomoob","no maternal obesity",subgroup)) %>%
  mutate(subgroup = gsub("moob","maternal obesity",subgroup)) %>%
  mutate(subgroup = Hmisc::capitalize(subgroup)) %>%
  mutate(subgroup = factor(subgroup, levels=c("Child","Teen","Male","Female","Maternal obesity", "No maternal obesity"))) %>%
  mutate(category = factor(category, levels = unique(category))) %>%
  mutate(
    Exposure = str_replace(Exposure, "^(.*?)\\s+risk factors$", "Combined \\1")
  ) 

group_colors <- c(
  Personal = "#20854E99",
  Socioeconomic = "#FFDC91FF",
  Maternal = "#0072B599",
  Intrauterine = "#6F99AD99"
)

fill_vals <- c(
  "Child" = "black", "Teen" = "red",
  "Male" = "black", "Female" = "red",
  "Maternal obesity" = "black", "No maternal obesity" = "red"
)

fig5_df <- fig5_df %>%
  group_by(category) %>%
  mutate(
    Exposure = {
      combined <- Exposure[grepl("Combined", Exposure)]
      non_combined <- Exposure[!grepl("Combined", Exposure)]
      # sort non-combined in *decreasing* PAR (so plot shows increasing up the axis)
      non_combined <- non_combined[order(-PAF[!grepl("Combined", Exposure)])]
      factor(Exposure, levels = unique(c(combined, non_combined)))
    }
  ) %>%
  ungroup()

# Step 1. Compute a global label position to keep all aligned
x_offset <- max(fig5_df$UCI, na.rm = TRUE) * 1.05  # 15% to the right of the max CI
phet_df <- fig5_df %>%
  group_by(category, group, Exposure) %>%
  summarise(
    p_het = unique(na.omit(p_het))[1]
  ) %>%
  ungroup() %>%
  mutate(
    p_label = case_when(
      is.na(p_het) ~ "",
      p_het < 0.001 ~ "p-het < 0.001",
      TRUE ~ paste0("p-het = ", formatC(p_het, format = "f", digits = 3))
    ),
    x_pos = x_offset  # fixed right margin
  )

# Step 2. Plot with aligned p-het labels
fig5_plot <- ggplot(fig5_df, aes(x = PAF, y = Exposure, fill=subgroup, group = subgroup)) +
  geom_point(position = position_dodge(width = 0.25), shape=23, size=3, stroke=0.1) +
  geom_errorbar(aes(xmin = LCI, xmax = UCI),
                width = 0.2,
                position = position_dodge(width = 0.25)) +
  geom_text(
    data = phet_df,
    aes(x = x_pos, y = Exposure, label = p_label),
    color = "black",
    inherit.aes = FALSE,
    hjust = 0, vjust = 0.5, size = 3
  ) +
  ggh4x::facet_grid2(
    rows = vars(category),
    cols = vars(group),
    scales = "free_y", space = "free",
    strip = ggh4x::strip_themed(
      background_y = ggh4x::elem_list_rect(fill = group_colors),
      text_y = ggh4x::elem_list_text(color = "black", size = 9)
    )
  ) +
  scale_fill_manual(values = fill_vals) +
  theme_bw() +
  theme(
    axis.title.y = element_blank(),
    panel.spacing = unit(1, "lines"),
    axis.text.x = element_text(angle=90, color="black", size=10),
    axis.text.y = element_text(color="black", size=10),
    plot.margin = margin(10, 90, 10, 10)  # make room for labels
  ) +
  scale_x_continuous(
  limits = c(-2, NA),                 # extend slightly below 0
  expand = expansion(mult = c(0, 0.35)) # keep the right margin for p-het
)

fig5_plot

CairoPDF("Fig4_par_strat.pdf", family = "Helvetica", width = 15, height = 8)
#plot_grid(fig3_rr, fig3_par, align="v", axis = c("bt"), rel_widths = c(1, 0.5))
plot_grid( fig5_plot)
dev.off()


