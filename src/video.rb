require 'sdl'

module Video
    Screen_width   = 875
    Screen_height  = 775
    Bits_per_pixel = 32
    Image_width    = 25
    Image_height   = 25

    begin
        SDL.init(SDL::INIT_AUDIO | SDL::INIT_VIDEO)
        Game_screen = SDL::Screen.open(
            Screen_width, Screen_height, Bits_per_pixel,
            SDL::SWSURFACE|SDL::DOUBLEBUF)#|SDL::FULLSCREEN)
    rescue Exception => a 
        puts "Failed to initialize video. Error message: #{a}"
        SDL.quit
    end 
    # TODO
    def Video::load_bmp image
        graph = SDL::Surface.load(image)
        #graph = graph.set_color_key(SDL::SRCCOLORKEY,graph[0,0])
        graph = graph.display_format
    end
end
