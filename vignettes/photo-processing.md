---
title: "Camera Trap Photo Processing"
author: "Matt Strimas-Mackey"
date: "2016-02-04"
output: html_document
vignette: >
  %\VignetteIndexEntry{Camera Trap Photo Processing}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



`camtrapr` is designed to process photos from camera trapping projects into a form useful for further analysis in R. The functions are inspired by the Windows programs developed for the same purpose by the [Small Wild Cat Conservation Foundation](http://www.smallcats.org/). So, users of these tools will easily be able to transition to `camtrapr`.

The motivation behind creating this package was a desire to have an open source, user friendly, cross platform tool (i.e. not Windows only) that allows for a seamless R camera trapping workflow.

# Example Datasets

This package comes with two sets of example photos to demonstrate the functionality of the package. They are from a hypothetical camera trapping project that sampled a logged forest and a primary forest to compare mammal diversity. At each site two camera trap stations were set up, and a variety of mammal species were caught on camera and identified.

In the first set of photos, they have all been correctly identified and organized. In the second, a variety of errors have been intentionally introduced. The paths to these photos on your local machine are given by:


```r
library(camtrapr)
system.file("extdata", "example-photos", package = "camtrapr")
system.file("extdata", "messy", package = "camtrapr")
```

# Photo Organization

Prior to using this package, the animals in all photos need to be identified and the photos need to be put into a very particular, hierarchical directory structure. This directory structure conveys the metadata about each photo to the functions within this package. For those familiar with the tools from [smallcats.org](http://www.smallcats.org/), the photo organization is essentially identical.

The assumption is that you have a project where you're trapping at multiple sites, at each site you have multiple cameras, and each camera records multiple species with varying numbers of individuals. Every photo should be placed in a series of directories:

```
project/site/camera/species/n/photo.jpg
```

Where each sub-directory conveys a distinct piece of metadata as follows:

1.  `project`: a top level directory for a given project, which should contain
    only organized camera trap photos and nothing else.
2.  `site`: the unique name or ID of each site where the photos were taken, e.g.
    `logged-forest`, `danum-valley` or `palm-plantation`. 
3.  `camera`: the unique name or ID of each camera, e.g. `cam01` or `dvca101`.
4.  `species`: the name of the species you recorded on the camera, e.g. `deer`,
    `wild-boar`, or `elephas_maximus`.
5.  `n`: the number of individuals of the given species seen in the photo. This 
    must be an integer (e.g. `1` or `11`) or, if you don't know or don't care 
    how many individuals were seen, use an `x`.
6.  `photo.jpg`: the actual camera trap photo. The name of the photo is not
    important; however, the photo should have an EXIF DateTime stamp.
    
There is one exception to this hierarchy: if any directory is named `ignore`, all its contents will be completely ignore. This is a good way to deal with photos that haven't been sorted yet or photos that have no animal in them.

As an example, the sample photos provided with this package are organized as follows:

```
example-photos/
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
```

For brevity, only the first image is displayed within each directory. In this example project, the sites are `logged` and `primary`, the cameras are named `cam001`-`cam004`, and `example-photos` is the top level directory containing everything.

## Naming Files

Adhering to strict, well thought out file naming conventions is critical to reducing the number of errors introduced into your data. `camtrapr` will work on messy directory names, but I **strongly** recommend following these protocols when naming the directories in the above hierarchy:

- Use only letters (a-z) and numbers (0-9) in directory names. No 
  special characters, e.g. `%`, `&`, or `#`.
- Avoid uppercase letters (A-Z). This will avoid giving multiple names to the 
  species, e.g. `Deer` and `deer`.
- Avoid whitespace in names, instead use underscores (`_`) or dashes (`-`) as 
  separators
- Be consistent! If you decide to use `_` as a separator, stick with it and 
  don't also use `-`. Try not to mix common and scientific names. Again, this
  will ensure you don't end up with multiple "species" that are actually the 
  same, e.g. `elephant`, `AsianElephant`, `asian-elephant`, and 
  `Elephas_maximus`.

# Checking for Errors

Prior to processing the camera trap photos, it's recommended that you run `cam_check()` to help find any errors that may have been introduced during the file organization and naming process.

The `messy` directory, provided with this package, has a variety of intentionally introduced errors. To run the checks, provide the path to this directory to the `cam_check()` function.


```r
messy_path <- system.file("extdata", "messy", package = "camtrapr")
checks <- cam_check(messy_path)
```

`checks` is a list with 8 named elements, each corresponding to a different check that is performed by `cam_checks`.

The list elements, and corresponding names, are:

- `ignore`: photos ignored because they're in directories named `ignore`.
- `directory_problem`: photos that are not correctly nested within sub-directory
  structure.
- `missing_date`: photos that have no associated EXIF date
- `name_problem`: directories with spaces or special characters in the name; 
  only letters, numbers, and "_" or "-"" should occur.
- `count_problem`: count directories that are not either integers or "x".
- `site`: alphabetic list of unique sites; check for typos.
- `camera`: alphabetic list of unique cameras; check for typos.
- `species`: alphabetic list of unique species; check for typos.

The default print methods provides a concise summary:


```r
checks
#> # photos in ignored directories (ignore):  1 
#> # photos in non-standard directories (directory_problem):  2 
#> # photos with datetime or EXIF problems (missing_date):  1 
#> # naming problems (name_problem):  2 
#> # count directory parse errors (count_problem):  2 
#> # sites (site):  2 
#> # cameras (camera):  4 
#> # species (species):  5
```

Evidently there are a bunch of potential issues that need investigating. For further details on each, access the corresponding list element. For example, there appears to be two directory problems:


```r
checks$directory_problem
#> [1] "primary/cam 004/wild_boar/IMG016.JPG"
#> [2] "primary/cam003/IMG001.JPG"
```

These photos are not in the correct hierarchy as describe above. In particular, the first is not within a directory for the count and the second is missing count and species directories. After fixing these images we can move on to another check.

There is one photo that's missing an EXIF date.


```r
checks$missing_date
#> [1] "primary/cam 004/muntjac/1/IMG011.jpg"
```

This image should be removed or, if the date and time can be found by some other method, the image can be included, but you'll have to manually enter the date after processing the photos.

The next check looks at non-standard naming of files.


```r
checks$name_problem
#> [1] "logged/cam001/muntj@c"   "primary/cam 004/muntjac"
```

In the first case there's a special character (`@`), and in the second the name contains a space. Photo processing will work despite these issues; however, the best practice is to fix the names so they're in the standard format.

`count_problem` highlights a couple directories for which the count sub-directory has been named `one` rather than `1`.


```r
checks$count_problem
#> [1] "logged/cam001/muntj@c/one" "primary/cam003/muntjc/one"
```

Finally, `species` gives an alphabetical list of species in the dataset. Taking a quick look at this is a good way to check for potential typos.


```r
checks$species
#> [1] "muntj@c"   "muntjac"   "muntjc"    "wild-boar" "wildboar"
```

Sure enough Muntjac has been misspelled twice, and Wild Boar appears under two names: `wild-board` and `wildboar`.

Quickly running through these checks (and correcting issues!) before processing the photos can save time and frustration further down the line.

# Processing Camera Trap Photos

Now that the hard work of identifying and organizing your photos is done, and you've used `cam_check()` to ensure no mistakes were made, it's time to process the photos into a data frame with `cam_process()`. In the simplest case, just provide the path to the top-level directory.


```r
photo_path <- system.file("extdata", "example-photos", package = "camtrapr")
cam_data <- cam_process(photo_path)
```

In the resulting data frame, each row corresponds to a single photo and the columns provide information about that photo


|photo_path               |photo_file |site   |camera |species  |  n|datetime            |
|:------------------------|:----------|:------|:------|:--------|--:|:-------------------|
|logged/cam001/muntjac/1  |IMG020.JPG |logged |cam001 |muntjac  |  1|2014-06-14 07:36:50 |
|logged/cam001/muntjac/1  |IMG021.JPG |logged |cam001 |muntjac  |  1|2014-06-14 07:36:54 |
|logged/cam001/muntjac/1  |IMG022.JPG |logged |cam001 |muntjac  |  1|2014-07-06 21:07:23 |
|logged/cam001/squirrel/1 |IMG025.JPG |logged |cam001 |squirrel |  1|2014-06-02 18:43:13 |
|logged/cam001/squirrel/1 |IMG026.JPG |logged |cam001 |squirrel |  1|2014-06-25 14:21:32 |

The columns `photo_path` and `photo_file` specify the location and filename of the image, which connects each row back to the image from which it was derived. We can also look at the structure and data types of the columns.


```r
dplyr::glimpse(cam_data)
#> Observations: 30
#> Variables: 7
#> $ photo_path (chr) "logged/cam001/muntjac/1", "logged/cam001/muntjac/1...
#> $ photo_file (chr) "IMG020.JPG", "IMG021.JPG", "IMG022.JPG", "IMG025.J...
#> $ site       (chr) "logged", "logged", "logged", "logged", "logged", "...
#> $ camera     (chr) "cam001", "cam001", "cam001", "cam001", "cam001", "...
#> $ species    (chr) "muntjac", "muntjac", "muntjac", "squirrel", "squir...
#> $ n          (int) 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 2, 2, NA,...
#> $ datetime   (time) 2014-06-14 07:36:50, 2014-06-14 07:36:54, 2014-07-...
```

Note that the column `datetime` is not a character string, but a POSIXct DateTime object. This will prove useful for later processing involving manipulation of the date and time.

## Addiontal Functionality

In most cases, the default behaviour of `cam_process()` will produce the desired results; however, there are some additional arguments to tweak the way it works.

### Messages

`cam_process()` will display a progress bar and informative messages as it process a set of camera trap photos. These messages will highlight potential issues with your photos and can be particularly useful if you haven't run `cam_check()` first. For example, processing the photos in the included `messy` photo set will produce a series of messages highlighting some of the same problems that were found by `cam_check()` above:


```r
messy_path <- system.file("extdata", "messy", package = "camtrapr")
messy_data <- cam_process(messy_path)
#> 1 images are in ignored directories.
#> The following images are not correctly filed:
#> primary/cam 004/wild_boar/IMG016.JPG
#> primary/cam003/IMG001.JPG
#> 
#> The following directories do not have valid counts:
#> logged/cam001/muntj@c/one
#> primary/cam003/muntjc/one
```

To turn these messages off use the argument `verbose = FALSE`.

### Cleaning Names

As discussed above, it's best to have tidy, consistent names for the folders in the directory hierarchy of your photos. If you don't, `cam_process()` will "clean" the `site`, `camera`, and `species` variables as follows:

1.  Characters will be converted to lower case.
2.  Any whitespace (e.g. tabs or spaces) will be trimmed from the beginning and 
    end of the string.
3.  All characters that are not either numbers, letters, or separators 
    (`_` and `-`) will be replaced with underscores.

Note that no files or folders will be renamed on your hard drive, only the associated variables will be affected.

If you wish to turn on this functionality and preserve all variables as they are, use the `clean_names` argument to `cam_process()`.


```r
messy_data_asis <- cam_process(messy_path, clean_names = FALSE, verbose = FALSE)
messy_data_asis[c(1,10,11),]
#> Source: local data frame [3 x 7]
#> 
#>                  photo_path photo_file    site  camera species     n
#>                       (chr)      (chr)   (chr)   (chr)   (chr) (int)
#> 1 logged/cam001/muntj@c/one IMG020.JPG  logged  cam001 muntj@c    NA
#> 2 primary/cam 004/muntjac/1 IMG010.JPG primary cam 004 muntjac     1
#> 3 primary/cam 004/muntjac/1 IMG011.jpg primary cam 004 muntjac     1
#> Variables not shown: datetime (time)
messy_data[c(1,10,11),]
#> Source: local data frame [3 x 7]
#> 
#>                  photo_path photo_file    site  camera species     n
#>                       (chr)      (chr)   (chr)   (chr)   (chr) (int)
#> 1 logged/cam001/muntj@c/one IMG020.JPG  logged  cam001 muntj_c    NA
#> 2 primary/cam 004/muntjac/1 IMG010.JPG primary cam_004 muntjac     1
#> 3 primary/cam 004/muntjac/1 IMG011.jpg primary cam_004 muntjac     1
#> Variables not shown: datetime (time)
```

### Datetimes vs. Strings

By default, `cam_process()` returns photo time stamps as `POSIXct` datetime objects. This is R's native format for storing dates and times. The benefit of using a variable of this type, as opposed to a character string, is that it can be easily manipulated with functions from base R or the [`lubridate`](https://github.com/hadley/lubridate) package. For example, the difference between datetimes can be calculated, or the week number in the current year be extracted:


```r
cam_data$datetime[1] - cam_data$datetime[nrow(cam_data)]
#> Time difference of -440.5695 days
lubridate::week(cam_data$datetime[1])
#> [1] 24
```

`POSIXct` variables always have a time zone associated with them. By default, `camtrapr` uses [Universal Coordinated Time](https://en.wikipedia.org/wiki/Coordinated_Universal_Time) (UTC), which is essentially Greenwich Mean Time (GMT). In most situations, although UTC is likely not technically correct for your photos, the time zone is not relevant provided it's consistent across all photos. So, unless you have a good reason, leave the defaults as it.

If you do wish to change the time zone, pass the desired platform specific time zone string to the `tz` parameter of `cam_process()`. To read more about time zones in R, consult `help("timezones")`.


```r
(my_tz <- Sys.timezone())
#> [1] "America/Vancouver"
cam_data_tz <- cam_process(photo_path, tz = my_tz, verbose = FALSE)
head(cam_data_tz$datetime, 3)
#> [1] "2014-06-14 07:36:50 PDT" "2014-06-14 07:36:54 PDT"
#> [3] "2014-07-06 21:07:23 PDT"
head(cam_data$datetime, 3)
#> [1] "2014-06-14 07:36:50 UTC" "2014-06-14 07:36:54 UTC"
#> [3] "2014-07-06 21:07:23 UTC"
```

If you prefer character strings instead of datetimes, the `datetime` column can easily be converted with `as.character()`


```r
head(as.character(cam_data$datetime))
#> [1] "2014-06-14 07:36:50" "2014-06-14 07:36:54" "2014-07-06 21:07:23"
#> [4] "2014-06-02 18:43:13" "2014-06-25 14:21:32" "2014-06-28 07:02:39"
```

Or, use `as_datetime = FALSE` when calling `cam_process()`


```r
cam_process(photo_path, as_datetime = FALSE)
```
