#' Process camera trap photos
#'
#' Process organized and identified camera trap photos into a dataframe.
#'
#' This function requires that animals in camera trap photos have been
#' identified and photos have been organized into a strict, hierarchical
#' directory structure. In brief, every photo should be placed into a series of
#' directories such as \code{site/camera/species/number/photo.jpg} where:
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
#' All these directory are placed within a top-level directory containing no
#' other files. It is this directory that is passed to \code{cam_process()}.
#' The recommended best practice is to only use underscores and lowercase
#' letters in all site, camera, and species directory names. Uppercase letters,
#' special characters, and whitespace should be avoided.
#'
#' It is critical that the directory structure is correct because
#' \code{cam_process()} will use this structure populate the resulting data
#' frame. As a result, it is highly recommended that users run
#' \code{\link{cam_check}} to find and correct any problems before
#' \code{cam_process()} is run.
#'
#' There are two special cases for directory names. Any directory named "ignore"
#' will be completely ignored, and so will it's subdirectories. A count
#' directory named "x" signals that the number of individuals in unknown and
#' that field should be populated with \code{NA}.
#'
#' @param path character; base path for all photos
#' @param clean_names logical idicating whether to clean up site, camera, and
#'   species names. If \code{TRUE}, leading and trailing whitespace is trimmed,
#'   any non-alphanumeric character (other than _ and -) will be converted to an
#'   underscore. WARNING: if names are cleaned it is possible that previously
#'   unique site, camera, or species names will no longer be unique.
#' @param verbose logical indicating whether to print messages highlighting
#'   potential issues including directories than have been ignore, invalid
#'   directory structures, and count directories not corresponding to integers.
#' @inheritParams exif_date
#'
#' @return Data frame (with class \code{tbl_df} from \code{dplyr}) of processed
#'   camera trapping photo data. The returned data frame also has S3 class
#'   \code{cam_data} for use with other methods in the \code{camtrapr} package.
#' @export
#' @examples
#' photo_path <- system.file("extdata", "example-photos", package = "camtrapr")
#' cam_data <- cam_process(photo_path)
#' dplyr::glimpse(cam_data)
#' messy_path <- system.file("extdata", "messy", package = "camtrapr")
#' messy_data <- cam_process(messy_path)
#' dplyr::glimpse(messy_data)
cam_process <- function(path, as_datetime = TRUE, tz = "UTC",
                        clean_names = TRUE, verbose = TRUE) {
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

  # drop any files in directories named "ignore"
  ignore <- find_ignore(photos)
  if (verbose && any(ignore)) {
    message(paste0(sum(ignore), " images are in ignored directories.\n"))
  }
  photos <- photos[!ignore]

  # drop any files not in correct subdirectory structure
  # i.e. not in 4 subdirectories
  bad_sd <- find_bad_sd(photos)
  if (verbose && any(bad_sd)) {
    message("The following images are not correctly filed:")
    message(paste(photos[bad_sd], collapse = "\n"))
    message()
  }
  photos <- photos[!bad_sd]

  if (length(photos) == 0) {
    stop(paste0("No correctly filed photos found in:\n", path))
  }

  # find exif dates for these photos
  dt <- exif_date(file.path(path, photos), as_datetime = as_datetime,
                  tz = tz, error = FALSE)
  cam_data <- data.frame(photo_path = dirname(photos),
                         photo_file = basename(photos),
                         datetime = dt,
                         stringsAsFactors = FALSE)

  # turn directory structure into variables
  path_df <- parse_path(unique(cam_data$photo_path))
  cam_data <- dplyr::inner_join(path_df, cam_data, by = "photo_path")
  cam_data <- dplyr::select_(cam_data,
                             "photo_path", "photo_file",
                             "site", "camera", "species", "n", "datetime")

  # clean up variables names
  if (clean_names) {
    cam_data <- dplyr::mutate_each_(cam_data, dplyr::funs(clean_str),
                                   c("site", "camera", "species"))
  }

  # parse final subdirectory into numbers
  bad_counts <- find_bad_counts(cam_data$n)
  if (verbose && any(bad_counts)) {
    message("The following directories do no have valid counts:")
    message(paste(unique(cam_data$photo_path[bad_counts]), collapse = "\n"))
  }
  cam_data$n[bad_counts] <- NA
  cam_data$n[tolower(cam_data$n) == "x"] <- NA
  cam_data <- dplyr::mutate_(cam_data, n = ~as.integer(n))

  cam_data <- dplyr::arrange_(cam_data, "site", "camera", "species", "n",
                              "datetime")
  cam_data <- dplyr::tbl_df(cam_data)
  structure(cam_data, class = c("cam_data", class(cam_data)))
}
