#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
d3hive <- function(data = NULL, width = NULL, height = NULL) {

  # forward options using x
  x = list(
    data = data
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'd3hive',
    x,
    width = width,
    height = height,
    package = 'd3hiveR'
  )
}

#' Widget output function for use in Shiny
#'
#' @export
d3hiveOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'd3hive', width, height, package = 'd3hiveR')
}

#' Widget render function for use in Shiny
#'
#' @export
renderD3hive <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, d3hiveOutput, env, quoted = TRUE)
}
