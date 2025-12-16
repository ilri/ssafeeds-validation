library(data.table)

dt <- fread("dataset_step4_with_plant_parts.csv")

cat("=== STEP 5: FEED TYPE MAPPING ===\n\n")

# Get unique feed type values with counts from Feed type_0
unique_feedtypes <- dt[!is.na(`Feed type_0`) & `Feed type_0` != "" & `Feed type_0` != "0", 
                       .N, by = `Feed type_0`][order(-N)]

# Create proposed mapping
mapping <- data.table(
  Original_Feed_Type = unique_feedtypes$`Feed type`,
  Record_Count = unique_feedtypes$N,
  Proposed_Standard_Category = ""
)

# Populate proposed mappings based on content analysis
mapping[grep("hay|pasture|forage|grass|silage", Original_Feed_Type, ignore.case = TRUE), 
        Proposed_Standard_Category := "Herbaceous forages"]

mapping[grep("straw|stover|residue|hull|haulm", Original_Feed_Type, ignore.case = TRUE), 
        Proposed_Standard_Category := "Food crops: cereals & legumes, residues"]

mapping[grep("concentrate|industrial|oil seed|meal|by-product", Original_Feed_Type, ignore.case = TRUE), 
        Proposed_Standard_Category := "Concentrate feeds and agro-industrial by-products"]

mapping[grep("tree|shrub|browse", Original_Feed_Type, ignore.case = TRUE), 
        Proposed_Standard_Category := "Fodder trees and shrubs"]

mapping[grep("root|tuber", Original_Feed_Type, ignore.case = TRUE), 
        Proposed_Standard_Category := "Food crops: roots & tubers"]

mapping[grep("mineral", Original_Feed_Type, ignore.case = TRUE), 
        Proposed_Standard_Category := "Mineral supplements"]

mapping[grep("waste", Original_Feed_Type, ignore.case = TRUE), 
        Proposed_Standard_Category := "Other less common feeds"]

mapping[grep("cereal.*green|legume.*green", Original_Feed_Type, ignore.case = TRUE) & Proposed_Standard_Category == "", 
        Proposed_Standard_Category := "Food crops: cereals & legumes, green"]

mapping[grep("grain|seed", Original_Feed_Type, ignore.case = TRUE) & Proposed_Standard_Category == "", 
        Proposed_Standard_Category := "Food crops: cereals & legumes, green"]

# Handle remaining unmapped
mapping[Proposed_Standard_Category == "", 
        Proposed_Standard_Category := "Other less common feeds"]

# Apply mapping to dataset to create Feed type column
dt[mapping, `Feed type` := i.Proposed_Standard_Category, on = .(`Feed type_0` = Original_Feed_Type)]

