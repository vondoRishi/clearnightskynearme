
# clearnightskynearme

<!-- badges: start -->
<!-- badges: end -->

The goal of clearnightskynearme is to identify the time and location of clearest night sky near user given distance. This will be useful for sky gazing.

## Installation

You can install the released version of clearnightskynearme with:

``` r
if (!requireNamespace("devtools")) {
  install.packages("devtools")
}
devtools::install_github("vondoRishi/clearnightskynearme")

```

## Setup  

This depends on [owmr](https://crazycapivara.github.io/owmr/) package which further depends on [openweathermap.org](https://openweathermap.org/api/) .
User needs to register and get their own api key. Then follow below instruction to setup the api key.


## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(clearnightskynearme)
## basic example code
clearnightskynearme(apikey = "api_key")
```

![](clearnightskynearme.png)
