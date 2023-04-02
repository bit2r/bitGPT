#' Chat with chatGPT
#' @description chatGPT의 chat completion을 이용해서 채팅을 수행합니다.
#' @param prompt character. 채팅을 위한 user role의 프롬프트.
#' @param last logical. 마지막 user role의 프롬프트와 assistant role의 답변을 출력할지의 여부.
#' 기본값은 TRUE로 마지막 대화내용만 출력함. FALSE일 경우에는 모든 대화 이력을 출력함.
#' @param initialize logical. 지존의 대화 정보를 초기화한 후, 채팅을 수할지의 여부.
#' 기본값은 FALSE로 대화를 계속 이어감.
#' @references {https://github.com/bit2r/bitGPT/issues/25 이 기능의 구현과 코드는 HelloDataScience님의 제안을 반영하였습니다. 감사드립니다.}
#' @examples
#' \dontrun{
#' # 대화 생성
#' keep_completion(prompt = "지금 대한민국에서 가장 중요한 이슈가 뭐야?")
#' keep_completion(prompt = "그렇다면 현재 진행 중인 상태는 어떤가?")
#'
#' # 새로운 대화를 시작함
#' keep_completion(prompt = "지금 대한민국에서 가장 중요한 이슈가 뭐야?", initialize = TRUE)
#'
#' # 처음 대화부터 출력함
#' keep_completion(prompt = "그렇다면 현재 진행 중인 상태는 어떤가?", last = FALSE)
#' }
#' @export
#' @import dplyr
keep_completion <- function(prompt, last = TRUE, initialize = FALSE) {
  if (initialize) {
    unset_gptenv("chat_messages")
  }

  # messages 생성 또는 추가하여 패키지 environment에 추가
  if (is.null(get_gptenv("chat_messages"))) {
    # messages가 없으면 prompt로 새 messages 생성
    set_gptenv("chat_messages", create_messages(user = prompt))
  } else {
    # messages가 있으면 user prompt 추가
    get_gptenv("chat_messages") %>%
      add(user = prompt) %>%
      set_gptenv("chat_messages", .)
  }

  # 채팅 형태로 질문에 답변(answer) 생성
  answer <- chat_completion(messages = get_gptenv("chat_messages"), type = 'messages')
  set_gptenv("chat_messages", answer)

  if (last) {
    # 마지막 질문과 답변만 출력
    show(messages = last(answer))
  } else {
    show(messages = answer)
  }
}


#' Extract chat messages from environment
#' @description 패키지 environment의 채팅 messages 객체를 추출합니다.
#' @details 채팅을 위해서 개발된 keep_completion() 함수가 생성하는 messages 객체를 추출하는 기능입니다.
#' @examples
#' \dontrun{
#' keep_completion(prompt = "지금 대한민국에서 가장 중요한 이슈가 뭐야?")
#' keep_completion(prompt = "그렇다면 현재 진행 중인 상태는 어떤가?")
#'
#' extract_chat()
#' }
#' @export
extract_chat <-  function() {
  if (is.null(get_gptenv("chat_messages"))) {
    stop("채팅 메시지가 존재하지 않습니다.")
  }
  get_gptenv("chat_messages")
}
