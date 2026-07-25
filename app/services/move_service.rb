class MoveService
  def initialize(board)
    @board = board
    @validator = MoveValidator.new(board)
  end

  def next_move(color)
    legal_moves = generate_legal_moves(color)

    return nil if legal_moves.empty?

    legal_moves.max_by do |move|
      score(move)
    end
  end

  private

  def generate_legal_moves(color)
    moves = []

    @board.pawns(color).each do |pawn|
      moves.concat(@validator.valid_moves(pawn))
    end

    moves
  end

  def score(move)
    score = 0

    score += 1000 if move.winning_move?
    score += 100 if move.capture?
    score += move.advance_distance

    score
  end
end
