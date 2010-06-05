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
        end

        def x; @sprite_coords[:x]/Video::Image_width; end
        def y; @sprite_coords[:y]/Video::Image_height; end
        def sprite_x; @sprite_coords[:x]; end
        def sprite_y; @sprite_coords[:y]; end

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
        Opposite_directions = [[:up,:down],[:left,:right]]
        def opposite_direction? direction
            for opp in Opposite_directions
                return true if ([@direction,direction] == opp or
                                [direction,@direction] == opp)
            end
            return false
        end
    end
    
    class PacMan < Creature
        attr_reader :speed, :powered_at
        Pacman_speed           = 3
        Pacman_animation_speed = 3
        def initialize name
            super name
            @lifes = 2
            @power_time = 0
            self.set_defaults
        end

        def set_defaults
            start_x = 15; start_y = 23
            @direction  = :left
            @state      = :normal
            @speed      = Pacman_speed
            @anim_state = Video::Init_animation
            @sprite_coords = { :x => start_x*Video::Image_width,
                               :y => start_y*Video::Image_height }
        end

        def alive?;        @lifes >= 0;           end
        def eating?;       @state == :eating;     end
        def powered_up?;   @state == :powered_up; end

        def subtract_life; @lifes -= 1;            end
        def change_state_to state; @state = state; end

        def move direction,maze,ghosts
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
                    #@state = :eating
                elsif maze.power_pill?(self.x,self.y)
                    maze[self.x,self.y] = :empty
                    ghosts.each { |ghost| ghost.weaken }
                    @powered_at = SDL::get_ticks
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
        def check_power_time
            now = SDL::get_ticks
            @state = :normal if(self.powered_up? and
                                now - @powered_at > 8000)
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
            @anim_state += 1
            pict = @anim_state / Pacman_animation_speed
            if @state == :dead
                return pict      
            else
                @anim_state = 0 if pict == 7
                pict = 8 - pict if pict > 4
                return pict
            end    
        end
    end

    class Ghost < Creature
        attr_accessor :state
        Ghost_speed           = 3
        Ghost_animation_speed = 10
        def initialize name
            super name
            @weak_pic = {
                :left  => Video::load_bmp("../images/weak.bmp"),
                :right => Video::load_bmp("../images/weak.bmp"),
                :up    => Video::load_bmp("../images/weak.bmp"),
                :down  => Video::load_bmp("../images/weak.bmp")}
            @dead_pic = {
                :left  => Video::load_bmp("../images/eyes_left.bmp" ),
                :right => Video::load_bmp("../images/eyes_right.bmp"),
                :up    => Video::load_bmp("../images/eyes_up.bmp"   ),
                :down  => Video::load_bmp("../images/eyes_down.bmp" )}
            self.set_defaults
        end
        
        def set_defaults
             case @name
                when :blinky
                    start_x = 15; start_y = 11
                    @direction = :left
                when :inky
                    start_x = 14; start_y = 14
                    @direction = :up
                when :pinky
                    start_x = 15; start_y = 14
                    @direction = :up when :clyde
                    start_x = 16; start_y = 14
                    @direction = :up
            end
            @state      = :alive
            @speed      = Ghost_speed
            @anim_state = Video::Init_animation
            @sprite_coords = { :x => start_x*Video::Image_width,
                               :y => start_y*Video::Image_height }
        end
        # TODO it's NOT working properly!
        def weaken; @state = :weak if not(self.dead?); end
        def recover maze,pacman
            now = SDL::get_ticks
            if (self.dead? and self.in_cage?(maze))
                @state = :alive
                return
            end
            if(self.weak? or self.flashing?)
                case (now-pacman.powered_at)
                    when 0..5000    then @state = :weak
                    when 5000..8000 then @state = :flashing
                    else @state = :alive
                end
            end
        end
        def move maze,pacman
        @speed.times do
            if self.fits_the_grid?
                # Get direction
                if self.alive?
                # TODO change name
                    self.get_direction_to(maze,pacman.x,pacman.y)
                elsif self.weak? or self.flashing?
                # TODO running away from pacman
                    self.allot_direction(maze)
                elsif self.dead?
                    self.get_direction_to(maze,14,14)
                end
                # Move within chosen direction
                x1,y1 = self.new_coords(@direction)
                if maze.teleport?(x1,y1)
                    if x1 == 29
                        @sprite_coords[:x] = Video::Image_width * 1
                    else
                        @sprite_coords[:x] = Video::Image_width * 28
                    end
                    return
                elsif maze.wall?(x1,y1)
                    return
                end
            end
            self.move_sprite
        end
        end
        def get_direction_to maze,x1,y1
            if @name == :blinky
                if (self.x < x1 and 
                    maze[self.x+1,self.y] != :wall and 
                    !self.opposite_direction?(:right))
                    @direction = :right
                elsif(self.x > x1 and
                    maze[self.x-1,self.y] != :wall and
                    not(self.opposite_direction?(:left)))
                    @direction = :left
                elsif(self.y < y1 and
                    maze[self.x,self.y+1] != :wall and
                    !self.opposite_direction?(:down))
                    @direction = :down
                elsif(self.y > y1 and
                    maze[self.x,self.y-1] != :wall and
                    !self.opposite_direction?(:up))
                    @direction = :up
                else
                    self.allot_direction maze
                end
            else
                self.allot_direction maze
            end
        end
        def allot_direction maze
            if self.in_cage?(maze)
                if maze[self.x,self.y-1] != :wall
                    @direction = :up
                    return
                elsif maze[self.x-1,self.y] != :wall
                    @direction = :left
                    return
                else
                    @direction = :right
                    return
                end
            end
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
            @direction = directions[rand(i+=1)]
        end

        def alive?;     @state == :alive;    end
        def dead?;      @state == :dead;     end
        def weak?;      @state == :weak;     end
        def flashing?;  @state == :flashing; end
        def in_cage? maze
            maze[self.x,self.y] == :cage or
            maze[self.x,self.y] == :gate
        end

        def draw
            begin
                case @state
                    when :alive then state_pic = @my_pic
                    when :dead  then state_pic = @dead_pic
                    else state_pic = @weak_pic
                end
                pict_x = self.animate
                SDL::Screen.blit(
                    state_pic[@direction],
                    pict_x*Video::Image_width, 0,
                    Video::Image_width,Video::Image_height,
                    Video::Game_screen,@sprite_coords[:x],@sprite_coords[:y])
                @anim_state += 1
            rescue Exception => a
                puts "Blit error: #{a}"
            end
        end
        def animate
            @anim_state += 1
            pict = @anim_state / Ghost_animation_speed
            if pict == 4
                @anim_state = 0
                pict = 3
            end
            case @state
                when :alive     then return pict % 2 
                when :flashing  then return pict
                when :weak      then return pict % 2 
                else return 0 
            end
        end
    end
end
