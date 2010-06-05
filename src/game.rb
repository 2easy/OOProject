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
        @players = []
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
    end
    def draw
        @maze.redraw
        @eatable.draw(@maze.eatable,@maze)
        for name in @ghosts
            name.draw
        end
        @pacman.draw 
        Video::Game_screen.flip
    end
    def judge
        for ghost in @ghosts
            for player in @players
                player.check_power_time
                if self.collide?(ghost,player)
                    case ghost.state
                        when :weak 
                            ghost.state = :dead
                        when :flashing then
                            ghost.state = :dead
                        when :alive then
                            self.new_round 
                        else next
                    end
                end
            end
        end 
    end
    def collide? ghost,player
        return true if ((ghost.sprite_x - player.sprite_x).abs < 15 and
                        (ghost.sprite_y - player.sprite_y).abs < 15)
        return false
    end
    def new_round
        for name in @players
            name.change_state_to(:dead)
            name.subtract_life
            self.death_animation
            name.set_defaults
        end
        for name in @ghosts
            name.set_defaults
        end
        sleep 1
    end
    def death_animation
        for i in 0...25
            self.draw 
            sleep 0.05
        end
    end

    def run
        direction = :left
        @maze.draw
        while @pacman.alive?
            self.draw 
            @pacman.move(direction,@maze,@ghosts)
            for name in @ghosts
                name.recover(@maze,@pacman)
                name.move(@maze,@pacman)
            end
            self.judge

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
