class GameService
  def initialize(board, current_player)
    @board = board
    @current_player = current_player

    @validator = MoveValidator.new(board)
    @winner = WinnerService.new(board)
    @computer = MoveService.new(board)
  end

  # Validates and applies a move for the human (white) side.
  # Returns :invalid, :white (human just won), :draw, or :continue.
  def play_human_move(pawn, to_row, to_col)
    move = MoveCommand.new(pawn, to_row, to_col)
    return :invalid unless @validator.legal?(move)

    @validator.execute(move)

    winner = @winner.winner
    return winner if winner
    return :draw if @winner.draw?(:black)

    :continue
  end

  def play_turn
    move = @computer.next_move(@current_player)
    return :draw if move.nil?

    @validator.execute(move)

    winner = @winner.winner
    return winner if winner

    switch_turn

    return :draw if @winner.draw?(@current_player)

    :continue
  end

  private

  def switch_turn
    @current_player =
      @current_player == :white ? :black : :white
  end
end
