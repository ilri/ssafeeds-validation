library(data.table)

dt <- fread("Feed_Importer_newdata_upto_2024_with country_clean.csv")

cat("=== FINAL COMPLETENESS CHECK ===\n")
cat("Total records:", nrow(dt), "\n\n")

fields <- c("Feed type", "Species", "Genus", "Scientific name", "Feed Name")

for(field in fields) {
  missing <- sum(is.na(dt[[field]]) | dt[[field]] == "" | trimws(dt[[field]]) == "")
  complete <- nrow(dt) - missing
  pct <- round(complete/nrow(dt)*100, 1)
  
  cat(field, ":\n")
  cat("  Complete:", complete, "(", pct, "%)\n")
  cat("  Missing:", missing, "\n\n")
}