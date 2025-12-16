# Author: John Mutua
# Date: 2025-12-16
# Description: Data quality flagging for SSA feeds database

library(data.table)

dt <- fread("../References/Feed_Importer_newdata_upto_2024_with country.csv")

cat("=== DATA QUALITY FLAGGING ===\n\n")

# Fix misplaced "Wheat straw" in Feed type column (Reference IDs 116161-116260)
dt[Reference >= 116161 & Reference <= 116260 & (is.na(`Crop name`) | `Crop name` == "") & `Feed type` == "Wheat straw", 
   `Crop name` := "Wheat straw"]
cat("Fixed misplaced Wheat straw for reference IDs 116161-116260\n\n")

# 1. Duplicates (flag only the duplicate copies, keep first occurrence)
dt_check <- copy(dt)
dt_check[, s.n := NULL]
dt[, Flag_Duplicate := duplicated(dt_check)]
cat("Duplicates (copies to remove):", sum(dt$Flag_Duplicate), "\n")

# 2. Feed mixtures
mix_pattern <- "mixture|mix|blend|;|\\+|&| and | with|:|desho-vetch|oat:vetch|oats vetch|maize lablab|rearing feed|napier desmodium intercrop|frute waste|fruit waste|vegitable waste|vegetable waste"
# Exclude legitimate crop by-products
legitimate_byproducts <- "^(wheat|barley|maize|oat|bean|lentil|rice|soyabean|soya bean|teff|noug|enset|vetch|cottonseed|linseed|sorghum|sunflower|sesame) (hull|bran|cake|middling|short|straw|stover|silage)s?$|^noug seeds cake$|^bean hull \\((un)?roasted\\)$|^rosted barley hull$|^sunflower seed cake$|^wheat bran \\(fine bran\\)$|^nuge seed cake$|^linen seed cake$|^nuge cake$|^barly husk$|^lin seeds cake$|^cotton seed cake$|^fine maize bran$|^roasted barley hull$|^soaked barley$|^maiz middling$|^sweet potato vines and tuber$|^sesame seed cake$"
dt$Flag_Mixture <- (ifelse(is.na(dt$`Crop name`), FALSE, grepl(mix_pattern, dt$`Crop name`, ignore.case = TRUE)) |
                   ifelse(is.na(dt$`Feed type`), FALSE, grepl(mix_pattern, dt$`Feed type`, ignore.case = TRUE)) |
                   ifelse(is.na(dt$`Feed Name`), FALSE, grepl(mix_pattern, dt$`Feed Name`, ignore.case = TRUE)) |
                   ifelse(is.na(dt$Species), FALSE, grepl(mix_pattern, dt$Species, ignore.case = TRUE))) &
                   !(ifelse(is.na(dt$`Crop name`), FALSE, grepl(legitimate_byproducts, dt$`Crop name`, ignore.case = TRUE)) |
                     ifelse(is.na(dt$`Feed Name`), FALSE, grepl(legitimate_byproducts, dt$`Feed Name`, ignore.case = TRUE)) |
                     ifelse(is.na(dt$Species), FALSE, grepl(legitimate_byproducts, dt$Species, ignore.case = TRUE)))
cat("Feed mixtures:", sum(dt$Flag_Mixture), "\n")

# 3. Fecal samples
fecal_pattern <- "feces|fecal sample"
dt$Flag_Fecal <- ifelse(is.na(dt$`Crop name`), FALSE, grepl(fecal_pattern, dt$`Crop name`, ignore.case = TRUE)) |
                 ifelse(is.na(dt$`Feed type`), FALSE, grepl(fecal_pattern, dt$`Feed type`, ignore.case = TRUE)) |
                 ifelse(is.na(dt$`Feed Name`), FALSE, grepl(fecal_pattern, dt$`Feed Name`, ignore.case = TRUE)) |
                 ifelse(is.na(dt$Species), FALSE, grepl(fecal_pattern, dt$Species, ignore.case = TRUE))
cat("Fecal samples:", sum(dt$Flag_Fecal), "\n")

