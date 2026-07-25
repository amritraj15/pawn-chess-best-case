class WinnerService
  def initialize(board)
    @board = board

    @validator = MoveValidator.new(board)
  end

  def winner
    return :white if white_wins?
    return :black if black_wins?

    nil
  end

  def draw?(current_player)
    @validator.valid_moves_for_color(current_player).empty?
  end

  private

  def white_wins?
    @board.pawns(:white).any? { |p| p.row.zero? } ||
      @board.pawns(:black).empty?
  end

  def black_wins?
    @board.pawns(:black).any? { |p| p.row == 7 } ||
      @board.pawns(:white).empty?
  end
end
