#' Calculates the EMD for two vectors \code{x} and \code{y}.
#'
#' Calculates the EMD for two vectors \code{x} and \code{y}.
#'
#' @param x,y The two vectors to compare
#' @param weight.m Matrix of weights. Values should be 'numeric'.
#' @return The EMD between \code{x} and \code{y}.
#' @export
#' @examples
#' EMD(1:5/sum(1:5), 6:10/sum(6:10))
#' EMD(1:5, 6:10) # The vectors are normalised by the function
#' m <- matrix(1:25, ncol=5)
#' diag(m) <- 0
#' EMD(1:5, 6:10, weight.m=m)
#'
EMD <- function(x, y, weight.m = matrix(rep(1, length(x)**2), ncol=length(x), byrow=TRUE) - diag(1,length(x),length(x))) {
    if(base::missing(x)) x
    if(base::missing(y)) y

    if(length(x) != length(y)) {
        stop("x and y should have the same length.")
    }
    if(!Hmisc::all.is.numeric(weight.m)) {
        stop("All values of weight.m should be of type 'numeric'.")
    }

    x <- matrix(x/sum(x), ncol=1)
    y <- matrix(y/sum(y), ncol=1)
    fdist <- function(a, b, w = weight.m) {
        return(as.numeric(w[a[1], b[1]]))
    }

    emdist::emd2d(x, y, dist=fdist) / max(weight.m)
}
