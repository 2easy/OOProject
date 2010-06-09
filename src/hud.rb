module HUD
    def HUD::draw
        Video::Game_screen.fill_rect(30*Video::Image_width,
                                     1*Video::Image_height,
                                     4*Video::Image_width,
                                     6*Video::Image_height,
                                     Video::Black_color)    
        Font::HUD_font.draw_solid_utf8(Video::Game_screen,
                                       "Score:",
                                       30*Video::Image_width,
                                       1*Video::Image_height,
                                       *Video::White_color)
        Font::HUD_font.draw_solid_utf8(Video::Game_screen,
                                       "#{$SCORE}",
                                       30*Video::Image_width,
                                       2*Video::Image_height,
                                       *Video::White_color)
        Font::HUD_font.draw_solid_utf8(Video::Game_screen,
                                      "Lifes:",
                                      30*Video::Image_width,
                                      3*Video::Image_height,
                                      *Video::White_color)
        Font::HUD_font.draw_solid_utf8(Video::Game_screen,
                                      "Level:",
                                      30*Video::Image_width,
                                      5*Video::Image_height,
                                      *Video::White_color)
        Font::HUD_font.draw_solid_utf8(Video::Game_screen,
                                      "#{$LEVEL}",
                                      30*Video::Image_width,
                                      6*Video::Image_height,
                                      *Video::White_color)
        Video::Game_screen.flip
    end
    def update pacman,score,level
        SDL::Screen.blit(@my_pic[@direction],
                    pict_x*Video::Image_width, 0,
                    Video::Image_width,Video::Image_height,
                    Video::Game_screen,@sprite_coords[:x],@sprite_coords[:y])
    end
end
