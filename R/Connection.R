# Refer to https://github.com/rstats-db/odbc/blob/master/R/Connection.R

#' Teradata Odbc Connection Methods
#'
#' Implementations of pure virtual functions defined in the `DBI` package
#' for TeradataOdbcConnection objects.
#' @name TeradataOdbcConnection
NULL

#' @rdname TeradataOdbcConnection
#' @export
setClass("TeradataOdbcConnection",
         contains="OdbcConnection",
         slots = list(
           ptr = "externalptr",
           quote = "character",
           info = "ANY",
           encoding = "character"
         ))

#' @rdname TeradataOdbcConnection
#' @inheritParams methods::show
#' @export
setMethod(
  "show", "TeradataOdbcConnection",
  function(object) {
    info <- dbGetInfo(object)

    cat(sep = "", "<TeradataOdbcConnection>",
        if (nzchar(info[["servername"]])) {
          paste0(" ",
                 if (nzchar(info[["username"]])) paste0(info[["username"]], "@"),
                 info[["servername"]], "\n")
        },
        if (!dbIsValid(object)) {
          "  DISCONNECTED\n"
        } else {
          paste0(collapse = "",
                 if (nzchar(info[["dbname"]])) {
                   paste0("  Database: ", info[["dbname"]], "\n")
                 },
                 if (nzchar(info[["dbms.name"]]) && nzchar(info[["db.version"]])) {
                   paste0("  ", info[["dbms.name"]], " ", "Version: ", info[["db.version"]], "\n")
                 },
                 NULL)
        })
  })

# #' @rdname OdbcConnection
# #' @inheritParams DBI::dbIsValid
# #' @export
# setMethod(
#   "dbIsValid", "OdbcConnection",
#   function(dbObj, ...) {
#     connection_valid(dbObj@ptr)
#   })
#
# #' @rdname OdbcConnection
# #' @inheritParams DBI::dbDisconnect
# #' @export
# setMethod(
#   "dbDisconnect", "OdbcConnection",
#   function(conn, ...) {
#     if (!dbIsValid(conn)) {
#       warning("Connection already closed.", call. = FALSE)
#     }
#
#     on_connection_closed(conn)
#     connection_release(conn@ptr)
#     invisible(TRUE)
#   })
#
# #' @rdname OdbcConnection
# #' @inheritParams DBI::dbSendQuery
# #' @export
# setMethod(
#   "dbSendQuery", c("OdbcConnection", "character"),
#   function(conn, statement, ...) {
#     res <- OdbcResult(connection = conn, statement = statement)
#     res
#   })
#
# #' @rdname OdbcConnection
# #' @inheritParams DBI::dbSendStatement
# #' @export
# setMethod(
#   "dbSendStatement", c("OdbcConnection", "character"),
#   function(conn, statement, ...) {
#     res <- OdbcResult(connection = conn, statement = statement)
#     res
#   })
#
# #' @rdname OdbcConnection
# #' @inheritParams DBI::dbDataType
# #' @export
# setMethod(
#   "dbDataType", "OdbcConnection",
#   function(dbObj, obj, ...) {
#     odbcDataType(dbObj, obj)
#   })
#
# #' @rdname OdbcConnection
# #' @inheritParams DBI::dbDataType
# #' @export
# setMethod(
#   "dbDataType", c("OdbcConnection", "data.frame"),
#   function(dbObj, obj, ...) {
#     vapply(obj, odbcDataType, con = dbObj, FUN.VALUE = character(1), USE.NAMES = TRUE)
#   })
#
# #' @rdname OdbcConnection
# #' @inheritParams DBI::dbQuoteString
# #' @export
# setMethod(
#   "dbQuoteString", c("OdbcConnection", "character"),
#   function(conn, x, ...) {
#     # Optional
#     getMethod("dbQuoteString", c("DBIConnection", "character"), asNamespace("DBI"))(conn, x, ...)
#   })
#
# #' @rdname OdbcConnection
# #' @inheritParams DBI::dbQuoteIdentifier
# #' @export
# setMethod(
#   "dbQuoteIdentifier", c("OdbcConnection", "character"),
#   function(conn, x, ...) {
#     if (nzchar(conn@quote)) {
#       x <- gsub(conn@quote, paste0(conn@quote, conn@quote), x, fixed = TRUE)
#     }
#     DBI::SQL(paste(conn@quote, encodeString(x), conn@quote, sep = ""))
#   })
#
#
# #' Un-Quote identifiers
# #'
# #' Call this method to generate a string that is unquoted. This is the inverse
# #' of `DBI::dbQuoteIdentifier`.
# #'
# #' @param x A character vector to un-quote.
# #' @inheritParams DBI::dbQuoteIdentifier
# #' @export
# setGeneric(
#   "dbUnQuoteIdentifier",
#   function(conn, x, ...) standardGeneric("dbUnQuoteIdentifier")
# )
#
# #' @rdname dbUnQuoteIdentifier
# #' @inheritParams DBI::dbQuoteIdentifier
# #' @export
# setMethod(
#   "dbUnQuoteIdentifier", c("OdbcConnection", "SQL"),
#   function(conn, x) {
#     x <- as.character(x)
#     x <- gsub(paste0("^", conn@quote), "", x)
#     x <- gsub(paste0(conn@quote, "$"), "", x)
#     x
#   })
#
# #' @rdname dbUnQuoteIdentifier
# #' @inheritParams DBI::dbQuoteIdentifier
# #' @export
# setMethod(
#   "dbUnQuoteIdentifier", c("OdbcConnection", "character"),
#   function(conn, x) {
#     x
#   })
#
# # @rdname OdbcConnection
# # @inheritParams DBI::dbListTables
# # @export
# setMethod(
#   "dbListTables", "OdbcConnection",
#   function(conn, ...) {
#     connection_sql_tables(conn@ptr, ...)$table_name
#   })
#
# # @rdname OdbcConnection
# # @inheritParams DBI::dbExistsTable
# # @export
# setMethod(
#   "dbExistsTable", c("OdbcConnection", "character"),
#   function(conn, name, ...) {
#     stopifnot(length(name) == 1)
#     dbUnQuoteIdentifier(conn, name) %in% dbListTables(conn, ...)
#   })
#
# # @rdname OdbcConnection
# # @inheritParams DBI::dbListFields
# # @export
# setMethod(
#   "dbListFields", c("OdbcConnection", "character"),
#   function(conn, name, ...) {
#     connection_sql_columns(conn@ptr, table_name = name)[["name"]]
#   })
#
# # @rdname OdbcConnection
# # @inheritParams DBI::dbRemoveTable
# # @export
# setMethod(
#   "dbRemoveTable", c("OdbcConnection", "character"),
#   function(conn, name, ...) {
#     name <- dbQuoteIdentifier(conn, name)
#     dbExecute(conn, paste("DROP TABLE ", name))
#     on_connection_updated(conn, name)
#     invisible(TRUE)
#   })

