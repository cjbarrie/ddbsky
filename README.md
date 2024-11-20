# BlueSky UK Sampling Project

This repository contains scripts to sample, collect, process, and analyze data from BlueSky users who follow key UK news outlets. The project is organized into three main steps:

---

## **Scripts Overview**

### 1. **`00_seed_uk_sample.R`**
- **Purpose**: Collects the initial sample of BlueSky users who follow specific UK news outlets.
- **Process**:
  - Identifies followers of three key outlets: BBC Newsnight, The Guardian, and The Telegraph.
  - For each follower:
    - Fetches user information and their authored posts.
    - Saves the data into directories named by outlet and date.
- **Output**:
  - User information and post data saved in directories such as `bsky_data/bbcnewsnight_<date>`.

### 2. **`01_process_uk_sample.R`**
- **Purpose**: Processes and combines the data collected in the previous step into unified datasets.
- **Process**:
  - Combines all user information files into `combined_userinfo_<date>.rds`.
  - Combines all post files into `combined_posts_<date>.rds`.
- **Output**:
  - Combined datasets saved in `bsky_data/processed/`.

### 3. **`02_get_follows.R`**
- **Purpose**: Collects the list of accounts followed by users in the combined sample.
- **Process**:
  - Reads the combined user information dataset.
  - Fetches the list of accounts each user follows.
  - Saves this data into user-specific directories named with the collection date.
- **Output**:
  - Follows data saved in directories such as `bsky_data/follows/<user>_<date>`.

---

## **Overall Sampling Strategy**

1. **Seed Selection**:
   - Begin with followers of key UK news outlets (BBC Newsnight, The Guardian, The Telegraph).

2. **User Information**:
   - Collect metadata and post activity for each follower.

3. **Follow Network**:
   - Record who each user in sample follows so we have record of (potential) information exposure for each user.

---

## **Getting Started**

To replicate:
1. Run `00_seed_uk_sample.R` to collect the initial data.
2. Run `01_process_uk_sample.R` to combine the data into unified datasets.
3. Run `02_get_follows.R` to retrieve the network of accounts followed by the sampled users.

---
