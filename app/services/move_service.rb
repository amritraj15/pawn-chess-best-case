class MoveService
  def initialize(board)
    @board = board
    @validator = MoveValidator.new(board)
    @evaluator = Computer::HeuristicEvaluator.new
  end

  def next_move(color)
    legal_moves = generate_legal_moves(color)

    return nil if legal_moves.empty?

    legal_moves.max_by do |move|
      @evaluator.score(move)
    end
  end

  private

  def generate_legal_moves(color)
    @board
      .pawns(color)
      .flat_map do |pawn|
        @validator.valid_moves(pawn)
      end
  end
end