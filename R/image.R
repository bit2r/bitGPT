#' Create image with chatGPT
#' @description chatGPT를 이용해서 프롬프트에 부합하는 이미지를 생성함.
#' @param prompt character. 이미지 생성 명령을 수행할 프롬프트.
#' @param ko2en logical. 프롬프트가 한국어일 때, 영어로 번역하여 질의하는 여부 설정.
#' TRUE이면 한글 프롬프트를 영어로 번역하여 프롬프트를 질의.
#' @param n integer. 생성할 이미지의 개수. 기본값은 1이며, 1과 10 사이의 정수를 사용함.
#' @param size character. 이미지의 크기로 "1024x1024", "256x256", "512x512"에서
#' 하나를 선택함. 기본값은 "1024x1024".
#' @param type character. 반환하는 이미지 타입. "url", "image", "file"에서 선택하며,
#' 기본값인 "url"은 이미지를 포함하는 URL을, "image"는 R환경에서 플롯으로 반환하고,
#' "image"는 이미지 파일을 생성합니다.
#' @param format character. 이미지 파일의 포맷으로 type의 값이 "file"일 경우만 적용됨.
#' "png", "jpeg", "gif"에서 선택하며, 기본값은 "png"임.
#' @param path character. 파일을 생성할 디렉토리 경로로 type의 값이 "file"일 경우만 적용됨.
#' @param fname character. 경로와 확장자를 제외한 이미지 파일의 이름으로,
#' type의 값이 "file"일 경우만 적용됨.
#' @param openai_api_key character. openai의 API key.
#' @details openai의 이미지 생성을 위한 프롬프트를 한글로 만들 경우에는 결과의
#' 성능이 매우 낮기 때문에, 한글 프롬프트의 경우에는 ko2en를 TRUE로 지정하는 것을 권장.
#' 이 경우에는 네이버의 파파고 번역 결과로 질의.
#' @seealso \code{\link{draw_img_edit}}, \code{\link{draw_img_variation}}
#' @examples
#' \dontrun{
#' # 영어 프롬프트
#' prompt_en <- "Draw a sunrise and a seagull in Vincent van Gogh style."
#'
#' #' # 생성된 파일의 경로로서의 URL 반환
#' draw_img(prompt_en, ko2en = FALSE)
#'
#' # 한글 프롬프트
#' prompt_ko <- "빈센트 반 고흐 스타일로 일출과 갈매기를 그려줘"
#'
#' # 이미지를 반환
#' draw_img(prompt_ko, type = "image")
#'
#' # 파일로 출력
#' draw_img(prompt_ko, type = "file")
#' }
#' @export
#' @importFrom openai create_image
#' @importFrom magick image_read image_write
draw_img <- function(prompt, ko2en = TRUE, n = 1L,
                     size = c("1024x1024", "256x256", "512x512"),
                     type = c("url", "image", "file"),
                     format = c("png", "jpeg", "gif"),
                     path = "./", fname = "aidrawing",
                     openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  size <- match.arg(size)
  type <- match.arg(type)
  format <- match.arg(format)

  if (n == 1) {
    path <- glue::glue("{path}/{fname}.{format}")
  } else if (n > 1 & n <= 10) {
    path <- paste(paste(glue::glue("{path}/{fname}"),
                        sprintf("%02d", 1:n), sep = "_"), format, sep = ".")
  } else {
    stop("생성할 이미지 개수를 지정하는 인수 n의 값은 1~10의 값만 허용합니다.")
  }

  if (ko2en) {
    prompt <- translate(prompt)
  }

  response <- openai::create_image(
    prompt,
    n = n,
    size = size,
    openai_api_key = openai_api_key
  )

  img_url <- response$data$url

  if (type %in% "url") {
    return(img_url)
  } else if (type %in% "image") {
    img_url %>%
      purrr::walk(
        function(x) {
          img <- magick::image_read(x)

          par(mar = c(0, 0, 0, 0))
          plot(as.raster(img))
        }
      )
  } else if (type %in% "file") {
    img_url %>%
      length() %>%
      seq() %>%
      purrr::walk(
        function(x) {
          img <- magick::image_read(img_url[x])
          magick::image_write(img, path = path[x], format = format)
        }
      )

  }
}


