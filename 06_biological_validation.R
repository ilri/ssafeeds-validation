library(data.table)

dt <- fread("dataset_step5_with_feed_types.csv")

cat("=== STEP 6: BIOLOGICAL VALIDATION ===\n\n")
dt[, ADF := suppressWarnings(as.numeric(ADF))]
dt[, NDF := suppressWarnings(as.numeric(NDF))]
dt[, OM := suppressWarnings(as.numeric(OM))]
dt[, DM := suppressWarnings(as.numeric(DM))]
dt[, CP := suppressWarnings(as.numeric(CP))]

# Convert zeros to NA when other nutritional values exist
nutr_cols <- c("ADF", "NDF", "OM", "DM", "CP", "Ca", "P", "K", "Mg", "ME", "IVDMD", "ADL", "Nem", "Neg", "Nel", "Cu", "Fe", "Mn", "Na", "Zn")
existing_cols <- intersect(nutr_cols, names(dt))
for(col in existing_cols) {
  dt[, (col) := suppressWarnings(as.numeric(get(col)))]
}
# Remove records with all nutritional zeros (where data exists)
for(col in existing_cols) {
  dt[, (col) := suppressWarnings(as.numeric(get(col)))]
}
all_zeros <- rowSums(dt[, ..existing_cols] == 0, na.rm=TRUE) >= 5 & rowSums(!is.na(dt[, ..existing_cols]), na.rm=TRUE) >= 5
removed_count <- sum(all_zeros)
dt <- dt[!all_zeros]
cat("Removed", removed_count, "records with all nutritional zeros\n")

# Set zeros to NA if other nutritional values exist
if(length(existing_cols) > 1) {
  for(col in existing_cols) {
    other_cols <- setdiff(existing_cols, col)
    dt[get(col) == 0 & rowSums(!is.na(dt[, ..other_cols]) & dt[, ..other_cols] != 0, na.rm=TRUE) > 0, (col) := NA]
  }
}

cat("Zeros converted to missing values\n")
for(col in nutr_cols) {
  if(col %in% names(dt)) {
    cat(col, "= 0:", sum(dt[[col]] == 0, na.rm = TRUE), "\n")
  }
}
cat("ADF > NDF:", sum(dt$ADF > dt$NDF, na.rm = TRUE), "\n")
cat("OM > 100:", sum(dt$OM > 100, na.rm = TRUE), "\n")
cat("DM > 100:", sum(dt$DM > 100, na.rm = TRUE), "\n")
cat("IVDMD > 100:", sum(dt$IVDMD > 100, na.rm = TRUE), "\n")

fwrite(dt, "dataset_step6_biologically_validated.csv")
cat("Exported dataset_step6_biologically_validated.csv\n")
