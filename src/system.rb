require 'sound_and_video'

class Array
    def filter
        tmp = []
        self.each do |elem|
            tmp << elem if yield(elem)
        end
        tmp
    end
end

module System
    class Judge
        def initialize game,maze,players,ghosts
            @game    = game
            @maze    = maze
            @players = players
            @ghosts  = ghosts
        end
        def check_all
            self.check_dots
            self.check_collision
        end
        def check_dots
            if @maze.all_dots_eaten?
                $LEVEL += 1
                @players.each { |player| player.set_defaults }
                @ghosts.each { |ghost| ghost.set_defaults }
                @maze.set_defaults
                @game.draw
                Sound::Play::new_level
                sleep Sound::New_level_lenght 
                return
            end
        end
        def check_collision
            @ghosts.each { |ghost|
                @players.each { |player|
                    player.check_power_time
                    if self.collide?(ghost,player)
                        case ghost.state
                            when :weak 
                                $SCORE += 200
                                ghost.state = :dead
                                Sound::Play::chomp_a_ghost
                                sleep Sound::Chomp_a_ghost_length
                            when :flashing then
                                $SCORE += 200
                                ghost.state = :dead
                                Sound::Play::chomp_a_ghost
                                sleep Sound::Chomp_a_ghost_length
                            when :alive then
                                self.new_round 
                            else next
                        end
                    end
                }
            } 
        end
        def collide? ghost,player
            return true if ((ghost.sprite_x - player.sprite_x).abs < 15 and
                            (ghost.sprite_y - player.sprite_y).abs < 15)
            return false
        end
        def new_round
            @players.each { |player|
                player.change_state_to(:dead)
                player.subtract_life
                Sound::Play::pacman_death
                self.death_animation
                player.set_defaults
            }
            @ghosts.each { |ghost|
                ghost.set_defaults
            }
            sleep 1.0
        end
        def death_animation
            delay = Sound::Death_length/25
            25.times do
                @game.draw 
                sleep delay
            end
        end
    end
end