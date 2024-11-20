# Load libraries
library(dplyr)
library(ggplot2)
library(cowplot)
library(lubridate)
library(tidyr)

# Define the newspapers and their directories. 
# *****Change to most recent date when updating****

outlets <- list(
  bbcnewsnight = "bsky_data/bbcnewsnight_2024-11-18/posts/",
  telegraph = "bsky_data/tgraph_2024-11-18/posts/",
  guardian = "bsky_data/guardian_2024-11-18/posts/"
)

# Create the processed directory
processed_dir <- "bsky_data/processed/"
if (!dir.exists(processed_dir)) dir.create(processed_dir, recursive = TRUE)

# Get today's date for processing
processing_date <- Sys.Date()

# Load posts from each outlet
for (source in names(outlets)) {
  post_files <- list.files(outlets[[source]], full.names = TRUE, pattern = "\\.rds$")
  
  # Create a data frame for users with no posts
  users <- basename(post_files) %>% gsub("\\.rds$", "", .)
  source_posts <- lapply(post_files, function(file) {
    data <- readRDS(file)
    if (is.data.frame(data) && nrow(data) > 0) {
      # Valid data with rows
      data <- data %>% mutate(source = source)  # Add source label
    } else {
      # Handle empty or missing data
      data <- data.frame(
        author_handle = gsub("\\.rds$", "", basename(file)),  # Extract username from filename
        source = source,
        uri = NA,
        cid = NA,
        text = NA,
        reply_count = NA,
        repost_count = NA,
        like_count = NA,
        stringsAsFactors = FALSE
      )
    }
    return(data)
  })
  
  # Bind rows for each source
  all_posts[[source]] <- bind_rows(source_posts)
}

# Combine all posts into one dataset
combined_posts <- bind_rows(all_posts)

# Create a filename with a date suffix
output_file <- file.path(processed_dir, paste0("combined_posts_", processing_date, ".rds"))

# Save the combined dataset with a date suffix
saveRDS(combined_posts, output_file)



# Define the newspapers and their directories. 
# *****Change to most recent date when updating****
outlets <- list(
  bbcnewsnight = "bsky_data/bbcnewsnight_2024-11-18/userinfo/",
  telegraph = "bsky_data/tgraph_2024-11-18/userinfo/",
  guardian = "bsky_data/guardian_2024-11-18/userinfo/"
)

# Initialize an empty list to store user information
all_userinfo <- list()

# Create the processed directory
processed_dir <- "bsky_data/processed/"
if (!dir.exists(processed_dir)) dir.create(processed_dir, recursive = TRUE)

# Get today's date for processing
processing_date <- Sys.Date()

# Load user information from each outlet
for (source in names(outlets)) {
  userinfo_files <- list.files(outlets[[source]], full.names = TRUE, pattern = "\\.rds$")
  
  # Create a data frame for missing user info
  users <- basename(userinfo_files) %>% gsub("\\.rds$", "", .)
  source_userinfo <- lapply(userinfo_files, function(file) {
    data <- readRDS(file)
    if (is.data.frame(data) && nrow(data) > 0) {
      # Valid data with rows
      data <- data %>% mutate(source = source)  # Add source label
    }
    return(data)
  })
  
  # Bind rows for each source
  all_userinfo[[source]] <- bind_rows(source_userinfo)
}

# Combine all user information into one dataset
combined_userinfo <- bind_rows(all_userinfo)

# Create a filename with a date suffix
output_file <- file.path(processed_dir, paste0("combined_userinfo_", processing_date, ".rds"))

# Save the combined user information dataset with a date suffix
saveRDS(combined_userinfo, output_file)