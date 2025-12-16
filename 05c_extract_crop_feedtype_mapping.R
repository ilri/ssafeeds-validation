library(data.table)

dt <- fread("Feed_Importer_newdata_upto_2024_with country_clean.csv")

# Get unique crop name to feed type mappings
mapping <- dt[, .N, by = .(`Crop name`, `Feed type`)][order(`Crop name`, `Feed type`)]

# Export the mapping
fwrite(mapping, "final_crop_to_feedtype_mapping.csv")

cat("Extracted", nrow(mapping), "unique crop name to feed type mappings\n")

# Show summary of one-to-one vs one-to-many mappings
crop_counts <- mapping[, .N, by = `Crop name`]
one_to_one <- sum(crop_counts$N == 1)
one_to_many <- sum(crop_counts$N > 1)

cat("One-to-one mappings:", one_to_one, "\n")
cat("One-to-many mappings:", one_to_many, "\n")