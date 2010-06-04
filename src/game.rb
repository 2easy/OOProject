#!/usr/bin/ruby

require 'sdl'
require 'maze'
require 'eatable'
require 'video'
require 'characters'

Key = Struct.new("Key",:left,:right,:up,:down)
class Game
    def initialize mode
        @event = SDL::Event.new
        @level = 1
        @key = Key.new
        case mode
            when :single_player
                @pacman = Character::PacMan.new(:pacman)
                @ghosts = {}
                for name in Character::Ghosts
                    @ghosts[name] = Character::Ghost.new(name)
                end
                @maze = Maze.new
                @eatable = ToEat::Eatable.new
        end
    end
    def run
        direction = :left
        @maze.draw
        while @pacman.alive?
            #sleep 1
            #@pacman.speed -= 1 if @pacman.eating?
            @maze.redraw
            @eatable.draw(@maze.eatable,@maze)
            @pacman.draw 
            for ghost_name in Character::Ghosts
                @ghosts[ghost_name].draw
            end
            Video::Game_screen.flip

            @pacman.move(direction,@maze)
            for ghost_name in Character::Ghosts
                @ghosts[ghost_name].move(@maze,@pacman)
            end
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
