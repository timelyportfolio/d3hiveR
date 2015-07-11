#' htmlwidget for d3.js hive plots
#'
#' Tame your network hairball with hive plots.  For more on hive plots,
#'    see the Martin Krzywinski's \href{http://www.hiveplot.com/}{hive plot site}.
#'
#' @param data \code{\link[HiveR]{HivePlotData}} object
#' @param innerRadius \code{integer} in px for the inner radius of the hive
#'          plot.  The default is square root(height) * 2.
#' @param outerRadius \code{integer} in px for the outer radius of the hive
#'          plot.  The default is 0.9 * height/2.
#' @param width a valid \code{CSS} size for the width of the container
#' @param height a valid \code{CSS} size for the height of the container
#'
#' @examples
#' \dontrun{
#' library(HiveR)
#' library(d3hive)
#'
#' d3hive( ranHiveData( nx = 5, ne = 1000) )
#' }
#'
#' @import htmlwidgets
#' @importFrom dplyr '%>%' group_by summarise do ungroup inner_join mutate slice
#' @export

d3hive <- function(
  data = NULL
  , innerRadius = NULL
  , outerRadius = NULL
  , width = NULL, height = NULL
) {

  stopifnot( inherits(data,"HivePlotData") )

  #######
  #  how do we identify nodes that will need to be plotted
  #    when an HPD object does not easily show this
  #    or at least I don't think it does
  #    with dplyr we could do the following

  #  for now let's normalize with HiveR
  #     hopefully, we can move this to d3/javascript side
  data <- manipAxis( data, method = "norm" )

  #  to get number of unique nodes by axis
  data$nodes %>%
    group_by(axis) %>%
    # assuming same radius and size uniquely identify a node
    summarise( nrow(unique(data.frame(radius,size))) )
  #  to get the unique nodes with their radius and size
  nodes <- data$nodes %>%
    group_by(axis) %>%
    # assuming same radius and size uniquely identify a node
    do( unique( data.frame(radius = .$radius, size = .$size) ) ) %>%
    mutate( node_id = paste0(axis,"_",1:n() ) ) %>%
    ungroup %>%
    #   then we can send over a list of nodes
    #    but we will also need other meta information
    #    and we will need a mapping of node id to their new id based on unique size/radius
    #    which we should be able to accomplish by inner_join
    {suppressMessages(inner_join( .,data$nodes ))}

  #  now that we have nodes uniquely identified
  #    we'll need to add the node identifier to our links/edges
  edges <- data$edges %>%
  {
    data.frame(
      "source" = nodes[match(.$id1,nodes$id),][["node_id"]]
      ,"target" = nodes[match(.$id2,nodes$id),][["node_id"]]
      ,.
    )
  }

  #  should  be able to now pare down to only unique nodes
  nodes <- nodes %>%
    group_by( node_id ) %>%
    slice(1)


  # forward options using x
  x = list(
    data = list(nodes = nodes, edges = edges)
    ,options = list(
      innerRadius = innerRadius
      ,outerRadius = outerRadius
    )
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
