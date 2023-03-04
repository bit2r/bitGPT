
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bitGPT <img src="man/figures/bitGPT.png" align="right" height="120" width="103.6"/>

## Overview

chatGPT를 보다 쉽게 사용할 수 있는, 그리고 한국어를 지원하는 `bitGPT`.

Features:

- open API 키를 관리 기능으로 인한 손쉬운 서비스 인터페이싱
  - OpenAI의 API 키
  - Naver 파파고의 client ID와 secret
- OpenAI의 이미지 프로세싱
  - 이미지 생성
    - 영어 프롬프트와 한국어 프롬프트 지원
    - 한국어 프롬프트는 영어 프롬프트로 번역되어 질의
  - 이미지 변형
- OpenAI의 STT(Speech to Text)
- Naver 파파고의 텍스트 번역기

## Install bitGPT

github 리파지토리로부터 다음의 명령어로 패키지를 설치합니다.:

``` r
devtools::install_github("bit2r/bitGPT")
```
