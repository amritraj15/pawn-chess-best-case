class MoveValidator
  BOARD_SIZE = 8

  def initialize(board)
    @board = board
  end

  def execute(move)
    raise "Illegal Move" unless legal?(move)

    if @board.enemy?(
        move.to_row,
        move.to_col,
        move.pawn.color.to_sym
      )

      @board.remove_piece(
        move.to_row,
        move.to_col
      )
    end

    @board.move_piece(
      move.from_row,
      move.from_col,
      move.to_row,
      move.to_col
    )
  end

def legal?(move)
  return false unless inside?(move.to_row, move.to_col)

  return false unless @board.piece_at(
    move.from_row,
    move.from_col
  ) == move.pawn

  valid_direction?(move) &&
    valid_destination?(move)
end

  def valid_moves_for_color(color)
    @board
      .pawns(color)
      .flat_map { |pawn| valid_moves(pawn) }
  end


def inside?(row, col)
  row.between?(0, BOARD_SIZE - 1) &&
    col.between?(0, BOARD_SIZE - 1)
end

  def valid_direction?(move)
    expected =
      move.pawn.color.to_sym == :white ? -1 : 1

    (move.to_row - move.from_row) == expected
  end

  def valid_destination?(move)
    row_diff = (move.to_row - move.from_row).abs
    col_diff = (move.to_col - move.from_col).abs

    return false unless row_diff == 1

    if col_diff.zero?
      @board.empty?(move.to_row, move.to_col)
    elsif col_diff == 1
      @board.enemy?(
        move.to_row,
        move.to_col,
        move.pawn.color.to_sym
      )
    else
      false
    end
  end

  def valid_moves(pawn)
  moves = []

  direction = pawn.color.to_sym == :white ? -1 : 1

  forward_row = pawn.row + direction

  # Forward move
  if inside?(forward_row, pawn.column) &&
     @board.empty?(forward_row, pawn.column)

    moves << MoveCommand.new(
      pawn,
      forward_row,
      pawn.column
    )
  end

  # Diagonal captures
  [ -1, 1 ].each do |offset|
    col = pawn.column + offset

    next unless inside?(forward_row, col)

    if @board.enemy?(forward_row, col, pawn.color.to_sym)
      moves << MoveCommand.new(
        pawn,
        forward_row,
        col,
        true
      )
    end
  end

  moves
end
end
