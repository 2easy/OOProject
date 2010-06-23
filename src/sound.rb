require 'sdl'

module Sound
  begin
    SDL.init(SDL::INIT_AUDIO)
    SDL::Mixer.open(frequency=22050, format=SDL::Mixer::DEFAULT_FORMAT,
                    cannels=SDL::Mixer::DEFAULT_CHANNELS,chunksize=4096)
  rescue Exception => a 
    puts "Failed to initialize sound. Error message: #{a}"
    SDL.quit
  end 
  Background_channel    = 0
  Pacman_channel        = 1
  Theme_length          = 4.5
  New_level_lenght      = 1.0
  Chomp_a_ghost_length  = 0.5
  Death_length          = 1.5
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
