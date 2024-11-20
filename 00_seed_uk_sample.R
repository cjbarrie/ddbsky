# Load libraries
library(atrrr)

# Function to create directories
create_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
}

# Define the outlets and their handles
outlets <- list(
  bbcnewsnight = "bbcnewsnight.bsky.social",
  guardian = 'did:plc:vovinwhtulbsx4mwfw26r5ni',
  tgraph = "telegraphnews.bsky.social"
)

# Base directory for saving data
base_dir <- "bsky_data"
create_dir(base_dir)

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

# Loop through each outlet to get followers, posts, and user info
for (outlet in names(outlets)) {
  outlet_handle <- outlets[[outlet]]
  
  # Create directories with collection date suffix
  outlet_dir <- file.path(base_dir, paste0(outlet, "_", collection_date))
  create_dir(outlet_dir)
  
  # Save followers
  followers <- get_followers(actor = outlet_handle, limit = 15000)$actor_handle
  followers_path <- file.path(outlet_dir, "followers.rds")
  safe_save_rds(data.frame(handle = followers), followers_path)
  
  # Create subdirectories for posts and user info
  posts_dir <- file.path(outlet_dir, "posts")
  userinfo_dir <- file.path(outlet_dir, "userinfo")
  create_dir(posts_dir)
  create_dir(userinfo_dir)
  
  # Get posts and user info for each follower
  for (follower in followers) {
    tryCatch({
      # Get user info
      user_info <- get_user_info(actor = follower)
      userinfo_path <- file.path(userinfo_dir, paste0(follower, ".rds"))
      safe_save_rds(user_info, userinfo_path)
      
      # Get posts
      user_posts <- get_skeets_authored_by(actor = follower, limit = 1500L, parse = TRUE) #1500L limit for first run. 100kL thereafter
      posts_path <- file.path(posts_dir, paste0(follower, ".rds"))
      safe_save_rds(user_posts, posts_path)
    }, error = function(e) {
      message(sprintf("Error processing %s: %s", follower, e$message))
    })
  }
}
