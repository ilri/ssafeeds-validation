# Author: John Mutua
# Date: 2025-12-16
# Description: Plant parts population for SSA feeds database

library(data.table)

dt <- fread("dataset_step3_with_scientific_names.csv")

cat("=== STEP 4: PLANT PARTS POPULATION ===\n\n")

# Extract plant parts from Crop name
dt[, `Plant part` := NA_character_]

# Define plant part patterns
dt[grepl("root|tuber", `Crop name`, ignore.case = TRUE), `Plant part` := "Root"]
dt[grepl("hull|husk", `Crop name`, ignore.case = TRUE), `Plant part` := "Hull"]
dt[grepl("leaf|leaves", `Crop name`, ignore.case = TRUE) & !grepl("greenleaf|silverleaf", `Crop name`, ignore.case = TRUE), `Plant part` := "Leaf"]
dt[grepl("stem|stalk", `Crop name`, ignore.case = TRUE), `Plant part` := "Stem"]
dt[grepl("grain|seed", `Crop name`, ignore.case = TRUE), `Plant part` := "Seed"]
dt[grepl("straw|stover", `Crop name`, ignore.case = TRUE), `Plant part` := "Straw"]
dt[grepl("pod|haulm", `Crop name`, ignore.case = TRUE), `Plant part` := "Pod"]

# Place Plant part next to Plant part_0
part_col_idx <- which(names(dt) == "Plant part_0")
other_cols <- setdiff(names(dt), "Plant part")
new_order <- c(other_cols[1:part_col_idx], "Plant part", other_cols[(part_col_idx+1):length(other_cols)])
setcolorder(dt, new_order)

extracted <- sum(!is.na(dt$`Plant part`))
cat("Plant parts extracted:", extracted, "\n\n")

fwrite(dt, "dataset_step4_with_plant_parts.csv")
cat("Exported dataset_step4_with_plant_parts.csv\n")