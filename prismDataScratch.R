options(prism.path= "~/Documents/scratch/prismpath")
get_prism_normals("tmean","4km", annual = T)
library(ggplot2)
library(reshape2)
library(gridExtra)



# for visualization discretize the color scale
color_breaks <- c(0, 100, 500, 1000, 1500, 2000, 3000, 4000, 6000, 9000)
color_labels <- c(100, 500, 1000, 1500, 2000, 3000, 4000, 6000, 9000)

prism_cols <- 1405
prism_rows <- 621

# get annual totals for each grid, from 1895 to 2012

out_data <- array(data = NA, dim = c(prism_rows, prism_cols, length(seq(beg_year, end_year))))

path <- "/Users/thart/Documents/scratch/prismpath/PRISM_tmean_30yr_normal_4kmM2_annual_bil/PRISM_tmean_30yr_normal_4kmM2_annual_bil.bil"

prism_data <- readGDAL(path,silent = TRUE)
ann_tot <- prism_data@data$band1
ann_tot <- matrix(ann_tot, nrow = prism_rows, ncol = prism_cols, byrow = TRUE)

image(ann_tot)
j <- list()
j[["jenna"]] <- rnorm(100)
