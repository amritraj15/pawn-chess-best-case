class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  def self.initial_board
    board = Board.new

    8.times do |col|
      board.grid[7][col] = Pawn.new(:white, 7, col)

      board.grid[0][col] = Pawn.new(:black, 0, col)
    end

    board
  end

  def piece_at(row, column)
    return nil unless inside?(row, column)

    grid[row][column]
  end

  def empty?(row, column)
    piece_at(row, column).nil?
  end

  def move_piece(from_row, from_col, to_row, to_col)
    piece = piece_at(from_row, from_col)
    return unless piece

    grid[to_row][to_col] = piece
    grid[from_row][from_col] = nil

    piece.row = to_row
    piece.column = to_col
  end

  def remove_piece(row, column)
    piece = grid[row][column]

    grid[row][column] = nil

    piece
  end

  def pawns(color)
    grid.flatten.compact.select { |pawn| pawn.color.to_sym == color }
  end

  def enemy?(row, column, color)
    piece = piece_at(row, column)

    piece && piece.color.to_sym != color
  end

  def inside?(row, column)
    row.between?(0, 7) && column.between?(0, 7)
  end
end
