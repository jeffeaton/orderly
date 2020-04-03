<!-- DO NOT EDIT THIS FILE - SEE README.md.in -->
# orderly

<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/vimc/orderly.svg?branch=master)](https://travis-ci.org/vimc/orderly)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/vimc/orderly?branch=master&svg=true)](https://ci.appveyor.com/project/richfitz/orderly)
[![Build status](https://badge.buildkite.com/bc7993cd6960b205b32bd20f92d0d707c128e1a14bdb580f73.svg)](https://buildkite.com/mrc-ide/orderly)
[![codecov.io](https://codecov.io/github/vimc/orderly/coverage.svg?branch=master)](https://codecov.io/github/vimc/orderly?branch=master)
[![CodeFactor](https://www.codefactor.io/repository/github/vimc/orderly/badge)](https://www.codefactor.io/repository/github/vimc/orderly)
[![](https://www.r-pkg.org/badges/version/orderly)](https://cran.r-project.org/package=orderly)
<!-- badges: end -->

> 1. an attendant in a hospital responsible for the non-medical care of patients and the maintenance of order and cleanliness.
> 2. a soldier who carries orders or performs minor tasks for an officer.


`orderly` is a package designed to help make analysis more [reproducible](https://en.wikipedia.org/wiki/Reproducibility).  Its principal aim is to automate a series of basic steps in the process of writing analyses, making it easy to:

* track all inputs into an analysis (packages, code, and data resources)
* store multiple versions of an analysis where it is repeated
* track outputs of an analysis
* create analyses that depend on the outputs of previous analyses

With `orderly` we have two main hopes:

* analysts can write code that will straightforwardly run on someone else's machine (or a remote machine)
* when an analysis that is run several times starts behaving differently it will be easy to see when the outputs started changing, and what inputs started changing at the same time

`orderly` requires a few conventions around organisation of a project, and after that tries to keep out of your way.  However, these requirements are designed to make collaborative development with git easier by minimising conflicts and making backup easier by using an append-only storage system.

### The problem

One often-touted goal of R over point-and-click analyses packages is that if an analysis is scripted it is more reproducible.  However, essentially all analyses depend on external resources - packages, data, code, and R itself; any change in these external resources might change the results.  Preventing such changes in external resources is not always possible, but *tracking* changes should be straightforward - all we need to know is what is being used.

For example, while reproducible research [has become synonymous with literate programming](https://cran.r-project.org/view=ReproducibleResearch) this approach often increases the number of external resources.  A typical [`knitr`](https://cran.r-project.org/package=knitr) document will depend on:

* the source file (`.Rmd` or `.Rnw`)
* templates used for styling
* data that is read in for the analysis
* code that is directly read in with `source`

The `orderly` package helps by

* collecting external resources before an analysis
* ensuring that all required external resources are identified
* removing any manual work in tracking information about these external resources
* allowing running reports multiple times and making it easy to see what changed and why

The core problem is that analyses have no general _interface_.  Consider in contrast the role that functions take in programming.  All functions have a set of arguments (inputs) and a return value (outputs).  With `orderly`, we borrow this idea, and each piece of analysis will require that the user describes what is needed and what will be produced.

### The process

The user describes the inputs of their analysis, including:

* SQL queries (if using databases)
* Required R sources
* External resource files (e.g., csv data files, Rmd files, templates)
* Packages required to run the analysis
* Dependencies on previously run analyses

The user also provides a list of "artefacts" (file-based results) that they will produce.

Then `orderly`:

1. creates a new empty directory
2. copies over _only_ the declared file resources
3. loads only the declared packages
4. loads the declared R sources
5. evaluates any sql queries to create R objects
6. then runs the analysis
7. verifies that the declared artefacts are produced

It then stores metadata alongside the analysis including [md5 hashes](https://en.wikipedia.org/wiki/Hash_function) of all inputs and outputs, copies of data extracted from the database, a record of all R packages loaded at the end of the session, and (if using git) information about the git state (hash, branch and status).

Then if one of the dependencies of a report changes (the used data, code, etc), we have metadata that can be queried to identify the likely source of the change.


## Workflows with `orderly`

In the [MRC Centre for Global Infectious Disease Analysis](https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis) we use `orderly` on two major projects:

- The [Vaccine Impact Modelling Consortium](https://www.vaccineimpact.org/)
- Our part of the response to the 2018-2020 Ebola outbreak in the Democratic Republic of Congo
- Our part of the response to the 2019-2020 2019-nCoV-SARS/COVID-19 pandemic

The workflows we have developed here are oriented towards collaborative groups of researchers - other workflows are possible (indeed `orderly` is also designed to support a _decentralised_ workflow, though this has not been used in practice yet).

In these projects we have a group of researchers who develop and test analyses locally.  These are developed on a [branch in git](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging) and then run on a centralised _staging environment_ (a duplicate of our production environment).  The code and outputs are reviewed with the help of [GitHub's "Pull requests"](https://help.github.com/en/articles/about-pull-requests) and then the reports are run on our production environment.

Interaction with the remote environments is achieved using an [HTTP API](https://github.com/vimc/montagu-reporting-api) which `orderly` itself transparently uses, so that reports can be run remotely, [directly from R](https://vimc.github.io/orderly/reference/orderly_run_remote.html).  The remote systems also include an interactive web interface that can be used to explore and download versions of analyses, as well as run new ones.

## Internal database schema

`orderly` has a database, which should be the preferred way of querying the report archive from other programs.  The schema is programmatically described at [`inst/database/schema.yml`](inst/database/schema.yml) and automatically generated database documentation is available [here](https://vimc.github.io/orderly/schema).

## Testing

There is a set of regression tests that require the reference data.  Enable these by running the script `./scripts/copy_reference` which creates data in `tests/testthat/reference`

## Installation

Install `orderly` from CRAN with

```r
install.packages("orderly")
```

To install our internally released version (which might be ahead of CRAN) via drat, use

```r
# install.packages("drat")
drat:::add("vimc")
install.packages("orderly")
```

## License

MIT © Imperial College of Science, Technology and Medicine
