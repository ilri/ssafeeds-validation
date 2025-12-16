# Author: John Mutua
# Date: 2025-12-16
# Description: Nutritional range validation for SSA feeds database

library(data.table)

dt <- fread("dataset_step6_biologically_validated.csv")

cat("=== STEP 7: NUTRITIONAL RANGE VALIDATION ===\n\n")

# Fix ME and IVDMD interchange for reference IDs 113982-114977
interchange_refs <- dt$Reference >= 113982 & dt$Reference <= 114977
if(sum(interchange_refs) > 0) {
  temp_me <- dt[interchange_refs, ME]
  dt[interchange_refs, ME := IVDMD]
  dt[interchange_refs, IVDMD := temp_me]
  cat("Fixed ME/IVDMD interchange for", sum(interchange_refs), "records (Ref 113982-114977)\n\n")
}

# Fix ME and IVDMD interchange for reference IDs 118492-118573
interchange_refs2 <- dt$Reference >= 118492 & dt$Reference <= 118573
if(sum(interchange_refs2) > 0) {
  temp_me <- dt[interchange_refs2, ME]
  dt[interchange_refs2, ME := IVDMD]
  dt[interchange_refs2, IVDMD := temp_me]
  cat("Fixed ME/IVDMD interchange for", sum(interchange_refs2), "records (Ref 118492-118573)\n\n")
}

# Define acceptable ranges based on unit constraints
ranges <- list(
  DM = c(0, 100),       # Dry Matter % Dried basis
  OM = c(0, 100),       # Organic Matter % of DM
  ADF = c(0, 100),      # Acid Detergent Fiber % of DM
  NDF = c(0, 100),      # Neutral Detergent Fiber % of DM
  ADL = c(0, 100),      # Acid Detergent Lignin % of DM
  CP = c(0, 100),       # Crude Protein % of DM
  IVDMD = c(0, 100),    # In Vitro Dry Matter Digestibility % of DM
  ME = c(0, 1000),      # Metabolizable Energy MJ/kg DM
  Nem = c(0, 1000),     # Net Energy for Maintenance MJ/kg DM
  Neg = c(0, 1000),     # Net Energy for Gain MJ/kg DM
  Nel = c(0, 1000),     # Net Energy for Lactation MJ/kg DM
  Ca = c(0, 1000),      # Calcium g/kg DM
  Cu = c(0, Inf),       # Copper ppm DM
  P = c(0, 1000),       # Phosphorus g/kg DM
  Fe = c(0, Inf),       # Iron ppm DM
  K = c(0, 1000),       # Potassium g/kg DM
  Mg = c(0, 1000),      # Magnesium g/kg DM
  Mn = c(0, Inf),       # Manganese ppm DM
  Na = c(0, Inf),       # Sodium ppm DM
  Zn = c(0, Inf)        # Zinc ppm DM
)

# Validate each parameter
for (param in names(ranges)) {
  if (param %in% names(dt)) {
    vals <- suppressWarnings(as.numeric(dt[[param]]))
    range_vals <- ranges[[param]]
    out_of_range <- sum(vals < range_vals[1] | vals > range_vals[2], na.rm = TRUE)
    cat(param, "out of range:", out_of_range, "\n")
  }
}

fwrite(dt, "dataset_step7_range_validated.csv")
cat("Exported dataset_step7_range_validated.csv\n")
