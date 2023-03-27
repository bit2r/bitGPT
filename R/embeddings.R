#' Create embeddings with chatGPT
#' @description chatGPT를 이용해서 텍스트 임베딩을 생성함.
#' @param model character. 사용할 모델의 ID. 모델 목록을 조회하는 list_models()를
#' 사용하여 사용 가능한 모든 모델을 확인하거나,
#' Open AI의 모델 개요(https://platform.openai.com/docs/models/overview)에서 모델에 대한 설명을 참조할 수 있음.
#' @param input character. 임베딩을 가져올 텍스트를 문자열 또는 토큰의 character 벡터.
#' 단일 요청에서 여러 입력에 대한 임베딩을 가져오려면, 각각 벡터의 원소로 입력함.
#' 각 입력의 길이는 8192토큰을 초과하지 않아야 함.
#' @param user character. 최종 사용자를 나타내는 고유 식별자로, OpenAI가 악용을 모니터링하고 감지하는 데 도움이 될 수 있음.
#' @param openai_api_key character. openai의 API key.
#' @return {numeric matrix.} 개별 입력을 열로 갖는 수치 행렬.
#' @references OpenAI의 API reference 중에서 [Completions > Create embeddings](https://platform.openai.com/docs/api-reference/embeddings/create)
#' @examples
#' \dontrun{
#' # 사용 가능한 모델의 조회
#' library(dplyr)
#' list_models(unnest = TRUE) %>%
#'   filter(stringr::str_detect(id, "text-(embedding|similarity)")) %>%
#'   arrange(desc(created))
#'
#' poem <- c(
#'   "님은 갔습니다. 아아, 사랑하는 나의 님은 갔습니다. 푸른 산빛을 깨치고 단풍나무 숲을 향하야 난 적은 길을 걸어서 참어 떨치고 갔습니다.",
#'   "넓은 들 동쪽 끝으로 옛 이야기 지줄대는 실개천이 휘돌아 나가고 얼룩백이 황소가 해설피 금빛 게으른 울음을 우는 곳 그곳이 차마 꿈엔들 잊힐리야.",
#'   "한잔의 술을 마시고 우리는 버지니아울프의 생애와 목마를 타고 떠난 숙녀의 옷자락을 이야기한다.",
#'   "아아, 님은 갔지마는 나는 님을 보내지 아니하였습니다. 제 곡조를 못 이기는 사랑의 노래는 님의 침묵을 휩싸고 돕니다.",
#'   "전설바다에 춤추는 밤물결 같은 검은 귀밑머리 날리는 어린 누이와 아무렇지도 않고 예쁠 것도 없는 사철 발벗은 아내가 따가운 햇살을 등에 지고 이삭 줍던 곳, 그곳이 차마 꿈엔들 잊힐리야.",
#'   "목마는 주인을 버리고 거저 방울 소리만 울리며 가을 속으로 떠났다 술병에서 별이 떨어진다 상심한 별은 내 가슴에 가벼웁게 부서진다"
#' )
#'
#' poem_embddings <- create_embeddings(model = "text-embedding-ada-002", input = poem)
#'
#' dim(poem_embddings)
#' head(poem_embddings)
#'
#' # 코사인 유사도 계산
#' poem_embddings %>%
#'   lsa::cosine()
#' }
#' @export
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom openai create_embedding
create_embeddings <- function(model,
                              input,
                              user = NULL,
                              openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  #---------------------------------------------------------------------------
  # Validate arguments

  assertthat::assert_that(
    assertthat::is.string(model),
    assertthat::noNA(model)
  )

  if (!is.null(user)) {
    assertthat::assert_that(
      assertthat::is.string(user),
      assertthat::noNA(user)
    )
  }

  response <- openai::create_embedding(
    model = model,
    input = input,
    user = user,
    openai_api_key = openai_api_key
  )

  answer <- response$data$embedding %>%
    sapply(cbind)

  answer
}

