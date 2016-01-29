#' Process Camera Trap Photos
#'
#' @param path character; base path for all photos
#' @param strict logical
#'
#' @return Data frame of processed camera trapping photo data.
#' @export
#' @examples
#' photo_path <- system.file("extdata", "example_photos", package = "camtrapr")
#' cam_process(photo_path)
cam_process <- function(path, strict = TRUE) {
  assertthat::assert_that(is.character(path),
                          length(path) == 1,
                          dir.exists(path))
  path <- normalizePath(path, mustWork = FALSE)

  # list all jpegs in given folder
  photos <- list.files(path,pattern = "\\.(jpg|jpeg)$", ignore.case = TRUE,
                       recursive = TRUE)
  assertthat::assert_that(length(photos) > 0)

  # drop any files in directories named "ignore"
  photos <- drop_ignore(photos)

  # remove photos that appear in a
  # find exif dates for these photos
  dt <- exif_date(file.path(path, photos), error = FALSE)
  data.frame(photo_path = photos, datetime = dt)
}
