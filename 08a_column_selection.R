# Author: John Mutua
# Date: 2025-12-16
# Description: Column selection for SSA feeds database

library(data.table)

# Load dataset from Step 7
dataset <- fread("dataset_step7_range_validated.csv")

# Select and rename columns
dataset_final <- dataset[, .(s.n, Reference, `Feed type`, `Crop name`, 
                             `Plant part`, Maturity = Maturity_0, 
                             Location = Location_0, Genus, Species, `Scientific name`, 
                             Country, DM, ADF, NDF, ADL, CP, OM, P, Ca, Na, Fe, K, Mg, 
                             Cu, Mn, Zn, IVDMD, ME, Neg, Nel, Nem, `Feed Name`)]

# Export final dataset
fwrite(dataset_final, "Feed_Importer_newdata_upto_2024_with country_clean.csv")

cat("Step 8 complete: Final column selection\n")
cat("Columns exported:", ncol(dataset_final), "\n")
cat("Records:", nrow(dataset_final), "\n")
