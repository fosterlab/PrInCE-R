#' Detect significantly interacting complexes in a chromatogram matrix
#' 
#' Use a permutation testing approach to identify complexes that show a 
#' significant tendency to interact, relative to random sets of complexes
#' of equivalent size. The function begins by calculating the Pearson 
#' correlation or Euclidean distance between all proteins in the matrix, and 
#' 
#' @param profile_matrix a matrix of chromatograms, with proteins in the rows
#'   and fractions in the columns, or a \code{\linkS4class{MSnSet}} object
#' @param complexes a named list of protein complexes, where the name is the
#'   complex name and the entries are proteins within that complex 
#' @param min_pairs the minimum number of pairwise observations to count a 
#'   correlation or distance towards the z score 
#' @param method method to use to calculate edge weights;
#'   one of \code{pearson} or \code{euclidean}
#' @param bootstraps number of bootstraps to execute to estimate z scores
#' @param progress whether to show the progress of the function
#' 
#' @return a named vector of z scores for each complex in the input list
#' 
#' @examples 
#' data(scott)
#' data(gold_standard)
#' complexes <- gold_standard[lengths(gold_standard) >= 3]
#' z_scores <- detect_complexes(t(scott), complexes)
#' length(na.omit(z_scores)) ## number of complexes that could be tested
#' z_scores[which.max(z_scores)] ## most significant complex
#' 
#' @importFrom stats cor dist na.omit median sd
#' @importFrom utils combn
#' @importFrom progress progress_bar
#' @importFrom purrr map_dbl
#' @importFrom MSnbase exprs
#' @importFrom methods is
#' 
#' @export
detect_complexes <- function(profile_matrix, complexes, 
                             method = c("pearson", "euclidean"),
                             min_pairs = 10, 
                             bootstraps = 100,
                             progress = TRUE) {
  method <- match.arg(method)
  
  if (is(profile_matrix, "MSnSet")) {
    profile_matrix <- exprs(profile_matrix)
  }
  
  # transpose for correlations
  profile_matrix = t(profile_matrix)
  
  # construct network
  n <- crossprod(!is.na(profile_matrix))
  if (method == "pearson") {
    network <- cor(profile_matrix, use = 'pairwise.complete.obs')
  } else if (method == "euclidean") {
    network <- as.matrix(dist(t(profile_matrix)))  
  }
  network[n < min_pairs] = NA
  
  # do permutation testing
  z_scores <- numeric(0)
  pb <- progress_bar$new(
    format = "complex :what [:bar] :percent eta: :eta",
    clear = FALSE, total = length(complexes), width = 80)
  for (i in seq_along(complexes)) {
    complex_name <- names(complexes)[i]
    complex <- complexes[[i]]
    
    # subset complex to proteins present in this network 
    nodes <- colnames(network)
    overlap <- intersect(complex, nodes)
    
    # abort if overlap size is < 3
    if (length(overlap) < 3) {
      z_scores[complex_name] <- NA
    } else {
      # calculate median PCC for intra-complex interactions
      idxing_mat <- t(combn(overlap, 2))
      edge_weights <- na.omit(network[idxing_mat])
      obs <- median(edge_weights, na.rm = TRUE)
      
      # compare to random expectation
      rnd <- map_dbl(seq_len(bootstraps), ~ {
        # generate random set of proteins equivalent to # of complex subunits
        # present in this network 
        rnd_complex <- sample(nodes, length(overlap))
        # calculate observed D statistic
        idxing_mat <- t(combn(rnd_complex, 2))
        rnd_weights <- as.numeric(na.omit(network[idxing_mat]))
        median(rnd_weights, na.rm = TRUE)
      })
      
      # calculate Z score
      z <- (obs - mean(rnd, na.rm = TRUE)) / sd(rnd, na.rm = TRUE)
      z_scores[complex_name] <- z
    }
    
    # tick progress bar
    if (progress) {
      pb$tick(tokens = list(what = sprintf(
        paste0("%-", nchar(length(complexes)), "s"), i)))
    }
  }
  
  return(z_scores)
}
