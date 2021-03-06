% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/d3hive.R
\name{d3hive}
\alias{d3hive}
\title{htmlwidget for d3.js hive plots}
\usage{
d3hive(data = NULL, innerRadius = NULL, outerRadius = NULL,
  width = NULL, height = NULL)
}
\arguments{
\item{data}{\code{\link[HiveR]{HivePlotData}} object}

\item{innerRadius}{\code{integer} in px for the inner radius of the hive
plot.  The default is square root(height) * 2.}

\item{outerRadius}{\code{integer} in px for the outer radius of the hive
plot.  The default is 0.9 * height/2.}

\item{width}{a valid \code{CSS} size for the width of the container}

\item{height}{a valid \code{CSS} size for the height of the container}
}
\description{
Tame your network hairball with hive plots.  For more on hive plots,
   see the Martin Krzywinski's \href{http://www.hiveplot.com/}{hive plot site}.
}
\examples{
\dontrun{
library(HiveR)
library(d3hiveR)

d3hive( ranHiveData( nx = 5, ne = 1000) )
}
}

