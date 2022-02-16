# Minimal example START
# library(targets)
# library(tarchetypes)
# source("R/functions.R")
# options(tidyverse.quiet = TRUE)
# tar_option_set(packages = c("dplyr", "ggplot2", "readr", "tidyr"))
# list(
#     tar_target(
#         raw_data_file,
#         "data/raw_data.csv",
#         format = "file"
#     ),
#     tar_target(
#         raw_data,
#         read_csv(raw_data_file, col_types = cols())
#     ),
#     tar_target(
#         data,
#         raw_data %>%
#             filter(!is.na(Ozone))
#     ),
#     tar_target(fit, fit_mod(data))
# )
# Minimal example END

# # Future targets locally START
# library(targets)
# library(tarchetypes)
# library(future)
# library(future.batchtools)
# library(future.callr)
# plan(callr)
# source("R/functions.R")
# options(tidyverse.quiet = TRUE)
# tar_option_set(packages = c("dplyr", "ggplot2", "readr", "tidyr"))
# list(
#     tar_target(
#         raw_data_file,
#         "data/raw_data.csv",
#         format = "file"
#     ),
#     tar_target(
#         raw_data,
#         read_csv(raw_data_file, col_types = cols())
#     ),
#     tar_target(
#         data,
#         raw_data %>%
#             filter(!is.na(Ozone))
#     ),
#     tar_target(fit, fit_mod(data))
# )
# # Future targets locally END

# Future targets remotely on the droplet START
library(targets)
library(tarchetypes)
library(future)
library(future.batchtools)
library(future.callr)

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

plan(cluster, workers = cl)

species_table_mk_dir <- function() {
    here::here("data/supporting")
}

source("R/functions.R")

options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("dplyr", "ggplot2", "readr", "tidyr"))
list(
    # Species table directory
    tar_target(
        name = species_table,
        command = species_table_mk_dir(),
        format = "file",
    ),

    # Species table load
    tar_target(
        name = species,
        command = species_read_csv(species_table),
    ),

    # Species write
    tar_target(
        name = species_out,
        command = species_write_csv(species)
    )
)
# Future targets remotely END