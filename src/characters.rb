module Character
    Ghosts = [:blinky, :inky, :pinky, :clyde]
    class Creature 
        def initialize name
            @name = name
            @speed  = 0
            @my_pic = {
                :left  => Video::load_bmp("../images/#{name.to_s}_left.bmp" ),
                :right => Video::load_bmp("../images/#{name.to_s}_right.bmp"),
                :up    => Video::load_bmp("../images/#{name.to_s}_up.bmp"   ),
                :down  => Video::load_bmp("../images/#{name.to_s}_down.bmp" )}
            case name
                when :pacman
                    @sprite_coords = { :x => 15*Video::Image_width,
                                       :y => 23*Video::Image_height }
                    @direction = :left
                when :blinky
                    @sprite_coords = { :x => 15*Video::Image_width,
                                       :y => 11*Video::Image_height }
                    @direction = :left
                when :inky
                    @sprite_coords = { :x => 14*Video::Image_width,
                                       :y => 14*Video::Image_height }
                    @direction = :up
                when :pinky
                    @sprite_coords = { :x => 15*Video::Image_width,
                                       :y => 14*Video::Image_height }
                    @direction = :up
                when :clyde
                    @sprite_coords = { :x => 16*Video::Image_width,
                                       :y => 14*Video::Image_height }
                    @direction = :up
            end
            @anim_state = 0
        end
        def x
            @sprite_coords[:x] / Video::Image_width
        end
        def y
            @sprite_coords[:y] / Video::Image_height
        end
        def new_coords direction
            case direction
                when :left  then x1 = self.x - 1; y1 = self.y
                when :right then x1 = self.x + 1; y1 = self.y 
                when :up    then y1 = self.y - 1; x1 = self.x 
                when :down  then y1 = self.y + 1; x1 = self.x 
                when :none  then x1 = self.x; y1 = self.y
            end
            [x1,y1]
        end
        def fits_the_grid?
            @sprite_coords[:x] % Video::Image_width  == 0 and
            @sprite_coords[:y] % Video::Image_height == 0
        end
        def move_sprite
            case @direction
                when :left  then @sprite_coords[:x] -= 1
                when :right then @sprite_coords[:x] += 1
                when :up    then @sprite_coords[:y] -= 1
                when :down  then @sprite_coords[:y] += 1
            end
        end
    end
    
    class PacMan < Creature
        attr_accessor :speed, :state
        Pacman_speed           = 3
        Pacman_animation_speed = 3
        def initialize name
            super name
            @speed = Pacman_speed
            @lifes = 2
            @state  = :normal
        end

        def alive?;      @lifes >= 0;           end
        def eating?;     @state == :eating;     end
        def powered_up?; @state == :powered_up; end

        Opposite_directions = [[:up,:down],[:left,:right]]
        def opposite_direction? direction
            for opp in Opposite_directions
                return true if ([@direction,direction] == opp or
                                [direction,@direction] == opp)
            end
            return false
        end
        def move direction,maze
        self.speed.times do
            # Turning backwards
            @direction = direction if self.opposite_direction?(direction)
            # Changing direction
            if self.fits_the_grid?
                x1,y1 = self.new_coords(direction)
                unless direction == :none
                    @direction = direction unless(maze.wall?(x1,y1) or 
                                                  maze.cage?(x1,y1))
                end
                # Maze interaction
                if maze.dot?(self.x,self.y)
                    # TODO Score += 10
                    maze[self.x,self.y] = :empty
                    @state = :eating
                elsif maze.power_pill?(self.x,self.y)
                    maze[self.x,self.y] = :empty
                    @state = :powered_up
                end
                x1,y1 = self.new_coords(@direction)
                if maze.teleport?(x1,y1)
                    if x1 == 29
                        @sprite_coords[:x] = Video::Image_width * 1
                    else
                        @sprite_coords[:x] = Video::Image_width * 28
                    end
                elsif (maze.wall?(x1,y1) or maze.cage?(x1,y1))
                    return
                end 
            end
            self.move_sprite
        end
        end
        def draw
            begin
                pict_x = self.animate
                SDL::Screen.blit(
                    @my_pic[@direction],
                    pict_x*Video::Image_width, 0,
                    Video::Image_width,Video::Image_height,
                    Video::Game_screen,@sprite_coords[:x],@sprite_coords[:y])
            rescue Exception => a
                puts "Blit error: #{a}"
            end
        end
        def animate
            pict = @anim_state / Pacman_animation_speed
            @anim_state += 1
            @anim_state = 0 if pict == 7
            pict = 8 - pict if pict > 4
            pict
        end
    end

    class Ghost < Creature
        Ghost_speed           = 3
        Ghost_animation_speed = 10
        def initialize name
            super name
            @speed = Ghost_speed
            @state = :alive
        end
        def move maze
        @speed.times do
            if self.fits_the_grid?
                # Get direction
                if self.alive?
                    self.allot_direction(maze) 
                elsif self.weak? or self.flashing?
                    self.allot_direction(maze)
                elsif self.dead?
                    self.allot_direction(maze)
                else
                    self.allot_direction(maze)
                end
                # Move within chosen direction
                x1,y1 = self.new_coords(@direction)
                if maze.teleport?(x1,y1)
                    if x1 == 29
                        @sprite_coords[:x] = Video::Image_width * 1
                    else
                        @sprite_coords[:x] = Video::Image_width * 28
                    end
                elsif maze.wall?(x1,y1)
                    return
                end
            end
            self.move_sprite
        end
        end

        def alive?;     @state == :alive;    end
        def dead?;      @state == :dead;     end
        def weak?;      @state == :weak;     end
        def flashing?;  @state == :flashing; end
        def in_cage? maze
            maze[self.x,self.y] == :cage
        end

        def allot_direction maze
            directions = Array.new(4)
            directions.fill(@direction)
            i = -1
            directions[i+=1] = :right if(maze[self.x+1,self.y] != :wall and 
                                         @direction  != :left)
            directions[i+=1] = :left  if(maze[self.x-1,self.y] != :wall and
                                         @direction  != :right)
            directions[i+=1] = :up    if(maze[self.x,self.y-1] != :wall and
                                         @direction  != :down)
            directions[i+=1] = :down  if(maze[self.x,self.y+1] != :wall and
                                         @direction  != :up)
            #puts "#{@name}: #{directions[rand(i+=1)]}"
            @direction = directions[rand(i+=1)]
        end
        def draw
            begin
                pict_x = self.animate
                SDL::Screen.blit(
                    @my_pic[@direction],
                    pict_x*Video::Image_width, 0,
                    Video::Image_width,Video::Image_height,
                    Video::Game_screen,@sprite_coords[:x],@sprite_coords[:y])
                @anim_state += 1
            rescue Exception => a
                puts "Blit error: #{a}"
            end
        end
        def animate
            pict = @anim_state / Ghost_animation_speed
            @anim_state += 1
            if pict == 2
                @anim_state = 0 
                pict -= 1
            end
            pict
        end
    end
end
