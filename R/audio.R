#' Speech to Text with chatGPT
#' @description chatGPT를 이용해서 음성 오디오 파일로 STT(Speech to Text)를 수행함.
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


#' Record audio
#' @description record record audio using the current audio device
#' @param time numeric. 오디오를 레코딩할 시간. 단위는 초.
#' @param sample_rate integer. 샘플링 비율. 기본값은 44100으로 설정.
#' @param channels character. 레코딩 채널 설정. 모노와 스테레오 중에서 선택하며,
#' 기본값은 모노인 "mono".
#' @param fname character. 레코딩된 오디오 파일의 이름. 기본값은 "voice.wav".
#' @param overwrite logical. 이미 오디오 파일이 존재할 때, 파일을 overwrite할지의 여부.
#' @param openai_api_key character. openai의 API key.
#' @details 현재 오디오 드라이버의 오디오 인스턴스를 생성하여 오디오 녹음을 지정한 시간만큼 수행.
#' @examples
#' \dontrun{
#' # 10초동안 오디오를 녹음함
#' record_audio(10)
#'
#' # 10초동안 오디오를 스테레오로 녹음함
#' record_audio(10, channels = "stereo")
#' }
#' @export
#' @import dplyr
#' @importFrom glue glue
#' @importFrom audio record wait save.wave
#' @importFrom cli cli_alert_info
record_audio  <- function(time, sample_rate = 44100, channels = c("mono", "stereo"),
                          fname = "voice.wav", overwrite = FALSE) {
  if (fname %in% list.files()) {
    if (!overwrite) {
      stop(glue::glue("{fname} file already exists."))
    }

    file.remove(fname)
    glue::glue('xx files are overwritten.') %>%
      cli::cli_alert_info()
  }

  assertthat::assert_that(
    assertthat::is.number(time),
    assertthat::noNA(time),
    time > 0
  )

  channels <- match.arg(channels) == (c("mono", "stereo")) %>%
    which()

  number_sample <- rep(NA_real_, sample_rate * time)

  audio::record(number_sample, sample_rate, 1)
  audio::wait(time)
  audio::save.wave(number_sample, fname)
}
