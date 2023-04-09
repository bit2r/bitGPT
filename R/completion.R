
#' Create completion with chatGPT
#' @description chatGPT를 이용해서 completion을 수행함.
#' @param model character. 사용할 모델의 ID. 모델 목록을 조회하는 list_models()를
#' 사용하여 사용 가능한 모든 모델을 확인하거나,
#' Open AI의 모델 개요(https://platform.openai.com/docs/models/overview)에서 모델에 대한 설명을 참조할 수 있음.
#' @param prompt character. 문자열, 문자열 배열, 토큰 배열 또는 토큰 배열 배열로 인코딩된 완료를 생성할 프롬프트(들).
#' 기본값인 "<|endoftext|>"는 학습 중에 모델이 보는 문서 구분 기호이므로 프롬프트를 지정하지 않으면 모델은 새 문서가 시작될 때처럼 생성함.
#' @param suffix character. 삽입된 텍스트의 완성 뒤에 오는 접미사.
#' @param max_tokens integer. 생성된 답변에 허용되는 토큰의 최대 개수.
#' 기본적으로 모델이 반환할 수 있는 토큰 수는 (4096 - 프롬프트 토큰).
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
#' @param logprobs numeric. 로그 확률로 가장 높은 토큰과 선택한 토큰에 대한 로그 확률을 포함함.
#' 예를 들어 로그 확률이 5인 경우, API는 가장 가능성이 높은 5개 토큰 목록을 반환함.
#' API는 항상 샘플링된 토큰의 로그 확률을 반환하므로 응답에 최대 로그 확률+1 요소가 포함될 수 있음.
#' 로그 프로브의 최대 값은 5.
#' @param echo logical. 완료와 함께 메시지에 답장하기.
#' @param stop character. API가 추가 토큰 생성을 중지하는 시퀀스는 1부터 최대 4개까지임.
#' @param presence_penalty numeric. -2.0에서 2.0 사이의 숫자.
#' 양수 값은 지금까지 텍스트에 등장한 토큰에 따라 새로운 토큰에 불이익을 주므로 모델이 새로운 주제에 대해 이야기할 가능성이 높아짐.
#' @param frequency_penalty numeric. -2.0에서 2.0 사이의 숫자.
#' 양수 값은 지금까지 텍스트에서 기존 빈도에 따라 새 토큰에 불이익을 주어 모델이 같은 줄을 그대로 반복할 가능성을 낮춤.
#' @param best_of integer. 서버 측에서 best_of completions를 생성하고
#' '최고'(토큰당 로그 확률이 가장 높은 것)를 반환. 결과는 스트리밍할 수 없음.
#' n과 함께 사용할 경우, best_of는 후보 완료 수를 제어하고 n은 반환할 완료 수를 지정함(best_of는 n보다 커야 함).
#' @param logit_bias 완료에 지정된 토큰이 표시될 가능성을 수정.
#' 토큰(GPT 토큰화 도구에서 토큰 ID로 지정됨)을 -100에서 100 사이의 연관된 바이어스
#' 값에 매핑하는 list 객체를 받음. 이 토큰화 도구(GPT-2 및 GPT-3 모두에서 작동)를
#' 사용하여 텍스트를 토큰 ID로 변환할 수 있음. 수학적으로, 편향은 샘플링 전에 모델에서 생성된 로릿값에 추가됨.
#' 정확한 효과는 모델마다 다르지만 -1에서 1 사이의 값은 선택 가능성을 낮추거나 높이고,
#' -100 또는 100과 같은 값은 관련 토큰을 금지하거나 배타적으로 선택하게 됨.
#' 예를 들어 list("50256" = -100)을 전달하여 <|endoftext|> 토큰이 생성되지 않도록 할 수 있음.
#' @param user character. 최종 사용자를 나타내는 고유 식별자로, OpenAI가 악용을 모니터링하고 감지하는 데 도움이 될 수 있음.
#' @param ko2en logical. 프롬프트가 한국어일 때, 영어로 번역하여 질의하는 여부 설정.
#' TRUE이면 한글 프롬프트를 영어로 번역하여 프롬프트를 질의하고, 영어 질의 결과를 한국어로 번역해서 반환함.
#' @param type character. 반환하는 결과 타입. "text", "console", 에서 선택하며,
#' 기본값인 "text"는 텍스트를, "console"는 R 콘솔에 프린트 아웃됨.
#' @param openai_api_key character. openai의 API key.
#' @details best_of 인수는 많은 완료를 생성하므로 토큰 할당량을 빠르게 소모할 수 있습니다.
#' 최대_토큰과 중지에 대한 합리적인 설정이 있는지 확인하고 신중하게 사용하세요.
#' @references OpenAI의 API reference 중에서 [Completions > Create completion](https://platform.openai.com/docs/api-reference/completions/create)
#' @examples
#' \dontrun{
#' prompt_en <- "Tell us the best way to learn R. Include data analysis theories and important R packages to learn."
#' prompt_kr <- "최고의 R 학습 방법을 알려주세요. 학습해야할 데이터 분석 이론과 중요한 R 패키지를 포함해 주세요."
#' # 텍스트로 반환
#' create_completion(
#'   model = "text-davinci-003",
#'   max_tokens = 150,
#'   prompt = prompt_kr
#' )
#'
#' create_completion(
#'   model = "text-davinci-003",
#'   prompt = prompt_kr,
#'   ko2en = FALSE,
#'   max_tokens = 150,
#'   type = "console"
#' )
#'
#' logit_bias <- list(
#'   "11" = -100,
#'   "13" = -100
#' )
#'
#' create_completion(
#'   model = "text-davinci-002",
#'   prompt = prompt_kr,
#'   n = 4,
#'   best_of = 4,
#'   max_tokens = 150,
#'   logit_bias = logit_bias
#' )
#' }
#' @export
#' @importFrom assertthat assert_that is.string noNA is.readable
#' @importFrom glue glue
#' @importFrom openai create_completion
#' @importFrom stringr str_remove_all
#' @importFrom purrr map_chr walk
create_completion <- function(model,
                              prompt = "<|endoftext|>",
                              suffix = NULL,
                              max_tokens = 16L,
                              temperature = 1,
                              top_p = 1,
                              n = 1L,
                              stream = FALSE,
                              logprobs = NULL,
                              echo = FALSE,
                              stop = NULL,
                              presence_penalty = 0,
                              frequency_penalty = 0,
                              best_of = 1L,
                              logit_bias = NULL,
                              user = NULL,
                              ko2en = TRUE,
                              type = c("text", "console"),
                              openai_api_key = Sys.getenv("OPENAI_API_KEY")) {

  type <- match.arg(type)
  #-----------------------------------------------------------------------------
  # Validate arguments

  #---------------------------------------------------------------------------
  # Validate arguments

  assertthat::assert_that(
    assertthat::is.string(model),
    assertthat::noNA(model)
  )

  assertthat::assert_that(
    is.character(prompt),
    assertthat::noNA(prompt)
  )

  if (!is.null(suffix)) {
    assertthat::assert_that(
      assertthat::is.string(suffix),
      assertthat::noNA(suffix)
    )
  }

  assertthat::assert_that(
    assertthat::is.count(max_tokens)
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

  if (openai:::both_specified(temperature, top_p)) {
    warning(
      "It is recommended NOT to specify temperature and top_p at a time."
    )
  }

  assertthat::assert_that(
    assertthat::is.count(n)
  )

  assertthat::assert_that(
    assertthat::is.flag(stream),
    assertthat::noNA(stream),
    is_false(stream)
  )

  if (!is.null(logprobs)) {
    assertthat::assert_that(
      assertthat::is.count(logprobs + 1),
      value_between(logprobs, 0, 5)

    )
  }

  assertthat::assert_that(
    assertthat::is.flag(echo),
    assertthat::noNA(echo)
  )

  if (!is.null(stop)) {
    assertthat::assert_that(
      is.character(stop),
      assertthat::noNA(stop),
      openai:::length_between(stop, 1, 4)
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

  assertthat::assert_that(
    assertthat::is.count(best_of)
  )

  assertthat::assert_that(
    best_of >= n
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
    assertthat::is.string(openai_api_key),
    assertthat::noNA(openai_api_key)
  )

  if (ko2en) {
    prompt <- translate(prompt)
  }

  response <- openai::create_completion(
    model = model,
    prompt = prompt,
    suffix = suffix,
    max_tokens = max_tokens,
    temperature = temperature,
    top_p = top_p,
    n = n,
    stream = stream,
    logprobs = logprobs,
    echo = echo,
    stop = stop,
    presence_penalty = presence_penalty,
    frequency_penalty = frequency_penalty,
    best_of = best_of,
    logit_bias = logit_bias,
    user = user,
    openai_api_key = openai_api_key
  )

  answer <- response$choices$text

  if (ko2en) {
    answer <- answer %>%
      purrr::map_chr(
        function(x) {
          x <- stringr::str_remove_all(x, "\\n|\\t")
          translate(x, "en", "ko")
        }
      )
  }

  if (type %in% "text") {
    return(answer)
  } else   if (type %in% "console") {
    answer %>%
      purrr::walk(
        function(x) {
          cat(x, "\n")
        }
      )
  }
}
