#' Naver 파파고 번역기
#' @description Naver 파파고 번역 API를 이용해서 텍스트의 번역을 수행합니다.
#' @param text character. 번역할 텍스트.
#' @param source character. 번역할 텍스트 언어의 언어 코드. 기본값은 "ko"로 한국어를 번역함.
#' @param target character. 번역될 언어의 언어 코드. 기본값은 "en"로 영어로 번역함.
#' @param client_id character. Naver 파파고 API key의 client ID.
#' @param client_secret character. Naver 파파고 API key의 client Secret.
#' @details 지원되는 언어와 언어 코드는 https://developers.naver.com/docs/papago/papago-nmt-api-reference.md를 참고하세요.
#' @examples
#' \dontrun{
#' text <- "빈센트 반 고흐 스타일로 일출과 갈매기를 그려줘"
#' translate(text)
#' }
#' @export
#' @importFrom glue glue
#' @importFrom httr POST add_headers
#' @importFrom jsonlite fromJSON
translate <- function(text = NULL, source = "ko", target = "en",
                      client_id = Sys.getenv("NAVER_CLIENT_ID"),
                      client_secret = Sys.getenv("NAVER_CLIENT_SECRET")) {
  if (is.null(text)) {
    stop("번역할 텍스트인 text를 입력하지 않았습니다.")
  }

  if (is.null(client_id)) {
    stop("Naver API Clint ID를 입력하지 않았습니다.")
  }

  if (is.null(client_secret)) {
    stop("Naver API Clint Secret를 입력하지 않았습니다.")
  }

  transURL <- "https://openapi.naver.com/v1/papago/n2mt"

  response <- transURL %>%
    httr::POST(
      httr::add_headers(
        "Content-Type"          = "application/x-www-form-urlencoded; charset=UTF-8",
        "X-Naver-Client-Id"     = client_id,
        "X-Naver-Client-Secret" = client_secret
      ),
      body = glue::glue("text={text}&source={source}&target={target}")
    ) %>%
    toString() %>%
    jsonlite::fromJSON()

  response$message$result$translatedText
}



