library(ssh)
library(tidyverse)
library(analogsea)
library(targets)
library(future)
library(future.batchtools)
library(furrr)
library(tictoc)

# Path to public SSH key
ssh_key_file <- "~/.ssh/id_rsa"

# Check on available droplet sizes and information
analogsea::sizes()

# After selecting one, create it
droplet1 <- docklet_create(region = "nyc3", size = "s-1vcpu-1gb", ssh_keys = "Analogsea")

# Now, pull in the docker container with everything we need...
droplet(droplet1$id) %>%
    docklet_pull("ajall1985/gmri_rocker:v4.1.2", keyfile = ssh_key_file)

# Get IP addresses
ip1 <- droplet(droplet1$id)$networks$v4[[1]]$ip_address
ips <- c(ip1)

rscript <- c(
    "sudo", "docker", "run", "--net=host",
    "ajall1985/gmri_rocker:v4.1.2", "Rscript"
)

# Connect and create a cluster
cl <- makeClusterPSOCK(
    ips,

    # User name; DO droplets use root by default
    user = "root",

    # Use private SSH key registered with DO
    rshopts = c(
        "-o", "StrictHostKeyChecking=no",
        "-o", "IdentitiesOnly=yes",
        "-i", ssh_key_file
    ),
    rscript = rscript,

    # Things to run each time the remote instance starts
    rscript_args = c(
        # Set up .libPaths() for the root user
        "-e", shQuote("local({p <- Sys.getenv('R_LIBS_USER'); dir.create(p, recursive = TRUE, showWarnings = FALSE); .libPaths(p)})"),
        # Make sure the remote computer uses all CPU cores with Stan
        "-e", shQuote("options(mc.cores = parallel::detectCores())")
    ),
    dryrun = FALSE
)

# Use the cluster of computers as the backend for future and furrr functions
plan(cluster, workers = cl)

# We'll use gapminder data to estimate the relationship between health and
# wealth in each continent using a Bayesian model

# Process and manipulate data locally
# Nest continent-based data frames into one larger data frame
gapminder_to_model <- gapminder %>%
    group_by(continent) %>%
    nest() %>%
    # Not enough observations here, so ignore it
    filter(continent != "Oceania")
gapminder_to_model
#> # A tibble: 4 x 2
#>   continent data
#>   <fct>     <list>
#> 1 Asia      <tibble [396 × 5]>
#> 2 Europe    <tibble [360 × 5]>
#> 3 Africa    <tibble [624 × 5]>
#> 4 Americas  <tibble [300 × 5]>

# Fit a simple model
model_to_run <- function(df) {
    model_lm <- lm(lifeExp ~ gdpPercap + country,
        data = df
    )
    return(model_lm)
}

# Use future_map to outsource each of the continent-based models to a different
# remote computer, where it will be run with all 4 remote cores
tic()
gapminder_models <- gapminder_to_model %>%
    mutate(model = data %>% future_map(~ model_to_run(.x)))
toc()


# What about if we have a targets workflow?
# To start off with, give the targets minimal example a shot by copying over all of the relevant folders. Head over to the [Targets minimal example](https://github.com/wlandau/targets-minimal) and then copy over files to this directory to create a `data/raw_data.csv` file, a `R/functions.R` file and a `_targets.R` file.

# That seemed to work. What about future targets?