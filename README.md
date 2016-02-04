<!-- README.md is generated from README.Rmd. Please edit that file -->
`camtrapr` is designed to process photos from camera trapping projects into a form useful for further analysis in R. The functions are inspired by the Windows programs developed for the same purpose by the [Small Wild Cat Conservation Foundation](http://www.smallcats.org/). So, users of these tools will easily be able to transition to `camtrapr`.

The motivation behind creating this package was a desire to have an open source, user friendly, cross platform tool (i.e. not Windows only) that allows for a seamless R camera trapping workflow.

Installation
============

``` r
install.packages("devtools")
devtools::install_github("mstrimas/camtrapr", build_vignettes = TRUE)
library(camtrapr)
```

Use
===

This package is designed to take a set of identified and organized camera trap photos in a directory structure like this:

    camera-trap-photos/
    ├── logged
    │   ├── cam001
    │   │   ├── muntjac
    │   │   │   └── 1
    │   │   │       ├── IMG020.JPG
    │   │   │       ├── IMG021.JPG
    │   │   │       └── IMG022.JPG
    │   │   ├── squirrel
    │   │   │   └── 1
    │   │   │       ├── IMG025.JPG
    │   │   └── wild-boar
    │   │       ├── 1
    │   │       │   ├── IMG032.JPG
    │   │       └── 2
    │   │           ├── IMG049.JPG
    │   └── cam002
    │       ├── squirrel
    │       │   └── 1
    │       │       ├── IMG034.JPG
    │       └── wild-boar
    │           ├── 2
    │           │   ├── IMG046.JPG
    │           └── x
    │               ├── IMG048.JPG
    └── primary
        ├── cam003
        │   ├── ignore
        │   │   └── IMG001.JPG
        │   ├── muntjac
        │   │   └── 1
        │   │       ├── IMG004.JPG
        │   └── porcupine
        │       └── 1
        │           └── IMG008.JPG
        └── cam004
            ├── muntjac
            │   └── 1
            │       ├── IMG010.JPG
            ├── squirrel
            │   └── 2
            │       ├── IMG012.JPG
            └── wild-boar
                └── 1
                    ├── IMG015.JPG

And produce a tidy data frame ready for analysis like this:

``` r
photo_path <- system.file("extdata", "example-photos", package = "camtrapr")
cam_data <- cam_process(photo_path, verbose = FALSE)
knitr::kable(head(cam_data, 5))
```

| photo\_path              | photo\_file | site   | camera | species  |    n| datetime            |
|:-------------------------|:------------|:-------|:-------|:---------|----:|:--------------------|
| logged/cam001/muntjac/1  | IMG020.JPG  | logged | cam001 | muntjac  |    1| 2014-06-14 07:36:50 |
| logged/cam001/muntjac/1  | IMG021.JPG  | logged | cam001 | muntjac  |    1| 2014-06-14 07:36:54 |
| logged/cam001/muntjac/1  | IMG022.JPG  | logged | cam001 | muntjac  |    1| 2014-07-06 21:07:23 |
| logged/cam001/squirrel/1 | IMG025.JPG  | logged | cam001 | squirrel |    1| 2014-06-02 18:43:13 |
| logged/cam001/squirrel/1 | IMG026.JPG  | logged | cam001 | squirrel |    1| 2014-06-25 14:21:32 |

For further details on the use of this package consult the vignette:

``` r
browseVignettes('camtrapr')
```
