#' A wrapper for all the crest functions.
#'
#' Runs all the different steps of a CREST reconstruction in one function.
#'
#' @param site_info A vector containing the coordinates of the study site.
#' @return A \code{\link{crestObj}} containing the reconstructions.
#' @export
#' @examples
#'
biomise <- function(s, pol2pft, pft2biome) {
    stopifnot("s should be a data frame" = is.data.frame(s))

    res <- pollen2pft(s, pol2pft)
    res <- pft2biomme(res, pft2biomme)
    res
}
