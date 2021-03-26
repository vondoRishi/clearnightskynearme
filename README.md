
# clearnightskynearme

<!-- badges: start -->
<!-- badges: end -->

The goal of clearnightskynearme is to ...

## Installation

You can install the released version of clearnightskynearme from [CRAN](https://CRAN.R-project.org) with:

``` r
if (!requireNamespace("devtools")) {
  install.packages("devtools")
}
devtools::install_github("vondoRishi/clearnightskynearme")

```

## Setup  

This depends on [owmr](https://crazycapivara.github.io/owmr/) package which further depends on [openweathermap.org](https://openweathermap.org/api/) .
User needs to register and get their own api key. Then follow below instruction to setup the api key.


``` r
library(owmr)

# first of all you have to set up your api key
owmr_settings("your_api_key")

# or store it in an environment variable called OWM_API_KEY (recommended)
Sys.setenv(OWM_API_KEY = "your_api_key") # if not set globally
```


## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(clearnightskynearme)
## basic example code
```

