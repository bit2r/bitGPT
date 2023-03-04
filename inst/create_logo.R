library(hexSticker)
library(showtext)

chatGPT_logo <- "mix_image.png"

font_add_google("Nanum Pen Script", "pen")

sticker(chatGPT_logo, package = "비트지피티", p_family = "pen",
        p_size = 30, p_y = 1.5, p_color = "#FFFFFF",
        s_x = 1, s_y = 1, s_width = 1, s_height = 1,
        h_size = 1.5, h_color = "#FF9801", h_fill = "#4F95CD",
        filename = "bitGPT.png")


