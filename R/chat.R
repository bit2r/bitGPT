#' @rdname create_messages
#' @export
add <- function(messages, ...) {
  UseMethod("add", messages)
}


#' @export
show <- function(messages, type = c("console", "viewer"), ...) {
  UseMethod("show", messages)
}


#' @export
last <- function(messages, ...) {
  UseMethod("last", messages)
}

#' Create chat messages for chatGPT
#' @description chatGPT의 chat completion을 수행하기 위한 messages를 생성함
#' @param user character. user role을 갖는 메시지.
#' @param system character. system role을 갖는 메시지.
#' @return messages object.
#' @examples
#' \dontrun{
#' # 메시지 생성
#' msg <- create_messages("Who won the world series in 2020?", "You are a helpful assistant.")
#' msg
#'
#' # 메시지 생성
#' msg <- create_messages("Who won the world series in 2020?")
#' msg
#' }
#' @export
#' @importFrom assertthat assert_that is.string noNA
create_messages <- function(user = NULL, system = NULL) {
  if (!is.null(user)) {
    assertthat::assert_that(
      assertthat::is.string(user),
      assertthat::noNA(user)
    )
  }

  if (!is.null(system)) {
    assertthat::assert_that(
      assertthat::is.string(system),
      assertthat::noNA(system)
    )
  }

  if (!is.null(system)) {
    messages <- list(list(role = "system", content = system),
                     list(role = "user", content = user))
  } else {
    messages <- list(list(role = "user", content = user))
  }

  class(messages) <- append("messages", class(messages))

  messages
}


#' Add chat messages for chatGPT
#' @description chatGPT의 chat completion messages에 메시지를 추가
#' @param messages messages. chatGPT와 chat completion을 수행하기 위한 메시지 객체.
#' @param assistant character. assistant role을 갖는 메시지.
#' @param user character. user role을 갖는 메시지.
#' @return messages object.
#' @examples
#' \dontrun{
#' # 메시지 생성
#' msg <- create_messages("Who won the world series in 2020?", "You are a helpful assistant.")
#' msg
#'
#' # 메시지 추가
#' library(dplyr)
#'
#' msg <- msg %>%
#'   add(assistant = "The Los Angeles Dodgers won the World Series in 2020.",
#'       user = "Where was it played?")
#' msg
#'
#' }
#' @method add messages
#' @export
#' @import dplyr
add.messages <- function(messages, assistant = NULL, user = NULL, ...) {
  if (!is.null(user)) {
    assertthat::assert_that(
      assertthat::is.string(user),
      assertthat::noNA(user)
    )
  }

  if (!is.null(assistant)) {
    assertthat::assert_that(
      assertthat::is.string(assistant),
      assertthat::noNA(assistant)
    )
  }

  if (!is.null(assistant)) {
    messages <- messages %>%
      append(list(list(role = "assistant", content = assistant)))
  }

  if (!is.null(user)) {
    messages <- messages %>%
      append(list(list(role = "user", content = user)))
  }

  class(messages) <- append("messages", class(messages))

  messages
}


