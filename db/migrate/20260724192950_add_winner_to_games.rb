class AddWinnerToGames < ActiveRecord::Migration[8.1]
  def change
    # GameRepository#update_game already writes `winner` on game completion
    # (see app/repositories/game_repository.rb); the column just never
    # existed, so every finished game raised ActiveModel::UnknownAttributeError.
    add_column :games, :winner, :integer
  end
end
