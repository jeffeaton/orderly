FROM rocker/r-ver:3.6.2

RUN apt-get update && apt-get -y install \
  git \
  libssl-dev \
  libpq-dev \
  sqlite3 \
  wget

RUN sed  -i'' '/mran.microsoft.com/d' /usr/local/lib/R/etc/Rprofile.site

# R package dependencies, including a few extras that we'll want handy
RUN install2.r \
  DBI \
  R6 \
  RPostgres \
  RSQLite \
  digest \
  docopt \
  fs \
  ids \
  jsonlite \
  knitr \
  remotes \
  rmarkdown \
  withr \
  yaml \
  zip

RUN Rscript -e 'remove.packages("BH")'

# Install Pandoc
ENV PANDOC_VERSION "2.7.3"
RUN wget https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb \
  && dpkg --install pandoc-${PANDOC_VERSION}-1-amd64.deb \
  && rm pandoc-${PANDOC_VERSION}-1-amd64.deb

ARG GIT_ID='UNKNOWN'
ARG GIT_BRANCH='UNKNOWN'
ARG ORDERLY_VERSION='UNKNOWN'
ENV ORDERLY_GIT_HASH $GIT_ID
ENV ORDERLY_GIT_BRANCH $GIT_BRANCH
ENV ORDERLY_VERSION $ORDERLY_VERSION

COPY . /orderly
RUN R CMD INSTALL /orderly && \
  Rscript -e 'orderly:::write_script("/usr/bin")' && \
  cp /orderly/inst/create_orderly_demo.sh /usr/bin/ && \
  rm -rf /orderly

ENTRYPOINT ["/usr/bin/orderly"]
