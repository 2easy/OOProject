#!/usr/bin/ruby1.8

require 'sdl'
require 'hud'
require 'menu'
require 'maze'
require 'system'
require 'eatable'
require 'characters'
require 'sound_and_video'
Key = Struct.new("Key",:left,:right,:up,:down,:space,:enter)

class Game
    def initialize mode
        @event      = SDL::Event.new
        @key        = Key.new
        @level      = 1
        @players    = []
        @ghosts     = []
        @characters = []
        case mode
            when :single_player
                @players = [Character::PacMan.new(:pacman)]
                for name in Character::Ghosts
                    @ghosts << Character::Ghost.new(name)
                end
                @characters = @players + @ghosts 

                @maze = Maze.new
                @eatable = ToEat::Eatable.new
        end
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
    def detect_key_press
        if @event.poll != 0 then
            exit if @event.type == SDL::Event::QUIT
            if @event.type == SDL::Event::KEYDOWN then
                return :end if @event.keySym == SDL::Key::ESCAPE
            end
        end
        SDL::Key::scan
        @key.left  = SDL::Key::press?(SDL::Key::LEFT )
        @key.right = SDL::Key::press?(SDL::Key::RIGHT)
        @key.up    = SDL::Key::press?(SDL::Key::UP   )
        @key.down  = SDL::Key::press?(SDL::Key::DOWN )
  
        if    @key.left  then return :left
        elsif @key.right then return :right
        elsif @key.up    then return :up
        elsif @key.down  then return :down
        else return :none end
    end
    def run
        direction = :left
        $SCORE = 0
        $LEVEL = 1
        @maze.draw
        self.draw 
        self.draw_get_ready
        Sound::Play::theme
        sleep Sound::Theme_length
        while(@players.each { |player| player.alive? })
            self.draw 
            
            @characters.each do |character|
                character.recover(@maze,@players)
                character.move(direction,@maze,@characters)
            end

            @judge.check_all

            direction = self.detect_key_press
            break if direction == :end
        end
    end
end

menu = Menu.new
menu.start
