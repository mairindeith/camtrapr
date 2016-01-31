#' Check camera trap photos & directories
#'
#' @param path character; base path for all photos
#'
#' @return \code{cam_check} returns an S3 object of class "cam_check", which is
#'        a named list with each element corresponding to results of a different
#'        check. Call \code{print} to see a summary of the number of errors, or
#'        potential errors, found in each category.
#' @export
#' @examples
#' messy_path <- system.file("extdata", "messy", package = "camtrapr")
#' checks <- cam_check(messy_path)
#' checks
#' checks$directory_problem
#' checks$species
cam_check <- function(path) {
  assertthat::assert_that(is.character(path),
                          length(path) == 1,
                          dir.exists(path))
  path <- normalizePath(path, mustWork = FALSE)

  # list all jpegs in given folder
  photos <- list.files(path,pattern = "\\.(jpg|jpeg)$", ignore.case = TRUE,
                       recursive = TRUE)
  assertthat::assert_that(length(photos) > 0)

  # ignore directories
  ignore <- find_ignore(photos)
  ignore_photos <- photos[ignore]
  photos <- photos[!ignore]

  # missing dates
  dt <- exif_date(photos, error = FALSE)
  missing_dt_photos <- photos[!is.na(dt)]

  # bad subdirectory structure
  bad_sd <- find_bad_sd(photos)
  bad_sd_photos <- photos[bad_sd]
  photos <- photos[!bad_sd]

  # check counts
  counts <- basename(dirname(photos))
  bad_counts <- find_bad_counts(counts)
  bad_count_dirs <- unique(dirname(photos)[bad_counts])

  # check directories for nonstandard characters
  base_dirs <- unique(dirname(dirname(photos)))
  bad_names <- find_bad_names(base_dirs)
  bad_name_dirs <- base_dirs[bad_names]

  # unique sites, cams, and species
  species <- sort(unique(basename(base_dirs)))
  camera <- unique(dirname(base_dirs))
  site <- unique(dirname(dirname(base_dirs)))

  structure(
    list(
      ignore = ignore_photos,
      directory_problem = bad_sd_photos,
      missing_dates = missing_dt_photos,
      name_problem = bad_name_dirs,
      count_problem = bad_count_dirs,
      site = site,
      camera = camera,
      species = species
    ),
    class = "cam_check"
  )
}

#' @export
print.cam_check <- function(x, ...) {
  cat("# photos in ignored directories (ignore): ", length(x$ignore), "\n")
  cat("# photo in non-standard directories (directory_problem): ",
      length(x$directory_problem), "\n")
  cat("# photos with datetime or EXIF problems (missing_dates): ",
                length(x$missing_dates), "\n")
  cat("# naming problems (name_problem): ", length(x$name_problem), "\n")
  cat("# count directory parse errors (count_problem): ",
      length(x$count_problem), "\n")
  cat("# sites (site): ", length(x$site), "\n")
  cat("# cameras (camera): ", length(x$camera), "\n")
  cat("# species (species): ", length(x$species), "\n")
}
