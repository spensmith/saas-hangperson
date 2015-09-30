class GamesController < ApplicationController
  require 'hangperson_game'

  private
    def load_game
      @game = YAML.load(cookies[:game])
    end
    
    def store_game
      cookies[:game] = @game.to_yaml
    end
end
