% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/chating.R
\name{extract_chat}
\alias{extract_chat}
\title{Extract chat messages from environment}
\usage{
extract_chat()
}
\description{
패키지 environment의 채팅 messages 객체를 추출합니다.
}
\details{
채팅을 위해서 개발된 keep_completion() 함수가 생성하는 messages 객체를 추출하는 기능입니다.
}
\examples{
\dontrun{
keep_completion(prompt = "지금 대한민국에서 가장 중요한 이슈가 뭐야?")
keep_completion(prompt = "그렇다면 현재 진행 중인 상태는 어떤가?")

extract_chat()
}
}
