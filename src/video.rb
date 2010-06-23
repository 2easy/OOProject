require 'sdl'

module Video
  Screen_width   = 875
  Screen_height  = 775
  Bits_per_pixel = 32
  Image_width    = 25
  Image_height   = 25
  Option_width   = 200
  Option_height  = 50
  Init_animation = -1
  White_color  = [255,255,255]
  Black_color  = [0,0,0]

  begin
    SDL.init(SDL::INIT_VIDEO)
    Game_screen = SDL::Screen.open(
      Screen_width, Screen_height, Bits_per_pixel,
      SDL::SWSURFACE|SDL::DOUBLEBUF)
#      SDL::SWSURFACE|SDL::DOUBLEBUF|SDL::FULLSCREEN)
    SDL::Mouse.hide
  rescue Exception => a 
    puts "Failed to initialize video. Error message: #{a}"
    SDL.quit
  end 
  def Video::load_no_transparent image
    graph = SDL::Surface.load(image)
    graph.display_format
  end
  def Video::load_bmp image
    graph = SDL::Surface.load(image)
    graph.set_color_key(SDL::RLEACCEL | SDL::SRCCOLORKEY,0)
    graph.display_format
  end
end

module Font
  begin
    SDL::TTF.init
    My_font = SDL::TTF.open("../images/arial.ttf",25) 
    My_font.style = SDL::TTF::STYLE_BOLD #STYLE_NORMAL
    HUD_font = SDL::TTF.open("../images/arial.ttf",25) 
    HUD_font.style = SDL::TTF::STYLE_BOLD #STYLE_NORMAL
  rescue Exception => a 
    puts "Failed to initialize font. Error message: #{a}"
    SDL.quit
  end
end
