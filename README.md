
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bitGPT <img src="man/figures/bitGPT.png" align="right" height="120" width="103.6"/>

## Overview

chatGPT를 보다 쉽게 사용할 수 있는, 그리고 한국어를 지원하는 `bitGPT`.

Features:

- open API key를 관리 기능으로 인한 손쉬운 서비스 인터페이싱
  - OpenAI의 API key
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

## Prepare API keys

chatGPT를 사용하기 위해서는
[OpenAI](https://platform.openai.com/account/api-keys) 링크에서
`회원을 가입`하고 `OpenAI API key`를 발급받아야 합니다. **가입 후 첫
3달은 18 US 달러 credit이 무료이나, 이후에는 유료임을 인지하고
진행**하시기 바랍니다.

또한 한국어 환경으로 좀 더 편안한 사용을 위해서는
`Naver 파파고 API key`도 준비해야 합니다. [오픈 API
이용신청](https://developers.naver.com/apps/#/register?api=ppg_n2mt)
링크에서 `애플리케이션 등록(API 이용신청)`을 통해서 API key를 발급받아야
합니다.

### OpenAI API key 등록

API key는 공유되어서는 안됩니다. 예시에서는 OpenAI API key가
XXXXXXXXXXX임을 가정하였습니다.

`regist_openai_key()`를 한번 수행하면, 번거롭게 매번 세션마다 API key를
설정할 필요가 없습니다.

``` r
library(bitGPT)

# 실제 사용자가 할당받은 openai API key를 사용합니다.
regist_openai_key("XXXXXXXXXXX")
```

만약에 개인 컴퓨터가 아닌 여러 사용자가 사용하는 환경에 bitGPT 패키지를
설치한 경우라면, API key의 보안을 위해서 `regist_openai_key()`대신
`set_openai_key()`를 사용하세요.

`set_openai_key()`는 OpenAI API key를 R System environment에 설정하기
때문에 세션이 종료되고 다시 R을 구동해서 새로운 세션이 생기면,
재설정해야 합니다.

``` r
# 실제 사용자가 할당받은 openai API key를 사용합니다.
set_openai_key("XXXXXXXXXXX")
```

### Naver 파파고 API key 등록

Naver 파파고 API key는 `client ID`와 `client secret`로 구성되어
있습니다. OpenAI API key와 유사한 방법으로 `regist_naver_key()`를 한번
수행하여 등록하거나, `set_naver_key()`로 세션 내에서 설정합니다.

``` r
# 실제 사용자가 할당받은 Naver API key로 등록합니다.
regist_naver_key(client_id = "XXXXXXXXXXX", client_secret = "XXXXXXXXXXX")
```

``` r
# 실제 사용자가 할당받은 Naver API key로 설정합니다.
set_naver_key(client_id = "XXXXXXXXXXX", client_secret = "XXXXXXXXXXX")
```

## Laguage translation

### 파파고 번역

`translate()`는 파파고 번역을 수행합니다.

``` r
translate(
  text = NULL,
  source = "ko",
  target = "en",
  client_id = Sys.getenv("NAVER_CLIENT_ID"),
  client_secret = Sys.getenv("NAVER_CLIENT_SECRET")
)
```

- text
  - character. 번역할 텍스트입니다.
- source
  - character. 번역할 텍스트 언어의 언어 코드입니다. 기본값은 “ko”로
    한국어를 번역합니다.
- target
  - character. 번역될 언어의 언어 코드입니다. 기본값은 “en”로 영어로
    번역합니다.
- client_id
  - character. Naver 파파고 API key의 client ID입니다.
- client_secret
  - character. Naver 파파고 API key의 client Secret입니다.

몇 개 문장을 번역해 봅니다.

``` r
text <- "빈센트 반 고흐 스타일로 일출과 갈매기를 그려줘"
translate(text)
#> [1] "Draw a sunrise and a seagull in Vincent van Gogh style."

text <- "We’ve trained a model called ChatGPT which interacts in a conversational way. The dialogue format makes it possible for ChatGPT to answer followup questions, admit its mistakes, challenge incorrect premises, and reject inappropriate requests."
translate(text, "en", "ko")
#> [1] "우리는 대화 방식으로 상호 작용하는 ChatGPT이라는 모델을 훈련시켰다. 대화 형식을 통해 ChatGPT는 후속 질문에 답변하고, 실수를 인정하며, 잘못된 전제에 도전하고, 부적절한 요청을 거부할 수 있습니다."
```

## Image processing

### Create image with chatGPT

`chatGPT`를 이용해서, 생성할 이미지를 설명하는 프롬프트에 부합하는
이미지를 생성할 수 있습니다.

여러분은 다음의 `draw_img()`로 원하는 그림을 그리는 화가가 될 수
있습니다.

``` r
draw_img(
  prompt,
  ko2en = TRUE,
  n = 1L,
  size = c("1024x1024", "256x256", "512x512"),
  type = c("url", "image", "file"),
  format = c("png", "jpeg", "gif"),
  path = "./",
  fname = "aidrawing",
  openai_api_key = Sys.getenv("OPENAI_API_KEY")
)
```

- prompt
  - character. 이미지 생성 명령을 수행할 프롬프트입니다. 그림을 그리고자
    하는 화가의 상상을 영어나 한글로 쓰면 됩니다.
- ko2en
  - logical. 프롬프트가 한국어일 때, 영어로 번역하여 질의하는 여부
    설정합니다. TRUE이면 한글 프롬프트를 영어로 번역하여 프롬프트를
    질의합니다. 한글로 프롬프트를 작성하면, 그려진 그림의 결과가 원하는
    결과를 만들지 못한 경험이 많습니다. 그래서 한글 프롬프트에서는
    반드시 TRUE로 지정하는 것이 좋습니다.
- n
  - integer. 생성할 이미지의 개수를 1과 10 사이의 정수로 지정합니다.
    기본값은 1로 하나의 그림을 그립니다.
- size
  - character. 생성할 이미지의 크기로 “1024x1024”, “256x256”,
    “512x512”에서 하나를 선택합니다. 정사각형 크기만 지원하며, 기본값은
    “1024x1024”입니다.
- type
  - character. 반환하는 이미지 타입을 다음 3가지에서 선택합니다.
    - “url” : 기본값으로 생성된 이미지에 접근할 수 있는 OpenAI의 URL을
      반환합니다.
    - “image” : 생성한 이미지를 R 환경의 플롯으로 출력합니다.
    - “file” : 이미지 파일을 생성합니다.
- format
  - character. 이미지 파일의 포맷으로 `type`의 값이 “file”일 경우만
    적용됩니다. “png”, “jpeg”, “gif”에서 선택하며, 기본값은 “png”입니다.
- path
  - character. 파일을 생성할 디렉토리 경로로 `type`의 값이 “file”일
    경우만 적용됩니다.
- fname
  - character. 경로와 확장자를 제외한 이미지 파일의 이름으로, `type`의
    값이 “file”일 경우만 적용됩니다.
- openai_api_key
  - character. OpenAI API key입니다. 만약 `regist_openai_key()`,
    `sett_openai_key()`로 API key를 설정했다면 이 인수값을 지정할
    필요없습니다.

**빈센트 반 고흐 스타일로 해변에서의 일출과 갈매기를 그려보겠습니다.**

영어 프롬프트로 그림을 그립니다. `ko2en` 인수값은 FALSE로 지정합니다. 이
예제는 그려진 이미지에 접근할 수 있는 URL을 반환합니다.

``` r
prompt_en <- "Draw a sunrise and a seagull in Vincent van Gogh style."
draw_img(prompt_en, ko2en = FALSE)
```

한글 프롬프트로 그림을 그립니다. 그려진 결과는 R 플롯으로 반환되므로
RStudio 환경이라면, `Plots` 패널에서 확인할 수 있습니다.

``` r
prompt_ko <- "빈센트 반 고흐 스타일로 일출과 갈매기를 그려줘"
draw_img(prompt_ko, type = "image")
```

파일로 출력하고 싶다면 `type`의 값을 “file”로 지정합니다. 파일의 경로와
이름을 지정하지 않았기 때문에, 현재의 working directory에
“aidrawing.png”라는 이름으로 생성됩니다.

``` r
draw_img(prompt_ko, type = "file")
```

그리는 그림의 모양은 매번 달라집니다. 다음은 고흐가 그린 일출과 갈매기
작품입니다.

<img src="man/figures/gogh_01.png" style="width:60.0%;height:60.0%"
alt="고흐풍 드로잉" />
<img src="man/figures/gogh_02.png" style="width:60.0%;height:60.0%"
alt="고흐풍 드로잉" />
<img src="man/figures/aidrawing.png" style="width:60.0%;height:60.0%"
alt="고흐풍 드로잉" />

### Variate image with chatGPT

`chatGPT`를 이용해서, 이미지를 변형할 수 있습니다.

여러분은 다음의 `draw_img_variation()`로 원하는 이미지를 유사하게 다른
이미지를 변형할 수 있습니다. 함수의 인수는 `draw_img()`와 거의
유사합니다. `image` 인수에 변형하고자 할 원래의 이미지 파일을 지정하면
됩니다.

``` r
draw_img_variation(
  image,
  n = 1L,
  size = c("1024x1024", "256x256", "512x512"),
  type = c("url", "image", "file"),
  format = c("png", "jpeg", "gif"),
  path = "./",
  fname = "aivariation",
  openai_api_key = Sys.getenv("OPENAI_API_KEY")
)
```

`bitGPT` 패키지에는 “cloud.png” 파일을 제공하고 있습니다. 이 파일은
정사각형 규격의 이미지 파일로 다음과 같습니다.

<figure>
<img src="inst/images/cloud.png" style="width:60.0%;height:60.0%"
alt="원 소스 이미지" />
<figcaption aria-hidden="true">원 소스 이미지</figcaption>
</figure>

이 이미지 파일을 변형해 보겠습니다.

``` r
# 변형할 이미지
image <- system.file("images", "cloud.png", package = "bitGPT")

draw_img_variation(image, type = "image")
```

<figure>
<img src="man/figures/after_cloud.png" style="width:60.0%;height:60.0%"
alt="변형된 이미지" />
<figcaption aria-hidden="true">변형된 이미지</figcaption>
</figure>

## Speech to text

### Speech to Text with chatGPT

`chatGPT`를 이용해서, 음성 오디오 파일로 STT(Speech to Text )를
수행합니다.

여러분은 `transcript_audio()`로 STT를 수행할 수 있습니다.

``` r
transcript_audio(
  file,
  language = "ko",
  openai_api_key = Sys.getenv("OPENAI_API_KEY")
)
```

- file
  - character. 음성 오디오 파일 이름을 지정합니다. 오디오 파일의 포맷은
    mp3, mp4, mpeg, mpga, m4a, wav, webm중 하나만 허용합니다.
- language
  - character. 음성 오디오 파일의 언어로 ISO-639-1 포맷으로 지정해야
    하며, 기본값은 한국어인 “ko”입니다. 영어를 제외한 다국어 음성파일을
    지원합니다.
- openai_api_key
  - character. OpenAI API key입니다. 만약 `regist_openai_key()`,
    `sett_openai_key()`로 API key를 설정했다면 이 인수값을 지정할
    필요없습니다.

`bitGPT` 패키지에는 “korea_r\_user.m4a” 파일을 제공하고 있습니다. 이
파일은 `한국R사용자회` 소개하는 짧은 음성파일입니다. 성능이 좋지 않는
스피치의 텍스트 전환의 성능을 판단하기 위해서, 스피치의 성능은 높지 않게
생성했습니다. 잘못 발음하여 다시 발음하거나, 문장내에서 띄어 읽는 부분이
부자연스러운 곳도 있습니다.

``` r
# 음성 오디오 파일
speech <- system.file("audios", "korea_r_user.m4a", package = "bitGPT")

# 음성 오디오를 텍스트로 전환
transcript_audio(speech)
```

``` r
text 
"사단법인 한국R 사용자예는 디지털 분평 등 해소와 통계 대중화를 위해 2020년 설립되었습니다. 
오픈 통계 패키지 개발을 비롯하여 최근에 통계 및 데이터 과학 관련 오픈 전자책도 함께 제작하여 발간하고 있습니다. 
통계 패키지와 통계 및 데이터 과학 책은 사용자의 회원들의 자발적인 참여로 개발 및 유지 보수되고 있습니다. 
데이터 과학 분야의 인공지능 ai 체질 비트와 공존을 본격적으로 탐색하기 시작했습니다." 
```

스피치의 대상이 되는 원문 문장은 다음과 같습니다.

``` r
사단법인 한국 R 사용자회는 디지털 불평등 해소와 통계 대중화를 위해 2022년 설립되었습니다. 
오픈 통계 패키지 개발을 비롯하여 최근에 통계 및 데이터 과학 관련 오픈 전자책도 함께 제작하여 발간하고 있습니다. 
통계 패키지와 통계 및 데이터 과학 전자책은 사용자회 회원들의 자발적인 참여로 개발 및 유지보수 되고 있습니다. 
데이터 과학 분야 인공지능 AI chatGPT와 공존을 본격적으로 탐색하기 시작했습니다. 
```
