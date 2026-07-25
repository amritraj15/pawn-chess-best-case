class GamesController < ApplicationController
  before_action :load_game, only: %i[show move]

  def create
    board = Board.initial_board

    @game = Game.create!(
      status: :in_progress,
      current_turn: :white,
      board_state: BoardSerializer.serialize(board)
    )

    redirect_to game_path(@game)
  end

  def show
    @board = @repository.load_board(@game)
  end

  def move
    board = @repository.load_board(@game)
    pawn = board.piece_at(params[:from_row].to_i, params[:from_col].to_i)

    unless pawn
      redirect_to game_path(@game), alert: "No pawn found."
      return
    end

    unless pawn.color.to_sym == :white
      redirect_to game_path(@game), alert: "You can only move white pawns."
      return
    end

    engine = GameService.new(board, :black)
    result = engine.play_human_move(pawn, params[:to_row].to_i, params[:to_col].to_i)

    if result == :invalid
      redirect_to game_path(@game), alert: "Invalid Move"
      return
    end

    @repository.save_board(@game, board)
    @repository.update_game(@game, result)

    if result != :continue
      redirect_to game_path(@game), notice: notice_for(result)
      return
    end

    # ---------- Computer's turn ----------
    result = engine.play_turn

    @repository.save_board(@game, board)
    @repository.update_game(@game, result)

    redirect_to game_path(@game), notice: notice_for(result)
  end

  private

  def load_game
    @repository = GameRepository.new
    @game = @repository.find(params[:id])
  end

  def notice_for(result)
    case result
    when :white then "White Wins"
    when :black then "Black Wins"
    when :draw  then "Draw"
    else "Move completed"
    end
  end
end
