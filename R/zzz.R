.onAttach <- function(libname, pkgname) {
  if (Sys.getenv("OPENAI_API_KEY") == "") {
    api_key <- get_api_key()

    if (is.null(api_key$openai_api_key)) {
      message("To use bitGPT, you need to regist openai API key.\nYou can regist it with regist_api_key().")
    } else {
      set_openai_key(api_key$openai_api_key)
    }

    # https://developers.naver.com/apps/#/register
    if (!is.null(api_key$naver_client_id) & !is.null(api_key$naver_client_secret)) {
      set_naver_key(api_key$naver_client_id, api_key$naver_client_secret)
    }
  }
}
