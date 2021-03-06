% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/threshold_precision.R
\name{threshold_precision}
\alias{threshold_precision}
\title{Threshold interactions at a given precision cutoff}
\usage{
threshold_precision(interactions, threshold)
}
\arguments{
\item{interactions}{the ranked list of interactions output by
\code{\link[PrInCE]{predict_interactions}}, including a \code{precision}
column}

\item{threshold}{the minimum precision of the unweighted interaction
network to return}
}
\value{
the subset of the original ranked list at the given precision
}
\description{
Threshold interactions at a given precision cutoff
}
\examples{
data(scott)
data(scott_gaussians)
data(gold_standard)
# analyze only the first 100 profiles
subset <- scott[seq_len(500), ]
gauss <- scott_gaussians[names(scott_gaussians) \%in\% rownames(subset)]
ppi <- PrInCE(subset, gold_standard,
  gaussians = gauss, models = 1,
  cv_folds = 3
)
network <- threshold_precision(ppi, threshold = 0.5)
nrow(network)
}
