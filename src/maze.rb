require 'sdl'

class Maze
    attr_reader :to_redraw
    Maze_width  = 30
    Maze_height = 31
    Maze_pic_width = 775
    Maze_pic_height = 850
    Maze_tiles  = { '#' => :wall,     ' ' => :empty,
                    '.' => :dot,      'P' => :power_pill,
                    'T' => :teleport, 'C' => :cage     }
    def initialize
        @maze = []
        @to_redraw = []
        Maze_height.times do |y|
            @maze[y] = Array.new Maze_width
        end 
        File.open("maze.txt","r") do |file|
            for y in 0...Maze_height do
                line = file.readline.chomp!.split ""
                x = 0
                for symbol in line
                    self[x,y] = Maze_tiles[symbol]
                    @to_redraw << [x,y] if(Maze_tiles[symbol] == :dot or 
                                         Maze_tiles[symbol] == :empty or
                                         Maze_tiles[symbol] == :power_pill or
                                         Maze_tiles[symbol] == :bonus)
                    x += 1
                end
            end
        end
        @maze_pic = SDL::Surface.load("../images/maze.bmp")
        @sprite_coords = { :x => 25, :y => 0 }
    end
    def [](x,y)
        @maze[y][x]
    end
    def []=(x,y,n)
        @maze[y][x] = n
    end
    def wall_or_cage? x,y 
        self[x,y] == :wall or self[x,y] == :cage 
    end
    def dot? x,y
        self[x,y] == :dot
    end
    def power_pill? x,y
        self[x,y] == :power_pill
    end
    def teleport? x,y
        self[x,y] == :teleport
    end
    #SDL::Surface.blit(src,srcX,srcY,srcW,srcH,dst,dstX,dstY)
    def draw
        begin
            SDL::Screen.blit(
                    @maze_pic, 0, 0,
                    34*Video::Image_width, 31*Video::Image_height,
                    Video::Game_screen,@sprite_coords[:x],@sprite_coords[:y])
        rescue Exception => a
            puts "Blit error: #{a}"
        end
    end
end
