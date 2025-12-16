library(data.table)

# Read the mapping
mapping <- fread("final_crop_to_feedtype_mapping.csv")

cat("=== CROP NAME TO FEED TYPE MAPPING ANALYSIS ===\n\n")

# One-to-many analysis (crop names mapping to multiple feed types)
crop_counts <- mapping[, .N, by = `Crop name`]
one_to_many_crops <- crop_counts[N > 1]

cat("ONE-TO-MANY MAPPINGS (Crop names with multiple feed types):\n")
if(nrow(one_to_many_crops) > 0) {
  for(i in 1:nrow(one_to_many_crops)) {
    crop <- one_to_many_crops[i, `Crop name`]
    feed_types <- mapping[`Crop name` == crop, `Feed type`]
    cat("- '", crop, "' maps to ", length(feed_types), " feed types: ", paste(feed_types, collapse = ", "), "\n")
  }
} else {
  cat("None found - all crop names have consistent one-to-one mappings\n")
}

cat("\n")

# Many-to-one analysis (multiple crop names mapping to same feed type)
feedtype_counts <- mapping[, .N, by = `Feed type`]
cat("MANY-TO-ONE MAPPINGS (Feed types with multiple crop names):\n")
for(i in 1:nrow(feedtype_counts)) {
  feed_type <- feedtype_counts[i, `Feed type`]
  count <- feedtype_counts[i, N]
  cat("- '", feed_type, "' has ", count, " crop names\n")
}

cat("\n=== SUMMARY ===\n")
cat("Total unique crop names:", nrow(crop_counts), "\n")
cat("Total unique feed types:", nrow(feedtype_counts), "\n")
cat("One-to-one mappings:", sum(crop_counts$N == 1), "\n")
cat("One-to-many mappings:", sum(crop_counts$N > 1), "\n")