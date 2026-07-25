class BoardSerializer
  def self.serialize(board)
    board.grid.map do |row|
      row.map do |pawn|
        next unless pawn

        {
          color: pawn.color,
          row: pawn.row,
          column: pawn.column
        }
      end
    end
  end

  def self.deserialize(state)
    board = Board.new

    state.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        next unless cell

        board.grid[r][c] =
          Pawn.new(
            (cell["color"] || cell[:color]).to_sym,
            cell["row"] || cell[:row],
            cell["column"] || cell[:column]
          )
      end
    end

    board
  end
end
