cam_process <- function(path) {
  path <- normalizePath(path, mustWork = FALSE)
  assertthat::assert_that(dir.exists(path))

  photo_directories <- list.dirs(path, full.names = FALSE) %>%
    get_photo_dir
  process_photo_dir(path, photo_directories[1])
}
