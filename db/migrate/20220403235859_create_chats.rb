class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.references :app, type: :string, null: false, foreign_key: {to_table: :apps, primary_key: :token}
      t.integer :number
      t.integer :messages_count
      t.timestamps
    end
    rename_column :chats, :app_id, :app_token
    add_index :chats, [:app_token, :number], unique: true
    remove_index :chats, :app_token
  end
end
