# Nebraska Mosquito Distribution Mapping Project

## Overview
This R-based project creates detailed, enhanced geographic visualizations of mosquito populations across Nebraska counties. The project focuses on mapping three key mosquito datasets:
- Total mosquito population
- *Culex tarsalis* distribution
- *Culex pipiens* complex distribution

## Key Features
- Advanced geospatial data visualization using R
- Custom mapping functions with enhanced color schemes
- Detailed county-level mosquito population analysis
- High-resolution output maps (400 DPI)

## Visualization Highlights
- Vibrant, saturated color palettes to highlight population hotspots
- Thicker borders for counties with high mosquito counts
- Detailed count categorization (0, 1-10, 10-100, 100-500, etc.)
- Three distinct color schemes for different map types

## Technical Details
**Libraries Used:**
- `sf` for spatial data handling
- `ggplot2` for advanced mapping
- `readxl` for Excel file import
- `dplyr` for data manipulation
- `viridis` for color palettes

## Outputs
The project generates three high-resolution PNG maps:
1. `enhanced_all_mosquitoes_map.png` - Total mosquito population (red scheme)
2. `enhanced_tarsalis_map.png` - *Culex tarsalis* distribution (blue scheme)
3. `enhanced_pipiens_map.png` - *Culex pipiens* complex distribution (green scheme)

## Requirements
- R (with required libraries)
- US County shapefile
- Excel data file with mosquito population data

## Installation
1. Clone the repository
2. Install required R packages:
   ```R
   install.packages(c("sf", "ggplot2", "readxl", "dplyr", "viridis"))
   ```
3. Ensure you have the necessary input files:
   - US county shapefile (`tl_2024_us_county.shp`)
   - Excel data file (`x.xlsx`)

## Usage
Run the R script to generate the mosquito distribution maps:
```R
source("mosquito_mapping.R")
```

## Purpose
This project provides a detailed, visually compelling representation of mosquito population distribution in Nebraska, which can be valuable for:
- Ecological research
- Public health planning
- Pest control strategies

## License

## Contact
[Zach Pella/UNMC Data Scientist]

![all_mosquitoes_map](https://github.com/user-attachments/assets/23512d46-822b-4131-ba49-003b2ac0eec3)


![enhanced_pipiens_map](https://github.com/user-attachments/assets/e175d606-c7f8-4b0a-af4c-6cc4af185506)


![enhanced_tarsalis_map](https://github.com/user-attachments/assets/0286ddb9-f067-41f2-b9fc-755bd5157f8d)
