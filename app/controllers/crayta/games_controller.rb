class Crayta::GamesController < ApplicationController
  before_action :set_game, only: [:show]

  def index
    @games = CraytaGame.all
  end

  def show
  end

  def search
  end

  private
  def set_game
    @game = CraytaGame.find(params[:id])
  end
end