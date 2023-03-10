% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/env.R
\name{regist_naver_key}
\alias{regist_naver_key}
\title{Regist Naver API key to package file}
\usage{
regist_naver_key(client_id = NULL, client_secret = NULL)
}
\arguments{
\item{client_id}{character. 등록할 API key의 client ID.}

\item{client_secret}{character. 등록할 API key의 client Secret.}
}
\description{
Naver와 인터페이스하기 위한 Client ID와 Client Secret를 등록합니다.
}
\details{
만약에 개인 컴퓨터가 아닌 여러 사용자가 사용하는 환경에 bitGPT 패키지를 설치한 경우라면,
API key의 보안을 위해서 regist_naver_key()대신 set_naver_key()를 사용하세요.
}
\examples{
\dontrun{
# 실제 사용자가 할당받은 Naver API key를 사용합니다.
# regist_naver_key(client_id = "XXXXXXXXXXX", client_secret = "XXXXXXXXXXX")
}
}