#' Create image edit with chatGPT
#' @description chatGPT를 이용해서 이미지를 편집함.
#' @param image character. 편집할 이미지 파일의 이름.
#' @param prompt character. 편집을 원하는 이미지에 대한 설명으로 최대 길이는 1000자.
#' @param mask character. 투명한(alpha 값이 0인 경우) 영역이 이미지를 편집하 위치를 나타내는 추가 이미지.
#' 4MB 미만의 유효한 PNG 파일이어야 하며 이미지와 크기가 같아야 함.
#' @param ko2en logical. 프롬프트가 한국어일 때, 영어로 번역하여 질의하는 여부 설정.
#' TRUE이면 한글 프롬프트를 영어로 번역하여 프롬프트를 질의.
#' @param n integer. 생성할 이미지의 개수. 기본값은 1이며, 1과 10 사이의 정수를 사용함.
#' @param size character. 이미지의 크기로 "1024x1024", "256x256", "512x512"에서
#' 하나를 선택함. 기본값은 "1024x1024".
#' @param type character. 반환하는 이미지 타입. "url", "image", "file"에서 선택하며,
#' 기본값인 "url"은 이미지를 포함하는 URL을, "image"는 R환경에서 플롯으로 반환하고,
#' "image"는 이미지 파일을 생성합니다.
#' @param format character. 이미지 파일의 포맷으로 type의 값이 "file"일 경우만 적용됨.
#' "png", "jpeg", "gif"에서 선택하며, 기본값은 "png"임.
#' @param path character. 파일을 생성할 디렉토리 경로로 type의 값이 "file"일 경우만 적용됨.
#' @param fname character. 경로와 확장자를 제외한 이미지 파일의 이름으로,
#' type의 값이 "file"일 경우만 적용됨.
#' @param openai_api_key character. openai의 API key.
#' @details 편집할 이미지 파일은 정사각형의 png 파일만 지원하며, 파일의 용량은 4MB미만이어야 함.
#' @seealso \code{\link{draw_img}}, \code{\link{draw_img_variation}}
#' @examples
#' \dontrun{
#' # 편집할 이미지
#' image <- system.file("images", "cloud.png", package = "bitGPT")
#'
#' # Mask 이미지
#' mask <- system.file("images", "cloud_mask.png", package = "bitGPT")
#'
#' # 생성된 파일의 경로로서의 URL 반환
#' draw_img_edit(image, mask, prompt = "UFOs flying in the sky", ko2en = FALSE)
#'
#' # 이미지를 반환
#' draw_img_edit(image, mask, prompt = "하늘을 날아다니는 UFO", type = "image")
#'
#' # 파일로 출력
#' draw_img_edit(image, mask, prompt = "하늘을 날아다니는 UFO", type = "file")
#' }
#' @export
#' @importFrom openai create_image_variation
#' @importFrom magick image_read image_write
draw_img_edit <- function(image, mask, prompt, ko2en = TRUE,
                          n = 1L, size = c("1024x1024", "256x256", "512x512"),
                          type = c("url", "image", "file"),
                          format = c("png", "jpeg", "gif"),
                          path = "./", fname = "aiedit",
                          openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  size <- match.arg(size)
  type <- match.arg(type)
  format <- match.arg(format)

  if (n == 1) {
    path <- glue::glue("{path}/{fname}.{format}")
  } else if (n > 1 & n <= 10) {
    path <- paste(paste(glue::glue("{path}/{fname}"),
                        sprintf("%02d", 1:n), sep = "_"), format, sep = ".")
  } else {
    stop("생성할 이미지 개수를 지정하는 인수 n의 값은 1~10의 값만 허용합니다.")
  }

  if (ko2en) {
    prompt <- translate(prompt)
  }

  response <- openai::create_image_edit(
    image = image,
    mask = mask,
    prompt = prompt,
    n = n,
    size = size,
    openai_api_key = openai_api_key
  )

  img_url <- response$data$url

  if (type %in% "url") {
    return(img_url)
  } else if (type %in% "image") {
    img_url %>%
      purrr::walk(
        function(x) {
          img <- magick::image_read(x)

          par(mar = c(0, 0, 0, 0))
          plot(as.raster(img))
        }
      )
  } else if (type %in% "file") {
    img_url %>%
      length() %>%
      seq() %>%
      purrr::walk(
        function(x) {
          img <- magick::image_read(img_url[x])
          magick::image_write(img, path = path[x], format = format)
        }
      )

  }
}



