# Load libraries
library(dplyr)
library(lubridate)

# Define input file
userinfo_file <- "bsky_data/processed/combined_userinfo_2024-11-18.rds"

# Define base directory for saving follows data
base_dir <- "bsky_data/follows"
if (!dir.exists(base_dir)) dir.create(base_dir, recursive = TRUE)

# Get today's date for collection
collection_date <- Sys.Date()

# Function to safely save data as .rds
safe_save_rds <- function(data, path) {
  tryCatch({
    saveRDS(data, path)
  }, error = function(e) {
    message(sprintf("Error saving data to %s: %s", path, e$message))
  })
}

# Load the user info dataset
userinfo <- readRDS(userinfo_file)

# Ensure the dataset contains the `actor_handle` column
if (!"actor_handle" %in% names(userinfo)) {
  stop("The userinfo dataset must contain an 'author_handle' column.")
}

# Process each user to get and save follows
for (user in userinfo$actor_handle) {
  tryCatch({
    # Get follows
    follows <- get_follows(actor = user, limit = 10000L)
    
    # Create a directory for the user with the date suffix
    user_dir <- file.path(base_dir, paste0(user, "_", collection_date))
    if (!dir.exists(user_dir)) dir.create(user_dir, recursive = TRUE)
    
    # Save the follows data
    follows_path <- file.path(user_dir, paste0("follows_", collection_date, ".rds"))
    safe_save_rds(data.frame(follows), follows_path)
    
    # Message for successful processing
    message(sprintf("Saved follows for user %s to %s", user, follows_path))
  }, error = function(e) {
    message(sprintf("Error processing follows for user %s: %s", user, e$message))
  })
}
