#' Get prism metadata
#' 
#' Retrieves prism metadata for a given type, temporal period, and dates. The 
#' metadata is retrieved from the .info.txt files.
#' 
#' @details   
#' The metadata includes the following variables from the .info.txt file for 
#' daily, monthly, and annual data:
#' - PRISM_DATASET_FILENAME
#' - PRISM_DATASET_CREATE_DATE
#' - PRISM_DATASET_TYPE
#' - PRISM_DATASET_VERSION
#' - PRISM_CODE_VERSION
#' - PRISM_DATASET_REMARKS
#' 
#' Additionally, two local variables are added identifying where the file is 
#' located on the local system:
#' - file_path
#' - folder_path
#' 
#' The annual and monthly normals data includes different keys in 
#' the .info.txt, so they are renamed to be the same as those found in the 
#' other temporal data. The keys/variables are renamed as follows:
#' - PRISM_FILENAME --> PRISM_DATASET_FILENAME
#' - PRISM_CREATE_DATE --> PRISM_DATASET_CREATE_DATE
#' - PRISM_DATASET --> PRISM_DATASET_TYPE
#' - PRISM_VERSION --> PRISM_CODE_VERSION
#' - PRISM_REMARKS --> PRISM_DATASET_REMARKS
#' 
#' Additionally, the normals does not include PRISM_DATASET_VERSION, so that 
#' variable is added with `NA` values.
#'   
#' @inheritParams prism_data_subset
#' 
#' @return data.frame containing metadata for all specified dates.
#' 
#' @export
prism_data_get_md <- function(type, temp_period, years = NULL, mon = NULL, 
                              minDate = NULL, maxDate = NULL, dates = NULL, 
                              resolution = NULL)
{
  prism_check_dl_dir()
  
  final_folders <- prism_data_subset(type, temp_period, years = years, 
                                         mon = mon, minDate = minDate, 
                                         maxDate = maxDate, dates = dates,
                                         resolution = resolution)
  
  final_txt_full <- file.path(
    prism_get_dl_dir(), 
    final_folders, 
    paste0(final_folders, ".info.txt")
  )
  
  if(length(final_txt_full) == 0){
    stop("No files exist to obtain metadata from.")
  }
  out <- lapply(1:length(final_txt_full), function(i) {
    readin <- tryCatch(
      utils::read.delim(
        final_txt_full[i], 
        sep = "\n", 
        header = FALSE, 
        stringsAsFactors = FALSE
      ),
      error = function(e) {
        warning(e)
        warning(paste0(
          "Problem opening ", 
          final_txt_full[i], 
          ". The folder may exist without the .info.text file inside it."
        ))
      }
    )
    str_spl <- stringr::str_split(
      as.character(readin[[1]]), 
      ": ", 
      n = 2, 
      simplify = TRUE
    )
    
    names_md <- str_spl[, 1]
    data_md <- str_spl[, 2]
    out <- matrix(data_md, nrow = 1)
    out <- as.data.frame(out, stringsAsFactors = FALSE)
    names(out) <- names_md
    
    # add in two additional values (not found in .info.txt)
    out$file_path <- final_txt_full[i]
    out$folder_path <- file.path(prism_get_dl_dir(), final_folders[i])
    
    out
  })
  
  out <- dplyr::bind_rows(out)
  
  # update column names for normals to match those from other time periods
  if (temp_period %in% c("monthly normals", "annual normals")) {
    # rename columns
    colnames(out) <- normals_name_map()[colnames(out)]
    # add empty column 
    out[["PRISM_DATASET_VERSION"]] <- NA
    
    message(
      "Renaming variables for normals to match those for other temporal periods.\n",
      "See details in ?prism_data_get_md."
    )
  } 
  
  out
}

normals_name_map <- function() {
  c(
    "PRISM_FILENAME" = "PRISM_DATASET_FILENAME",     
    "PRISM_CREATE_DATE" = "PRISM_DATASET_CREATE_DATE",  
    "PRISM_DATASET" = "PRISM_DATASET_TYPE",         
    "PRISM_VERSION" = "PRISM_CODE_VERSION",         
    "PRISM_REMARKS" = "PRISM_DATASET_REMARKS",
    "file_path" = "file_path",
    "folder_path" = "folder_path"
  )
}
