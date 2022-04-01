#' Test if two set of samples are more similar than expected if random.
#'
#' Calculates the EMD for two matrices \code{x} and \code{y} and test if the
#' comparison is better than random.
#'
#' @param x,y The two matrices to compare
#' @param weight.m Matrix of weights. Values should be 'numeric'.
#' @param nrep The number of randomisation to perform (Default 1000).
#' @param alpha The significance threshold of the test (Default 0.05).
#' @param width,height The dimensions of the output file in cm (default 9x9cm).
#' @param save A boolean to indicate if the diagram should be saved as a pdf file.
#'        Default is \code{FALSE}.
#' @param as.png A boolean to indicate if the output should be saved as a png.
#'        Default is \code{TRUE}. If \code{FALSE}, the figure is saved as a pdf.
#' @param png.res The resolution of the png file (default 300 pixels per inch).
#' @param filename An absolute or relative path that indicates where the diagram
#'        should be saved. Also used to specify the name of the file. Default:
#'        the file is saved in the working directory under the name
#'        \code{'Reconstruction_climate.pdf'}.
#' @param col A vector of two colours to use for significant and non-significant
#'        tests, respectively.
#' @param emd.step Graphical parameter that defines the width of the histogram bins.
#' @param plot A boolean to indicate if the results of the test should be
#'        plotted. Default is \code{FALSE}.
#' @param verbose A boolean to indicate if the results of the test should be
#'        printed on the screen (default \code{TRUE}).
#' @return A list containing 3 items: 1. The mean EMD derived the comparison of
#'         \code{x} and \code{y}. 2. The ensemble of EMDs calculated from the
#'         \code{nrep} randomised data. 3. The pvalue of the test.
#' @export
#' @examples
#' m1 <- matrix(abs(rnorm(500)), ncol=5)
#' m2 <- matrix(abs(rnorm(500)), ncol=5)
#' EMD.test(m1, m2)
#' res <- EMD.test(m1, m2, plot=FALSE, verbose=TRUE)
#' str(res)
#' \dontrun{
#'   EMD.test(m1, m2, save=TRUE, filename='test-emd.png')
#' }
#'
EMD.test <- function( x, y, nrep=200, alpha = 0.05,
                      weight.m =  matrix(1, ncol=ncol(x), nrow=ncol(x)) - diag(1, ncol=ncol(x), nrow=ncol(x)),
                      plot=TRUE, verbose=TRUE, emd.step = 0.002,
                      save=FALSE, filename=paste0('test', ifelse(as.png, '.png', '.pdf')),
                      as.png=TRUE, png.res=300, width=9, height=9, col=c('#66a182', '#d95f02')
                     ) {
    if(base::missing(x)) x
    if(base::missing(y)) y

    if((nrow(x) != nrow(y)) | (ncol(x) != ncol(y))) {
        stop("x and y should have the same dimensions.")
    }
    if(!Hmisc::all.is.numeric(weight.m)) {
        stop("All values of weight.m should be of type 'numeric'.")
    }

    if(length(col) < 1) {
        warning("Only one colour provided. The same colour will be used for significant and non-significant results")
        col <- c(col, col)
    }

    fdist <- function(a, b, w = weight.m) {
        return(as.numeric(w[a[1], b[1]]))
    }
    #if(is.matrix(y)) y <- list(y=y)

    nsample <- nrow(y)

    ##> Re-normalising in case it was not.
    x <- x / apply(x, 1, sum)
    y <- y / apply(y, 1, sum)
    #for(j in 1:length(y))  y[[j]] <- y[[j]] / apply(y[[j]], 1, sum)

    ##> Calculating EMD with randomised data
    rndm.emds <- rep(0, nrep)
    for(i in 1:nrep) {
        rndm.pos <- base::sample(1:nsample, nsample, replace=FALSE)
        for(j in 1:nsample) {
            rndm.emds[i] <- rndm.emds[i] + emdist::emd2d(matrix(x[j, ]), matrix(y[rndm.pos[j], ]), dist=fdist)
        }
    }
    rndm.emds <- rndm.emds / nsample / max(weight.m)

    ##> Calculating EMD with the true data
    real.emd <- 0
    for(j in 1:nsample) {
        real.emd <- real.emd + emdist::emd2d(matrix(x[j, ]), matrix(y[j, ]), dist=fdist)
    }
    real.emd <- real.emd / nsample / max(weight.m)

    ##> Calculating the uncertainties of the true EMD
    btstrppd.emds <- rep(0, nrep)
    for(i in 1:nrep) {
        btstrppd.pos <- base::sample(1:nsample, nsample, replace=TRUE)
        for(j in 1:nsample) {
            btstrppd.emds[i] <- btstrppd.emds[i] + emdist::emd2d(matrix(x[btstrppd.pos[j], ]), matrix(y[btstrppd.pos[j], ]), dist=fdist)
        }
    }
    btstrppd.emds <- btstrppd.emds / nsample / max(weight.m)

    ##> Printing results on screen
    if(verbose) {
        pos_val <- (stats::knots(stats::ecdf(btstrppd.emds))-rev(stats::knots(stats::ecdf(rndm.emds)))) > 0

        cat('\n\tTesting significativity of the EMD\n\n')
        cat('Measured EMD:', round(real.emd, 3), '\n')
        cat('Uncertainty range:   Max\t   99%\t   95%\t   90%\n')
        cat('                  ', round(max(btstrppd.emds), 3),'\t', round(stats::quantile(btstrppd.emds, 0.99), 3),'\t', round(stats::quantile(btstrppd.emds, 0.95), 3),'\t', round(stats::quantile(btstrppd.emds, 0.90), 3),'\n')
        cat('Randomised data:     Min\t    1%\t    5%\t   10%\n')
        cat('                  ', round(min(rndm.emds), 3),'\t', round(stats::quantile(rndm.emds, 0.01), 3),'\t', round(stats::quantile(rndm.emds, 0.05), 3),'\t', round(stats::quantile(rndm.emds, 0.10), 3),'\n')
        cat('pvalue', ifelse(sum(pos_val) == 0, paste0('< ',round(1/nrep,4)), paste0('= ',round(sum(pos_val)/nrep, 3))), '\n\n')
    }

    ##> Plotting results
    if(plot) {
        if(save) {
            if(as.png) {
                grDevices::png(filename, width = width, height = height, units='cm', res=png.res)
            } else {
                grDevices::pdf(filename, width=width*0.393701, height=height*0.393701)
            }
        } else {
            par_usr <- graphics::par(no.readonly = TRUE)
            on.exit(graphics::par(par_usr))
        }

        if(stats::quantile(btstrppd.emds, 1-alpha) > stats::quantile(rndm.emds, alpha)){
            colour <- col[2]
        } else {
            colour <- col[1]
        }

        graphics::par(mar=c(2,2,.5,0.5), ps=ifelse(save, 8, 12), cex=1)
        graphics::par(mgp=c(0.8,0.1,0))

        h1 <- graphics::hist(rndm.emds, plot=FALSE, breaks=seq(0,1, emd.step))
        h2 <- graphics::hist(btstrppd.emds, plot=FALSE, breaks=seq(0,1, emd.step))
        graphics::plot(h1, xlim=range(c(btstrppd.emds, rndm.emds, real.emd)) + emd.step*c(-1, 1), xaxs='i', yaxs='i', main='', xlab="Earth Mover's Distance", ylab='Abundance\n', cex.lab=7/8, cex.axis=6/8, cex.main=8/8, col='black', axes=FALSE, xaxs='i', yaxs='i')

        graphics::plot(h2, add=TRUE, col=colour)


        graphics::rect(stats::quantile(rndm.emds, alpha), 0, 1, max(h1$counts), col=crestr::makeTransparent('grey40', alpha=0.4),border='gray', lwd=0.4)
        graphics::rect(stats::quantile(btstrppd.emds, 1-alpha), 0, 0, max(h2$counts), col=crestr::makeTransparent(colour, alpha=0.4),border=colour, lwd=0.4)

        graphics::abline(v=real.emd, lwd=2, col=colour)

        graphics::text(min(c(btstrppd.emds, rndm.emds, real.emd))-emd.step/2, max(h1$counts)*0.98, paste0('pvalue = ', round(sum(pos_val)/nrep, 3), ' (n=', nrep, ')'), adj=c(0,1), cex=7/8 )

        graphics::par(mgp=c(0.4, 0.1, 0))
        graphics::axis(side=1,tck=-0.01, cex.axis=6/8)
        graphics::par(mgp=c(3, 0.3, 0))
        graphics::axis(side=2,at=c(0, max(h1$counts)), labels=NA, tck=0, cex.axis=6/8)
        graphics::axis(side=2,tck=0.01, cex.axis=6/8, las=2)
        graphics::axis(side=4,tck=0.01, labels=NA, cex.axis=6/8, las=2)
        graphics::box()

        if(save) grDevices::dev.off()
    }

    ##> Returning all values
    invisible(list('target' = real.emd,
                   'pvalue' = sum(pos_val)/nrep,
                   'randomised' = rndm.emds,
                   'bootstrapped' = btstrppd.emds))
}
