% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/migrate.R
\name{orderly_migrate}
\alias{orderly_migrate}
\title{Migrate an orderly archive}
\usage{
orderly_migrate(config = NULL, locate = TRUE, to = NULL,
  verbose = FALSE, dry_run = FALSE)
}
\arguments{
\item{config}{An orderly configuration, or the path to one (or
\code{NULL} to locate one if \code{locate} is \code{TRUE}).}

\item{locate}{Logical, indicating if the configuration should be
searched for.  If \code{TRUE} and \code{config} is not given,
then orderly looks in the working directory and up through its
parents until it finds an \code{orderly_config.yml} file.}

\item{to}{The version to migrate to.  The default is the current
archive version; this is almost always what is wanted.}

\item{verbose}{Logical, indicating if extra noisy output from the
migration should be given.}

\item{dry_run}{Logical, indicating if we should try running the
migration but not actually applying it.  This is intended
primarily for developing new migrations and will probably not
work if you are multiple archive versions behind.}
}
\description{
Migrate an orderly archive.  This is needed periodically when the
orderly archive version changes.  If you get a message like
\code{orderly archive needs migrating from a.b.c => x.y.z} then
you need to run this function.  The archive version is at most
equal to the package version.
}
\details{
Sometimes we add change information saved out in the orderly run.
This requires patching previously run versions of the orderly
metadata and that's not something we want to do lightly.  This
function uses a relatively safe, and reversible, way of migrating
metadata.  We only modify the \code{orderly_run.rds} files and
leave the human-readable \code{orderly_run.yml} ones alone (at
least for now).
}