# For records with missing Feed type, infer from Crop name
dt[is.na(`Feed type`) & grepl("bran|meal|cake|maize grain", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Concentrate feeds and agro-industrial by-products"]

dt[is.na(`Feed type`) & grepl("straw|stover|hull|middling|short", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Food crops: cereals & legumes, residues"]

dt[is.na(`Feed type`) & grepl("grass|hay|silage|forage", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Herbaceous forages"]

dt[is.na(`Feed type`) & grepl("tree|shrub|leucaena|gliricidia|sesbania|calliandra|erythrina|wild tamarind|flemingia|mother of cocoa|riverhemp", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Fodder trees and shrubs"]

dt[is.na(`Feed type`) & grepl("fodder", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Food crops: cereals & legumes, green"]

dt[is.na(`Feed type`) & grepl("grain|seed|flour", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Concentrate feeds and agro-industrial by-products"]

dt[is.na(`Feed type`) & grepl("enset|potato|cassava|yam", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Food crops: roots & tubers"]

dt[is.na(`Feed type`) & grepl("mineral|limestone|salt|bone", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Mineral supplements"]

dt[is.na(`Feed type`) & grepl("concentrate|pellet|malt", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Concentrate feeds and agro-industrial by-products"]

# Specific crop classifications
dt[is.na(`Feed type`) & grepl("^lentil$|^oats$|^cowpea$|pigeon pea", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Food crops: cereals & legumes, residues"]

dt[is.na(`Feed type`) & grepl("asian tick trefoil|wild jicama|^centro$|sharp-leaved centrosema", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Other less common feeds"]

dt[is.na(`Feed type`) & grepl("cabbage", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Food crops: others"]

dt[is.na(`Feed type`) & grepl("hyparrhenia|brachiaria|panicum|alfalfa|lucerne|vetch|clover|telegraph plant|tropical kudzu|butterfly pea|medic|lablab|perennial soybean", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Herbaceous forages"]

dt[is.na(`Feed type`) & grepl("desmodium|stylosanthes|african stylo", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Food crops: cereals & legumes, green"]

# Additional specific crop mappings
dt[is.na(`Feed type`) & grepl("pasto rastiero|stylo|tall fescue", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Herbaceous forages"]

dt[is.na(`Feed type`) & grepl("rhizoma peanut", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Food crops: cereals & legumes, residues"]

dt[is.na(`Feed type`) & grepl("slenderleaf bundleflower", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Other less common feeds"]

dt[is.na(`Feed type`) & grepl("perennial horsegram", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Food crops: cereals & legumes, green"]

dt[is.na(`Feed type`) & grepl("vegetable hummingbird", `Crop name`, ignore.case=TRUE), 
   `Feed type` := "Fodder trees and shrubs"]

# Apply comprehensive feed type mappings directly in code
# Herbaceous forages 
dt[`Crop name` %in% c("Abyssinian grass", "Abyssinian joint vetch", "African clover", "African stylo", "Alfalfa", "Alyce clover", "American jointvetch", "Barrel medic", "Beard grass", "Bejuco engordador", "Bird's foot trefoil", "Black medick", "Blue wiss", "Brachiaria decumbens", "Brachiaria grass", "Brachiaria hybrid", "Brachiaria mutica", "Brachiaria spp", "Bristly foxtail", "Buffel grass", "Bulgras", "Burchell clover", "Burchell's clover", "Burgamensia", "Burr medic", "Butterfly pea", "Canary grass", "Chain pod", "Chili clover", "Chinese beard grass", "Clover", "Cluster love grass", "Common sesban", "Common thatching grass", "Couch grass", "Cyperus", "Dense-spiked rattlepod", "Desho grass", "Desmodium", "Desmodium dichotomum", "Desmodium uncinatum", "Drege's thatching grass", "Dwarf tephrosia", "Elegant clover", "Eleusine grass", "Erect indigo", "Fascicled muraingrass", "Florida beggarweed", "Forked tick trefoil", "Fountain grass", "Golden-spiked beard grass", "Grass pea", "Great leadtree", "Greenleaf desmodium", "Guatemala grass", "Guinea grass", "Hairy cowpea", "Hairy jointvetch", "Hairy sensitive pea", "Hairy slipper orchid", "Hairy vetch", "Harding grass", "Harding grass silage", "Hyparrhenia rufa", "Kenya Clover", "Kenya clover", "Kenya white clover", "Klein grass", "Lablab", "Lady's mantle", "Large-fruited butterfly pea", "Long-styled fountain grass", "Love grass", "Lupin", "Mexican stylosanthes", "Mission grass", "Mulato II", "Napier grass", "Narrow-leavedlLupin", "Oats silage", "Pale rattlepod", "Panicum maximum", "Parramatta grass", "Pasto rastiero", "Peavines", "Perennial ryegrass", "Perennial soybean", "Phasey bean", "Pichisermolli clover", "Pinto peanut", "Plowden's rattlepod", "Purple vetch", "Quartinian clover", "Rattlepod", "Rattlepods", "Red clover", "Red moneywort", "Rhodes grass", "Riparian fountain grass", "Riverhemp", "Rueppell's clover", "Schott's butterfly pea", "Sedge", "Sensitive partridge pea", "Showy clover", "Silverleaf desmodium", "Simien clover", "Siratro", "Small-flowered bean", "Snail medic", "Snowdenia grass", "Spiked indigo", "Spiny rattlepod", "Splendid everlasting", "Spurred butterfly pea", "Strand medic", "Stylo", "Stylosanthes hamata", "Stylosanthes scabra", "Tall fescue", "Tambuki grass", "Telegraph plant", "Tembien clover", "Thatching grass", "Tropical kudzu", "Twining pea", "Two-lined clover", "White clover", "Woolly rattlepod", "Woolly-fruited rattlepod", "Yellow loudetia", "Zavattari's indigo"), `Feed type` := "Herbaceous forages"]

# Other less common feeds 
dt[`Crop name` %in% c("Asian tick trefoil", "Centro", "Sharp-leaved centrosema", "Slenderleaf bundleflower", "Wild jicama"), `Feed type` := "Other less common feeds"]

# Food crops: cereals & legumes, residues 
dt[`Crop name` %in% c("Barley", "Barley hull", "Barley husk", "Barley straw", "Bean", "Bean hull", "Bean straw", "Cowpea", "Lentil", "Lentil hull", "Maize", "Maize hull", "Maize short", "Maize stover", "Naked barley", "Oat hull", "Oats straw", "Pea hull", "Pigeon pea", "Rhizoma peanut", "Soya bean hull", "Soybean", "Teff straw", "Turnip husk", "Vetch", "Vetch straw", "Wheat husk", "Wheat short", "Wheat straw"), `Feed type` := "Food crops: cereals & legumes, residues"]

# Concentrate feeds and agro-industrial by-products 
dt[`Crop name` %in% c("Barley middling", "Cottonseed cake", "Groundnut cake", "Linseed cake", "Maize bran", "Maize flour", "Maize grain", "Maize middling", "Noug seed cake", "Oat grain", "Rice bran", "Sorghum middling", "Soya bean cake", "Soya bean meal", "Sunflower seed cake", "Wheat bran", "Wheat malt", "Wheat middling"), `Feed type` := "Concentrate feeds and agro-industrial by-products"]

# Fodder trees and shrubs 
dt[`Crop name` %in% c("Blackthorn", "Egyptian riverhemp", "Florida Keys Indian mallow", "Gregg lead tree", "Hairy rock fig", "Large-leaf flemingia", "Lead tree", "Leucaena", "Mexican lilac", "Mother of cocoa", "Red calliandra", "Red-hot-poker tree", "Round-leaved balanites", "Spikethorn", "Vegetable hummingbird", "Wild tamarind", "Woolly leadtree"), `Feed type` := "Fodder trees and shrubs"]

# Food crops: others 
dt[`Crop name` %in% c("Cabbage", "Cabbage leaf"), `Feed type` := "Food crops: others"]

# Food crops: cereals & legumes, green 
dt[`Crop name` %in% c("Coba leaf", "Forage oats", "Maize fodder", "Maize silage", "Oats", "Para grass", "Perennial horsegram"), `Feed type` := "Food crops: cereals & legumes, green"]

# Food crops: roots & tubers 
dt[`Crop name` %in% c("Enset", "Enset leaf", "Enset leaf and stem", "Enset roots", "Enset silage", "Enset stem"), `Feed type` := "Food crops: roots & tubers"]

# Mineral supplements 
dt[`Crop name` %in% c("Limestone"), `Feed type` := "Mineral supplements"]





# Reorder columns to place Feed type next to Feed type_0
feedtype_col_idx <- which(names(dt) == "Feed type_0")
other_cols <- setdiff(names(dt), "Feed type")
new_order <- c(other_cols[1:feedtype_col_idx], "Feed type", other_cols[(feedtype_col_idx+1):length(other_cols)])
setcolorder(dt, new_order)



# Export dataset
fwrite(dt, "dataset_step5_with_feed_types.csv")
cat("Exported dataset_step5_with_feed_types.csv\n\n")

# Summary
cat("Summary by feed type category:\n")
summary_table <- dt[, .N, by = `Feed type`][order(-N)]
print(summary_table)
