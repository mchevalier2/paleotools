#' A wrapper for all the crest functions.
#'
#' Runs all the different steps of a CREST reconstruction in one function.
#'
#' @param site_info A vector containing the coordinates of the study site.
#' @return A \code{\link{crestObj}} containing the reconstructions.
#' @export
#' @examples
#'
EMD <- function(x, y, weight.m = matrix(rep(1, length(x)**2), ncol=length(x), byrow=TRUE) - diag(1,length(x),length(x))) {

    x <- matrix(x/sum(x), ncol=1)
    y <- matrix(y/sum(y), ncol=1)
    fdist <- function(a, b, w = weight.m) {
        return(as.numeric(w[a[1], b[1]]))
    }

    emdist::emd2d(x, y, dist=fdist    )
}
