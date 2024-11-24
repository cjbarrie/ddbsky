# Load required libraries
library(dplyr)
library(data.table)
library(atrrr)
library(pbapply)

# Define paths
panel_users_file <- "bsky_data/processed/panel_users.rds"
follows_dir <- "bsky_data/follows/"
processed_dir <- "bsky_data/processed/"
output_follows_file <- file.path(processed_dir, "panel_follows.rds")
output_unique_follows_file <- file.path(processed_dir, "unique_followed_accounts.rds")

# Get today's date for processing
processing_date <- Sys.Date()

# Load panel users
panel_users <- readRDS(panel_users_file)

# Get unique handles of panel users
panel_handles <- panel_users$author_handle

# Initialize a data table to store all follows
all_follows <- data.table(actor_handle = character(), follower = character())

# Function to process follows for a single user
process_user_follows <- function(user) {
  user_subdirs <- list.dirs(follows_dir, recursive = FALSE, full.names = TRUE)
  user_subdirs <- user_subdirs[grepl(paste0("^", user, "_"), basename(user_subdirs))]
  
  if (length(user_subdirs) == 0) {
    message(sprintf("No follows data found for user %s. Skipping.", user))
    return(data.table(actor_handle = character(), follower = character()))
  }
  
  user_follows <- data.table(actor_handle = character(), follower = character())
  
  for (subdir in user_subdirs) {
    follows_files <- list.files(subdir, pattern = "\\.rds$", full.names = TRUE)
    for (file in follows_files) {
      follows_data <- readRDS(file)
      if ("actor_handle" %in% colnames(follows_data)) {
        user_follows <- rbindlist(list(user_follows, data.table(
          actor_handle = follows_data$actor_handle,
          follower = user
        )), use.names = TRUE)
      }
    }
  }
  return(user_follows)
}

# Process all users with a progress bar
all_follows_list <- pblapply(panel_handles, process_user_follows)
all_follows <- rbindlist(all_follows_list, use.names = TRUE)

# Deduplicate follows data
all_follows <- unique(all_follows)

# Extract unique followed accounts
unique_followed_accounts <- unique(all_follows[, .(actor_handle)])

# Save the panel follows data with the processing date in the filename
panel_follows_file <- file.path(processed_dir, paste0("panel_follows_", processing_date, ".rds"))
saveRDS(unique_followed_accounts, panel_follows_file)
