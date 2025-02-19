#' DeepL 번역기
#' @description DeepL 번역 API를 이용해서 텍스트의 번역을 수행합니다.
#' @param text character. 번역할 텍스트.
#' @param source character. 번역할 텍스트 언어의 언어 코드. 기본값은 "KO"로 한국어를 번역함.
#' @param target character. 번역될 언어의 언어 코드. 기본값은 "EN"로 영어로 번역함.
#' @param deepl_api_key character. DeepL API key.
#' @details 지원되는 언어와 언어 코드는 https://developers.deepl.com/docs/api-reference/translate/openapi-spec-for-text-translation를 참고하세요.
#' @examples
#' \dontrun{
#' text <- "빈센트 반 고흐 스타일로 일출과 갈매기를 그려줘"
#' translate(text)
#' }
#' @export
#' @importFrom glue glue
#' @importFrom httr POST add_headers
translate <- function(text = NULL, target = "EN", source = "KO",
                      deepl_api_key = Sys.getenv("DEEPL_API_KEY")) {
  if (is.null(text)) {
    stop("번역할 텍스트인 text를 입력하지 않았습니다.")
  }

  if (is.null(deepl_api_key)) {
    stop("DeepL API Key를 입력하지 않았습니다.")
  }

  transURL <- "https://api-free.deepl.com/v2/translate"

  response <- httr::POST(
    url  = transURL,
    body = list(text = text, source_lang = source, target_lang = target),
    httr::add_headers(Authorization = paste("DeepL-Auth-Key", deepl_api_key)))

  httr::content(response)[["translations"]] |>
    purrr::map_chr("text")
}


