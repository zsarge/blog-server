class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.text :content
      t.references :author, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :comments }
      t.string :url, null: false

      t.timestamps
    end
  end
end
