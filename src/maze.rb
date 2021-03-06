require 'sdl'

class Maze
  attr_reader :eatable
  Maze_width  = 30
  Maze_height = 31
  Maze_pic_width = 775
  Maze_pic_height = 850
  Maze_tiles  = { '#' => :wall,   ' ' => :empty,
                  '.' => :dot,    'P' => :power_pill,
                  'T' => :teleport, 
                  'C' => :cage,   'G' => :gate }
  def initialize
    @maze = []
    Maze_height.times do |y|
      @maze[y] = Array.new(Maze_width)
    end 
    self.set_defaults
    @maze_pic = SDL::Surface.load("../images/maze.bmp")
    @ground_pic = Video::load_no_transparent("../images/ground.bmp")
    @sprite_coords = { :x => 25, :y => 0 }
  end

  def [](x,y);         @maze[y][x];              end
  def []=(x,y,n);      @maze[y][x] = n;          end
  def cage? x,y;       self[x,y] == :cage;       end
  def wall? x,y;       self[x,y] == :wall;       end
  def dot? x,y;        self[x,y] == :dot;        end
  def power_pill? x,y; self[x,y] == :power_pill; end
  def teleport? x,y;   self[x,y] == :teleport;   end
  def all_dots_eaten?; @dots_quantity <= 0;      end

  def remove_dot x,y
    self[x,y] = :empty
    @dots_quantity -= 1
  end
  
  def set_defaults
    @dots_quantity = 0
    @ground = []
    @eatable = []
    File.open("maze.txt","r") do |file|
      for y in 0...Maze_height do
        line = file.readline.chomp!.split ""
        x = 0
        for symbol in line
          self[x,y] = Maze_tiles[symbol]
          @ground << [x,y]  if ( Maze_tiles[symbol] == :gate  or
                                 Maze_tiles[symbol] == :cage )
          @eatable << [x,y] if ( Maze_tiles[symbol] == :empty or
                                 Maze_tiles[symbol] == :dot or
                                 Maze_tiles[symbol] == :power_pill or
                                 Maze_tiles[symbol] == :bonus )
          @dots_quantity += 1 if Maze_tiles[symbol] == :dot  
          x += 1
        end
      end
    end
  end

  def redraw
    for unit in @ground
      x,y = unit
      case self[x,y]
        when :cage  then pict_x = 0
        when :gate  then pict_x = 25
        else next
      end
      SDL::Screen.blit(
        @ground_pic, pict_x, 0,
        Video::Image_width, Video::Image_height,
        Video::Game_screen,
        x*Video::Image_width, y*Video::Image_height)
    end
  end 
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
