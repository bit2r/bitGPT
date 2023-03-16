#' List models
#' @description 현재 사용 가능한 모델을 나열하고 소유자 및 사용 가능 여부와 같은,
#' 각 모델에 대한 기본 정보를 제공.
#' @param unnest logical. nested list 변수인 permission을 펼칠지의 여부.
#' 기본값은 FALSE로 펼치지 않고, TRUE이면 펼쳐서 data.frame의 변수로 만들어짐.
#' @return a data.frame.
#' Names of data.frame is as follows.
#' \itemize{
#'   \item id : 모델의 고유 식별자. 이 식별자는 모델을 호출하거나 다른 API 요청에서 참조할 때 사용됨.
#'   \item object : 객체의 종류를 나타내는 문자열. 모든 "List models" API 결과의 object 값은 "model".
#'   \item created : 모델이 생성된 날짜와 시간.
#'   \item owned_by : 모델의 오너.
#'   \item permission : 모델의 권한. 중첩된 정보를 포함하고 있음. 다음의 변수를 포함함.
#'   \itemize{
#'     \item id : 권한의 고유 식별자.
#'     \item object : 객체의 종류를 나타내는 문자열. 모든 object 값은 "model_permission".
#'     \item created : 권한이 생성된 날짜와 시간.
#'     \item allow_create_engine : 엔진 생성 가부.
#'     \item allow_sampling : 샘플링 가부.
#'     \item allow_logprobs : logprobs 가부.
#'     \item allow_search_indices : search indices 가부.
#'     \item allow_view : view 가부.
#'     \item allow_fine_tuning : fine tuning 가부.
#'     \item organization : organization.
#'     \item group : 그룹.
#'     \item is_blocking : 블록 여부.
#'   }
#'   \item root : 모델의 루트.
#'   \item parent : 모델의 부모 모델.
#' }
#' @examples
#' \dontrun{
#' get_model_list()
#'
#' # nested list 변수인 permission을 펼침
#' get_model_list(unnest = TRUE)
#' }
#' @export
#' @import dplyr
#' @importFrom openai list_models
#' @importFrom lubridate as_datetime
#' @importFrom purrr map_dfr
model_list <- function(unnest = FALSE) {
  models <- openai::list_models() %>%
    "$"("data") %>%
    mutate(created = lubridate::as_datetime(created))

  if (unnest) {
    permission <- models$permission %>%
      purrr::map_dfr(
        function(x) x
      ) %>%
      mutate(created = lubridate::as_datetime(created)) %>%
      rename("permission_id" = id,
             "permission_object" = object,
             "permission_created" = created)

    models <- models %>%
      bind_cols(permission) %>%
      select(-permission)
  }

  models
}

