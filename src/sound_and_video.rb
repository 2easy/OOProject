require 'sdl'

module Video
    Screen_width   = 875
    Screen_height  = 775
    Bits_per_pixel = 32
    Image_width    = 25
    Image_height   = 25
    Init_animation = -1

    begin
        SDL.init(SDL::INIT_VIDEO)
        Game_screen = SDL::Screen.open(
            Screen_width, Screen_height, Bits_per_pixel,
            SDL::SWSURFACE|SDL::DOUBLEBUF)#|SDL::FULLSCREEN)
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

module Sound
    Background_channel = 0
    Pacman_channel = 1
    Ghosts_channel = 2 

    begin
        SDL.init(SDL::INIT_AUDIO)
        SDL::Mixer.open(frequency=22050,format=SDL::Mixer::DEFAULT_FORMAT,cannels=SDL::Mixer::DEFAULT_CHANNELS,chunksize=4096)
    rescue Exception => a 
        puts "Failed to initialize sound. Error message: #{a}"
        SDL.quit
    end 
end
