require 'maze'

module ToEat
  class Eatable
    def initialize
      @my_pic = Video::load_no_transparent("../images/eatable.bmp")
      # TODO
      name = :dot
      case name
        when :dot        then @value = 10
        when :power_pill then @value = 50
        when :bonus      then @value = 100
      end
    end

    def dot?;         @name == :dot;        end
    def power_pill?;  @name == :power_pill; end
    def bonus?;       @name == :bonus;      end

    def draw coords,maze
      coords.each do |unit|
        x,y = unit
        case maze[x,y]
          when :empty       then pict_x = 0
          when :dot         then pict_x = 25 
          when :power_pill  then pict_x = 50
          when :bonus       then pict_x = 75
          else next
        end
        SDL::Screen.blit(
          @my_pic, pict_x, 0,
          Video::Image_width, Video::Image_height,
          Video::Game_screen,
          x*Video::Image_width, y*Video::Image_height)
      end 
    end
  end
end
