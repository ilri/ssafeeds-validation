# Data Validation Rules Implementation

## Overview
The validation system has been implemented in `validate_new_data.R` to enforce all 6 validation rules for new data entries before they are added to the SSA feeds database.

## Validation Rules Implemented

### Rule 1: Reference ID Format
- **Pattern**: 6 digits (e.g., 111517)
- **Uniqueness**: Ensures no duplicate references
- **Column**: `Reference`

### Rule 2: Numeric Values Only
- **Rejects**: Text values like 'NA', 'NV', 'N/A', etc.
- **Applies to**: DM, ADF, NDF, ADL, CP, OM, P, Ca, Na, Fe, K, Mg, Cu, Mn, Zn, IVDMD, ME, Neg, Nel, Nem
- **Implementation**: Checks for non-numeric values and common text placeholders

### Rule 3: Nutritional Parameter Ranges
- **Percentages (0-100%)**: DM, OM, ADF, NDF, ADL, CP, IVDMD
- **Energy (0-1000 MJ/kg DM)**: ME, Nem, Neg, Nel
- **Minerals (0-1000 g/kg DM)**: Ca, P, K, Mg
- **Trace minerals (≥0 ppm DM)**: Cu, Fe, Mn, Na, Zn

### Rule 4: Biological Constraints
- **OM ≤ DM**: Organic matter cannot exceed dry matter
- **ADF ≤ NDF**: Acid detergent fiber cannot exceed neutral detergent fiber
- **ADL ≤ ADF**: Acid detergent lignin cannot exceed acid detergent fiber
- **ME > NEm/NEg/NEl**: Metabolizable energy must be greater than net energy values

### Rule 5: Required Fields
- **Reference**: Must be present and unique
- **Crop name**: Must be populated (from controlled vocabulary)
- **At least one nutritional parameter**: Must have some nutritional data

### Rule 6: Feed Type Validation
Valid feed type categories (based on dataset_final.csv):
1. Herbaceous forages
2. Fodder trees and shrubs
3. Food crops: cereals & legumes, green
4. Food crops: cereals & legumes, residues
5. Food crops: roots & tubers
6. Food crops: others
7. Concentrate feeds and agro-industrial by-products
8. Mineral supplements
9. Other less common feeds

## Usage

### Command Line
```bash
Rscript validate_new_data.R your_data_file.csv
```

### From R
```r
source("validate_new_data.R")
result <- validate_new_data("your_data_file.csv")
```

## Output
- **PASS**: Validation rule passed
- **FAIL**: Validation rule failed with details
- **STATUS**: 
  - `APPROVED`: Data ready for import
  - `REJECTED`: Issues must be addressed before import
- **Return value**: `TRUE` if all validations pass, `FALSE` otherwise

## Data Structure Requirements
The input CSV file must match the structure of `dataset_final.csv` with columns:
- s.n, Reference, Feed type, Crop name, Plant part, Maturity, Location
- Genus, Species, Scientific name, Country
- Nutritional parameters: DM, ADF, NDF, ADL, CP, OM, P, Ca, Na, Fe, K, Mg, Cu, Mn, Zn, IVDMD, ME, Neg, Nel, Nem
- Feed Name

## Error Handling
- Missing columns are detected and reported
- Non-numeric values in nutritional parameters are flagged
- Out-of-range values are identified with specific limits
- Biological constraint violations are detailed
- Invalid feed types are listed

## Integration
This validation script should be run on all new data before adding to the database to ensure data quality and consistency with existing records.