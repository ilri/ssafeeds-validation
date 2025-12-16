# SSA Feeds Processing Pipeline

Automated data cleaning and validation pipeline for sub-Saharan Africa feeds composition database ('SSA Feeds').

## Overview

This pipeline includes two critical components:
1. **Data Cleaning**: Processes feed composition records through 9 sequential cleaning steps with high retention rate
2. **Data Validation**: Validates new data entries against 6 validation rules before database import

## Quick Start

**Data Cleaning Pipeline:**
```r
source("run_SSAfeeds_data_cleaning.R")
```

**Data Validation:**
```r
source("run_SSAfeeds_data_validation.R new_data.csv")
```

## Data Cleaning Pipeline (9 Steps)

1. **Data Quality Flagging** (`01_data_quality_flagging.R`) - Remove duplicates, mixtures, trial codes, generic feeds
2. **Naming Standardisation** (`02_naming_standardisation.R`) - Standardize crop and feed names
3. **Scientific Name Population** (`03_scientific_name_population.R`) - Add taxonomic information
4. **Plant Parts Population** (`04_plant_parts_population.R`) - Extract plant parts from names
5. **Feed Type Mapping** (`05a_feed_type_mapping.R`) - Classify into 9 feed categories
6. **Biological Validation** (`06_biological_validation.R`) - Check biological constraints
7. **Nutritional Range Validation** (`07_nutritional_range_validation.R`) - Validate parameter ranges
8. **Column Selection** (`08a_column_selection.R`) - Export final dataset
9. **Visualization** (`09_boxplots_by_feedtype.R`) - Generate boxplots by feed type

## Data Validation Pipeline (6 Rules)

1. **Reference ID Format** - Must be 6 digits, unique
2. **Numeric Values Only** - All nutritional parameters must be numeric
3. **Nutritional Parameter Ranges** - Values within acceptable biological ranges
4. **Biological Constraints** - ADF ≤ NDF, DM/OM ≤ 100%
5. **Required Fields** - Crop name and at least one nutritional parameter
6. **Reference Data Validation** - Valid feed types, plant parts, countries, crop names, genus

## Output

**Data Cleaning:**
- **Final dataset**: Clean records with standardized columns
- **Metadata completeness**: High completion rates for feed types and taxonomic information
- **Visualizations**: Boxplots for 8 nutritional parameters by feed type

**Data Validation:**
- **Passed records**: `filename_passed.csv` - Records ready for import
- **Failed records**: `filename_failed.csv` - Records requiring correction
- **Validation report**: Console output with detailed failure reasons

## Requirements

- R 4.0+
- Required packages: dplyr, ggplot2, readr