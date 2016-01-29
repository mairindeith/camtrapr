# http://stackoverflow.com/questions/29214932/split-a-file-path-into-folder-names-vector
split_path <- function(path) {
  setdiff(strsplit(path, "/|\\\\")[[1]], "")
}

drop_ignore <- function(x, pattern = "ignore") {
  assertthat::assert_that(is.character(x),
                          is.character(pattern),
                          length(pattern) == 1)
  to_ignore <- vapply(x, function(x) any("ignore" %in% tolower(split_path(x))),
             logical(1))
  x[!to_ignore]
}
