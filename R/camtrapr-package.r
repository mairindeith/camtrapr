#' camtrapr: Camera Trap Photo Processing
#'
#' This R package aids in the processing of camera trap photos in preparation
#' for further statistical analysis in R. Species within each photo should be
#' identified, and the photos should be organized into a specific directory
#' structure, prior to using the functions within the package.
#'
#' @section camtrapr functions:
#'
#' \enumerate{
#'  \item \code{fbind}: create a new factor from two existing factors, where the new
#'        factor's levels are the union of the levels of the input factors.
#'  \item \code{freq_out}: make a frequency table for a factor
#'  \item \code{factor_asis}: convert character to factor ordering levels as
#'        they appear in the original vector
#'  \item \code{fwrite_csv}: write to file preserving factor information
#'  \item \code{fread_csv}: read to file preserving factor information
#'  }
#'
#' To learn more about camtrapr, start with the vignettes:
#' \code{browseVignettes(package = "camtrapr")}
#'
#' @name camtrapr
#' @docType package
#' @importFrom magrittr %>%
NULL
