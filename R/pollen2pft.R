#' A wrapper for all the crest functions.
#'
#' Runs all the different steps of a CREST reconstruction in one function.
#'
#' @param site_info A vector containing the coordinates of the study site.
#' @return A \code{\link{crestObj}} containing the reconstructions.
#' @export
#' @examples
#'
pollen2pft <- function(s, pol2pft) {
    stopifnot("s should be a data frame" = is.data.frame(s))

    missing_taxa <- rownames(s)[ !( rownames(s) %in% rownames(pollen2pft)) ]
    if( length(missing_taxa) > 0 ) {
        warning(paste0("Somme pollen taxa (", paste(missing_taxa, collapse=', '), ") were not in the PFT scheme."))
    }

    res <- setNames(data.frame(matrix(ncol = ncol(pol2pft), nrow = nrow(s))), colnames(pol2pft))
    rownames(res) <- rownames(s)

    for( i in 1:nrow(s)) { ## Loop on the samples
        for( j in 1:ncol(pol2pft)) { ## Loop on the PFTs
            res[i, j] <- sum( s[i, pol2pft[, j] > 0] )
        }
    }
    res
}
