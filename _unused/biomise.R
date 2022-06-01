#' A wrapper for all the crest functions.
#'
#' Runs all the different steps of a CREST reconstruction in one function.
#'
#' @param s .
#' @param pol2pft .
#' @param pft2biome .
#' @return A .
#' @export
#' @examples
#' 1:5
#'
biomise <- function(s, pol2pft, pft2biome) {
    stopifnot("s should be a data frame" = is.data.frame(s))

    res <- paleotools::pollen2pft(s, pol2pft)
    res <- paleotools::pft2biome(res, pft2biome)
    res
}
