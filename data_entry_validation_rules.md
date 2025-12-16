# Data Entry Validation Rules

## Mandatory Fields

All records MUST have values for:
- **Crop name** OR **Species**: At least one must be populated
- **Feed type**: Must be one of the 9 standardized categories
- **Country**: Geographic location required

## Feed Type Categories (Standardized)

Use ONLY these 9 categories:
1. Herbaceous forages
2. Food crops: cereals & legumes, residues
3. Food crops: cereals & legumes, green
4. Concentrate feeds and agro-industrial by-products
5. Fodder trees and shrubs
6. Food crops: roots & tubers
7. Mineral supplements
8. Other less common feeds
9. Food crops: others

## Prohibited Entries

### Feed Mixtures
DO NOT enter feed mixtures. Each feed must be a single ingredient.

**Prohibited patterns:**
- Multiple feeds separated by: `+`, `&`, `;`, `/`, `:`
- Words indicating mixtures: "and", "mixture", "mix", "intercrop"
- Examples to AVOID: "desho-vetch", "oat:vetch", "maize + lablab"

### Generic Names
DO NOT use generic or non-specific names.

**Prohibited generic names:**
- "grass hay" (specify species: e.g., "Rhodes grass hay")
- "pulse bran" (specify: e.g., "Chickpea bran")
- "legume" (specify: e.g., "Desmodium")
- "brachiaria" (specify: e.g., "Brachiaria brizantha")
- "silage" (specify: e.g., "Maize silage")
- "weed", "forbs" (specify species)

### Trial Codes
DO NOT use trial codes or accession numbers as feed names.

**Prohibited patterns:**
- Single letter + number: V1, V2, B1, T1
- Accession codes: B2-T10, 18659, ILRI-12345

### Local Names Only
DO NOT use only local names without standard names.

**Examples requiring standard names:**
- "nachibuto", "yimbro", "yimrao" → Add standard name
- "mogecho", "nalleto", "gero" → Add standard name

## Naming Standards

### Crop Name Format
- Use common name in English
- Remove parenthetical information: "Napier grass (Bana)" → "Napier grass"
- Remove accession numbers: "B.Mutica (18659)" → "Brachiaria mutica"
- Use full species name, not abbreviations: "B. mutica" → "Brachiaria mutica"

### Scientific Name Format
- Use binomial nomenclature: Genus species
- Capitalize genus, lowercase species: "Cenchrus purpureus"
- No abbreviations: "C. purpureus" → "Cenchrus purpureus"

## Nutritional Data Validation

### Percentages (0-100%)
- DM (Dry Matter)
- OM (Organic Matter)
- ADF (Acid Detergent Fiber)
- NDF (Neutral Detergent Fiber)
- ADL (Acid Detergent Lignin)
- CP (Crude Protein)
- IVDMD (In Vitro Dry Matter Digestibility)

### Energy (0-1000 MJ/kg DM)
- ME (Metabolizable Energy)
- Nem (Net Energy for Maintenance)
- Neg (Net Energy for Gain)
- Nel (Net Energy for Lactation)

### Minerals (0-1000 g/kg DM)
- Ca (Calcium)
- P (Phosphorus)
- K (Potassium)
- Mg (Magnesium)

### Trace Minerals (0-Inf ppm DM)
- Cu (Copper)
- Fe (Iron)
- Mn (Manganese)
- Na (Sodium)
- Zn (Zinc)

## Biological Constraints

### Must NOT Violate:
- **ADF > NDF**: ADF must be ≤ NDF
- **OM > 100%**: Organic Matter cannot exceed 100%
- **DM = 0**: Dry Matter must be > 0
- **DM > 100%**: Dry Matter cannot exceed 100%
- **CP > 60%**: Crude Protein rarely exceeds 60% (verify if true)

## Data Entry Checklist

Before submitting new data, verify:

- [ ] No duplicate records
- [ ] No feed mixtures
- [ ] No generic names (all feeds specifically identified)
- [ ] No trial codes or accession numbers as names
- [ ] Crop name OR Species populated
- [ ] Feed type is one of 9 standard categories
- [ ] Scientific names use proper binomial format
- [ ] All nutritional values within valid ranges
- [ ] No biological constraint violations
- [ ] Country field populated
- [ ] Reference/citation provided

## Validation Process

1. **Before Entry**: Review data against this checklist
2. **After Entry**: Run `validate_new_data.R` script
3. **Address Issues**: Fix any warnings before final submission
4. **Final Check**: Ensure validation script returns "APPROVED"
