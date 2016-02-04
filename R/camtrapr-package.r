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
#'  \item \code{cam_check}: check photos are directory structure for errors
#'  \item \code{cam_process}: process photos into a data frame
#'  \item \code{exif_date}: read EXIF date of a Jpeg image
#' }
#'
#' To learn more about camtrapr, start with the vignettes:
#' \code{browseVignettes(package = "camtrapr")}
#'
#' @name camtrapr
#' @docType package
NULL
