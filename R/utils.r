# http://stackoverflow.com/questions/29214932/split-a-file-path-into-folder-names-vector
split_path <- function(path) {
  setdiff(strsplit(path, "/|\\\\")[[1]], "")
}

# ignore all directories or files named "ignore"
find_ignore <- function(x, pattern = "ignore") {
  assertthat::assert_that(is.character(x),
                          is.character(pattern),
                          length(pattern) == 1)
  l <- vapply(x, function(x) any("ignore" %in% tolower(split_path(x))),
              logical(1))
  unname(l)
}

# all photos should be 4 subdirectories deep
find_bad_sd <- function(x) {
  assertthat::assert_that(is.character(x))
  l <- vapply(x, function(x) (length(split_path(x)) != 5), logical(1))
  unname(l)
}

find_bad_counts <- function(x) {
  assertthat::assert_that(is.character(x))
  !grepl("^(([0-9]+)|([xX]{1}))$", x)
}

find_bad_names <- function(x) {
  assertthat::assert_that(is.character(x))
  l <- vapply(x, function(x) any(grepl("[^_[:alnum:]]", split_path(x))), logical(1))
}

# given a df with a path to photo variable, split and convert into variables
parse_path <- function(x) {
  assertthat::assert_that(is.character(x))
  plyr::ldply(x,
              function(x) {
                setNames(
                  data.frame(x, t(split_path(x)), stringsAsFactors = FALSE),
                  c("photo_path", "site", "camera", "species", "n"))
              })
}

clean_str <- function(x) {
  x <- tolower(x)
  # convert whitespace and non-alphanumeric characters to _
  gsub("[^[:alnum:]]+", "_", trimws(x))
}
