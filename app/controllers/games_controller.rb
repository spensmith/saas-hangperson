class GamesController < ApplicationController
  require 'hangperson_game'

  def create
     @game = HangpersonGame.new HangpersonGame.get_random_word
     store_game
     redirect_to '/show'
  end
  
  def show
    load_game
    case @game.check_win_or_lose
    when :win
      redirect_to '/win'
    when :lose
      redirect_to '/lose'
    end
  end
  
  def guess
    load_game
    letter = params[:guess].to_s || ' '  
    if @game.guesses.include?(letter) or 
       @game.wrong_guesses.include?(letter)
      flash[:alert] = "You have already used that letter"
    end
   
    @game.guess letter
    store_game
    redirect_to '/show'
  end

  
  def win
    load_game
  end

  def lose
    load_game
  end

  
  
  
  private
    def load_game
      @game = YAML.load(cookies[:game])
    end
    
    def store_game
      cookies[:game] = @game.to_yaml
    end
end
