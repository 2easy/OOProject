#!/usr/bin/ruby

require 'sdl'
require 'system'
require 'hud'
require 'maze'
require 'eatable'
require 'characters'
require 'sound_and_video'

Key = Struct.new("Key",:left,:right,:up,:down)

class Game
    def initialize mode
        @event      = SDL::Event.new
        @key        = Key.new
        @level      = 1
        @players    = []
        @theme      = SDL::Mixer::Wave.load("../sounds/theme.wav")
        case mode
            when :single_player
                @pacman = Character::PacMan.new(:pacman)
                @players << @pacman
                @ghosts = []
                for name in Character::Ghosts
                    @ghosts << Character::Ghost.new(name)
                end
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
    def run
        direction = :left
        @maze.draw
        self.draw 
        self.draw_get_ready
        SDL::Mixer.play_channel(Sound::Background_channel,@theme,0)
        sleep Sound::Theme_length
        while @pacman.alive?
            self.draw 

            @pacman.move(direction,@maze,@ghosts)
            for name in @ghosts
                name.recover(@maze,@pacman)
                name.move(@maze,@pacman)
            end
            @judge.check_all

            if @event.poll != 0 then
                if @event.type == SDL::Event::QUIT then
                    break
                end
                if @event.type == SDL::Event::KEYDOWN then
                    exit if @event.keySym == SDL::Key::ESCAPE
                end
            end
            SDL::Key::scan
            @key.left  = SDL::Key::press?(SDL::Key::LEFT )
            @key.right = SDL::Key::press?(SDL::Key::RIGHT)
            @key.up    = SDL::Key::press?(SDL::Key::UP   )
            @key.down  = SDL::Key::press?(SDL::Key::DOWN )
  
            if    @key.left  then direction = :left
            elsif @key.right then direction = :right
            elsif @key.up    then direction = :up
            elsif @key.down  then direction = :down
            else direction = :none end
        end
        SDL.quit
    end
end

game = Game.new(:single_player)
game.run
