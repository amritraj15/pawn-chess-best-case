class MoveCommand
  attr_reader :pawn,
              :from_row,
              :from_col,
              :to_row,
              :to_col,
              :capture

  def initialize(pawn, to_row, to_col, capture = false)
    @pawn = pawn

    @from_row = pawn.row
    @from_col = pawn.column

    @to_row = to_row
    @to_col = to_col

    @capture = capture
  end

  def capture?
    @capture
  end

  def winning_move?
    if pawn.color.to_sym == :white
      to_row.zero?
    else
      to_row == 7
    end
  end

  def advance_distance
    (to_row - from_row).abs
  end
end
