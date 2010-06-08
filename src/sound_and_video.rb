require 'sdl'

module Video
    Screen_width   = 875
    Screen_height  = 775
    Bits_per_pixel = 32
    Image_width    = 25
    Image_height   = 25
    Init_animation = -1
    White_color    = [255,255,255]

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
    begin
        SDL.init(SDL::INIT_AUDIO)
        SDL::Mixer.open(frequency=22050, format=SDL::Mixer::DEFAULT_FORMAT,
                        cannels=SDL::Mixer::DEFAULT_CHANNELS,chunksize=4096)
    rescue Exception => a 
        puts "Failed to initialize sound. Error message: #{a}"
        SDL.quit
    end 
    Background_channel = 0
    Pacman_channel = 1
    Theme_length   = 4.5
    New_level_lenght = 1.0
    Chomp_a_ghost_length = 0.5
    Death_length = 1.5
    begin
        Theme         = SDL::Mixer::Wave.load("../sounds/theme.wav")
        New_level     = SDL::Mixer::Wave.load("../sounds/newlevel.wav")
        Pacman_death  = SDL::Mixer::Wave.load("../sounds/death.wav")
        Killmode      = SDL::Mixer::Wave.load("../sounds/killmode.wav")
        Chomp_a_ghost = SDL::Mixer::Wave.load("../sounds/chompaghost.wav")
        Chomp_a_dot   = SDL::Mixer::Wave.load("../sounds/chompadot.wav")
    rescue Exception => a
        puts "Failed to load sound file. Error message: #{a}"
        SDL.quit
    end
    class Play
        def Play::theme
            SDL::Mixer.play_channel(Background_channel, Theme, 0)
        end
        def Play::new_level
            SDL::Mixer.play_channel(Background_channel, New_level, 0)
        end
        def Play::pacman_death
            SDL::Mixer.play_channel(Background_channel, Pacman_death, 0)
        end
        def Play::killmode
            SDL::Mixer.play_channel(Background_channel, Killmode, 3)
        end
        def Play::chomp_a_ghost
            SDL::Mixer.play_channel(Pacman_channel, Chomp_a_ghost, 0)
        end
        def Play::chomp_a_dot
            SDL::Mixer.play_channel(Pacman_channel, Chomp_a_dot, 0)
        end
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
