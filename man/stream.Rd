% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/stream.R
\name{stream}
\alias{stream}
\title{Stream objects}
\usage{
stream(x)
}
\arguments{
\item{p}{a plotly or figure object.}
}
\description{
Stream objects
}
\examples{
# generate 100 random observations
n <- 100
x <- rnorm(n)

# start a plotly stream
s <- stream()
# write to the stream
for (i in seq_len(50)) {
  s$write(x = x)
  x <- x[-n]
  x[1] <- rnorm(1)
}
# close the stream
s$close()
}

