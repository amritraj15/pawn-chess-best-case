class MoveService
  SEARCH_DEPTH = 2

  def initialize(board)
    @board = board
    @validator = MoveValidator.new(board)
    @evaluator = Computer::HeuristicEvaluator.new(board)
  end

  def next_move(color)
    moves = generate_legal_moves(color)
    return nil if moves.empty?

    moves.max_by do |move|
      evaluate_after_response(move)
    end
  end

  private

  def generate_legal_moves(color)
    @board
      .pawns(color)
      .flat_map { |pawn| @validator.valid_moves(pawn) }
  end

  def evaluate_after_response(move)
    board = @board.deep_clone

    validator = MoveValidator.new(board)

    validator.execute(move.clone_for(board))

    winner = WinnerService.new(board).winner

    return Float::INFINITY if winner == :black
    return -Float::INFINITY if winner == :white

    evaluate_opponent(board)
  end

  def evaluate_opponent(board)
    validator = MoveValidator.new(board)

    evaluator = HeuristicEvaluator.new(board)

    responses =
      board
        .pawns(:white)
        .flat_map { |pawn| validator.valid_moves(pawn) }

    return evaluator.board_score(:black) if responses.empty?

    responses.map do |move|
      clone = board.deep_clone

      MoveValidator
        .new(clone)
        .execute(move.clone_for(clone))

      HeuristicEvaluator
        .new(clone)
        .board_score(:black)
    end.min
  end
end
