# Author: John Mutua
# Date: 2025-12-16
# Description: Master script for SSA Feeds Database Cleaning - 9 Steps
# Executes all cleaning steps in chronological order

cat("=== SSA FEEDS DATABASE CLEANING - 9 STEPS ===\n\n")

# Step 1: Data Quality Flagging
cat("STEP 1: Data Quality Flagging...\n")
source("01_data_quality_flagging.R")
# Step 2: Naming Standardisation
cat("STEP 2: Naming Standardisation...\n")
source("02_naming_standardisation.R")
# Step 3: Scientific Name Population
cat("STEP 3: Scientific Name Population...\n")
source("03_scientific_name_population.R")
# Step 4: Plant Parts Population
cat("STEP 4: Plant Parts Population...\n")
source("04_plant_parts_population.R")
# Step 5: Feed Type Mapping
cat("STEP 5: Feed Type Mapping...\n")
source("05a_feed_type_mapping.R")
# Step 6: Biological Validation
cat("STEP 6: Biological Validation...\n")
source("06_biological_validation.R")
# Step 7: Nutritional Range Validation
cat("STEP 7: Nutritional Range Validation...\n")
source("07_nutritional_range_validation.R")
# Step 8: Final Column Selection
cat("STEP 8: Final Column Selection...\n")
source("08a_column_selection.R")
# Step 9: Boxplots by Feed Type
cat("STEP 9: Boxplots by Feed Type...\n")
source("09_boxplots_by_feedtype.R")

cat("\n=== ALL 9 STEPS COMPLETE ===\n")
cat("Final output: Feed_Importer_newdata_upto_2024_with country_clean.csv\n")
cat("Analysis outputs: Outputs/ folder\n")
