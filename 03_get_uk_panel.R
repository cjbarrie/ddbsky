# Load required libraries
library(dplyr)

# Define paths
follows_dir <- "bsky_data/follows/"
processed_dir <- "bsky_data/processed/"
combined_posts_file <- file.path(processed_dir, "combined_posts_2024-11-18.rds")  # Update filename as needed
output_panel_posts_file <- file.path(processed_dir, "panel_posts.rds")
if (!dir.exists(processed_dir)) dir.create(processed_dir, recursive = TRUE)

# Get today's date for saving the panel
processing_date <- Sys.Date()

# Extract unique usernames from directory names
get_unique_usernames <- function(follows_dir) {
  # Get all subdirectory names (full paths)
  subdirs <- list.dirs(follows_dir, recursive = FALSE, full.names = FALSE)
  
  # Remove date suffixes from directory names to extract usernames
  unique_usernames <- gsub("_\\d{4}-\\d{2}-\\d{2}$", "", subdirs)
  
  # Return deduplicated usernames
  return(unique(unique_usernames))
}

# Extract unique usernames
unique_usernames <- get_unique_usernames(follows_dir)

# Select a random panel of 2000 unique users
set.seed(123L)  # For reproducibility
panel_users <- sample(unique_usernames, size = min(2000, length(unique_usernames)))

# Save the panel users as an .rds file
panel_users_file <- file.path(processed_dir, "panel_users.rds")
saveRDS(data.frame(author_handle = panel_users), panel_users_file)

# Get combined posts file
combined_posts <- readRDS(combined_posts_file)

# Filter combined posts for panel users
panel_posts <- combined_posts %>%
  filter(author_handle %in% panel_users)

# Save the filtered panel posts with the processing date in the filename
panel_posts_file <- file.path(processed_dir, paste0("panel_posts_", processing_date, ".rds"))
saveRDS(panel_posts, panel_posts_file)