# 4. Trial codes
trial_pattern <- "^V[0-9]$|45 days|maturity|^B[0-9]-?T?[0-9]+$"
dt$Flag_Trial <- ifelse(is.na(dt$`Crop name`), FALSE, grepl(trial_pattern, dt$`Crop name`, ignore.case = TRUE)) |
                 ifelse(is.na(dt$`Feed type`), FALSE, grepl(trial_pattern, dt$`Feed type`, ignore.case = TRUE)) |
                 ifelse(is.na(dt$`Feed Name`), FALSE, grepl(trial_pattern, dt$`Feed Name`, ignore.case = TRUE)) |
                 ifelse(is.na(dt$Species), FALSE, grepl(trial_pattern, dt$Species, ignore.case = TRUE))
cat("Trial codes:", sum(dt$Flag_Trial), "\n")

# 5. Accessions (ILRI numbers only)
dt[, Flag_Accession := grepl("^ILRI [0-9]+$|^[0-9]{5}$", `Crop name`, ignore.case = TRUE)]
cat("Accessions only:", sum(dt$Flag_Accession), "\n")

# 5b. Empty key columns
dt$Flag_Empty <- (is.na(dt$`Crop name`) | dt$`Crop name` == "" | trimws(dt$`Crop name`) == "") &
                 (is.na(dt$Species) | dt$Species == "" | trimws(dt$Species) == "") &
                 (is.na(dt$`Feed Name`) | dt$`Feed Name` == "" | trimws(dt$`Feed Name`) == "")
cat("Empty key columns:", sum(dt$Flag_Empty), "\n")

# 6. Generic and non-specific feeds (using comprehensive patterns)
is_generic <- function(crop_name, feed_type, feed_name, species) {

  # Protect specific crop names from being flagged as generic
  protected_crops <- c("napier grass", "cowpea", "wheat straw", "lentil hull", "noug seeds cake", 
                      "barley straw", "maize stover", "teff straw", "rosted barly hull", 
                      "rosted barley hull", "elephant grass", "barly husk", "turnip husk", 
                      "oat hull", "noug seed cake", "barely straw", "guetmala", "guatemala grass",
                      "choped maize straw", "soyabean hull", "maize hull", "wheat staw", 
                      "bean hulls", "wheat husk", "roasted barley hull", "bean straw", "roasted barely hull",
                      "brachiaria", "forage oats", "grass", "vetch straw", "wheat short", "wheat shorts",
                      "wheat middling", "cottonseed cake", "linseed cake", "maize middling", 
                      "noug seeds cake", "sorghum middling", "maize bran", "bean hull (unroasted)", "bean hull (roasted)",
                      "rosted barley hull", "sunflower seed cake", "wheat bran (fine bran)", "nuge seed cake",
                      "linen seed cake", "nuge cake", "barly husk", "lin seeds cake", "cotton seed cake",
                      "fine maize bran", "roasted barley hull", "soaked barley", "maiz middling",
                      "sweet potato vines and tuber", "sesame seed cake")
  if(!is.na(crop_name) && tolower(trimws(crop_name)) %in% protected_crops) {
    return(FALSE)
  }
  
  # Force flag specific problematic records
  if(!is.na(species) && species %in% c("Pea straw", "Poultry liter", "Bean Hull")) {
    return(TRUE)
  }
  # If species has specific scientific name (genus + species), not generic
  # Check for scientific name patterns (flexible formatting)
  if(!is.na(species)) {
    # Standard format: Genus species
    if(grepl("^[A-Z][a-z]+ [a-z]+", species) && 
       !grepl("^(Indigenous|Local|Native|Wild|Natural|Commercial|Green|Fresh|Dry)", species, ignore.case=TRUE)) {
      return(FALSE)
    }
    # Flexible format: genus species (case insensitive, handle misspellings)
    if(grepl("^[a-z]+\\s+[a-z]+$", species, ignore.case=TRUE) && 
       !grepl("^(indigenous|local|native|wild|natural|commercial|green|fresh|dry)\\s", species, ignore.case=TRUE) &&
       nchar(gsub("\\s.*", "", species)) >= 4) {  # genus at least 4 characters
      return(FALSE)
    }
    # Abbreviated scientific names: p.species, a.species etc.
    if(grepl("^[a-z]\\.[a-z]+$", species, ignore.case=TRUE)) {
      return(FALSE)
    }
  }
  
  # Special case: if species is "guetmala" (Guatemala grass), protect it
  if(!is.na(species) && tolower(trimws(species)) == "guetmala") {
    return(FALSE)
  }
  
  # Check for crop residue first (but allow specific protected crops)
  for(text in c(crop_name, feed_type, feed_name, species)) {
    if(!is.na(text) && grepl("crop residue", text, ignore.case=TRUE)) {
      # Don't flag if crop name is protected
      if(!is.na(crop_name) && tolower(trimws(crop_name)) %in% protected_crops) {
        return(FALSE)
      }
      return(TRUE)
    }
  }
  
  # Keep specific crop by-products
  for(text in c(crop_name, feed_type, feed_name, species)) {
    if(!is.na(text) && grepl("^(wheat|barley|maize|oat|bean|lentil|rice|soyabean|soya bean|teff|noug|enset|chopped maize|roasted barley) (hull|bran|cake|middling|short|straw|stover|silage)$", text, ignore.case=TRUE)) {
      return(FALSE)
    }
    # Also check for specific patterns like "bean hulls", "maize silage" etc.
    if(!is.na(text) && grepl("^(wheat|barley|maize|oat|bean|lentil|rice|soyabean|soya bean|teff|noug|enset) (hulls?|brans?|cakes?|middlings?|shorts?|straws?|stovers?|silages?)$", text, ignore.case=TRUE)) {
      return(FALSE)
    }
  }
  
  generic_patterns <- c(
    "^feed |^indigenous |^natural |^composite |^fallow",
    "^local |^native |^wild |^unknown",
    "pasture|^forage$|^grass$|^hay$|^straw$|^residue$|^waste$|dry forages|animal waste",
    "^dairy |^layer |^calf |^calves |^heifer |^shoat |^poultry |^pullet |^noug |^broiler |^finisher |^chick |^beef |saso",
    "^commercial |^home made |^super |^pellet$|^concen",
    "^green grass$|^wet grass$|^grasses$|grass hay|litter",
    "^legume$|^legumes$|grass:legume|^v[0-9]|^silage$|^medicago$|^weed$|^forbs$",
    "pulse bran|brewery by product|bone dust|pea straw|pea hull|pea husk|nachibuto|yimbro|yimrao|yamesho|imamo|kolacho|mogecho|nalleto|gero|grawa|kello|gato|bambo|hairy rock fig|mbamba ngoma|grass/ fresh harvest|fresh harvested grass|pentasa schemperia|sweet potato bran|alfalfa meal|commercail feeds|hydrophonics|crop residue \\(straw, hay, haulm, pods, stover, hulls\\)|mogneabeba|mogne abeba|eluecine floccifolia|poultry liter|bean hull"
  )
  
  for(text in c(crop_name, feed_type, feed_name, species)) {
    if(!is.na(text)) {
      for(pattern in generic_patterns) {
        if(grepl(pattern, text, ignore.case = TRUE)) return(TRUE)
      }
    }
  }
  return(FALSE)
}

