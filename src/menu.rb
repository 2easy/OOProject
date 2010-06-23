require 'sdl'

class Menu
  Num_of_opts   = 6
  Single_player = 0
  Two_players   = 1
  High_scores   = 2
  Controls      = 3
  Credits       = 4
  Quit          = 5
  Options = [Single_player,Two_players,High_scores,Controls,Credits,Quit]
  def initialize
    @event  = SDL::Event.new
    @key    = Key.new
    @option = Single_player
    @last_option = Single_player
    @single_player_pic = Video::load_bmp("../images/single_player.bmp" )
    @two_player_pic    = Video::load_bmp("../images/two_players.bmp" )
    @high_scores_pic   = Video::load_bmp("../images/high_scores.bmp" )
    @controls_pic      = Video::load_bmp("../images/controls.bmp" )
    @credits_pic       = Video::load_bmp("../images/credits.bmp" )
    @quit_pic          = Video::load_bmp("../images/quit.bmp" )
    @quiting_pic       = Video::load_bmp("../images/quiting.bmp" )
    @back_pic          = Video::load_bmp("../images/back.bmp" )
    @controls_t_pic    = Video::load_bmp("../images/controls_content.bmp" )
    @credits_t_pic     = Video::load_bmp("../images/credits_content.bmp" )
    @option_pics       = [@single_player_pic, @two_player_pic,
                          @high_scores_pic, @controls_pic,
                          @credits_pic, @quit_pic]
  end

  def start
    stop = false
    while true
      self.draw_entry_menu
      if @event.poll != 0 then
        if @event.type == SDL::Event::QUIT then
          exit
        end
        if @event.type == SDL::Event::KEYDOWN then
          @option = Quit if @event.keySym == SDL::Key::ESCAPE
        end
        if @event.type == SDL::Event::KEYUP then
          stop = false
        end
      end
      SDL::Key::scan
      @key.up    = SDL::Key::press?(SDL::Key::UP   )
      @key.down  = SDL::Key::press?(SDL::Key::DOWN )
      @key.space = SDL::Key::press?(SDL::Key::SPACE)
      @key.enter = SDL::Key::press?(SDL::Key::RETURN)
  
      if stop then next
      else
        if    @key.up    then stop = true; self.prev
        elsif @key.down  then stop = true; self.next
        elsif @key.space then stop = false; self.enter
        elsif @key.enter then stop = false; self.enter
        end
      end
    end
  end
     
  def next; @option = (@option+1) % Num_of_opts; end
  def prev; @option = (@option-1) % Num_of_opts; end

  def enter
    case @option
      when Single_player  then 
        game = Game.new(:single_player)
        game.run
      when Two_players then
        #here run two players
      when High_scores then
        #here show hiscores
        self.draw_high_scores
        self.wait
      when Controls    then
        #here show controls
        self.draw_controls
        self.wait
      when Credits     then
        #here show credits
        self.draw_credits
        self.wait
      when Quit        then
        self.draw_quiting
        SDL.quit
        exit
    end
  end
  def wait
    sleep 0.5
    event = SDL::Event.new
    key = Key.new
    begin
      begin
        event.poll
        pressed = event.key_press?
      rescue
        next
      end
    end while not(pressed)
    sleep 0.5
  end

  def draw_entry_menu
    Video::Game_screen.fill_rect(0,0,875,775,Video::Black_color)  
    dest_y = 300 
    @option_pics.each_with_index do |option,i| 
      if i == @option then pict_y = 50
      else pict_y = 0 end
      SDL::Screen.blit(
        option,
        0, pict_y,
        Video::Option_width, Video::Option_height,
        Video::Game_screen,335,dest_y)
      dest_y += 50
    end
    Video::Game_screen.flip
  end
  def draw_high_scores
    Video::Game_screen.fill_rect(0,0,875,750,Video::Black_color)  
    SDL::Screen.blit(
      @high_scores_pic,
      0,50,
      Video::Option_width, Video::Option_height,
      Video::Game_screen,335,150)
    Video::Game_screen.flip
  end
  def draw_controls
    Video::Game_screen.fill_rect(0,0,875,750,Video::Black_color)  
    SDL::Screen.blit(
      @controls_t_pic,
      0, 0,
      425, 375,
      Video::Game_screen,225,175)
    Video::Game_screen.flip
  end
  def draw_credits
    Video::Game_screen.fill_rect(0,0,875,750,Video::Black_color)  
    SDL::Screen.blit(
      @credits_t_pic,
      0, 0,
      375, 350,
      Video::Game_screen,250,200)
    Video::Game_screen.flip
  end
  def draw_quiting
    Video::Game_screen.fill_rect(0,0,875,750,Video::Black_color)  
    SDL::Screen.blit(
      @quiting_pic, 0, 0,
      Video::Option_width, Video::Option_height,
      Video::Game_screen,335,350)
    Video::Game_screen.flip
  end
end
