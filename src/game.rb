#!/usr/bin/ruby1.8

require 'sdl'
require 'hud'
require 'menu'
require 'maze'
require 'sound'
require 'video'
require 'system'
require 'eatable'
require 'characters'

class Game
  Controls = [[SDL::Key::LEFT,SDL::Key::RIGHT,SDL::Key::UP,SDL::Key::DOWN],
              [SDL::Key::A,SDL::Key::D,SDL::Key::W,SDL::Key::S]]
  def initialize mode
    @level    = 1
    @characters = []
    @players  = []
    @ghosts   = []
    @maze = Maze.new
    @eatable = ToEat::Eatable.new
    for name in Character::Ghosts
      @ghosts << Character::Ghost.new(name)
    end
    case mode
      when :single_player
        @players << Character::PacMan.new(:pacman,Controls.shift)
      when :two_players
        2.times do
          @players << Character::PacMan.new(:pacman,Controls.shift)
        end
    end
    @characters = @players + @ghosts 
    @judge = System::Judge.new(self,@maze,@players,@ghosts)
  end
  def draw
    @maze.redraw
    @eatable.draw(@maze.eatable,@maze)
    @ghosts.each { |ghost| ghost.draw }
    @players.each { |player| player.draw }
    HUD::draw
    Video::Game_screen.flip
  end
  def draw_get_ready
    Font::My_font.draw_solid_utf8(Video::Game_screen,
                                  "GET READY!",
                                  12*Video::Image_width-10,
                                  17*Video::Image_height,
                                  *Video::White_color)
    Video::Game_screen.flip
  end
  
  def run
    $SCORE = 0
    $LEVEL = 1
    $LIFES = 3
    @maze.draw
    self.draw 
    self.draw_get_ready
    Sound::Play::theme
    #sleep Sound::Theme_length
    while(@players.each { |player| player.alive? })
      self.draw 
      
      @characters.each do |character|
        character.recover(@maze,@players)
        character.move(@maze,@characters)
      end

      @judge.check_all
      # TODO breaking loop on Esc
      #break if direction == :end
    end
  end
end

menu = Menu.new
menu.start
