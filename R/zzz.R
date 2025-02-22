.bitGPTEnv <- new.env()

.onAttach <- function(libname, pkgname) {
  if (Sys.getenv("OPENAI_API_KEY") == "" | Sys.getenv("DEEPL_API_KEY") == "") {
    api_key <- get_api_key()

    # set openai API key
    if (is.null(api_key$openai_api_key)) {
      message("To use bitGPT, you need to regist openai API key.\nYou can regist it with regist_openai_key().")
    } else {
      set_openai_key(api_key$openai_api_key)
    }

    # set DeepL API key
    if (is.null(api_key$deepl_api_key)) {
      message("To use bitGPT, you need to regist DeepL API key.\nYou can regist it with regist_deepl_key().")
    } else {
      set_deepl_key(api_key$deepl_api_key)
    }
  }
}
