library(data.table)

# Validation script for new data entries implementing 6 validation rules
# Run this script on new data before adding to database

validate_new_data <- function(input_file, output_report = "validation_report.txt") {
  
  dt <- fread(input_file)
  issues <- list()
  dt[, failure_reason := ""]
  
  cat("=== DATA VALIDATION REPORT ===\n\n")
  
  # RULE 1: Reference ID Format Validation
  if("Reference" %in% names(dt)) {
    invalid_ref_idx <- !grepl("^[0-9]{6}$", dt$Reference) | is.na(dt$Reference)
    invalid_refs <- sum(invalid_ref_idx, na.rm = TRUE)
    dt[invalid_ref_idx, failure_reason := paste0(failure_reason, "Invalid Reference format; ")]
    
    dup_ref_idx <- duplicated(dt$Reference, incomparables = NA)
    dup_refs <- sum(dup_ref_idx)
    dt[dup_ref_idx, failure_reason := paste0(failure_reason, "Duplicate Reference; ")]
    
    if(invalid_refs > 0) {
      issues$ref_format <- paste(invalid_refs, "invalid Reference formats (must be 6 digits)")
      cat("FAIL:", issues$ref_format, "\n")
    } else {
      cat("PASS: Reference format valid\n")
    }
    
    if(dup_refs > 0) {
      issues$ref_unique <- paste(dup_refs, "duplicate References")
      cat("FAIL:", issues$ref_unique, "\n")
    } else {
      cat("PASS: References unique\n")
    }
  } else {
    issues$ref_missing <- "Reference column missing"
    cat("FAIL:", issues$ref_missing, "\n")
    dt[, failure_reason := paste0(failure_reason, "Missing Reference column; ")]
  }
  
  # RULE 2: Numeric Values Only
  numeric_cols <- c("DM", "ADF", "NDF", "ADL", "CP", "OM", "P", "Ca", "Na", "Fe", "K", "Mg", "Cu", "Mn", "Zn", "IVDMD", "ME", "Neg", "Nel", "Nem")
  non_numeric_issues <- 0
  
  for(col in numeric_cols) {
    if(col %in% names(dt)) {
      text_values <- sum(grepl("^(NA|NV|N/A|na|nv|n/a)$", dt[[col]]), na.rm = TRUE)
      non_numeric <- sum(!is.na(dt[[col]]) & is.na(suppressWarnings(as.numeric(dt[[col]]))))
      
      if(text_values > 0 || non_numeric > 0) {
        non_numeric_issues <- non_numeric_issues + text_values + non_numeric
        cat("FAIL:", text_values + non_numeric, "non-numeric values in", col, "\n")
      }
    }
  }
  
  if(non_numeric_issues == 0) {
    cat("PASS: All nutritional parameters are numeric\n")
  } else {
    issues$non_numeric <- paste(non_numeric_issues, "non-numeric values in nutritional parameters")
  }
  
  # RULE 3: Nutritional Parameter Ranges
  range_issues <- 0
  ranges <- list(
    DM = c(0, 100), OM = c(0, 100), ADF = c(0, 100), NDF = c(0, 100), ADL = c(0, 100), CP = c(0, 100), IVDMD = c(0, 100),
    ME = c(0, 1000), Nem = c(0, 1000), Neg = c(0, 1000), Nel = c(0, 1000),
    Ca = c(0, 1000), P = c(0, 1000), K = c(0, 1000), Mg = c(0, 1000),
    Cu = c(0, Inf), Fe = c(0, Inf), Mn = c(0, Inf), Na = c(0, Inf), Zn = c(0, Inf)
  )
  
  for(param in names(ranges)) {
    if(param %in% names(dt)) {
      vals <- suppressWarnings(as.numeric(dt[[param]]))
      range_vals <- ranges[[param]]
      out_range_idx <- vals < range_vals[1] | vals > range_vals[2]
      out_range <- sum(out_range_idx, na.rm = TRUE)
      dt[out_range_idx & !is.na(out_range_idx), failure_reason := paste0(failure_reason, param, " out of range; ")]
      if(out_range > 0) {
        range_issues <- range_issues + out_range
        cat("FAIL:", out_range, param, "values out of range\n")
      }
    }
  }
  
  if(range_issues == 0) {
    cat("PASS: All nutritional values within valid ranges\n")
  } else {
    issues$ranges <- paste(range_issues, "values outside acceptable ranges")
  }
  
  # RULE 4: Biological Constraints
  bio_issues <- 0
  for(col in c("ADF", "NDF", "OM", "DM", "CP", "ADL", "ME", "Nem", "Neg", "Nel")) {
    if(col %in% names(dt)) {
      dt[, (col) := suppressWarnings(as.numeric(get(col)))]
    }
  }
  
  if("ADF" %in% names(dt) & "NDF" %in% names(dt)) {
    adf_ndf_idx <- dt$ADF > dt$NDF & !is.na(dt$ADF) & !is.na(dt$NDF)
    adf_ndf_violations <- sum(adf_ndf_idx, na.rm = TRUE)
    dt[adf_ndf_idx, failure_reason := paste0(failure_reason, "ADF > NDF; ")]
    if(adf_ndf_violations > 0) {
      bio_issues <- bio_issues + adf_ndf_violations
      cat("FAIL:", adf_ndf_violations, "records with ADF > NDF\n")
    }
  }
  
  if("OM" %in% names(dt)) {
    om_idx <- dt$OM > 100 & !is.na(dt$OM)
    om_violations <- sum(om_idx, na.rm = TRUE)
    dt[om_idx, failure_reason := paste0(failure_reason, "OM > 100; ")]
    if(om_violations > 0) {
      bio_issues <- bio_issues + om_violations
      cat("FAIL:", om_violations, "records with OM > 100\n")
    }
  }
  
  if("DM" %in% names(dt)) {
    dm_idx <- dt$DM > 100 & !is.na(dt$DM)
    dm_violations <- sum(dm_idx, na.rm = TRUE)
    dt[dm_idx, failure_reason := paste0(failure_reason, "DM > 100; ")]
    if(dm_violations > 0) {
      bio_issues <- bio_issues + dm_violations
      cat("FAIL:", dm_violations, "records with DM > 100\n")
    }
  }
  
  if(bio_issues == 0) {
    cat("PASS: All biological constraints satisfied\n")
  } else {
    issues$biological <- paste(bio_issues, "biological constraint violations")
  }
  
  # RULE 5: Required Fields
  required_issues <- 0
  if(!"Crop name" %in% names(dt) || sum(is.na(dt$`Crop name`) | dt$`Crop name` == "") == nrow(dt)) {
    required_issues <- required_issues + 1
    cat("FAIL: Crop name field missing or empty\n")
  }
  
  has_nutrition <- FALSE
  for(col in numeric_cols) {
    if(col %in% names(dt) && sum(!is.na(dt[[col]])) > 0) {
      has_nutrition <- TRUE
      break
    }
  }
  
  if(!has_nutrition) {
    required_issues <- required_issues + 1
    cat("FAIL: No nutritional parameters provided\n")
  }
  
  if(required_issues == 0) {
    cat("PASS: All required fields present\n")
  } else {
    issues$required <- paste(required_issues, "required field violations")
  }
  
  # RULE 6: Reference Data Validation
  valid_feed_types <- c("Concentrate feeds and agro-industrial by-products", "Fodder trees and shrubs", "Food crops: cereals & legumes, green", "Food crops: cereals & legumes, residues", "Food crops: others", "Food crops: roots & tubers", "Herbaceous forages", "Mineral supplements", "Other less common feeds")
  
  if("Feed type" %in% names(dt)) {
    invalid_feed_idx <- !dt$`Feed type` %in% valid_feed_types | is.na(dt$`Feed type`)
    invalid_feed_types <- sum(invalid_feed_idx)
    dt[invalid_feed_idx, failure_reason := paste0(failure_reason, "Invalid feed type; ")]
    if(invalid_feed_types > 0) {
      issues$feed_type <- paste(invalid_feed_types, "invalid feed type categories")
      cat("FAIL:", issues$feed_type, "\n")
    } else {
      cat("PASS: All feed types valid\n")
    }
  }
  
  valid_plant_parts <- c("", "Hull", "Leaf", "Pod", "Root", "Seed", "Stem", "Straw")
  if("Plant part" %in% names(dt)) {
    invalid_plant_parts <- sum(!dt$`Plant part` %in% valid_plant_parts)
    if(invalid_plant_parts > 0) {
      issues$plant_part <- paste(invalid_plant_parts, "invalid plant parts")
      cat("FAIL:", issues$plant_part, "\n")
    } else {
      cat("PASS: All plant parts valid\n")
    }
  }
  
  valid_countries <- c("Ethiopa", "ethiopia", "Ethiopia")
  if("Country" %in% names(dt)) {
    invalid_countries <- sum(!dt$Country %in% valid_countries | is.na(dt$Country))
    if(invalid_countries > 0) {
      issues$country <- paste(invalid_countries, "invalid countries")
      cat("FAIL:", issues$country, "\n")
    } else {
      cat("PASS: All countries valid\n")
    }
  }
  
  valid_crop_names <- c("African stylo", "Alfalfa", "Alyce clover", "American jointvetch", "Asian tick trefoil", "Barley", "Barrel medic", "Bean", "Bean hull", "Bejuco engordador", "Blackthorn", "Blue wiss", "Brachiaria decumbens", "Brachiaria mutica", "Brachiaria sp.", "Brachiaria spp", "Buffel grass", "Burchell clover", "Butterfly pea", "Cabbage", "Cabbage leaf", "Centro", "Chili clover", "Clover", "Coba leaf", "Common thatching grass", "Cowpea", "Cyperus", "Desho grass", "Desmodium", "Desmodium dichotomum", "Desmodium uncinatum", "Egyptian riverhemp", "Enset", "Enset leaf", "Enset leaf and stem", "Enset roots", "Enset stem", "Florida beggarweed", "Florida Keys Indian mallow", "Forage oats", "Forbs", "Grass pea", "Greenleaf desmodium", "Gregg lead tree", "Ground nut cake", "Groundnut cake", "Guatemala grass", "Hairy cowpea", "Hairy jointvetch", "Hairy sensitive pea", "Hairy vetch", "Harding grass", "Harding grass silage", "Hyparrhenia rufa", "Kenya white clover", "Klein grass", "Lablab", "Large-fruited butterfly pea", "Large-leaf flemingia", "Lentil", "Lentil hull", "Leucaena", "Limestone", "Linseed cake", "Lucerne", "Lupin", "Maize", "Maize bran", "Maize flour", "Maize fodder", "Maize grain", "Mexican stylosanthes", "Mother of cocoa", "Naked barley", "Napier grass", "Narrow-leavedlLupin", "Oat grain", "Oats", "Oats silage", "Oats straw", "Panicum maximum", "Para grass", "Peavines", "Perennial soybean", "Phasey bean", "Pigeon pea", "Pinto peanut", "Purple vetch", "Quartinian clover", "Rattlepod", "Rattlepods", "Red calliandra", "Red moneywort", "Red-hot-poker tree", "Rhodes grass", "Rice bran", "River bean", "Riverhemp", "Schott's butterfly pea", "Sedge", "Sensitive partridge pea", "Sesbania", "Sharp-leaved centrosema", "Showy clover", "Silverleaf desmodium", "Siratro", "Small-flowered bean", "Snail medic", "Soya bean cake", "Soya bean meal", "Spikethorn", "Spurred butterfly pea", "Strand medic", "Stylosanthes hamata", "Stylosanthes scabra", "Teff straw", "Telegraph plant", "Tembien clover", "Tropical kudzu", "Twining pea", "Vegetable hummingbird tree", "Vetch", "Wheat bran", "Wheat malt", "Wheat middling", "Wheat short", "Wheat straw", "White clover", "Wild jicama", "Wild tamarind", "Woolly leadtree", "Woolly rattlepod")
  
  if("Crop name" %in% names(dt)) {
    invalid_crop_idx <- !dt$`Crop name` %in% valid_crop_names | is.na(dt$`Crop name`)
    invalid_crops <- sum(invalid_crop_idx)
    dt[invalid_crop_idx, failure_reason := paste0(failure_reason, "Invalid crop name; ")]
    if(invalid_crops > 0) {
      issues$crop_name <- paste(invalid_crops, "invalid crop names")
      cat("FAIL:", issues$crop_name, "\n")
    } else {
      cat("PASS: All crop names valid\n")
    }
  }
  
  valid_genus <- c("Abutilon", "Aeschynomene", "Alysicarpus", "Arachis", "Avena", "Bouffordia", "Brachiaria", "Brassica", "Cajanus", "Calliandra", "Calopogonium", "Cenchrus", "Centrosema", "Chamaecrista", "Chloris", "Clitoria", "Coba", "Codariocalyx", "Crotalaria", "Cyperus", "Desmodium", "Ensete", "Eragrostis", "Erythrina", "Flemingia", "Gliricidia", "Glycine", "Grona", "Hordeum", "Hyparrhenia", "Lablab", "Lathyrus", "Lens", "Leucaena", "Linum", "Lupinus", "Macroptilium", "Maytenus", "Medicago", "Megathyrsus", "Mineral", "Mixed", "Neonotonia", "Neustanthus", "Oryza", "Panicum", "Pennisetum", "Phalaris", "Phaseolus", "Sesbania", "Stylosanthes", "Teramnus", "Trifolium", "Tripsacum", "Triticum", "Urochloa", "Vachellia", "Vicia", "Vigna", "Zea")
  
  if("Genus" %in% names(dt)) {
    invalid_genus <- sum(!dt$Genus %in% valid_genus | is.na(dt$Genus))
    if(invalid_genus > 0) {
      issues$genus <- paste(invalid_genus, "invalid genus names")
      cat("FAIL:", issues$genus, "\n")
    } else {
      cat("PASS: All genus names valid\n")
    }
  }
  
  # Summary and file output
  cat("\n=== SUMMARY ===\n")
  cat("Total records:", nrow(dt), "\n")
  cat("Total validation issues:", length(issues), "categories\n")
  
  # Split data into passed and failed
  failed_data <- dt[failure_reason != ""]
  passed_data <- dt[failure_reason == ""]
  
  # Generate output filenames
  base_name <- tools::file_path_sans_ext(input_file)
  passed_file <- paste0(base_name, "_passed.csv")
  failed_file <- paste0(base_name, "_failed.csv")
  
  # Write files
  if(nrow(passed_data) > 0) {
    passed_data[, failure_reason := NULL]
    fwrite(passed_data, passed_file)
    cat("\nPassed records written to:", passed_file, "(", nrow(passed_data), "records)\n")
  }
  
  if(nrow(failed_data) > 0) {
    fwrite(failed_data, failed_file)
    cat("Failed records written to:", failed_file, "(", nrow(failed_data), "records)\n")
  }
  
  if(length(issues) == 0) {
    cat("\nSTATUS: APPROVED - Data ready for import\n")
    return(TRUE)
  } else {
    cat("\nSTATUS: REJECTED - Please address all validation failures\n")
    return(FALSE)
  }
}

# Run validation
args <- commandArgs(trailingOnly = TRUE)
if(length(args) > 0) {
  result <- validate_new_data(args[1])
  if(!result) quit(status = 1)
} else {
  cat("Usage: Rscript validate_new_data.R <input_file.csv>\n")
  cat("\nValidation Rules Implemented:\n")
  cat("1. Reference ID Format (6 digits)\n")
  cat("2. Numeric Values Only\n")
  cat("3. Nutritional Parameter Ranges\n")
  cat("4. Biological Constraints\n")
  cat("5. Required Fields\n")
  cat("6. Feed Type Validation\n")
}