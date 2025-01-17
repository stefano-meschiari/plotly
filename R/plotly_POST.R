#' Create/Modify plotly graphs
#'
#' POST messages to the clientresp resource of plotly's REST API. Unlike \link{ggplotly},
#' this function does not translate ggplot objects.
#'
#' @param x either a plotly object or a list.
#' @export
#' @references https://plot.ly/rest/
#' @seealso \link{signup}
#' @return An R object created by mapping the JSON content of the plotly API
#' response to its R equivalent.
#' @author Carson Sievert
#' @examples
#' \dontrun{
#' # If you want, you can still construct lists by hand...
#' trace1 <- list(
#'   x = c(1, 2, 3, 4), 
#'   y = c(10, 15, 13, 17), 
#'   type = "scatter"
#' )
#' trace2 <- list(
#'   x = c(1, 2, 3, 4), 
#'   y = c(16, 5, 11, 9), 
#'   type = "scatter"
#' )
#' plotly_POST(list(trace1, trace2))
#' }

plotly_POST <- function(x) {
  x <- plotly_build(x)
  # empty keyword arguments can cause problems
  kwargs <- x[get_kwargs()]
  kwargs <- kwargs[sapply(kwargs, length) > 0]
  
  # filename & fileopt are keyword arguments required by the API
  # (note they can also be specified by the user)
  
  if (!is.null(x$url) || !is.null(kwargs$filename)) kwargs$fileopt <- "overwrite"
  if (is.null(kwargs$filename)) {
    kwargs$filename <- 
      as.character(kwargs$layout$title) %||% 
      paste(
        c(kwargs$layout$xaxis$title, 
          kwargs$layout$yaxis$title, 
          kwargs$layout$zaxis$title), 
        collapse = " vs. "
      ) %||%
      "plot from api" 
  }
  if (is.null(kwargs$fileopt)) kwargs$fileopt <- "new"
  # ugh, annotations _must_ be an _array_ of object(s)...
  a <- kwargs$layout$annotations
  if (!is.null(a) && !is.null(names(a))) {
    kwargs$layout$annotations <- list(kwargs$layout$annotations)
  }
  # construct body of message to plotly server
  bod <- list(
    un = verify("username"),
    key = verify("api_key"),
    origin = if (is.null(x$origin)) "plot" else x$origin,
    platform = "R",
    version = as.character(packageVersion("plotly")),
    args = to_JSON(x$data),
    kwargs = to_JSON(kwargs)
  )
  base_url <- file.path(get_domain(), "clientresp")
  resp <- httr::POST(base_url, body = bod)
  con <- process(struct(resp, "clientresp"))
  msg <- switch(kwargs$fileopt,
                new = "Success! Created a new plotly here -> ",
                overwrite = "Success! Modified your plotly here -> ")
  message(msg, con$url)
  con
}
