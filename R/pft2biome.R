#' A wrapper for all the crest functions.
#'
#' Runs all the different steps of a CREST reconstruction in one function.
#'
#' @param s .
#' @param pft2biome .
#' @return A .
#' @export
#' @examples
#' 1:5
#'
pft2biome <- function(s, pft2biome) {
    stopifnot("s should be a data frame" = is.data.frame(s))

    missing_pfts <- rownames(s)[ !( rownames(s) %in% rownames(pft2biome)) ]
    if( length(missing_pfts) > 0 ) {
        warning(paste0("Somme PFTs (", paste(missing_pfts, collapse=', '), ") were not in the Biome scheme."))
    }

    res <- stats::setNames(data.frame(matrix(ncol = ncol(pft2biome), nrow = nrow(s))), colnames(pft2biome))
    rownames(res) <- rownames(s)

    for( i in 1:nrow(s)) { ## Loop on the samples
        for( j in 1:ncol(pft2biome)) { ## Loop on the Biomes
            res[i, j] <- sum( sqrt( s[i, pft2biome[, j] > 0] ) )
        }
    }
    res
}