dt$Flag_Generic <- as.logical(mapply(is_generic, dt$`Crop name`, dt$`Feed type`, dt$`Feed Name`, dt$Species))
cat("Generic & non-specific feeds:", sum(dt$Flag_Generic), "\n")

# Combine all flags (duplicates only flag the copies, not first occurrence)
dt$Flag_Any <- dt$Flag_Duplicate | dt$Flag_Mixture | dt$Flag_Fecal | dt$Flag_Trial | dt$Flag_Accession | dt$Flag_Empty | dt$Flag_Generic
cat("\nTotal flagged records:", sum(dt$Flag_Any), "\n")
cat("Clean records:", sum(!dt$Flag_Any), "\n\n")

# Export all records with flags
fwrite(dt, "all_records_with_quality_flags.csv")
cat("Exported all records with flags to all_records_with_quality_flags.csv\n")

# Export clean dataset (remove all flagged records)
dt_clean <- dt[Flag_Any == FALSE]
dt_clean[, c("Flag_Duplicate", "Flag_Mixture", "Flag_Fecal", "Flag_Trial", "Flag_Accession", "Flag_Empty", "Flag_Generic", "Flag_Any") := NULL]
fwrite(dt_clean, "dataset_step1_quality_flagged.csv")
cat("\nExported", nrow(dt_clean), "clean records to clean_dataset.csv\n")
cat("Removed:", nrow(dt) - nrow(dt_clean), "flagged records\n")
