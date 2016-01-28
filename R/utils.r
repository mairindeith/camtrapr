# http://stackoverflow.com/questions/29214932/split-a-file-path-into-folder-names-vector
split_path <- function(path) {
  setdiff(strsplit(path, "/|\\\\")[[1]], "")
}

get_photo_dir <- function(path) {
  depth <- vapply(path, function(x) length(split_path(x)), integer(1))
  ignore <- grepl("ignore", path, ignore.case = TRUE)
  path[(depth == 4) & !ignore]
}

process_photo_dir <- function(base_path, photo_dir) {
  imgs <- file.path(base_path, photo_dir) %>%
    list.files(pattern = "\\.(jpg|jpeg)$", ignore.case = TRUE)
  img_paths <- file.path(base_path, photo_dir, imgs)
  dates <- vapply(img_paths, exif_date_clean, character(1)) %>%
    as.character

}

exif_date_clean <- function(img_path) {
  tryCatch(exif_date(img_path), error = function(x) NA, warning = function(x) NA)
}
