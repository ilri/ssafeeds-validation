# Author: John Mutua
# Date: 2025-12-16
# Description: Naming standardisation for SSA feeds database

library(data.table)

dt <- fread("dataset_step1_quality_flagged.csv")

cat("=== STEP 2: NAMING STANDARDISATION ===\n\n")

# Rename original columns with _0 suffix
setnames(dt, 
         old = c("Feed type", "Crop name", "Plant part", "Maturity", "Location", "Genus", "Species", "Scientific name", "Feed Name"),
         new = c("Feed type_0", "Crop name_0", "Plant part_0", "Maturity_0", "Location_0", "Genus_0", "Species_0", "Scientific name_0", "Feed Name_0"))

# Load standardization mapping
std_mapping <- fread("crop_name_to_standard_name.csv")

# Create Crop name column by mapping Crop name_0
dt[std_mapping, `Crop name` := i.Standard_Name, on = .(`Crop name_0` = Original_Name)]

# For rows still missing Crop name, apply standardization to Species_0 column
dt_missing <- dt[is.na(`Crop name`) | `Crop name` == ""]
dt_missing[std_mapping, `Crop name` := i.Standard_Name, on = .(`Species_0` = Original_Name)]
dt[is.na(`Crop name`) | `Crop name` == "", `Crop name` := dt_missing$`Crop name`]

# Check if any Standard_Name values exist in Crop name_0 or Species_0 columns
for(std_name in unique(std_mapping$Standard_Name)) {
  # If Crop name is NA but Crop name_0 or Species_0 matches a Standard_Name, use it
  dt[is.na(`Crop name`) & (`Crop name_0` == std_name | `Species_0` == std_name), `Crop name` := std_name]
}

# For rows still missing Standard_name, check Species against scientific name mapping
sci_to_common <- fread("scientific_names_to_common_names.csv")
# Match Species_0 directly against Original_Name (as appears in data) and use Common_Name
dt[sci_to_common, Crop_name_temp := i.Common_Name, on = .(`Species_0` = Original_Name)]
dt[is.na(`Crop name`) | `Crop name` == "", `Crop name` := Crop_name_temp]
dt[, Crop_name_temp := NULL]

# Handle specific cases for records 122843 and 122852
dt[Reference == 122843 & `Species_0` == "Trifolium semipilosum†", `Crop name` := "Kenya clover"]
dt[Reference == 122852 & `Species_0` == "Leucaena pulverulenta†", `Crop name` := "Great leadtree"]

# Create Feed Name column from cleaned Crop name
dt[, `Feed Name` := `Crop name`]

# Reorder columns to place Crop name next to Crop name_0 and Feed Name next to Feed Name_0
crop_col_idx <- which(names(dt) == "Crop name_0")
feedname_col_idx <- which(names(dt) == "Feed Name_0")
other_cols <- setdiff(names(dt), c("Crop name", "Feed Name"))
new_order <- c(other_cols[1:crop_col_idx], "Crop name", other_cols[(crop_col_idx+1):(feedname_col_idx-1)], "Feed Name", other_cols[feedname_col_idx:length(other_cols)])
setcolorder(dt, new_order)

cat("Applied", nrow(std_mapping), "name standardizations\n")
cat("Unique crop names before:", length(unique(dt$`Crop name_0`)), "\n")
cat("Unique crop names after:", length(unique(dt$`Crop name`)), "\n\n")

# Export
fwrite(dt, "dataset_step2_standardized.csv")
cat("Exported dataset_step2_standardized.csv\n")
