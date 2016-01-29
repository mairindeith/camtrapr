# cam_process <- function(path) {
#   path <- normalizePath(path, mustWork = FALSE)
#   assertthat::assert_that(dir.exists(path))
#
#   site_paths <- list.dirs(path, recursive = FALSE)
#   site_paths <- ignore_dirs(site_paths)
#   for (site_path in site_paths) {
#     site <- basename(site_path)
#     cam_paths <- list.dirs(site_path, recursive = FALSE)
#     cam_paths <- ignore_dirs(cam_paths)
#     for (cam_path in cam_paths) {
#       cam <- basename(cam_path)
#       spp_paths <- list.dirs(cam_path, recursive = FALSE)
#       spp_paths <- ignore_dirs(spp_paths)
#       for (spp_path in spp_paths) {
#         species <- basename(spp_path)
#         n_paths <- list.dirs(spp_path, recursive = FALSE)
#         n_paths <- ignore_dirs(n_paths)
#         for (n_path in n_paths) {
#           n <- basename(n_path)
#           photos <- list.files(n_path, pattern = "\\.(jpg|jpeg)$",
#                                full.names = TRUE, ignore.case = TRUE)
#           if (length(photos) > 0) {
#             data.frame(site = site,
#                        camera = cam,
#                        species = species,
#                        n = as.integer(n),
#                        datetime = exif_date(photos, error = FALSE),
#                        stringsAsFactors = FALSE)
#           }
#         }
#       }
#     }
#   }
# }
