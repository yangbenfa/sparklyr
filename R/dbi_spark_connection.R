#' @include dbi_spark_driver.R
NULL

#' DBISparkConnection and methods.
#'
#' @keywords internal
#' @export
#' @rdname dbi-spark-connection
setClass("DBISparkConnection",
         contains = "DBIConnection",
         slots = c(con = "list")
)

#' @export
#' @rdname dbi-spark-connection
setMethod("dbGetInfo", "DBISparkConnection", function(dbObj, ...) {
  connection_info(dbObj)
})

#' @export
#' @rdname dbi-spark-connection
setMethod("show", "DBISparkConnection", function(object) {
  info <- dbGetInfo(object)

  cat("<DBISparkConnection> ", info$master, "\n", sep = "")
})

#' Connect to Spark
#'
#' @param drv \code{splyr::DBISpark()}
#' @param master Master location.
#' @export
#' @rdname dbi-spark-connection
#' @examples
#' library(DBI)
#' con <- dbConnect(splyr::DBISpark())
#' dbDisconnect(con)
setMethod("dbConnect", "DBISparkDriver", function(drv, master = NULL, ...) {
  con <- spark_api_start(master = "local", appName = "splyr")
  new("DBISparkConnection", con = con)
})

#' @export
#' @rdname dbi-spark-connection
setMethod("dbDisconnect", "DBISparkConnection", function(conn, ...) {
  stop_shell(conn@con)

  TRUE
})

#' Determine database type for R vector.
#'
#' @export
#' @param dbObj Spark driver or connection.
#' @param obj Object to convert
#' @keywords internal
#' @rdname dbi-spark-connection
setMethod("dbDataType", "DBISparkDriver", function(dbObj, obj) {
  get_data_type(obj)
})

#' @export
#' @rdname dbi-spark-connection
setMethod("dbDataType", "DBISparkConnection", function(dbObj, obj) {
  get_data_type(obj)
})

get_data_type <- function(obj) {
  if (is.factor(obj)) return("TEXT")

  switch(typeof(obj),
         integer = "INTEGER",
         double = "REAL",
         character = "STRING",
         logical = "INTEGER",
         list = "BLOB",
         stop("Unsupported type", call. = FALSE)
  )
}

#' @export
#' @rdname dbi-spark-connection
setMethod("dbQuoteIdentifier", c("DBISparkConnection", "character"), function(conn, x, ...) {
  if (regexpr("`", x)[[1]] >= 0)
    stop("Can't scape back tick from string")

  y <- paste("`", x, "`", sep = "")

  SQL(y)
})