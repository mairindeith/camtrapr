#' Extract EXIF DateTime from Jpeg
#'
#' Extract the date and time a photo was taken from its EXIF data. This
#' funtion was heavily inspired by the R package \code{EXIFr}, and the
#' references listed below.
#'
#' @param img_path character; vector of paths to jpeg images
#' @param error a logical value indicating whether errors should be raised by
#'        \code{exif_date}. If \code{error == TRUE}, then an error will be
#'        raised if the file cannot be found, it is not an image, there is a
#'        problem with the EXIF data, or there is no date present. If
#'        \code{error == FALSE}, then exectution should always proceed error
#'        free, and \code{NA} will be returned in all these problem cases.
#'
#' @return Character vector with datetime for each image as "Y:M:D H:M:S".
#' @references
#'    \url{http://code.flickr.net/2012/06/01/parsing-exif-client-side-using-javascript-2/}
#'    \url{https://github.com/cmartin/EXIFr/}
#' @export
#' @examples
#' img_path <- system.file("extdata", "muntjac.jpg", package = "camtrapr")
#' exif_date(img_path)
exif_date <- function(img_path, error = TRUE) {
  if (error) {
    dt <- vapply(img_path, .exif_date, character(1))
  } else {
    dt <- vapply(img_path,
                 function(x){
                   tryCatch(.exif_date(x),
                            error = function(x) NA_character_,
                            warning = function(x) invisible())
                 },
                 character(1)
    )
  }
  unname(dt)
}

.exif_date <- function(img_path) {
  assertthat::assert_that(file.exists(img_path))

  # read the file header; exif data should be in first 128kb
  con <- file(img_path, "rb")
  b <- readBin(con, "raw", n = 128000)
  close(con)

  # check for valid SOI marker (FFD8)
  if (!paste0(b[1], b[2]) == "ffd8") {
    stop(paste0("Invalid EXIF: missing SOI marker in\n", img_path))
  }

  # find app1 marker (FFE1)
  mark <- which(b == "e1")
  found <- FALSE
  for (i in mark) {
    if ("ffe1" == paste0(b[i - 1], b[i])) {
      found <- TRUE
      break()
    }
  }
  if (!found) {
    stop(paste0("Invalid EXIF: missing APP1 marker in\n", img_path))
  }

  # app1 size
  size <- readBin(b[(i + 1):(i + 2)], "integer", size = 2, signed = FALSE, endian = "big")
  if ((i + 3 + size) > length(b)) {
    stop(paste0("Invalid EXIF: end of file reached early in\n", img_path))
  }
  # this chunk of bytes contains the exif data
  exif <- b[(i + 3):(i + 3 + size)]
  rm(b)

  # check for exif marker (45786966)
  if (!paste(exif[1:4], collapse = "") == "45786966") {
    stop(paste0("Invalid EXIF: missing EXIF marker in\n", img_path))
  }

  # endian check
  if (paste0(exif[7:8], collapse = "") == "4949") {
    endian = "little"
  } else if (paste0(exif[7:8], collapse = "") == "4d4d") {
    endian = "big"
  } else {
    stop(paste0("Invalid EXIF: missing endian marker in\n", img_path))
  }

  # tiff varification
  if (!readBin(exif[9:10], "integer", size = 2, signed = FALSE,
               endian = endian) == 42) {
    stop(paste0("Invalid EXIF: missing tiff verification in\n", img_path))
  }

  tiff_start <- 7
  dir_start <- 15

  # search directory entries for datetime
  # datetime has tag id (0x0132 == 306)
  entries <- readBin(exif[dir_start:(dir_start + 1)], "integer", size = 2,
                     signed = FALSE, endian = endian)
  entry_locs <- 12 * (0:(entries - 1)) + dir_start + 2
  found <- FALSE
  for (i in entry_locs) {
    tag_id <- readBin(exif[i:(i + 1)], "integer", size = 2, signed = FALSE,
                      endian = endian)
    if (tag_id == 306) {
      dt_type <- readBin(exif[(i + 2):(i + 3)], "integer", size = 2,
                         signed = FALSE, endian = endian)
      dt_length <- readBin(exif[(i + 4):(i + 7)], "integer", size = 4,
                           endian = endian)
      dt_start <- readBin(exif[(i + 8):(i + 11)], "integer", size = 4,
                          endian = endian)
      dt_start <- dt_start + tiff_start
      found <- TRUE
      break()
    }
  }
  if (!found) {
    stop(paste0("DateTime missing from EXIF in\n", img_path))
  }

  # extract datetime
  dt_str <- readBin(exif[dt_start:(dt_start + dt_length)], "character",
                    size = dt_length, endian = endian)
  dt_str
}
