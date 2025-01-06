
<!-- README.md is generated from README.Rmd. Please edit that file -->

# paleotools

<!-- badges: start -->
<!-- badges: end -->

The goal of paleotools is to …

## Installation

You can install the development version of the package from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mchevalier2/paleotools")
```

## Example

This is a basic example which shows you how to use the Earth Movers’
Distance (EMD) and the associated significance test.

``` r
library(paleotools)

EMD(1:5/sum(1:5), 6:10/sum(6:10))
#> [1] 0.125
EMD(1:5, 6:10) # The vectors are normalised by the function
#> [1] 0.125
m <- matrix(1:25, ncol=5)
for(i in 1:5) m[i,i] <- 0
EMD(1:5, 6:10, weight.m=m)
#> [1] 0.03298612
```

``` r
m1 <- matrix(abs(rnorm(500)), ncol=5) ; m1 <- m1 / apply(m1, 1, sum)
m2 <- matrix(abs(rnorm(500)), ncol=5) ; m2 <- m2 / apply(m2, 1, sum)
signif_struct(m1, m2, plot=FALSE)
#> 
#>  Testing significativity of the EMD
#> 
#> Measured EMD: 0.378 
#> Uncertainty range:   Max    99%     95%     90%
#>                    0.418      0.41    0.402   0.398 
#> Randomised data:     Min     1%      5%     10%
#>                    0.345      0.346   0.355   0.359 
#> pvalue = 0.56
res <- signif_struct(m1, m2, plot=TRUE, verbose=TRUE)
#> 
#>  Testing significativity of the EMD
#> 
#> Measured EMD: 0.378 
#> Uncertainty range:   Max    99%     95%     90%
#>                    0.412      0.408   0.401   0.393 
#> Randomised data:     Min     1%      5%     10%
#>                    0.351      0.351   0.356   0.359 
#> pvalue = 0.57
res <- signif_struct(m1, 1+m1, plot=TRUE, verbose=TRUE, nrep=100)
#> 
#>  Testing significativity of the EMD
#> 
#> Measured EMD: 0.225 
#> Uncertainty range:   Max    99%     95%     90%
#>                    0.24   0.239   0.236   0.234 
#> Randomised data:     Min     1%      5%     10%
#>                    0.266      0.267   0.269   0.27 
#> pvalue < 0.01
str(res)
#> List of 4
#>  $ target      : num 0.225
#>  $ pvalue      : num 0
#>  $ randomised  : num [1:100] 0.277 0.279 0.274 0.269 0.272 ...
#>  $ bootstrapped: num [1:100] 0.216 0.219 0.223 0.227 0.222 ...
```

<img src="man/figures/README-signif_struct-1.png" width="100%" /><img src="man/figures/README-signif_struct-2.png" width="100%" />