#' @rdname TeradataOdbcConnection
#' @inheritParams DBI::dbGetInfo
#' @export
setMethod(
  "dbGetInfo", "TeradataOdbcConnection",
  function(dbObj, ...) {
    info <- dbObj@info
    structure(info, class = c(info$dbms.name, "driver_info", "list"))
  })

# # @rdname OdbcConnection
# # @inheritParams DBI::dbGetQuery
# # @inheritParams DBI::dbFetch
# # @export
# setMethod("dbGetQuery", signature("OdbcConnection", "character"),
#           function(conn, statement, n = -1, ...) {
#             rs <- dbSendQuery(conn, statement, ...)
#             on.exit(dbClearResult(rs))
#
#             df <- dbFetch(rs, n = n, ...)
#
#             if (!dbHasCompleted(rs)) {
#               warning("Pending rows", call. = FALSE)
#             }
#
#             df
#           }
# )
#
# # @rdname OdbcConnection
# # @inheritParams DBI::dbBegin
# # @export
# setMethod(
#   "dbBegin", "OdbcConnection",
#   function(conn, ...) {
#     connection_begin(conn@ptr)
#     invisible(TRUE)
#   })
#
# # @rdname OdbcConnection
# # @inheritParams DBI::dbCommit
# # @export
# setMethod(
#   "dbCommit", "OdbcConnection",
#   function(conn, ...) {
#     connection_commit(conn@ptr)
#     invisible(TRUE)
#   })
#
# # @rdname OdbcConnection
# # @inheritParams DBI::dbRollback
# # @export
# setMethod(
#   "dbRollback", "OdbcConnection",
#   function(conn, ...) {
#     connection_rollback(conn@ptr)
#     invisible(TRUE)
#   })
#
# # List Available ODBC Drivers
# #
# # @return A data frame with three columns.
# # If a given driver does not have any attributes the last two columns will be
# # `NA`.
# # \describe{
# #   \item{name}{Name of the driver}
# #   \item{attribute}{Driver attribute name}
# #   \item{value}{Driver attribute value}
# # }
# # @export
# odbcListDrivers <- function() {
#   res <- list_drivers_()
#   if (nrow(res) > 0) {
#     res[res == ""] <- NA_character_
#   }
#   res
# }
#
# # List Available Data Source Names
# #
# # @return A data frame with two columns.
# # \describe{
# #   \item{name}{Name of the data source}
# #   \item{description}{Data Source description}
# # }
# # @export
# odbcListDataSources <- function() {
#   list_data_sources_()
# }
#
# # Set the Transaction Isolation Level for a Connection
# #
# # @param levels One or more of \Sexpr[stage=render, results=rd]{odbc:::choices_rd(names(odbc:::transactionLevels()))}.
# # @inheritParams DBI::dbDisconnect
# # @seealso \url{https://docs.microsoft.com/en-us/sql/odbc/reference/develop-app/setting-the-transaction-isolation-level}
# # @export
# # @noMd
# # @examples
# # \dontrun{
# #   # Can use spaces or underscores in between words.
# #   odbcSetTransactionIsolationLevel(con, "read uncommitted")
# #
# #   # Can also use the full constant name.
# #   odbcSetTransactionIsolationLevel(con, "SQL_TXN_READ_UNCOMMITTED")
# # }
# odbcSetTransactionIsolationLevel <- function(conn, levels) {
#   # Convert to lowercase, spaces to underscores, remove sql_txn prefix
#   levels <- tolower(levels)
#   levels <- gsub(" ", "_", levels)
#   levels <- sub("sql_txn_", "", levels)
#   levels <- match.arg(tolower(levels), names(transactionLevels()), several.ok = TRUE)
#
#   set_transaction_isolation(conn@ptr, transactionLevels()[levels])
# }