#' Chat completion with chatGPT
#' @description chatGPT를 이용해서 Chat completion을 수행함.
#' @param messages character. 채팅을 위한 메시지. 메시지는 영문과 국문 모두 가능함.
#' @param model character. Chat completion에 사용할 OpenAI의 모델로,
#' "gpt-3.5-turbo", "gpt-3.5-turbo-0301"에서 선택함. 기본값은 "gpt-3.5-turbo".
#' @param temperature numeric. 0에서 2 사이에서 사용할 샘플링 온도.
#' 0.8과 같이 값이 높으면 출력이 더 무작위적이고,
#' 0.2와 같이 값이 낮으면 더 집중적이고 결정론적인 출력이 됨.
#' 일반적으로 이 값 또는 top_p를 변경하는 것이 좋지만 둘 다 변경하는 것은 권장하지 않음.
#' @param top_p numeric. 온도를 이용한 샘플링의 대안으로, 핵 샘플링이라고 하며,
#' 모델이 상위_p 확률 질량을 가진 토큰의 결과를 고려.
#' 따라서 0.1은 상위 10% 확률 질량을 구성하는 토큰만 고려한다는 의미.
#' 일반적으로 이 값이나 temperature를 변경하는 것을 권장하지만 둘 다 변경하는 것은 권장하지 않음.
#' @param type character. 반환하는 결과 타입. "text", "console", "viewer"에서 선택하며,
#' 기본값인 "text"는 텍스트를, "console"는 R 콘솔에 프린트 아웃되며,
#' "viewer"는 HTML 포맷으로 브라우저에 출력됨.
#' @param openai_api_key character. openai의 API key.
#' @examples
#' \dontrun{
#' # 텍스트로 반환
#' messages <- "mtcars 데이터를 ggplot2 패키지로 EDA하는 R 스크립트를 짜줘."
#' chat_completion(messages)
#'
#' # R 콘솔에 프린트 아웃
#' chat_completion(messages, type = "console")
#'
#' # HTML 포맷으로 브라우저에 출력
#' chat_completion(messages, type = "viewer")
#' }
#' @export
#' @importFrom httr upload_file POST add_headers content http_error status_code
#' @importFrom assertthat assert_that is.string noNA is.readable
#' @importFrom glue glue
#' @importFrom jsonlite fromJSON
#' @importFrom knitr knit2html
#' @importFrom utils browseURL
chat_completion <- function(messages = NULL,
                            model = c("gpt-3.5-turbo", "gpt-3.5-turbo-0301"),
                            temperature = 1, top_p = 1,
                            type = c("text", "console", "viewer"),
                            openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  #-----------------------------------------------------------------------------
  # User defined function
  verify_mime_type <- function (result) {
    if (httr::http_type(result) != "application/json") {
      paste("OpenAI API probably has been changed. If you see this, please",
            "rise an issue at: https://github.com/irudnyts/openai/issues") %>%
        stop()
    }
  }

  model <- match.arg(model)
  type <- match.arg(type)
  #-----------------------------------------------------------------------------
  # Validate arguments

  if (!is.null(messages)) {
    assertthat::assert_that(
      assertthat::is.string(messages),
      assertthat::noNA(messages)
    )
  }

  assertthat::assert_that(
    assertthat::is.string(model),
    assertthat::noNA(model)
  )

  assertthat::assert_that(
    assertthat::is.number(temperature),
    assertthat::noNA(temperature),
    temperature >= 0  & temperature <= 2
  )

  assertthat::assert_that(
    assertthat::is.number(top_p),
    assertthat::noNA(top_p),
    temperature >= 0  & top_p <= 1
  )

  assertthat::assert_that(
    assertthat::is.string(type),
    assertthat::noNA(type)
  )

  assertthat::assert_that(
    assertthat::is.string(openai_api_key),
    assertthat::noNA(openai_api_key)
  )

  #-----------------------------------------------------------------------------
  # Build path parameters

  task <- "chat/completions"

  base_url <- glue::glue("https://api.openai.com/v1/{task}")

  headers <- c(
    "Authorization" = paste("Bearer", openai_api_key),
    "Content-Type" = "application/json"
  )

  messages_list = list(list(role = "user", content = messages))

  #---------------------------------------------------------------------------
  # Build request body

  body <- list()
  body[["model"]] <- model
  body[["messages"]] <- messages_list
  body[["temperature"]] <- temperature
  body[["top_p"]] <- top_p

  #---------------------------------------------------------------------------
  # Make a request and parse it

  response <- httr::POST(
    url = base_url,
    httr::add_headers(.headers = headers),
    encode = "json",
    body = body
  )

  verify_mime_type(response)

  parsed <- response %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON(flatten = TRUE)

  #---------------------------------------------------------------------------
  # Check whether request failed and return parsed

  if (httr::http_error(response)) {
    paste0(
      "OpenAI API request failed [",
      httr::status_code(response),
      "]:\n\n",
      parsed$error$message
    ) %>%
      stop(call. = FALSE)
  }

  answer <- parsed$choices$message.content

  if (type %in% "text") {
    return(answer)
  } else   if (type %in% "console") {
    cat(answer)
  } else   if (type %in% "viewer") {
    cat(glue::glue("Question\n\n<p><span style='font-weight: bold; font-size:15px; color:orange'>{messages}</span></p>\n\nAnswer\n\n"), file = "answer.md")
    cat(answer, file = "answer.md", append = TRUE)
    knitr::knit2html("answer.md")
    if (interactive()) utils::browseURL("answer.html")
    unlink("answer.md")
    unlink("answer.txt")
  }
}