#' Create image variation with chatGPT
#' @description chatGPT를 이용해서 변형된 이미지를 생성함.
#' @param image character. 변형할 이미지 파일의 이름.
#' @param n integer. 생성할 이미지의 개수. 기본값은 1이며, 1과 10 사이의 정수를 사용함.
#' @param size character. 이미지의 크기로 "1024x1024", "256x256", "512x512"에서
#' 하나를 선택함. 기본값은 "1024x1024".
#' @param type character. 반환하는 이미지 타입. "url", "image", "file"에서 선택하며,
#' 기본값인 "url"은 이미지를 포함하는 URL을, "image"는 R환경에서 플롯으로 반환하고,
#' "image"는 이미지 파일을 생성합니다.
#' @param format character. 이미지 파일의 포맷으로 type의 값이 "file"일 경우만 적용됨.
#' "png", "jpeg", "gif"에서 선택하며, 기본값은 "png"임.
#' @param path character. 파일을 생성할 디렉토리 경로로 type의 값이 "file"일 경우만 적용됨.
#' @param fname character. 경로와 확장자를 제외한 이미지 파일의 이름으로,
#' type의 값이 "file"일 경우만 적용됨.
#' @param openai_api_key character. openai의 API key.
#' @details 변형할 이미지 파일은 정사각형의 png 파일만 지원하며, 파일의 용량은 4MB미만이어야 함.
#' @seealso \code{\link{draw_img}}, \code{\link{draw_img_edit}}
#' @examples
#' \dontrun{
#' # 변형할 이미지
#' image <- system.file("images", "cloud.png", package = "bitGPT")
#'
#' # 생성된 파일의 경로로서의 URL 반환
#' draw_img_variation(image)
#'
#' # 이미지를 반환
#' draw_img_variation(image, type = "image")
#'
#' # 파일로 출력
#' draw_img_variation(image, type = "file")
#' }
#' @export
#' @importFrom openai create_image_variation
#' @importFrom magick image_read image_write
draw_img_variation <- function(image, n = 1L,
                               size = c("1024x1024", "256x256", "512x512"),
                               type = c("url", "image", "file"),
                               format = c("png", "jpeg", "gif"),
                               path = "./", fname = "aivariation",
                               openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  size <- match.arg(size)
  type <- match.arg(type)
  format <- match.arg(format)

  if (n == 1) {
    path <- glue::glue("{path}/{fname}.{format}")
  } else if (n > 1 & n <= 10) {
    path <- paste(paste(glue::glue("{path}/{fname}"),
                        sprintf("%02d", 1:n), sep = "_"), format, sep = ".")
  } else {
    stop("생성할 이미지 개수를 지정하는 인수 n의 값은 1~10의 값만 허용합니다.")
  }

  response <- openai::create_image_variation(
    image,
    n = n,
    size = size,
    openai_api_key = openai_api_key
  )

  img_url <- response$data$url

  if (type %in% "url") {
    return(img_url)
  } else if (type %in% "image") {
    img_url %>%
      purrr::walk(
        function(x) {
          img <- magick::image_read(x)

          par(mar = c(0, 0, 0, 0))
          plot(as.raster(img))
        }
      )
  } else if (type %in% "file") {
    img_url %>%
      length() %>%
      seq() %>%
      purrr::walk(
        function(x) {
          img <- magick::image_read(img_url[x])
          magick::image_write(img, path = path[x], format = format)
        }
      )

  }
}


