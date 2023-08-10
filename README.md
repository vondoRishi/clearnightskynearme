
# clearnightskynearme

<!-- badges: start -->
<!-- badges: end -->

The goal of clearnightskynearme is to identify the time and location of the clearest night sky near user's given distance. This will be useful for sky gazing.

## Installation

*Requirement*: [R](https://www.r-project.org/) should be installed on your computer.  
You can install the released version of clearnightskynearme with:

``` r
if (!requireNamespace("devtools")) {
  install.packages("devtools")
}
devtools::install_github("vondoRishi/clearnightskynearme")

```

## Setup  

This depends on [owmr](https://crazycapivara.github.io/owmr/) package which further depends on [openweathermap.org](https://openweathermap.org/api/) .
User needs to register and get their own api key (api_key). Then follow below instruction to pass your registered api_key.


## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(clearnightskynearme)
## basic example code, replace api_key with your own which will be a long character string.
clearnightskynearme(apikey = "api_key") 

```

![](clearnightskynearme.png)
