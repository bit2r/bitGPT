# using some script in https://github.com/irudnyts/openai/blob/main/R/utils-assertions.R
value_between <- function(x, lower, upper) {
  x >= lower && x <= upper
}

assertthat::on_failure(value_between) <- function(call, env) {
  paste0(
    deparse(call$x),
    " is not between ",
    deparse(call$lower),
    " and ",
    deparse(call$upper)
  )
}

is_false <- function(x) {
  !x
}

assertthat::on_failure(is_false) <- function(call, env) {
  paste0(deparse(call$x), " is not yet implemented.")
}

is_messages <- function(x) {
  x_class <- class(x)[1]

  if (x_class %in% "character") {
    return(is.character(x) && length(x) == 1)
  } else {
    return(x_class %in% "messages")
  }
}

assertthat::on_failure(is.string) <- function(call, env) {
  paste0(deparse(call$x), " is not a string (a length one character vector) or not a messages object.")
}


# modufy openai package
verify_mime_type <- function (result) {
  if (httr::http_type(result) != "application/json") {
    paste("OpenAI API probably has been changed. If you see this, please",
          "rise an issue at: https://github.com/bit2r/bitGPT/issues") %>%
      stop()
  }
}
