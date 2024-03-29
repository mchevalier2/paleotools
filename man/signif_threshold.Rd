% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/signif_threshold.R
\name{signif_threshold}
\alias{signif_threshold}
\title{Calculate an analogy threshold from a compilation of observations}
\usage{
signif_threshold(
  x,
  nrep = 1000,
  alpha = 0.05,
  weight.m = matrix(1, ncol = ncol(x), nrow = ncol(x)) - diag(1, ncol = ncol(x), nrow =
    ncol(x)),
  plot = TRUE,
  verbose = TRUE,
  emd.step = 0.002,
  save = FALSE,
  filename = paste0("test", ifelse(as.png, ".png", ".pdf")),
  as.png = TRUE,
  png.res = 300,
  width = 9,
  height = 9,
  col = "cornflowerblue"
)
}
\arguments{
\item{x}{A matrix of samples (rows) to compare.}

\item{nrep}{The number of randomisation to perform (Default 1000).}

\item{alpha}{The significance threshold of the test (Default 0.05).}

\item{weight.m}{Matrix of weights. Values should be 'numeric'.}

\item{plot}{A boolean to indicate if the results of the test should be
plotted. Default is \code{FALSE}.}

\item{verbose}{A boolean to indicate if the results of the test should be
printed on the screen (default \code{TRUE}).}

\item{emd.step}{Graphical parameter that defines the width of the histogram bins.}

\item{save}{A boolean to indicate if the diagram should be saved as a pdf file.
Default is \code{FALSE}.}

\item{filename}{An absolute or relative path that indicates where the diagram
should be saved. Also used to specify the name of the file. Default:
the file is saved in the working directory under the name
\code{'Reconstruction_climate.pdf'}.}

\item{as.png}{A boolean to indicate if the output should be saved as a png.
Default is \code{TRUE}. If \code{FALSE}, the figure is saved as a pdf.}

\item{png.res}{The resolution of the png file (default 300 pixels per inch).}

\item{width, height}{The dimensions of the output file in cm (default 9x9cm).}

\item{col}{A vector of two colours to use for significant and non-significant
tests, respectively.}
}
\value{
A list containing 3 items: 1. The mean EMD derived the comparison of
\code{x} and \code{y}. 2. The ensemble of EMDs calculated from the
\code{nrep} randomised data. 3. The pvalue of the test.
}
\description{
Calculate an analogy threshold from a compilation of observations
}
\examples{
##> We generate two tables of random, positive data
m1 <- matrix(abs(rnorm(500)), ncol=5) ; m1 <- m1 / apply(m1, 1, sum)
signif_threshold(m1, plot=FALSE)
res <- signif_threshold(m1, plot=TRUE, verbose=TRUE)
str(res)
\dontrun{
  signif_threshold(m1, save=TRUE, filename='test-emd.png')
}

}
