<!-- README.md is generated from README.Rmd. Please edit that file -->
    #> Warning in rgl.init(initValue, onlyNULL): RGL: unable to open X11 display
    #> Warning: 'rgl_init' failed, running with rgl.useNULL = TRUE

The **gris** package provides a relational geometry/topology model for spatial data in R. This is inspired by data models used in the commercial products Manifold GIS and Eonfusion. The main aspirations are

-   remove the X/Y limitation on vertex attributes for points, lines, surfaces (and polygons)
-   allow multiple topology types in individual layers
-   provide a flexible basis for conversion between other formats.
-   provide a raster model that avoids conflating grid dimension with cell attributes (not yet illustrated)

Related work

-   rglgris has the latest visualization examples, showing the need for quad and tri meshes in R and texture mapping
-   rcdd has some related facilities, not explored yet

### Build objects from other packages

Here we load a commonly used layer of country polygons and convert to the gris format of tables with vertices/branches/objects.

``` r
library(gris)
library(maptools)
data(wrld_simpl)
dat <- gris(wrld_simpl)
#dat1 <- sbs(dat, filter(dat$o, NAME %in% c("Australia", "Indonesia", "Papua New Guinea")))
dat1 <- dat[which(dat$o$NAME %in% c("Australia", "Indonesia", "Papua New Guinea")), ]
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
#pl(dat1$v, asp = 1.3)
plot(dat1)
```

![](README-unnamed-chunk-3-1.png)

The function `bld` builds a **gris** object from a SpatialPolygonsDataFrame, `sbs` provides simple subsetting based on **dplyr**, and `pl` plots the individual branches of each object using polypath with a unique colour for objects.

### Triangulation

Triangulate with CGAL via [cgalgris](https://github.com/mdsumner/cgalgris). The function `tri_xy` performs an exact Delaunay triangulation on all vertices, returning a triplet-index for each triangle (zero-based in CGAL). Then process all triangles to detect which fall within the input polygons and plot them separately. (This test is inexact, since some polygon boundaries will not conform to the overall triangulation but CGAL does provide this ability).

``` r
library(cgalgris)
## Delaunay triangulation (unconstrained)
dat1$vi <- tri_xy(dat1$v$x_, dat1$v$y_) + 1  ## plus 1 for R indexing

## centroids of triangles
centr <- data_frame(x = dat1$v$x_[dat1$vi], y = dat1$v$y_[dat1$vi], t = rep(seq(length(dat1$vi)/3), each = 3)) %>% group_by(t) %>% summarize(x = mean(x), y = mean(y)) %>% select(x, y, t)
 
x1 <-  dat1$v %>% inner_join(dat1$bXv) %>% mutate(mg = branch_) %>%  group_by(mg) %>% do(rbind(., NA_real_))
#> Joining, by = "vertex_"
inside <- which(point.in.polygon(centr$x, centr$y, x1$x_, x1$y_) == 1)
## plot all triangles
plot(dat1$v$x_, dat1$v$y_, type = "n", asp = 1.3)
apply(matrix(dat1$vi, ncol = 3, byrow = TRUE), 1, function(x) polypath(cbind(dat1$v$x_[x], dat1$v$y_[x]), col = "#FF000080"))
#> NULL
## overplot only those that are internal to the polygons (not exact since triangulation is unconstrained)
apply(matrix(dat1$vi, ncol = 3, byrow = TRUE)[inside, ], 1, function(x) polypath(cbind(dat1$v$x_[x], dat1$v$y_[x]), col = "#0066FF99", border = "grey"))
#> NULL

points(centr[, c("x", "y")], cex = 0.2) 
```

![](README-unnamed-chunk-4-1.png)

Future versions will leverage more of CGAL for this functionality.

### Current limitations and issues

-   all implementation is raw objects, with lists of dplyr tables to keep things simple for now
-   no normalization of vertices, this would require separate tables for linkages between vertices&lt;-&gt;branches and branches&lt;-&gt;objects
-   no distinction between polygons and lines, apart from the `type` argument to `pl` for interpretation of branches when plotting
-   no features for multi-point geometries, though this is pretty straightforward
-   dplyr is susceptible to left-over attributes on vectors: <https://github.com/hadley/dplyr/issues/859>
-   the relational model is incomplete, with branch and object ids both present on the vertices table for now

Setup
-----

``` r
tools::package_native_routine_registration_skeleton("../cgalgris", "src/init.c",character_only = FALSE)
```
