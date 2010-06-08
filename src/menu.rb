class Menu
    Num_of_opts   = 5
    Single_player = 0
    Two_players   = 1
    High_scores   = 2
    Controls      = 3
    Credits       = 4
    Quit          = 5

    def initialize
        @option = Single_player
    end

    def start
        
    end
    def next; @option = (@option+1) % Num_of_opts; end
    def prev; @option = (@option-1) % Num_of_opts; end

    def enter
        case @option
            when Single_player  then 
                game = Game.new(:single_player)
                game.run
            when Two_players    then 0
            when High_scores    then 0
            when Controls       then 0
            when Credits        then 0
            when Quit           then
                exit
            else @option = Single_player
        end
    end
end
