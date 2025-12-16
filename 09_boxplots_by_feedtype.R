# Author: John Mutua
# Date: 2025-12-16
# Description: Boxplot visualization for SSA feeds database

library(data.table)
library(ggplot2)

dt <- fread("Feed_Importer_newdata_upto_2024_with country_clean.csv")

cat("=== GENERATING BOXPLOTS BY FEED TYPE ===\n\n")

# Create Outputs folder
dir.create("Outputs", showWarnings = FALSE)

# Key nutritional parameters with units
nutr_params <- list(
  "DM" = "DM (%)",
  "CP" = "CP (% DM)", 
  "ADF" = "ADF (% DM)",
  "NDF" = "NDF (% DM)",
  "ADL" = "ADL (% DM)",
  "OM" = "OM (% DM)",
  "ME" = "ME (MJ/kg DM)",
  "IVDMD" = "IVDMD (%)"
)

# Create boxplots for each parameter
for(param in names(nutr_params)) {
  if(param %in% names(dt)) {
    p <- ggplot(dt[!is.na(get(param))], aes(x = `Feed type`, y = get(param))) +
      geom_boxplot() +
      scale_y_continuous(labels = function(x) sprintf("%.0f", x)) +
      labs(title = paste("Distribution of", nutr_params[[param]], "by Feed Type"),
           x = "", y = nutr_params[[param]]) +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 60, hjust = 1, size = 12),
            axis.text.y = element_text(size = 12),
            axis.title = element_text(size = 12),
            plot.title = element_text(size = 12),
            panel.background = element_rect(fill = "white"),
            plot.background = element_rect(fill = "white"),
            plot.margin = margin(20, 20, 80, 60))
    
    ggsave(paste0("Outputs/boxplot_", param, "_by_feedtype.png"), p, width = 14, height = 10)
    cat("Generated Outputs/boxplot_", param, "_by_feedtype.png\n")
  }
}

cat("\nAll boxplots generated\n")