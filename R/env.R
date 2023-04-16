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
#' # set_naver_key(client_id = "XXXXXXXXXXX", client_secret = "XXXXXXXXXXX")
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

set_gptenv <- function(name, value) {
  assign(name, value, envir = .bitGPTEnv)
}

unset_gptenv <- function(name) {
  value <- get_gptenv(name)
  if (!is.null(value)) {
    rm(list = name, envir = .bitGPTEnv)
  }
}

get_gptenv <- function(name) {
  if (missing(name)) {
    as.list(.bitGPTEnv)
  } else {
    .bitGPTEnv[[name]]
  }
}


set_last_tokens <- function(service = c("chat_completion", "create_completion", "create_embeddings"),
                            prompt_tokens = NULL, completion_tokens = NULL, total_tokens = NULL) {
  service <- match.arg(service)

  if (service %in% "create_embeddings") {
    completion_tokens <- 0
  }

  Sys.setenv(
    BITGPT_SERVICE_ID = service,
    BITGPT_PROMPT_TOKENS = prompt_tokens,
    BITGPT_COMPLETION_TOKENS = completion_tokens,
    BITGPT_TOTAL_TOKENS = total_tokens
  )
}


#' Get usage token for last call
#' @description 마지막에 호출된 언어모델에 대한 사용 토큰 정보를 가져옵니다.
#' @param is_value logical. TRUE이면 사용 토큰량들을 리스트 객체로 반환하고,
#' FALSE이면 그 정보를 콘솔에 출력합니다.
#' @details 언어모델을 인터페이스한 "chat_completion()", "create_completion()", "create_embeddings()"만 지원합니다.
#' API key의 보안을 위해서 regist_naver_key()대신 set_naver_key()를 사용하세요.
#' @examples
#' \dontrun{
#' poem <- c(
#'   "님은 갔습니다. 아아, 사랑하는 나의 님은 갔습니다. 푸른 산빛을 깨치고 단풍나무 숲을 향하야 난 적은 길을 걸어서 참어 떨치고 갔습니다.",
#'   "넓은 들 동쪽 끝으로 옛 이야기 지줄대는 실개천이 휘돌아 나가고 얼룩백이 황소가 해설피 금빛 게으른 울음을 우는 곳 그곳이 차마 꿈엔들 잊힐리야.",
#'   "한잔의 술을 마시고 우리는 버지니아울프의 생애와 목마를 타고 떠난 숙녀의 옷자락을 이야기한다.",
#'   "아아, 님은 갔지마는 나는 님을 보내지 아니하였습니다. 제 곡조를 못 이기는 사랑의 노래는 님의 침묵을 휩싸고 돕니다.",
#'   "전설바다에 춤추는 밤물결 같은 검은 귀밑머리 날리는 어린 누이와 아무렇지도 않고 예쁠 것도 없는 사철 발벗은 아내가 따가운 햇살을 등에 지고 이삭 줍던 곳, 그곳이 차마 꿈엔들 잊힐리야.",
#'   "목마는 주인을 버리고 거저 방울 소리만 울리며 가을 속으로 떠났다 술병에서 별이 떨어진다 상심한 별은 내 가슴에 가벼웁게 부서진다"
#' )
#'
#' poem_embeddings <- create_embeddings(model = "text-embedding-ada-002", input = poem)
#'
#' get_last_tokens()
#' }
#' @export
#' @importFrom glue glue
#' @importFrom cli cli_alert_info
get_last_tokens <- function(is_value = TRUE) {
  service <- Sys.getenv("BITGPT_SERVICE_ID")
  prompt_tokens <- Sys.getenv("BITGPT_PROMPT_TOKENS")
  completion_tokens <- Sys.getenv("BITGPT_COMPLETION_TOKENS")
  total_tokens <- Sys.getenv("BITGPT_TOTAL_TOKENS")

  result <- list(
    service = service,
    prompt_tokens = prompt_tokens,
    completion_tokens = completion_tokens,
    total_tokens = total_tokens
  )

  if (is_value) {
    return(result)
  } else {
    glue::glue("service: {service}, prompt tokens: {prompt_tokens}, completion tokens: {completion_tokens}, total tokens: {total_tokens}") %>%
      cli::cli_alert_info()
  }
}



