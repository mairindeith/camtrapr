#' Check camera trap photos & directories
#'
#' Check to ensure that a directory of camera trap photos is correctly organized
#' into subfolders.
#'
#' \code{\link{cam_process}} requires that camera trap photos are organized into
#' a strict, hierarchical directory structure. \code{cam_check} ensure that this
#' structure is adhered to and should always be run prior to
#' \code{\link{cam_process}}.
#'
#' Every photo should be placed into a series of directories such as
#' \code{site/camera/species/number/photo.jpg} where:
#'
#' \enumerate{
#'  \item \code{site}: names of the location where cameras were placed
#'  \item \code{camera}: unique identifiers for each camera
#'  \item \code{species}: name of species identified in photo
#'  \item \code{number}: number (e.g. 3) of individuals in photo. If the number
#'      of individuals is unknown use "x" for the directory name.
#'  \item \code{photo.jpg}: photos are placed at the end of this chain of
#'      directories, the actual name of the photo is irrelevant, but it must
#'      have an EXIF datetime stamp
#' }
#'
#' \code{cam_check} returns a named list with eight elements (each a character
#' vector) corresponding to the eight checks that it performs:
#'
#' \itemize{
#'  \item \code{ignore}: photos ignored because they're it directories
#'      named "ignore".
#'  \item \code{directory_problem}: photos that are not correctly nested within
#'      subdirectory structure.
#'  \item \code{missing_date}: photos that have no associated EXIF date
#'  \item \code{name_problem}: directories with spaces or special characters
#'      in the name; only letters, numbers, and _ or - should occur.
#'  \item \code{count_problem}: count directories that are not either integers
#'      or "x".
#'  \item \code{site}: alphabetic list of unique sites; check for typos.
#'  \item \code{camera}: alphabetic list of unique cameras; check for typos.
#'  \item \code{species}: alphabetic list of unique species; check for typos.
#' }
#'
#' @param path character; base path for all photos
#'
#' @return \code{cam_check} returns an S3 object of class "cam_check", which is
#'   a named list with each element corresponding to results of a different
#'   check. Call \code{print} to see a summary of the number of errors, or
#'   potential errors, found in each category.
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
  if (length(photos) == 0) {
    stop(paste0("No photos found in:\n", path))
  }

  # ignore directories
  ignore <- find_ignore(photos)
  ignore_photos <- photos[ignore]
  photos <- photos[!ignore]

  # missing dates
  dt <- exif_date(file.path(path, photos), error = FALSE)
  missing_dt_photos <- photos[is.na(dt)]

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
      missing_date = missing_dt_photos,
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
  cat("# photos in non-standard directories (directory_problem): ",
      length(x$directory_problem), "\n")
  cat("# photos with datetime or EXIF problems (missing_date): ",
                length(x$missing_date), "\n")
  cat("# naming problems (name_problem): ", length(x$name_problem), "\n")
  cat("# count directory parse errors (count_problem): ",
      length(x$count_problem), "\n")
  cat("# sites (site): ", length(x$site), "\n")
  cat("# cameras (camera): ", length(x$camera), "\n")
  cat("# species (species): ", length(x$species), "\n")
}
