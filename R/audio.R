#' Speech to Text with chatGPT
#' @description chatGPT를 이용해서 음성 오디오 파일로 STT(Speech to Text )를 수행함.
#' @param file character. 음성 오디오 파일 이름.
#' @param language character. 음성 오디오 파일의 언어. ISO-639-1 포맷으로 지정해야 하며,
#' 기본값은 한국어인 "ko".
#' @param openai_api_key character. openai의 API key.
#' @details 오디오 파일의 포맷은 mp3, mp4, mpeg, mpga, m4a, wav, webm중 하나만 허용함.
#' @examples
#' \dontrun{
#' # 음성 오디오 파일
#' speech <- system.file("audios", "korea_r_user.m4a", package = "bitGPT")
#'
#' # 음성 오디오를 텍스트로 전환
#' transcript_audio(speech)
#' }
#' @export
#' @importFrom httr upload_file POST add_headers content http_error status_code
#' @importFrom assertthat assert_that is.string noNA is.readable
#' @importFrom glue glue
#' @importFrom jsonlite fromJSON
transcript_audio <- function(file,
                             language = "ko",
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

  #-----------------------------------------------------------------------------
  # Validate arguments

  assertthat::assert_that(
    assertthat::is.string(file),
    assertthat::noNA(file),
    file.exists(file),
    assertthat::is.readable(file)
  )

  if (!is.null(language)) {
    assertthat::assert_that(
      assertthat::is.string(language),
      assertthat::noNA(language)
    )
  }

  assertthat::assert_that(
    assertthat::is.string(openai_api_key),
    assertthat::noNA(openai_api_key)
  )

  #-----------------------------------------------------------------------------
  # Build path parameters

  task <- "audio/transcriptions"

  base_url <- glue::glue("https://api.openai.com/v1/{task}")

  headers <- c(
    "Authorization" = paste("Bearer", openai_api_key),
    "Content-Type" = "multipart/form-data"
  )

  #---------------------------------------------------------------------------
  # Build request body

  body <- list()
  body[["file"]] <- httr::upload_file(file)
  body[["model"]] <- "whisper-1"
  body[["language"]] <- language

  #---------------------------------------------------------------------------
  # Make a request and parse it

  response <- httr::POST(
    url = base_url,
    httr::add_headers(.headers = headers),
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

  parsed %>%
    unlist()
}


