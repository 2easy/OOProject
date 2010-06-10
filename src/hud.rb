module HUD
    def HUD::draw
        blacken_rect 30,1,4,6
        write "Score:",30,1,Video::White_color
        write "#{$SCORE}",30,2,Video::White_color
        write "Lifes:",30,3,Video::White_color
        write "Level:",30,5,Video::White_color
        write "#{$LEVEL}",30,6,Video::White_color
        Video::Game_screen.flip
    end
    def HUD::blacken_rect x,y,width,height
        Video::Game_screen.fill_rect(x*Video::Image_width,
                                     y*Video::Image_height,
                                     width*Video::Image_width,
                                     height*Video::Image_height,
                                     Video::Black_color)    
    end
    def HUD::write text,x,y,colour
        Font::HUD_font.draw_solid_utf8(Video::Game_screen,
                                      text,
                                      x*Video::Image_width,
                                      y*Video::Image_height,
                                      *colour)
    end
end
