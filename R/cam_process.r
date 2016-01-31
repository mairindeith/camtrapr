#' Process Camera Trap Photos
#'
#' @param path character; base path for all photos
#' @param clean_names logical idicating whether to clean up site, camera, and
#'        species names. If \code{TRUE}, leading and trailing whitespace is
#'        trimmed, any non-alphanumeric character will be converted to an
#'        underscore, then groups of more than one underscore will be collapsed
#'        to one. WARNING: if names are cleaned it is possible that previously
#'        unique site, camera, or species names will no longer be unique.
#' @param verbose logical indicating whether to print messages highlighting
#'        potential issues including directories than have been ignore, invalid
#'        directory structures, and count directories not corresponding to
#'        integers.
#'
#' @return Data frame of processed camera trapping photo data.
#' @export
#' @examples
#' photo_path <- system.file("extdata", "example_photos", package = "camtrapr")
#' cam_data <- cam_process(photo_path)
#' dplyr::glimpse(cam_data)
#' messy_path <- system.file("extdata", "messy", package = "camtrapr")
#' messy_data <- cam_process(messy_path)
#' dplyr::glimpse(messy_data)
cam_process <- function(path, clean_names = TRUE, verbose = TRUE) {
  assertthat::assert_that(is.character(path),
                          length(path) == 1,
                          dir.exists(path))
  path <- normalizePath(path, mustWork = FALSE)

  # list all jpegs in given folder
  photos <- list.files(path,pattern = "\\.(jpg|jpeg)$", ignore.case = TRUE,
                       recursive = TRUE)
  assertthat::assert_that(length(photos) > 0)

  # drop any files in directories named "ignore"
  ignore <- find_ignore(photos)
  if (verbose && any(ignore)) {
    message("The following images are in ignored directories:")
    message(paste(photos[ignore], collapse = "\n"))
    message()
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

  # find exif dates for these photos
  dt <- exif_date(file.path(path, photos), error = FALSE)
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

  dplyr::arrange_(cam_data, "site", "camera", "species", "n", "datetime")
}
