#' Get API keys from package file
#' @description 패키지 파일에 등록된 openai API key와 Naver API key를 조회합니다.
#' @details regist_openai_key(), regist_naver_key()를 사용하지 않고, set_api_key(),
#' set_naver_key()로 API key를 설정한 경우라면, get_api_key() 대신에
#' Sys.getenv("OPENAI_API_KEY"), Sys.getenv("NAVER_CLIENT_ID"),
#' Sys.getenv("NAVER_CLIENT_SECRET")를 사용하세요.
#' @examples
#' \dontrun{
#' # get_api_key()
#' }
#' @export
#' @import dplyr
#' @importFrom base64enc base64decode
get_api_key <- function() {
  openai_file <- system.file(".openapiKey", package = "bitGPT")
  naver_file  <- system.file(".naverKey", package = "bitGPT")

  # for openai API key
  if (openai_file != "") {
    con <- file(openai_file, "r")

    tryCatch({
      openai_api_key <- readLines(con) %>%
        base64enc::base64decode() %>%
        rawToChar()
    },
    finally = {
      close(con)
    })
  } else {
    openai_api_key = NULL
  }

  # for Naver papago API key
  if (naver_file != "") {
    con <- file(naver_file, "r")

    tryCatch({
      naver_api_key <- readLines(con) %>%
        base64enc::base64decode() %>%
        rawToChar()

      naver_client_id <- strsplit(naver_api_key, ":")[[1]][1]
      naver_client_secret <- strsplit(naver_api_key, ":")[[1]][2]
    },
    finally = {
      close(con)
    })
  } else {
    naver_client_id = NULL
    naver_client_secret = NULL
  }

  list(openai_api_key = openai_api_key,
       naver_client_id = naver_client_id,
       naver_client_secret = naver_client_secret)
}


#' Set openai API key to system environment
#' @description openai와 인터페이스하기 위한 openai API key를 설정합니다.
#' @param api_key character. 등록할 openai API key.
#' @details 만약에 여러 사용자가 사용하는 환경이 아닌 개인 컴퓨터에 bitGPT 패키지를 설치한 경우라면,
#' set_openai_key() 대신에 매번 API key를 등록할 필요없는 regist_openai_key()를 사용하세요.
#' @examples
#' \dontrun{
#' # 실제 사용자가 할당받은 openai API key를 사용합니다.
#' # set_openai_key("XXXXXXXXXXX")
#' }
#' @export
set_openai_key <- function(api_key = NULL) {
  Sys.setenv(
    OPENAI_API_KEY = api_key
  )
}


#' Set Naver API key to system environment
#' @description Naver 파파고 번역기와 인터페이스하기 위한 openai API key를 설정합니다.
#' @param client_id character. 등록할 API key의 client ID.
#' @param client_secret character. 등록할 API key의 client Secret.
#' @details 만약에 여러 사용자가 사용하는 환경이 아닌 개인 컴퓨터에 bitGPT 패키지를 설치한 경우라면,
#' set_naver_key() 대신에 매번 API key를 등록할 필요없는 regist_naver_key()를 사용하세요.
#' @examples
#' \dontrun{
#' # 실제 사용자가 할당받은 Naver API key를 사용합니다.
#' # set_naver_key()
#' }
#' @export
set_naver_key <- function(client_id = NULL, client_secret = NULL) {
  Sys.setenv(
    NAVER_CLIENT_ID = client_id,
    NAVER_CLIENT_SECRET = client_secret
  )
}


#' Regist openai API key to package file
#' @description openai와 인터페이스하기 위한 openai API key를 등록합니다.
#' @param api_key character. 등록할 openai API key.
#' @details 만약에 개인 컴퓨터가 아닌 여러 사용자가 사용하는 환경에 bitGPT 패키지를 설치한 경우라면,
#' API key의 보안을 위해서 regist_openai_key()대신 set_openai_key()를 사용하세요.
#' @examples
#' \dontrun{
#' # 실제 사용자가 할당받은 openai API key를 사용합니다.
#' # regist_openai_key("XXXXXXXXXXX")
#' }
#' @export
#' @import dplyr
#' @importFrom base64enc base64encode
regist_openai_key <- function(api_key = NULL) {
  key_file <- file.path(system.file(package = "bitGPT"), ".openapiKey")

  decode_api_key <- api_key %>%
    charToRaw() %>%
    base64enc::base64encode()

  if (!file.exists(key_file)) {
    con <- file(key_file, "w")
    tryCatch({
      cat(decode_api_key, file = con, sep = "\n")
    }, finally = {
      close(con)
    })
  }

  Sys.setenv(
    OPENAI_API_KEY = api_key
  )
}


#' Regist Naver API key to package file
#' @description Naver와 인터페이스하기 위한 Client ID와 Client Secret를 등록합니다.
#' @param client_id character. 등록할 API key의 client ID.
#' @param client_secret character. 등록할 API key의 client Secret.
#' @details 만약에 개인 컴퓨터가 아닌 여러 사용자가 사용하는 환경에 bitGPT 패키지를 설치한 경우라면,
#' API key의 보안을 위해서 regist_naver_key()대신 set_naver_key()를 사용하세요.
#' @examples
#' \dontrun{
#' # 실제 사용자가 할당받은 Naver API key를 사용합니다.
#' # regist_naver_key(client_id = "XXXXXXXXXXX", client_secret = "XXXXXXXXXXX")
#' }
#' @export
#' @import dplyr
#' @importFrom base64enc base64encode
regist_naver_key <- function(client_id = NULL, client_secret = NULL) {
  key_file <- file.path(system.file(package = "bitGPT"), ".naverKey")

  decode_api_key <- glue::glue("{client_id}:{client_secret}") %>%
    charToRaw() %>%
    base64enc::base64encode()

  if (!file.exists(key_file)) {
    con <- file(key_file, "w")
    tryCatch({
      cat(decode_api_key, file = con, sep = "\n")
    }, finally = {
      close(con)
    })
  }

  Sys.setenv(
    NAVER_CLIENT_ID = client_id,
    NAVER_CLIENT_SECRET = client_secret
  )
}

