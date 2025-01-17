# ----------------------------------------------------------------------------
# Methods for processing API responses
# ----------------------------------------------------------------------------

process <- function(resp) {
  UseMethod("process")
}

process.clientresp <- function(resp) {
  httr::stop_for_status(resp)
  con <- from_JSON(httr::content(resp, as = "text"))
  if (nchar(con$error) > 0) stop(con$error, call. = FALSE)
  if (nchar(con$warning) > 0) warning(con$warning, call. = FALSE)
  if (nchar(con$message) > 0) message(con$message, call. = FALSE)
  con
}

process.figure <- function(resp) {
  httr::stop_for_status(resp)
  con <- from_JSON(content(resp, as = "text"))
  fig <- con$payload$figure
  fig$url <- sub("apigetfile/", "~", resp$url)
  # any reasonable way to return a data frame?
  hash_plot(data.frame(), fig)
}

process.signup <- function(resp) {
  httr::stop_for_status(resp)
  con <- from_JSON(content(resp, as = "text"))
  if (nchar(con[["error"]]) > 0) stop(con$error, call. = FALSE)
  # Relaying a message with a private key probably isn't a great idea --
  # https://github.com/ropensci/plotly/pull/217#issuecomment-100381166
  con
}
