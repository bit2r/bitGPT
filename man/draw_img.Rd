% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/image.R
\name{draw_img}
\alias{draw_img}
\title{Create image with chatGPT}
\usage{
draw_img(
  prompt,
  ko2en = FALSE,
  n = 1L,
  model = c("dall-e-3", "dall-e-2"),
  size = c("1024x1024", "1792x1024", "1024x1792", "512x512", "256x256"),
  type = c("url", "image", "file"),
  format = c("png", "jpeg", "gif"),
  path = "./",
  fname = "aidrawing",
  openai_api_key = Sys.getenv("OPENAI_API_KEY")
)
}
\arguments{
\item{prompt}{character. 이미지 생성 명령을 수행할 프롬프트.}

\item{ko2en}{logical. 프롬프트가 한국어일 때, 영어로 번역하여 질의하는 여부 설정.
model이 "dall-e-2"일 경우에만 사용하며, TRUE이면 한글 프롬프트를 영어로 번역하여 프롬프트를 질의.}

\item{n}{integer. 생성할 이미지의 개수. 기본값은 1이며, 1과 10 사이의 정수를 사용함.}

\item{model}{character. 사용할 모델로 dall-e-3", "dall-e-2"에서 선택함.}

\item{size}{character. 이미지의 크기로 "1024x1024", "256x256", "512x512"에서
하나를 선택함. 기본값은 "1024x1024".}

\item{type}{character. 반환하는 이미지 타입. "url", "image", "file"에서 선택하며,
기본값인 "url"은 이미지를 포함하는 URL을, "image"는 R환경에서 플롯으로 반환하고,
"image"는 이미지 파일을 생성합니다.}

\item{format}{character. 이미지 파일의 포맷으로 type의 값이 "file"일 경우만 적용됨.
"png", "jpeg", "gif"에서 선택하며, 기본값은 "png"임.}

\item{path}{character. 파일을 생성할 디렉토리 경로로 type의 값이 "file"일 경우만 적용됨.}

\item{fname}{character. 경로와 확장자를 제외한 이미지 파일의 이름으로,
type의 값이 "file"일 경우만 적용됨.}

\item{openai_api_key}{character. openai의 API key.}
}
\description{
chatGPT를 이용해서 프롬프트에 부합하는 이미지를 생성함.
}
\details{
openai의 이미지 생성을 위한 프롬프트를 한글로 만들 경우에는 결과의
성능이 매우 낮기 때문에, 한글 프롬프트의 경우에는 ko2en를 TRUE로 지정하는 것을 권장.
이 경우에는 네이버의 파파고 번역 결과로 질의.
}
\examples{
\dontrun{
# 영어 프롬프트
prompt_en <- "Vincent van Gogh-style painting of a fishing boat and beach scene at sunrise."
# 한글 프롬프트
prompt_ko <- "일출을 배경으로 낚시하는 어선과 해변의 풍경의 빈센트 반 고흐 화풍으로 그려줘"

#' # 생성된 파일의 경로로서의 URL 반환
draw_img(prompt_ko)

# 이미지를 반환
draw_img(prompt_ko, type = "image")

# 파일로 출력
draw_img(prompt_ko, type = "file")

# 파일로 출력
draw_img(prompt_ko, ko2en = TRUE, model = "dall-e-2", type = "file")
}
}
\seealso{
\code{\link{draw_img_edit}}, \code{\link{draw_img_variation}}
}
