class GameRepository
  def find(id)
    Game.find(id)
  end

  def save_board(game, board)
    game.update!(
      board_state: BoardSerializer.serialize(board)
    )
  end

  def load_board(game)
    BoardSerializer.deserialize(game.board_state)
  end

  def update_game(game, result)
    attrs = {}

    case result
    when :continue
        attrs[:current_turn] = :white
    when :draw
        attrs[:status] = :completed
    when :white, :black
        attrs[:status] = :completed
        attrs[:winner] = result
    end

    game.update!(attrs) unless attrs.empty?
  end
end
