# Author: John Mutua
# Date: 2025-12-16
# Description: Scientific name population for SSA feeds database

library(data.table)

dt <- fread("dataset_step2_standardized.csv")

cat("=== STEP 3: SCIENTIFIC NAME POPULATION ===\n\n")

# Load scientific name mapping
sci_mapping <- fread("standard_name_to_scientific_name.csv")

# Create Scientific name column by mapping Crop name
dt[sci_mapping, `Scientific name` := i.Scientific_Name, on = .(`Crop name` = Standard_Name)]

# Extract Genus and Species from Scientific name
dt[, Genus := ifelse(!is.na(`Scientific name`) & `Scientific name` != "", 
                     sub(" .*", "", `Scientific name`), 
                     NA_character_)]
dt[, Species := ifelse(!is.na(`Scientific name`) & grepl(" ", `Scientific name`), 
                       sub("^\\S+ ", "", `Scientific name`), 
                       NA_character_)]

# Remove scientific names for mineral supplements (after genus/species extraction)
mineral_feeds <- c("limestone", "salt", "bone meal", "dicalcium phosphate", "calcium carbonate")
dt[tolower(`Crop name`) %in% mineral_feeds, `:=`(`Scientific name` = "", Genus = "", Species = "")]

# Reorder columns: Crop name next to Crop name_0, then Genus next to Genus_0, Species next to Species_0, Scientific name next to Scientific name_0
crop_col_idx <- which(names(dt) == "Crop name_0")
genus_col_idx <- which(names(dt) == "Genus_0")
species_col_idx <- which(names(dt) == "Species_0")
sci_col_idx <- which(names(dt) == "Scientific name_0")

# Build new column order
all_cols <- names(dt)
other_cols <- setdiff(all_cols, c("Crop name", "Genus", "Species", "Scientific name"))

# Insert new columns after their _0 counterparts
new_order <- character(0)
for(i in seq_along(other_cols)) {
  new_order <- c(new_order, other_cols[i])
  if(other_cols[i] == "Crop name_0") new_order <- c(new_order, "Crop name")
  if(other_cols[i] == "Genus_0") new_order <- c(new_order, "Genus")
  if(other_cols[i] == "Species_0") new_order <- c(new_order, "Species")
  if(other_cols[i] == "Scientific name_0") new_order <- c(new_order, "Scientific name")
}
setcolorder(dt, new_order)

# Statistics
mapped <- sum(!is.na(dt$`Scientific name`) & dt$`Scientific name` != "")
total <- nrow(dt)
cat("Records with scientific names:", mapped, "\n")
cat("Mapping rate:", round(mapped/total*100, 1), "%\n\n")

# Export
fwrite(dt, "dataset_step3_with_scientific_names.csv")
cat("Exported dataset_step3_with_scientific_names.csv\n")
