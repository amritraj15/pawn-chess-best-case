class Pawn
  attr_accessor :color, :row, :column

  def initialize(color, row, column)
    @color = color
    @row = row
    @column = column
  end

  def position
    [ row, column ]
  end
end
