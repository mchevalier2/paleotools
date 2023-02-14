#' Calculate an analogy threshold from a compilation of observations
#'
#' Calculate an analogy threshold from a compilation of observations

#'
#' @param x A matrix of samples (rows) to compare.
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
#' ##> We generate two tables of random, positive data
#' m1 <- matrix(abs(rnorm(500)), ncol=5) ; m1 <- m1 / apply(m1, 1, sum)
#' signif_threshold(m1, plot=FALSE)
#' res <- signif_threshold(m1, plot=TRUE, verbose=TRUE)
#' str(res)
#' \dontrun{
#'   signif_threshold(m1, save=TRUE, filename='test-emd.png')
#' }
#'
signif_threshold <- function( x, nrep=1000, alpha = 0.05,
                           weight.m =  matrix(1, ncol=ncol(x), nrow=ncol(x)) - diag(1, ncol=ncol(x), nrow=ncol(x)),
                           plot=TRUE, verbose=TRUE, emd.step = 0.002,
                           save=FALSE, filename=paste0('test', ifelse(as.png, '.png', '.pdf')),
                           as.png=TRUE, png.res=300, width=9, height=9, col='cornflowerblue'
                          ) {
    if(base::missing(x)) x

    if(!Hmisc::all.is.numeric(weight.m)) {
        stop("All values of weight.m should be of type 'numeric'.")
    }

    fdist <- function(a, b, w = weight.m) {
        return(as.numeric(w[a[1], b[1]]))
    }

    m <- matrix(rep(-1, nrow(x)**2), ncol=nrow(x), nrow=nrow(x))

    for(i in 1:nrow(m)) {
        for(j in i:nrow(m)) {
            m[i, j]  <- m[j ,i]  <- emdist::emd2d(matrix(x[i, ]), matrix(x[j, ]), dist=fdist)
        }
    }

    sampled_vals <- sample(m[lower.tri(m, diag = FALSE)], size=nrep, replace=TRUE)
    quants <- stats::quantile(sampled_vals, probs=alpha)



    ##> Plotting results
    if(plot) {
        if(save) {
            if(as.png) {
                grDevices::png(filename, width = width, height = height, units='cm', res=png.res)
            } else {
                grDevices::pdf(filename, width=width*0.393701, height=height*0.393701)
            }
            graphics::par(mar=c(2,2,.5,0.5), ps=ifelse(save, 8, 12), cex=1)
        } else {
            par_usr <- graphics::par(no.readonly = TRUE)
            on.exit(graphics::par(par_usr))
        }
        graphics::par(mgp=ifelse(save, 1, 2)*c(0.8,0.1,0))

        h1 <- graphics::hist(sampled_vals, plot=FALSE, breaks=seq(0,1, emd.step))
        graphics::plot(h1, xlim=c(0, max(sampled_vals)) + emd.step*c(-1, 1), ylim=c(0, max(h1$counts)), xaxs='i', yaxs='i', main='', xlab="Earth Mover's Distance", ylab='Abundance\n', cex.lab=7/8, cex.axis=6/8, cex.main=8/8, col='black', axes=FALSE, xaxs='i', yaxs='i')

        graphics::rect(0, 0, quants, max(h1$counts)*1.1, col=crestr::makeTransparent(col, alpha=0.4), border=col, lwd=0.4)
        graphics::text(quants/2, max(h1$counts*0.95), paste0('Similar\nsamples'), adj=c(0.5, 01), font=2, cex=7/8)

        graphics::text(quants/2, max(h1$counts*0.95)-graphics::strheight('S\nS\n.', font=2, cex=7/8), paste0('(EMD <= ',round(quants, 3), ')'), font=1, cex=6/8)


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
    quants
}