#' Chat completion with chatGPT
#' @description chatGPT를 이용해서 chat completion을 수행함.
#' @param messages character. 채팅을 위한 메시지.
#' 길이가 1인 character vector나 messages 객체를 사용함.
#' character vector의 경우에는 role이 user인 경우의 메시지를 기술해야함.
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
#' @param n integer. 각 입력 메시지에 대해 생성할 채팅 완료 선택 항목의 수로 기본값은 1.
#' @param stream logical. 이 옵션을 설정하면 ChatGPT에서와 같이 부분 메시지가 전송됨.
#' 토큰은 사용 가능해지면 data-only server-sent 이벤트로 전송되며, 스트림은 data의 [DONE] 메시지로 스트림이 종료됨.
#' @param stop character. API가 추가 토큰 생성을 중지하는 시퀀스는 1부터 최대 4개까지임.
#' @param max_tokens integer. 생성된 답변에 허용되는 토큰의 최대 개수.
#' 기본적으로 모델이 반환할 수 있는 토큰 수는 (4096 - 프롬프트 토큰).
#' @param presence_penalty numeric. -2.0에서 2.0 사이의 숫자.
#' 양수 값은 지금까지 텍스트에 등장한 토큰에 따라 새로운 토큰에 불이익을 주므로 모델이 새로운 주제에 대해 이야기할 가능성이 높아짐.
#' @param frequency_penalty numeric. -2.0에서 2.0 사이의 숫자.
#' 양수 값은 지금까지 텍스트에서 기존 빈도에 따라 새 토큰에 불이익을 주어 모델이 같은 줄을 그대로 반복할 가능성을 낮춤.
#' @param logit_bias 완료에 지정된 토큰이 표시될 가능성을 수정.
#' 토큰(토큰화기에서 토큰 ID로 지정)을 -100에서 100 사이의 연관된 바이어스 값에 매핑하는 json 객체를 받음.
#' 수학적으로 바이어스는 샘플링 전에 모델에서 생성된 로그에 추가됨.
#' 정확한 효과는 모델마다 다르지만 -1에서 1 사이의 값은 선택 가능성을 줄이거나 늘리고,
#' -100 또는 100과 같은 값은 관련 토큰을 금지하거나 독점적으로 선택하게 됨.
#' @param user character. 최종 사용자를 나타내는 고유 식별자로, OpenAI가 악용을 모니터링하고 감지하는 데 도움이 될 수 있음.
#' @param type character. 반환하는 결과 타입. "messages", "console", "viewer"에서 선택하며,
#' "messages"는 결과를 assistant 컴포넌트에 추가한 messages 객체를 반환함.
#' "console"는 R 콘솔에 프린트 아웃되며, "viewer"는 HTML 포맷으로 브라우저에 출력됨.
#' 만약 결과에 R 코드가 chunk로 포함되어 있다면, 코드가 실행된 결과도 HTML 문서에 포함됨.
#' @details type 인수가 "viewer"일 경우에 질의 결과에 R 코드가 포함되어 있다고 모두 수행되는 것은 아님.
#' R 코드가 chunk로 포함되어 있을 경우에만, 해당 chunk의 R 코드가 실행되며,
#' 어쩌면 불완전한 코드로 인해서 에러가 발생할 수도 있음.
#' 메시지에 이전의 메시지를 추가하여 chat completion을 수행하면,
#' 이전 메시지를 고려하여 결과를 반환함.
#' @param openai_api_key character. openai의 API key.
#' @return messages 객체.
#' @examples
#' \dontrun{
#' # character 벡터로 메시지를 정의하는 사례
#' messages <- "mtcars 데이터를 ggplot2 패키지로 wt 변수와 mpg 변수를 EDA하는 R 스크립트를 짜줘."
#'
#' # 메시지 객체로 반환
#' chat_completion(messages)
#'
#' # R 콘솔에 프린트 아웃
#' chat_completion(messages, type = "console")
#'
#' # HTML 포맷으로 브라우저에 출력
#' chat_completion(messages, type = "viewer")
#'
#' # 메시지 객체로 메시지를 정의하는 사례
#' msg <- create_messages(user = "R을 이용한 통계학의 이해 커리큘럼을 부탁해",
#'                        system = "assistant는 R을 이용해서 통계학을 가르치는 강사입니다.")
#' # 메시지 객체로 반환
#' answer <- chat_completion(msg, type = "messages")
#' answer
#'
#' # 반환받은 메시지 객체에 질의를 위한 user role의 메시지 추가
#' msg <- add(answer, user = "커리큘럼에 tidyverse 패키지를 사용하는 방법을 추가해줘.")
#'
#' # 이전 메시지를 포함하여 추가 질의
#' answer2 <- chat_completion(msg, type = "viewer")
#' answer2
#'
#' }
#' @export
#' @importFrom httr upload_file POST add_headers content http_error status_code
#' @importFrom assertthat assert_that is.string noNA is.readable
#' @importFrom glue glue
#' @importFrom jsonlite fromJSON
#' @importFrom rmarkdown render
#' @importFrom utils browseURL
#' @importFrom stringr str_replace_all
chat_completion <- function(messages = NULL,
                            model = c("gpt-3.5-turbo", "gpt-3.5-turbo-0301"),
                            temperature = 1,
                            top_p = 1,
                            n = 1,
                            stream = FALSE,
                            stop = NULL,
                            max_tokens = NULL,
                            presence_penalty = 0,
                            frequency_penalty = 0,
                            logit_bias = NULL,
                            user = NULL,
                            type = c("messages", "console", "viewer"),
                            openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  #-----------------------------------------------------------------------------
  model <- match.arg(model)
  type <- match.arg(type)

  #-----------------------------------------------------------------------------
  # Validate arguments
  if (!is.null(messages)) {
    assertthat::assert_that(
      is_messages(messages),
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
    value_between(temperature, 0, 2)
  )

  assertthat::assert_that(
    assertthat::is.number(top_p),
    assertthat::noNA(top_p),
    value_between(top_p, 0, 1)
  )

  assertthat::assert_that(
    assertthat::is.count(n)
  )

  assertthat::assert_that(
    assertthat::is.flag(stream),
    assertthat::noNA(stream),
    is_false(stream)
  )

  if (!is.null(stop)) {
    assertthat::assert_that(
      is.character(stop),
      assertthat::noNA(stop),
      length_between(stop, 1, 4)
    )
  }

  if (!is.null(max_tokens)) {
    assertthat::assert_that(
      assertthat::is.count(max_tokens)
    )
  }

  assertthat::assert_that(
    assertthat::is.number(presence_penalty),
    assertthat::noNA(presence_penalty),
    value_between(presence_penalty, -2, 2)
  )

  assertthat::assert_that(
    assertthat::is.number(frequency_penalty),
    assertthat::noNA(frequency_penalty),
    value_between(frequency_penalty, -2, 2)
  )

  if (!is.null(logit_bias)) {
    assertthat::assert_that(
      is.list(logit_bias)
    )
  }

  if (!is.null(user)) {
    assertthat::assert_that(
      assertthat::is.string(user),
      assertthat::noNA(user)
    )
  }

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

  if (class(messages)[1] %in% "character") {
    messages_list <- create_messages(user = messages)
  } else {
    messages_list <- messages
  }


  #---------------------------------------------------------------------------
  # Build request body

  body <- list()
  body[["model"]] <- model
  body[["messages"]] <- messages_list
  body[["temperature"]] <- temperature
  body[["top_p"]] <- top_p
  body[["n"]] <- n
  body[["stream"]] <- stream
  body[["stop"]] <- stop
  body[["max_tokens"]] <- max_tokens
  body[["presence_penalty"]] <- presence_penalty
  body[["frequency_penalty"]] <- frequency_penalty
  body[["logit_bias"]] <- logit_bias
  body[["user"]] <- user

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
  messages_list <- add(messages_list, assistant = answer)

  if (type %in% "messages") {
    return(messages_list)
  } else   if (type %in% "console") {
    show(messages_list, type = "console")
    invisible(messages_list)
  } else if (type %in% "viewer") {
    show(messages_list, type = "viewer")
    invisible(messages_list)
  }
}



#' Show chat messages object
#' @description chatGPT의 chat completion를 위한 messages 객체를 조회함
#' @param messages messages. chatGPT와 chat completion messages 객체.
#' @param type character. 반환하는 결과 타입. console", "viewer"에서 선택하며,
#' 기본값인 "console"는 R 콘솔에 프린트 아웃되며, "viewer"는 HTML 포맷으로 브라우저에 출력됨.
#' 만약 결과에 R 코드가 chunk로 포함되어 있다면, 코드가 실행된 결과도 HTML 문서에 포함됨.
#' @examples
#' \dontrun{
#' msg <- create_messages(user = "R을 이용한 통계학의 이해 커리큘럼을 부탁해",
#'                        system = "assistant는 R을 이용해서 통계학을 가르치는 강사입니다.")
#' show(msg)
#'
#' # 메시지 객체로 반환
#' answer <- chat_completion(msg, type = "messages")
#' show(answer)
#'
#' # 반환받은 메시지 객체에 질의를 위한 user role의 메시지 추가
#' msg <- add(answer, user = "커리큘럼에 tidyverse 패키지를 사용하는 방법을 추가해줘.")
#'
#' # 이전 메시지를 포함하여 추가 질의
#' answer2 <- chat_completion(msg)
#' show(answer2)
#' }

#' @method show messages
#' @export
#' @import dplyr
#' @importFrom purrr walk
#' @importFrom stringr str_replace_all
#' @importFrom cli cli_div cli_rule cli_end
#' @importFrom glue glue
show.messages <- function(messages, type = c("console", "viewer"), ...) {
  if (!is.null(messages)) {
    assertthat::assert_that(
      is_messages_object(messages)
    )
  }

  type <- match.arg(type)

  if (type %in% "console") {
    messages %>%
      purrr::walk(
        function(x) {
          role <- x[["role"]]
          content <- x[["content"]]

          d <- cli::cli_div(theme = list(rule = list(color = "cyan",
                                                     "line-type" = "double")))
          cli::cli_rule("Chat with chatGPT", right = glue::glue("{role}"))
          cli::cli_end(d)
          cat(glue::glue("{content}\n\n\n"))
        }
      )
  } else if (type %in% "viewer") {
    cat("---\n", file = "answer.Rmd")
    cat("title: Chat with chatGPT\n", file = "answer.Rmd", append = TRUE)
    cat("output: html_document\n", file = "answer.Rmd", append = TRUE)
    cat("---\n\n", file = "answer.Rmd", append = TRUE)

    messages %>%
      purrr::walk(
        function(x) {
          role <- x[["role"]]
          content <- x[["content"]] %>%
            stringr::str_replace_all("```r", "```{r}")

          file_gear <- system.file("images", "gear.svg", package = "bitGPT")
          file_user <- system.file("images", "user.svg", package = "bitGPT")
          file_gpt <- system.file("images", "chatgpt-icon.png", package = "bitGPT")

          if (role %in% "system") {
            cat("<p><span style='font-weight: bold; font-size:15px; color:#A94342'>![](", file_gear, "){#id .class width=4% height=4%} System</span></p>\n\n",
                file = "answer.Rmd", append = TRUE)
            cat(glue::glue("<div class='alert alert-danger' role='alert'>{content}</div>\n\n"),
                file = "answer.Rmd", append = TRUE)
          } else if (role %in% "user") {
            cat("<p><span style='font-weight: bold; font-size:15px; color:#31708F'>![](", file_user, "){#id .class width=4% height=4%} User</span></p>\n\n",
                file = "answer.Rmd", append = TRUE)
            cat(glue::glue("<div class='alert alert-info' role='alert'>{content}</div>\n\n"),
                file = "answer.Rmd", append = TRUE)
          } else if (role %in% "assistant") {
            cat("<p><div align='right' style='margin-top:25px; margin-bottom:20px; font-weight: bold; font-size:15px; color:#0BA37F;'>Assistant ![](", file_gpt, "){#id .class width=3.3% height=3.3%}</div></p>\n\n",
                file = "answer.Rmd", append = TRUE)
            cat(glue::glue("<div class='alert alert-success' role='alert'>{content}</div>\n\n"),
                file = "answer.Rmd", append = TRUE)
          }
        }
      )

    rmarkdown::render("answer.Rmd")
    if (interactive()) utils::browseURL("answer.html")

    unlink("answer.Rmd")
    unlink("answer.md")
  }
}


#' Extract last messages from messages object
#' @description messages 객체에서 마지막 대화를 추출합니다.
#' @details 채팅을 기능을 구현하기 위해서 마지막 대화만 핸들링하는 경우에 유용합니다.
#' @examples
#' \dontrun{
#' msg <- create_messages(user = "R을 이용한 통계학의 이해 커리큘럼을 부탁해",
#'                        system = "assistant는 R을 이용해서 통계학을 가르치는 강사입니다.")
#' show(msg)
#'
#' # 메시지 객체로 반환
#' answer <- chat_completion(msg, type = "messages")
#' show(answer)
#'
#' # 반환받은 메시지 객체에 질의를 위한 user role의 메시지 추가
#' msg <- add(answer, user = "커리큘럼에 tidyverse 패키지를 사용하는 방법을 추가해줘.")
#'
#' # 이전 메시지를 포함하여 추가 질의
#' answer2 <- chat_completion(msg)
#' show(answer2)
#'
#' last(answer2)
#' }
#' @method last messages
#' @export
#' @importFrom assertthat assert_that
last.messages <- function(messages, ...) {
  if (!is.null(messages)) {
    assertthat::assert_that(
      is_messages_object(messages)
    )
  }

  n <- length(messages)
  last_message <- messages[(n-1):n]

  class(last_message) <- c('messages', 'list')

  last_message
}


