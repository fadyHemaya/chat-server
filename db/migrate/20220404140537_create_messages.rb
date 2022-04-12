class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.integer :number
      t.text :body

      t.timestamps
    end
    add_index :messages, [:chat_id, :number], unique: true
    remove_index :messages, :chat_id if index_exists?(:messages, :chat_id)
  end
end