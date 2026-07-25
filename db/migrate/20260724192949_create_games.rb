class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.integer :status, default: 0, null: false
      t.integer :current_turn, default: 0, null: false
      t.json :board_state, default: [], null: false

      t.timestamps
    end
  end
end
