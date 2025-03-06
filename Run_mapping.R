################### ENHANCED MOSQUITO MAPS ###################

# Load required packages
library(sf)
library(ggplot2)
library(readxl)
library(dplyr)
library(viridis) # For enhanced color palettes

#################################################
# STEP 1: READ DATA
#################################################

# Set path to your desktop - you'll need to adjust this
desktop_path <- "C:/Users/zachp/OneDrive/Desktop"
setwd(desktop_path)

# Read the national shapefile
counties <- st_read("tl_2024_us_county.shp", quiet = TRUE)

# Filter for just Nebraska counties (STATEFP "31" is Nebraska)
ne <- counties[counties$STATEFP == "31", ]

# Read the Excel file
mosquito_data_raw <- read_excel("x.xlsx", sheet = 1)

#################################################
# STEP 2: PREPARE DATA
#################################################

# Extract data for each mosquito type
all_mosquitoes_data <- data.frame(
  County = mosquito_data_raw[[1]],  # Column A - counties for all mosquitoes
  Count = mosquito_data_raw[[2]]    # Column B - count values for all mosquitoes
)

tarsalis_data <- data.frame(
  County = mosquito_data_raw[[4]],  # Column D - counties for C. tarsalis
  Count = mosquito_data_raw[[5]]    # Column E - count values for C. tarsalis
)

pipiens_data <- data.frame(
  County = mosquito_data_raw[[7]],  # Column G - counties for C. pipiens
  Count = mosquito_data_raw[[8]]    # Column H - count values for C. pipiens
)

# Remove rows with NA county names (blank rows)
all_mosquitoes_data <- all_mosquitoes_data[!is.na(all_mosquitoes_data$County), ]
tarsalis_data <- tarsalis_data[!is.na(tarsalis_data$County), ]
pipiens_data <- pipiens_data[!is.na(pipiens_data$County), ]

# Add "County" suffix to match shapefile names
all_mosquitoes_data$County <- paste0(all_mosquitoes_data$County, " County")
tarsalis_data$County <- paste0(tarsalis_data$County, " County")
pipiens_data$County <- paste0(pipiens_data$County, " County")

# Make sure Scotts Bluff has the right values
if (!"Scotts Bluff County" %in% all_mosquitoes_data$County) {
  all_mosquitoes_data <- rbind(all_mosquitoes_data, 
                               data.frame(County = "Scotts Bluff County", Count = 10138))
}
if (!"Scotts Bluff County" %in% tarsalis_data$County) {
  tarsalis_data <- rbind(tarsalis_data, 
                         data.frame(County = "Scotts Bluff County", Count = 7600))
}

# Add a fake county with >5000 value to ensure the category shows up in legend
fake_county <- "FAKE County"
all_mosquitoes_data <- rbind(all_mosquitoes_data, data.frame(County = fake_county, Count = 5001))
tarsalis_data <- rbind(tarsalis_data, data.frame(County = fake_county, Count = 5001))

# For pipiens, find the max value
max_pipiens <- max(pipiens_data$Count, na.rm = TRUE)
cat("Maximum value for pipiens data:", max_pipiens, "\n")

#################################################
# STEP 3: ENHANCED MAPPING FUNCTIONS
#################################################

# Function for All Mosquitoes and C. tarsalis maps (with >5000 category)
create_enhanced_map_with_5000 <- function(data, title, color_scheme = "red") {
  
  # Create a working copy of the data
  plot_data <- data
  
  # Exclude our fake county
  plot_data$Count[plot_data$County == "FAKE County"] <- NA
  
  # Join the mosquito data with the shape file
  ne_data <- left_join(ne, plot_data, by = c("NAMELSAD" = "County"))
  
  # Fill NAs with 0 for proper legend display
  ne_data$Count[is.na(ne_data$Count)] <- 0
  
  # Create categories using the breaks with >5000 category
  ne_data$category <- cut(
    ne_data$Count,
    breaks = c(-Inf, 0, 10, 100, 500, 1000, 3000, 5000, Inf),
    labels = c("0", "1-10", "10-100", "100-500", "500-1000", "1000-3000", "3000-5000", ">5000"),
    include.lowest = TRUE
  )
  
  # Set enhanced colors based on the color scheme
  if (color_scheme == "red") {
    # Enhanced red palette with more saturation and contrast
    colors <- c(
      "0" = "#F8F8F8",         # Very light gray (not pure white)
      "1-10" = "#FECC5C",      # Brighter yellow
      "10-100" = "#FD8D3C",    # Brighter orange
      "100-500" = "#F03B20",   # Brighter orange-red
      "500-1000" = "#BD0026",  # Brighter red
      "1000-3000" = "#7F0000", # Darker red
      "3000-5000" = "#4A0000", # Very dark red
      ">5000" = "#2A0000"      # Almost black red
    )
  } else if (color_scheme == "blue") {
    # Enhanced blue palette with more saturation and contrast
    colors <- c(
      "0" = "#F8F8F8",         # Very light gray (not pure white)
      "1-10" = "#D1E5F0",      # Brighter light blue
      "10-100" = "#92C5DE",    # Brighter medium-light blue
      "100-500" = "#4393C3",   # Brighter medium blue
      "500-1000" = "#2166AC",  # Brighter medium-dark blue
      "1000-3000" = "#0D52A1", # Brighter dark blue
      "3000-5000" = "#08306B", # Darker blue
      ">5000" = "#041E42"      # Almost black blue
    )
  }
  
  # Create the enhanced map with thicker borders and improved styling
  p <- ggplot() +
    # County base layer with emphasized borders
    geom_sf(data = ne_data, aes(fill = category), color = "black", size = 0.3) +
    # Add county outlines with slightly thicker borders for high count areas
    geom_sf(data = subset(ne_data, Count > 1000), fill = NA, color = "black", size = 0.6) +
    scale_fill_manual(values = colors, name = "Count", drop = FALSE) +
    theme_minimal() +
    ggtitle(title) +
    theme(
      plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
      legend.position = "right",
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 10),
      panel.grid = element_blank(),
      axis.text = element_text(size = 9)
    )
  
  return(p)
}

