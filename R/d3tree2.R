#' Create an Interactive Treemap (Version 2)
#'
#' \code{d3tree2} is the primary function for creating interactive d3.js treemaps from
#' various data types in R.  Easily use \code{\link[treemap]{treemap}} plots customized with
#' \code{treemap}, or supply a \code{list} for a more typical \code{d3.js} experience, or
#' blend the two.
#'
#' @param data the data to be plotted as either
#'           the result of \code{\link[treemap]{treemap}} or
#'           a \code{list} or \code{JSON} as \code{character} or \code{file}
#'           in the form of a \code{d3.js} hierarchy.
#' @param rootname \code{character} for the name of the root if \code{data} is a
#'           \code{treemap} object.
#' @param id \code{character} of the name or id.  The default is \code{"id"}.  Often
#'           \code{d3.js} hierarchies will use \code{"name"} instead of \code{"id"}.  We will use
#'           \code{id} as the default to allow nodes with non-unique names.
#' @param celltext \code{character} of the field that contains the title for each cell.  The
#'           default is \code{"name"}.
#' @param valueField \code{character} of the name of the field containing the value on which
#'           you would like your treemap based.  The default is \code{"size"}.
#' @param clickAction \code{character} or \code{htmlwidgets::JS} to provide additional
#'           actions to perform when a tree node/cell is clicked.  The JavaScript function should
#'           expect one argument, which will be the \code{object} of the node clicked, so the form
#'           should look something like \code{function(d){ console.log(d) }}.
#' @param width,height a valid \code{CSS} size for the width and height of the container.
#'           Percentage values work also by supplying as \code{character} such as \code{width = "100\%"}
#'
#' @examples
#' \dontrun{
#' #####  designed to work seamlessly with treemap
#' library(treemap)
#' library(d3treeR)
#'
#' # example 1 from ?treemap
#' data(GNI2010)
#' d3tree2(
#'    treemap(
#'      GNI2010
#'      ,index=c("continent", "iso3")
#'      ,vSize="population"
#'      ,vColor="GNI"
#'      ,type="value"
#'    )
#'    , rootname = "World"
#' )
#' }
#'
#' # last example from ?treemap
#' data(business)
#' # Brewer's Red-White-Grey palette reversed with predefined range
#' business$employees.growth <- business$employees - business$employees.prev
#' d3tree2(
#'   treemap(business,
#'        index=c("NACE1", "NACE2"),
#'        vSize="employees",
#'        vColor="employees.growth",
#'        type="value",
#'        palette="-RdGy",
#'        range=c(-30000,30000))
#'   , rootname="Fictitious Business Data"
#' )
#' ####
#'
#' #### also works with d3.js json
#' library(d3treeR)
#' d3tree2(
#'   "http://bl.ocks.org/mbostock/raw/4063269/flare.json"
#'   , celltext = "name"
#' )
#' ####
#'
#' @importFrom jsonlite fromJSON toJSON
#'
#' @export
d3tree2 <- function(
  data = NULL
  , rootname = NULL
  , celltext = "name"
  , id = "id"
  , valueField = "size"
  , clickAction = NULL
  , width = NULL
  , height = NULL
) {

  meta = NULL
  legend = NULL

  # accept treemap
  if( inherits(data,"list" ) && names(data)[1] == "tm" ){
    meta = data[-1]
    data = convert_treemap(
      data$tm
      , ifelse(!is.null(rootname),rootname,deparse(substitute(data)))
    )
    legend = extract_legend()
  }

  # accept data.frame

  # accept data.tree

  # accept JSON string
  if( inherits(data,c("character","connection")) ){
    data = jsonlite::toJSON(
      jsonlite::fromJSON( data )
      , auto_unbox = TRUE
      , dataframe = "rows"
    )
  }


  # accept list
  #  here we shouldn't need to do anything

  # convert clickAction if character to htmlwidgets::JS
  if(is.character(clickAction) && !inherits(clickAction,"JS_EVAL")){
    clickAction <- htmlwidgets::JS(clickAction)
  }

  # forward options using x
  x = list(
    data = data
    ,meta = meta
    ,legend = legend
    ,options = list(
      celltext = celltext
      ,id = id
      ,valueField = valueField
      ,clickAction = clickAction
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'd3tree2',
    x,
    width = width,
    height = height,
    package = 'd3treeR'
  )
}


#' Widget output function for use in Shiny
#'
#' @export
d3tree2Output <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'd3tree2', width, height, package = 'd3treeR')
}

#' Widget render function for use in Shiny
#'
#' @export
renderD3tree2 <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, d3tree2Output, env, quoted = TRUE)
}
