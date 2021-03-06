% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/is_weighted.R
\name{is_weighted}
\alias{is_weighted}
\title{Test whether a network is weighted}
\usage{
is_weighted(network)
}
\arguments{
\item{network}{the network to analyze}
}
\value{
true if the input network is a square numeric matrix with more than
  two values
}
\description{
Test whether a network is weighted
}
\examples{
data(gold_standard)
adj <- adjacency_matrix_from_list(gold_standard)
is_weighted(adj) ## returns FALSE

}