# Function for C. pipiens map (without >5000 category)
create_enhanced_map_without_5000 <- function(data, title) {
  
  # Create a working copy of the data
  plot_data <- data
  
  # Join the mosquito data with the shape file
  ne_data <- left_join(ne, plot_data, by = c("NAMELSAD" = "County"))
  
  # Fill NAs with 0 for proper legend display
  ne_data$Count[is.na(ne_data$Count)] <- 0
  
  # Create categories using the breaks WITHOUT >5000 category
  ne_data$category <- cut(
    ne_data$Count,
    breaks = c(-Inf, 0, 10, 100, 500, 1000, 3000, Inf),
    labels = c("0", "1-10", "10-100", "100-500", "500-1000", "1000-3000", ">3000"),
    include.lowest = TRUE
  )
  
  # Enhanced green color scheme with more saturation
  colors <- c(
    "0" = "#F8F8F8",         # Very light gray (not pure white)
    "1-10" = "#C7E9C0",      # Brighter light green
    "10-100" = "#A1D99B",    # Brighter medium-light green
    "100-500" = "#74C476",   # Brighter medium green
    "500-1000" = "#41AB5D",  # Brighter medium-dark green
    "1000-3000" = "#238B45", # Brighter dark green
    ">3000" = "#005A32"      # Very dark green
  )
  
  # Create the enhanced map with improved styling
  p <- ggplot() +
    # County base layer with emphasized borders
    geom_sf(data = ne_data, aes(fill = category), color = "black", size = 0.3) +
    # Add county outlines with slightly thicker borders for high count areas
    geom_sf(data = subset(ne_data, Count > 1000), fill = NA, color = "black", size = 0.6) +
    scale_fill_manual(values = colors, name = "Count", drop = FALSE) +
    theme_minimal() +
    ggtitle(title) +
    theme(
      plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
      legend.position = "right",
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 10),
      panel.grid = element_blank(),
      axis.text = element_text(size = 9)
    )
  
  return(p)
}

#################################################
# STEP 4: CREATE AND SAVE THE ENHANCED MAPS
#################################################

# 1. Enhanced All mosquitoes map
all_mosquito_map <- create_enhanced_map_with_5000(
  all_mosquitoes_data,
  "All Mosquito Distribution in Nebraska Counties",
  color_scheme = "red"
)

# Save the map with higher resolution
ggsave("enhanced_all_mosquitoes_map.png", all_mosquito_map, width = 12, height = 7, dpi = 400)

# 2. Enhanced C. tarsalis map
tarsalis_map <- create_enhanced_map_with_5000(
  tarsalis_data,
  "C. tarsalis Distribution in Nebraska Counties",
  color_scheme = "blue"
)

# Save the map with higher resolution
ggsave("enhanced_tarsalis_map.png", tarsalis_map, width = 12, height = 7, dpi = 400)

# 3. Enhanced C. pipiens complex map
pipiens_map <- create_enhanced_map_without_5000(
  pipiens_data,
  "C. pipiens complex Distribution in Nebraska Counties"
)

# Save the map with higher resolution
ggsave("enhanced_pipiens_map.png", pipiens_map, width = 12, height = 7, dpi = 400)

# Print confirmation message
cat("\n==== ENHANCED MOSQUITO MAPS CREATED ====\n")
cat("All maps have been enhanced with:\n")
cat("1. More saturated, vibrant colors to make hotspots stand out\n")
cat("2. Thicker borders around high-count counties\n")
cat("3. Improved contrast between color categories\n")
cat("4. Higher resolution output files\n")
cat("5. Slightly enlarged and bold text for better readability\n")
cat("\nFiles created:\n")
cat("- enhanced_all_mosquitoes_map.png (Enhanced red scheme)\n")
cat("- enhanced_tarsalis_map.png (Enhanced blue scheme)\n")
cat("- enhanced_pipiens_map.png (Enhanced green scheme)\n")
